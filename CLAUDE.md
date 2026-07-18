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
| **BFG9000** | Arbeitslaptop | Lenovo X1 Extreme G3 | Nvidia (Optimus, open) | 4K-Skalierung, Ferdium GPU-Workaround, kein Hamradio |
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

### Overlays

Aktive Overlays werden in `configuration.nix` (`usedOverlays`) mit Inline-Kommentar zum
Zweck importiert. Die meisten sind temporäre Workarounds für flaky Tests oder EOL-Pakete:

| Overlay | Zweck |
|---------|-------|
| `bubblewrap-setuid` | bwrap mit `support_setuid` — siehe Detailsektion unten |
| `ts3-legacy` | TS3-Client aus nixos-25.11 (Qt5-Stack EOL in unstable) |
| `spamassassin-ssl-test` | Workaround: `spamd_ssl.t` SSL-Test-Failure |
| `openldap-flaky-test` | Workaround: `test017-syncreplication-refresh` flaky |
| `patool-skip-tests` | Workaround: python-patool 4.0.5 Test-Env-Failures (via bottles) |
| `osm-gps-map`, `proxmark3` | Paket-Fixes |

**Entfernen wenn:** der jeweilige Upstream-Fix in nixpkgs-unstable landet — Import in
`configuration.nix` auskommentieren, `nix flake check`, dann Overlay-Verzeichnis löschen.

### Bubblewrap-Setuid Overlay (`overlays/bubblewrap-setuid/`)

Baut `bubblewrap` mit `-Dsupport_setuid=true`. Seit bwrap 0.11.2 (April 2026,
CVE-2026-41163) wird der setuid-Mode per default ausgebaut — Binaries die trotzdem
setuid gestartet werden, brechen mit *"setuid use of bubblewrap is not supported in
this build"* ab.

Trigger: `programs.gamescope.capSysNice = true` in `modules/software/applications/games.nix`
lässt das nixpkgs Steam-Modul einen setuid-Wrapper für `bwrap` installieren
(`security.wrappers.bwrap`, Modul-Kommentar: *"needed or steam fails"*) — der dann
mit dem ungepatchten bwrap crasht.

**Fallback wenn upstream den setuid-Pfad endgültig killt** (Overlay baut nicht mehr):
`capSysNice = false;` in `games.nix:32` setzen. Der setuid-Wrapper wird dann nicht mehr
installiert, gamescope verliert `CAP_SYS_NICE` — gamemode mit `enableRenice = true`
übernimmt das Renicing.

**Entfernen wenn:** nixpkgs den setuid-Build wieder als Default anbietet, oder das
Steam-Modul nicht mehr auf setuid-bwrap angewiesen ist.

### Auto-ESP-Resync nach GC (`bootloaderResyncAfterGc`) — UNTESTED

Feature-Flag (`modules/software/maintenance/bootloader-resync.nix`), aktiviert in
`commonFeatures`. `nix.gc` läuft täglich (`--delete-older-than 14d`), räumt aber die ESP
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
