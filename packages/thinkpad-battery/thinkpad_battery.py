#!/usr/bin/env python3
"""Minimales Batterie-Diagnose- und Steuer-Tool für ThinkPads.

Liest Akkudaten read-only aus /sys/class/power_supply/BAT*; alle
privilegierten Aktionen (Ladeschwellen, Vollladen, Kalibrierung) laufen
über pkexec + tlp.
"""

import os
import subprocess
import sys
from pathlib import Path

from PySide6.QtCore import QTimer
from PySide6.QtWidgets import (
    QApplication,
    QDialog,
    QDialogButtonBox,
    QGroupBox,
    QHBoxLayout,
    QLabel,
    QPushButton,
    QRadioButton,
    QSpinBox,
    QVBoxLayout,
    QWidget,
)

POWER_SUPPLY = Path("/sys/class/power_supply")
TLP = os.environ.get("TLP_BIN", "tlp")
SYSTEMD_RUN = os.environ.get("SYSTEMD_RUN_BIN", "systemd-run")
SYSTEMCTL = os.environ.get("SYSTEMCTL_BIN", "systemctl")
SH = os.environ.get("SH_BIN", "sh")
PKEXEC = "/run/wrappers/bin/pkexec"


def find_batteries():
    return sorted(p.name for p in POWER_SUPPLY.glob("BAT*"))


def read_attr(bat, name):
    try:
        return (POWER_SUPPLY / bat / name).read_text().strip()
    except OSError:
        return None


def read_int(bat, name):
    value = read_attr(bat, name)
    try:
        return int(value)
    except (TypeError, ValueError):
        return None


def active_charge_behaviour(bat):
    raw = read_attr(bat, "charge_behaviour")
    if not raw:
        return None
    for token in raw.split():
        if token.startswith("[") and token.endswith("]"):
            return token[1:-1]
    return raw


def health_percent(bat):
    full = read_int(bat, "energy_full")
    design = read_int(bat, "energy_full_design")
    if not full or not design:
        return None
    return full / design * 100


def fmt_de(value):
    return f"{value:.1f}".replace(".", ",")


def recalibrate_unit(bat):
    return f"tlp-recalibrate-{bat}.service"


def unit_active(bat):
    try:
        result = subprocess.run(
            [SYSTEMCTL, "is-active", "--quiet", recalibrate_unit(bat)],
            capture_output=True, timeout=10,
        )
    except (OSError, subprocess.TimeoutExpired):
        return False
    return result.returncode == 0


def run_privileged(args, timeout=30):
    try:
        result = subprocess.run(
            [PKEXEC, *args], capture_output=True, text=True, timeout=timeout,
        )
    except subprocess.TimeoutExpired:
        return False, "Zeitüberschreitung."
    except OSError as exc:
        return False, str(exc)
    if result.returncode in (126, 127):
        return False, "Abgebrochen."
    if result.returncode != 0:
        lines = (result.stderr or "").strip().splitlines()
        return False, lines[-1] if lines else f"Fehler (Exit {result.returncode})."
    return True, ""


