# thinkpad-battery 1.0 — Batterie-Diagnose- und Steuer-GUI für ThinkPads (eigenes Skript).
#
# Einzelnes PySide6-Skript, kein Build — nur installieren und wrappen. Akkudaten
# kommen read-only aus /sys/class/power_supply; privilegierte Aktionen
# (Ladeschwellen, Vollladen, Kalibrierung) laufen über pkexec + tlp.
#
# Qt-Wrapping nach dem nixpkgs-Muster für Nicht-C++-Qt-Anwendungen: wrapQtAppsHook
# mit dontWrapQtApps=true, die qtWrapperArgs werden im eigenen makeWrapper-Aufruf
# gesetzt — sonst findet PySide6 unter Wayland kein Plattform-Plugin.
#
# TLP_BIN & Co. als absolute Store-Pfade: pkexec setzt die Umgebung zurück, ein
# PATH-Lookup im Skript wäre daher unzuverlässig.
{ lib
, stdenvNoCC
, python3
, qt6
, makeWrapper
, makeDesktopItem
, copyDesktopItems
, tlp
, systemd
, bash
}:

let
  pythonEnv = python3.withPackages (ps: [ ps.pyside6 ]);

  desktopItem = makeDesktopItem {
    name = "thinkpad-battery";
    desktopName = "ThinkPad Akku";
    comment = "Akkustatus, Ladeschwellen und Kalibrierung";
    exec = "thinkpad-battery";
    icon = "battery"; # liefert Breeze
    categories = [ "System" "Settings" "HardwareSettings" ];
    terminal = false;
  };
in
stdenvNoCC.mkDerivation {
  pname = "thinkpad-battery";
  version = "1.0";

  src = ./.;

  nativeBuildInputs = [ qt6.wrapQtAppsHook makeWrapper copyDesktopItems ];

  # qtbase liefert dem Hook qtPluginPrefix & Co. — ohne bricht wrapQtAppsHook ab.
  buildInputs = [ qt6.qtbase ];

  # Wrapping selbst erledigen — der Hook liefert nur die qtWrapperArgs.
  dontWrapQtApps = true;

  desktopItems = [ desktopItem ];

  installPhase = ''
    runHook preInstall

    install -Dm444 thinkpad_battery.py \
      $out/share/thinkpad-battery/thinkpad_battery.py

    makeWrapper ${pythonEnv}/bin/python3 $out/bin/thinkpad-battery \
      --add-flags "$out/share/thinkpad-battery/thinkpad_battery.py" \
      --set TLP_BIN ${lib.getExe' tlp "tlp"} \
      --set SYSTEMD_RUN_BIN ${lib.getExe' systemd "systemd-run"} \
      --set SYSTEMCTL_BIN ${lib.getExe' systemd "systemctl"} \
      --set SH_BIN ${lib.getExe' bash "sh"} \
      "''${qtWrapperArgs[@]}"

    runHook postInstall
  '';

  meta = {
    description = "Batterie-Diagnose- und Steuer-GUI für ThinkPads (Ladeschwellen, Vollladen, Kalibrierung via tlp)";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "thinkpad-battery";
  };
}
