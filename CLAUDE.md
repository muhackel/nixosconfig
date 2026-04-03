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

Default ist `26.05` (gesetzt in `lib/default.nix`) — nicht ändern ohne guten Grund.

### Winboat-Overlay (`overlays/go-pin/`)

Workaround für winboat Go 1.26 Cross-Compilation Bug (Go#75734):
`_cgo_stub_export: symbol not defined` bei mingw32 Cross-Compilation.
Lösung: `pkgsCross.mingwW64.extend` pinnt Go auf 1.25 im Cross-Scope.

Electron-41-Fix wurde upstream behoben und aus dem Overlay entfernt.

**Deaktivieren wenn:** nixpkgs-unstable den Go-Fix enthält.
Test: Overlay-Import in `configuration.nix` auskommentieren, `nix flake check` laufen lassen.
Das Overlay bleibt als Referenz im Repo erhalten.

### Claude-Code-Pin (`overlays/claude-code-pin/`)

Pin auf claude-code 2.1.91 — nixpkgs enthält 2.1.88, das von npm unpublished wurde (404).
Baut das Paket via `buildNpmPackage` mit eigener `package-lock.json`.

**Entfernen wenn:** nixpkgs eine aktuelle claude-code-Version hat.

### SDL3 Test-Timeout Overlay (`overlays/sdl3-test-timeout/`)

Verdreifacht CTest-Timeouts für SDL3 Threading-Tests (`testrwlock` etc.) die in der
Nix-Sandbox bei parallelen Builds in Timeouts laufen. Aktuell auskommentiert in
`configuration.nix` — bei Bedarf aktivieren wenn `nix flake check` an SDL3-Tests scheitert.

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