class BatteryGroup(QGroupBox):
    def __init__(self, bat):
        model = read_attr(bat, "model_name") or "—"
        super().__init__(f"{bat} — {model}")
        self.bat = bat
        self.sysfs_start = None
        self.sysfs_stop = None
        self.behaviour = None

        manufacturer = read_attr(bat, "manufacturer")
        if manufacturer:
            self.setToolTip(f"Hersteller: {manufacturer}")

        self.info_label = QLabel("—")
        self.start_spin = QSpinBox()
        self.stop_spin = QSpinBox()
        for spin in (self.start_spin, self.stop_spin):
            spin.setRange(0, 100)
            spin.setSuffix(" %")

        thresholds = QHBoxLayout()
        thresholds.addWidget(QLabel("Ladeschwelle Start"))
        thresholds.addWidget(self.start_spin)
        thresholds.addWidget(QLabel("Stop"))
        thresholds.addWidget(self.stop_spin)
        thresholds.addStretch()

        layout = QVBoxLayout(self)
        layout.addWidget(self.info_label)
        layout.addLayout(thresholds)

        self.refresh()

    def refresh(self):
        capacity = read_int(self.bat, "capacity")
        health = health_percent(self.bat)
        cycles = read_int(self.bat, "cycle_count")
        status = read_attr(self.bat, "status")
        self.behaviour = active_charge_behaviour(self.bat)

        parts = [
            f"Ladung {capacity} %" if capacity is not None else "Ladung —",
            f"Gesundheit {fmt_de(health)} %" if health is not None else "Gesundheit —",
            f"{cycles} Zyklen" if cycles is not None else "— Zyklen",
            status or "—",
        ]
        self.info_label.setText("  ·  ".join(parts))

        self._sync_spin(self.start_spin, "sysfs_start",
                        read_int(self.bat, "charge_control_start_threshold"))
        self._sync_spin(self.stop_spin, "sysfs_stop",
                        read_int(self.bat, "charge_control_end_threshold"))

    def _sync_spin(self, spin, attr, new_value):
        last = getattr(self, attr)
        if new_value is not None and (last is None or spin.value() == last):
            spin.setValue(new_value)
        setattr(self, attr, new_value)


class CalibrateDialog(QDialog):
    def __init__(self, batteries, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Akku kalibrieren")

        warning = QLabel(
            "Der gewählte Akku wird am Netzteil vollständig zwangsentladen "
            "und anschließend auf 100 % geladen. Das dauert mehrere Stunden; "
            "das Gerät muss währenddessen am Netz bleiben."
        )
        warning.setWordWrap(True)

        self.radios = []
        layout = QVBoxLayout(self)
        layout.addWidget(warning)
        for i, bat in enumerate(batteries):
            radio = QRadioButton(bat)
            radio.setChecked(i == 0)
            self.radios.append(radio)
            layout.addWidget(radio)

        buttons = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok
            | QDialogButtonBox.StandardButton.Cancel
        )
        buttons.accepted.connect(self.accept)
        buttons.rejected.connect(self.reject)
        layout.addWidget(buttons)

    def selected(self):
        for radio in self.radios:
            if radio.isChecked():
                return radio.text()
        return None


class MainWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("ThinkPad Akku")
        self.message = ""
        self.running = []

        self.groups = [BatteryGroup(bat) for bat in find_batteries()]

        self.status_label = QLabel("")
        self.status_label.setWordWrap(True)

        self.apply_btn = QPushButton("Übernehmen")
        self.fullcharge_btn = QPushButton("Voll laden")
        self.calibrate_btn = QPushButton("Kalibrieren")
        self.reset_btn = QPushButton("Laden zurücksetzen")
        self.reset_btn.hide()

        self.apply_btn.clicked.connect(self.apply_thresholds)
        self.fullcharge_btn.clicked.connect(self.fullcharge)
        self.calibrate_btn.clicked.connect(self.calibrate_clicked)
        self.reset_btn.clicked.connect(self.reset_charging)

        buttons = QHBoxLayout()
        buttons.addWidget(self.apply_btn)
        buttons.addWidget(self.fullcharge_btn)
        buttons.addWidget(self.calibrate_btn)
        buttons.addWidget(self.reset_btn)
        buttons.addStretch()

        layout = QVBoxLayout(self)
        for group in self.groups:
            layout.addWidget(group)
        if not self.groups:
            layout.addWidget(QLabel("Keine Akkus unter /sys/class/power_supply gefunden."))
        layout.addWidget(self.status_label)
        layout.addLayout(buttons)

        if not self.groups:
            for btn in (self.apply_btn, self.fullcharge_btn, self.calibrate_btn):
                btn.setEnabled(False)

        self.timer = QTimer(self)
        self.timer.timeout.connect(self.refresh)
        self.timer.start(5000)
        self.refresh()

    def refresh(self):
        for group in self.groups:
            group.refresh()
        self.running = [g.bat for g in self.groups if unit_active(g.bat)]

        calibrating = bool(self.running)
        self.apply_btn.setEnabled(bool(self.groups) and not calibrating)
        self.fullcharge_btn.setEnabled(bool(self.groups) and not calibrating)
        self.calibrate_btn.setText(
            "Kalibrierung abbrechen" if calibrating else "Kalibrieren"
        )

        stuck = [
            (g.bat, g.behaviour)
            for g in self.groups
            if g.behaviour not in (None, "auto") and g.bat not in self.running
        ]
        self.reset_btn.setVisible(bool(stuck))

        parts = []
        if self.message:
            parts.append(self.message)
        for bat in self.running:
            parts.append(f"Kalibrierung von {bat} läuft …")
        for bat, behaviour in stuck:
            parts.append(
                f"Warnung: {bat} steht auf „{behaviour}“ statt „auto“ — "
                f"mit „Laden zurücksetzen“ beheben."
            )
        self.status_label.setText("\n".join(parts) if parts else "Bereit.")

    def apply_thresholds(self):
        results = []
        for g in self.groups:
            start, stop = g.start_spin.value(), g.stop_spin.value()
            if start == g.sysfs_start and stop == g.sysfs_stop:
                continue
            ok, err = run_privileged([TLP, "setcharge", str(start), str(stop), g.bat])
            results.append(f"{g.bat}: Schwellen gesetzt." if ok else f"{g.bat}: {err}")
        self.message = "  ".join(results) if results else "Keine Änderungen."
        self.refresh()

    def fullcharge(self):
        results = []
        for g in self.groups:
            ok, err = run_privileged([TLP, "fullcharge", g.bat])
            results.append(f"{g.bat}: wird voll geladen." if ok else f"{g.bat}: {err}")
        results.append(
            "Hinweis: Schwellen sind nur temporär angehoben — beim nächsten "
            "Boot oder per „Übernehmen“ gelten wieder die gesetzten Werte."
        )
        self.message = "  ".join(results)
        self.refresh()

    def calibrate_clicked(self):
        if self.running:
            results = []
            for bat in self.running:
                ok, err = run_privileged([SYSTEMCTL, "stop", recalibrate_unit(bat)])
                results.append(
                    f"Kalibrierung von {bat} abgebrochen." if ok else f"{bat}: {err}"
                )
            self.message = "  ".join(results)
            self.refresh()
            return

        dialog = CalibrateDialog([g.bat for g in self.groups], self)
        if dialog.exec() != QDialog.DialogCode.Accepted:
            return
        bat = dialog.selected()
        if bat is None:
            return
        ok, err = run_privileged([
            SYSTEMD_RUN, "--collect", f"--unit={recalibrate_unit(bat).removesuffix('.service')}",
            TLP, "recalibrate", bat,
        ])
        self.message = f"Kalibrierung von {bat} gestartet." if ok else f"{bat}: {err}"
        self.refresh()

    def reset_charging(self):
        results = []
        for g in self.groups:
            start = g.sysfs_start if g.sysfs_start is not None else g.start_spin.value()
            stop = g.sysfs_stop if g.sysfs_stop is not None else g.stop_spin.value()
            ok, err = run_privileged([TLP, "setcharge", str(start), str(stop), g.bat])
            if not ok:
                results.append(f"{g.bat}: {err}")
                continue
            ok, err = run_privileged([
                SH, "-c",
                f"echo auto > /sys/class/power_supply/{g.bat}/charge_behaviour",
            ])
            results.append(f"{g.bat}: Laden zurückgesetzt." if ok else f"{g.bat}: {err}")
        self.message = "  ".join(results)
        self.refresh()


def main():
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
