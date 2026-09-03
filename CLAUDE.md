# NixOS-Konfiguration

Multi-Host NixOS-Flake unter `/home/muhackel/nixosconfig`.

## Projekttyp

Projekt — Git MEIST OHNE Branches.
Branches können für temporäre Experimente oder größere Refactorings genutzt werden. 
User wird Branches fordern wenn sie gewünscht sind.
Branches müssen erhalten bleiben wenn sie gemerged wurden "--no-ff" 

## Hosts

| Host | Rolle | Hardware | GPU | Besonderheiten |
|------|-------|----------|-----|----------------|
| **SPIELKISTE** | Hauptrechner / Gaming-PC | Framework Desktop | AMD (RDNA) | Lanzaboote Secure Boot |
| **HAL9000** | Notebook | Lenovo ThinkPad 25 | Nvidia (Optimus) | CPU-Undervolting, NFC-Reader, Autorandr/EDID |
| **BFG9000** | Arbeitslaptop | Lenovo X1 Extreme G3 | Nvidia (Optimus, open) | 4K-Skalierung, Ferdium GPU-Workaround, kein Hamradio, lokale KMT-VPN-VM |
| **datengrab** | Heimserver (WIP) | — | — | ZFS, Plex/Jellyfin/*arr, noch nicht in flake.nix |

## Architektur

- **`flake.nix`** — Einstiegspunkt, definiert `nixosConfigurations` und `checks`
- **`lib/default.nix`** — `mkHost`-Helper: baut Hosts aus `hostModule` + `features` + `commonModules`
- **`configuration.nix`** — Gemeinsame Basis (Overlays, Nix-Settings, GC, SSH, etc.)
- **`modules/options.nix`** — Feature-Flags via `lib.mkEnableOption` unter `local.features`
- **`modules/host/<NAME>/`** — Host-spezifische Module (Hardware-Imports, hostName, hostId)
- **`modules/hardware/`** — Hardware-spezifische Konfiguration
- **`modules/software/`** — Feature-Module, reagieren auf `local.features.*`
- **`modules/user/muhackel/`** — User-Konfiguration + Home Manager (`home.nix`)
- **`overlays/`** — Paket-Overlays
- **`packages/`** — Eigene Paket-Definitionen

### Feature-Flag-System

Hosts werden über `commonFeatures` in `flake.nix` konfiguriert. Einzelne Hosts können Features überschreiben (z.B. `commonFeatures // { hamradio = false; }`). Module unter `modules/software/` prüfen `config.local.features.<flag>`.

### Gruppen-Sammlung

Benutzergruppen werden über `local.userExtraGroups` von Feature-Modulen gesammelt und zentral am User gesetzt — nicht direkt in den Modulen.

## Designentscheidungen

### hostId — bewusst identisch (`DEADBEEF`)

Alle Desktop-Hosts teilen dieselbe `hostId`. ZFS nutzt die `hostId` als Import-Guard — USB-ZFS-Datenträger werden bewusst zwischen Rechnern gewechselt. Gemeinsame `hostId` ermöglicht automatischen Import ohne Force-Flag.

### Initial-Passwörter

Sind im Flake gespeichert — bewusst akzeptiert, da kein System ein Passwort länger als einen Reboot behält.

### stateVersion

Zentral gepinnt auf `26.11` — let-Variable `stateVersion` in `lib/default.nix`, gesetzt
an `system.stateVersion`. `home.stateVersion` folgt automatisch via
`osConfig.system.stateVersion` (nicht mehr hart in `home.nix`). Der mkHost-Parameter
`hostStateVersion ? "26.05"` bleibt als Override-Fallback (letzte stable) erhalten, wird
aktuell aber von keinem Host genutzt.

Der Wechsel 26.05 → 26.11 ist verifiziert folgenlos (drvPath-Vergleich): SPIELKISTE/HAL9000
bit-identisch, BFG9000 verliert nur den ZFS-`forceImportRoot` (Default `true` → `false`) —
irrelevant, sobald die endgültige `hostId` im Pool-Label steht (Import-Guard greift nur bei
hostid-Mismatch auf einem unclean Pool, also praktisch nur direkt nach der Erstinstallation).

Nicht ohne guten Grund ändern.

### Lokale KMT-VPN-VM auf BFG9000

Das Feature `kmtVpnVm` erzeugt das persistente TAP `kmt-bue` für die vorhandene
libvirt-Session-VM `R2001-neu`. NetworkManager ignoriert das TAP; systemd-networkd
verwaltet ausschließlich dieses Interface. Es setzt bei Carrier die statische Adresse
`90.101.0.158/24` sowie Routen für `90.0.0.0/8` und `224.0.0.0/4`. Ohne laufende VM
entfernt networkd Adresse und Routen. Die VM startet weiterhin manuell.

### Rollenspiel-Software als eigene Pakete (statt /opt-Wrapper)

`genesis`, `commlink6` und `helden-software` liegen unter `packages/` und hängen am
Feature-Flag `games` (Liste `wantedGames` in `modules/software/applications/games.nix`).
Eigene Feature-Flags gibt es nicht mehr — die früheren `local.features.genesis` /
`.comlink6` samt ihrer Wrapper-Module sind entfallen.

Alle drei ziehen das offizielle Hersteller-`.deb` und entpacken es mit `dpkg-deb -x`;
die Debs bringen neben der Anwendung auch die Icons für den Menüeintrag mit.

| Paket | Aufbau | Start |
|-------|--------|-------|
| `helden-software` | reines Swing-JAR, kein JavaFX, keine nativen Libs | `jre` direkt, Argumente wie der Hersteller-Launcher (`-hsDebianMode`) |
| `genesis` | jpackage-Bundle mit eigener Java-17-Runtime + JavaFX | `steam-run` + `LD_LIBRARY_PATH` (GTK3/X11) |
| `commlink6` | jpackage-Bundle, nur der **Updater** | `steam-run` + `LD_LIBRARY_PATH` (GTK3/X11) |

Warum bei den jpackage-Bundles weiterhin `steam-run` statt `autoPatchelfHook`: JavaFX
entpackt seine nativen Libs erst zur Laufzeit aus den `javafx-*-linux.jar`, autoPatchelf
erreicht sie also gar nicht. Deshalb `dontPatchELF` + `dontStrip` — die RPATHs des
Bundles dürfen nicht angefasst werden. Der Launcher leitet sein `$ROOTDIR` aus dem
eigenen Pfad ab, das Bundle läuft daher unverändert aus dem Store.

Bei Commlink6 wird nur der Bootstrap deklarativ: der Updater lädt die eigentliche
Anwendung zur Laufzeit nach `~/CommLink6` und hält sie dort aktuell. Upstream liefert
nichts anderes aus. Der Launcher heißt mit Leerzeichen `Commlink6 Updater` und muss so
heißen — jpackage sucht die zugehörige `.cfg` über den eigenen Programmnamen.

**Platzbedarf:** genesis ~152 MB, commlink6 ~173 MB pro Generation. Bei
`--delete-older-than 21d` entsprechend einplanen.

**`curlOptsList = [ "--insecure" ]` in `packages/genesis` und `packages/comlink6`
entfernen, sobald das Zertifikat von `www.rpgframework.de` erneuert ist** (abgelaufen
am 2026-08-20, einziger Downloadserver, kein Alternativhost). Die Integrität sichert
der Hash der Fixed-Output-Derivation; der Workaround betrifft nur die
Transport-Validierung.

### ThinkPad-Akkuwerkzeug (`thinkpadBattery`)

Feature-Flag für HAL9000 und BFG9000 (nicht in `commonFeatures` — SPIELKISTE hat keinen
Akku). Installiert `pkgs.tlp` plus das eigene GUI `packages/thinkpad-battery`.

**`services.tlp.enable` bleibt bewusst aus.** power-profiles-daemon behält die
Power-Verwaltung (beide schließen sich in NixOS gegenseitig aus); tlp wird nur als
Werkzeug für die Batteriepflege-Kommandos installiert:

| Kommando | Wirkung |
|----------|---------|
| `tlp setcharge <start> <stop> [BAT]` | Ladeschwellen temporär setzen |
| `tlp fullcharge [BAT]` | einmalig auf 100 % laden (hebt die Schwellen temporär an) |
| `tlp discharge [BAT] [ziel%]` | erzwungene Entladung am Netzteil |
| `tlp recalibrate [BAT]` | vollständig entladen, dann auf 100 % laden |

Backend ist `natacpi` — seit Kernel 5.17 exportiert `thinkpad_acpi` pro Akku
`charge_control_{start,end}_threshold` und `charge_behaviour` (`auto`,
`inhibit-charge`, `force-discharge`). Weder `tp_smapi` noch `acpi_call` nötig; das galt
für ThinkPads vor Sandy Bridge. Verifiziert auf HAL9000 mit `tlp-stat -b`.

**`/etc/tlp.conf` ist Pflicht, obwohl kein Dienst läuft.** Fehlt die Datei, meldet
`read_config` (in `share/tlp/tlp-func-base`) rc=5 und überspringt das `. "$_conf_tmp"` —
die zusammengeführte Runtime-Config wird dann gar nicht gesourct und die Vendor-Presets
fehlen, auf denen `fullcharge` und `recalibrate` beruhen.

**Und darin muss `TLP_ENABLE=1` stehen.** `check_tlp_enabled` (ebenfalls
`tlp-func-base`) bricht sonst *jedes* Kommando mit *"TLP power save is disabled"* ab —
die Variable steuert nicht nur den Dienststart, sondern gibt die Kommandos überhaupt
erst frei. Scharf geschaltet wird dadurch nichts: ohne `services.tlp.enable` existieren
weder `tlp.service`/`tlp-sleep.service` noch die udev-Regeln aus `lib/udev/rules.d`, die
`tlp start` auslösen würden — verifiziert mit `systemctl list-unit-files | grep tlp`
(leer) auf HAL9000.

**Konflikt mit Plasma beachten:** PowerDevil verwaltet die Ladeschwellen ebenfalls
(Systemeinstellungen → Energieverwaltung, via `org.kde.powerdevil.chargethresholdhelper`)
und setzt sie bei Profilwechseln neu. Über das GUI oder `tlp setcharge` gesetzte Werte
können dadurch wieder überschrieben werden. Vollladen und Kalibrieren kann Plasma nicht —
dafür existiert das Werkzeug.

Das GUI (PySide6, passt zu Plasma) findet die Akkus dynamisch über
`/sys/class/power_supply/BAT*` — HAL9000 hat zwei (intern + Wechselakku), BFG9000 einen.
Lesen läuft ohne Rechte, alle Eingriffe über `pkexec` (`/run/wrappers/bin/pkexec`, der
setuid-Wrapper) und den KDE-Polkit-Agenten.

**Platzbedarf:** PySide6 zieht den Bindings-Stack (shiboken6, qtcharts, qt3d, …) nach —
rund 1 GB, aber nur einmal im Store. Alle Generationen teilen sich dieselben Pfade; ein
zweites Mal belegt wird er erst, wenn ein nixpkgs-Bump den Qt-/PySide6-Stack ändert und
daneben noch Generationen mit dem alten Stand gehalten werden.

Die Kalibrierung läuft als transiente Unit `tlp-recalibrate-<BAT>.service`
(`systemd-run --collect`), überlebt also das Schließen des Fensters; das GUI zeigt sie als
laufend an und bietet Abbruch. Weil ein harter Abbruch `charge_behaviour` auf
`force-discharge` stehen lassen kann, blendet das GUI in dem Fall
„Laden zurücksetzen“ ein — das setzt die Schwellen neu und schreibt `auto` zurück.

### Overlays

Aktive Overlays werden in `configuration.nix` (`usedOverlays`) mit Inline-Kommentar zum
Zweck importiert:

| Overlay | Zweck |
|---------|-------|
| `ts3-legacy` | Bewusster TS3-Pin aus nixos-25.11 mit EOL-Qt5-WebEngine |
| `proxmark3` | Gewünschte HF_COLIN-Firmware mit BlueShark/BTADDON für das „Knopf“-Script |

Entfallen:

- `lact-libdisplay-info` (2026-08-02): nixpkgs bietet `libdisplay-info_0_3` selbst an.
- `bubblewrap-setuid` (2026-09-03): nixpkgs erzeugt den Steam-`bwrap`-Wrapper nicht mehr.
- `spamassassin-ssl-test` (2026-09-03): nixpkgs überspringt `spamd_ssl.t` selbst.
- `patool-skip-tests` (2026-09-03): der nixpkgs-Landlock-Fix lässt alle 82 Tests bestehen.
- `libnfc-nci-ldflags` (2026-09-03): der gelockte Maintainer-Fork baut ohne Zusatzflags.
- `osm-gps-map` (2026-09-03): nixpkgs enthält den vollständigen Autotools-Aufbau.
- `openldap-flaky-test` (2026-09-04): der globale Overlay verhinderte Binärcache-Treffer für OpenLDAP und Reverse-Abhängigkeiten wie LibreOffice, GnuPG, SpamAssassin und Evolution.

**Neue Overlay-Verzeichnisse `git add`en** — sonst sieht Nix sie im Flake nicht
(*"Path … is not tracked by Git"*).

### TeamSpeak-3-Legacy-Pin (`overlays/ts3-legacy/`)

TeamSpeak 3.6.2 stammt aus dem gepinnten nixos-25.11-Commit
`25f538306313eae3927264466c70d7001dcea1df`. nixpkgs entfernte `teamspeak3` am
2026-04-26 bewusst aus unstable, weil der Client von der nicht mehr regulär gewarteten
Qt5-WebEngine abhängt. Der isolierte Paketbaum erlaubt ausschließlich `teamspeak3` als
unfreies Paket und `qtwebengine-5.15.19` als unsichere Laufzeitabhängigkeit.

Der Pin bleibt, solange TeamSpeak 3 benötigt wird. Entfernen, wenn TeamSpeak 3 ohne
Qt5-WebEngine verfügbar ist oder die Paketliste auf `teamspeak6-client` umgestellt wird.

### Proxmark3-Paketvariante (`overlays/proxmark3/`)

Die Variante baut für `PM3RDV4` die Standalone-Firmware `HF_COLIN` und aktiviert
BlueShark über `BTADDON`. Sie wird für das „Knopf“-Script benötigt. Behalten, solange
nixpkgs diese Kombination nicht als Standard oder eigenes Paketattribut liefert.

### Auto-ESP-Resync nach GC (`bootloaderResyncAfterGc`) — UNTESTED

Feature-Flag (`modules/software/maintenance/bootloader-resync.nix`), aktiviert in
`commonFeatures`. `nix.gc` läuft wöchentlich (`--delete-older-than 21d`), räumt aber die ESP
nicht — verwaiste Bootmenü-Einträge bleiben bis zum nächsten `switch`/`boot`.

Lösung: `bootloader-resync.service` (oneshot) hängt per `ExecStartPost` am `nix-gc.service`
und ruft `${config.system.build.installBootLoader} /run/current-system` auf — den
offiziellen, bootloader-agnostischen Install-Schritt (Lanzaboote signiert UKIs neu,
systemd-boot regeneriert Einträge). Greift NUR bei automatischem `nix.gc`, nicht bei
manuellem `nix-collect-garbage` (das wird vom nächsten Timer-Lauf nachgezogen).

**Status:** Eval geprüft (`nix flake check` grün), Laufzeitverhalten noch nicht verifiziert.
Funktionstest: `sudo systemctl start nix-gc.service`, dann `journalctl -u bootloader-resync`
+ `bootctl list` prüfen.

### Build-Troubleshooting

Runbook für Diagnose und Fix von Build-Fehlern nach `flake.lock`-Update:
→ Vault-Note: `[[nix/troubleshooting/build-fehler-nach-flake-update]]`

## Build & Deploy

```bash
# Auf dem jeweiligen Host (erkennt Config am Hostnamen):
nixos-rebuild switch --sudo

# Mit expliziter Flake-Angabe (Neuinstallation, anderer Rechnername):
nixos-rebuild switch --sudo --flake .#HOSTNAME

# Remote-Compiling auf SPIELKISTE:
nixos-rebuild switch --sudo --build-host spielkiste
```

## Activation Scripts

- **nvd diff** — Zeigt Paketänderungen nach Rebuild (ab Uptime > 30s)
- **GNS3-Extras** — Symlinks unter `/var/lib/gns3` bei Activation (ab Uptime > 30s)

Kein toter Code — die Uptime-Prüfung verhindert Fehler beim initialen Boot.
