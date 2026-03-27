# NixOS-Konfiguration

Multi-Host NixOS-Flake unter `/home/muhackel/nixosconfig`.

## Projekttyp

Projekt — Git mit Branches, kein Commit auf main.

## Hosts

| Host | Rolle | Hardware | GPU | Besonderheiten |
|------|-------|----------|-----|----------------|
| **SPIELKISTE** | Hauptrechner / Gaming-PC | Framework Desktop | AMD (RDNA) | Lanzaboote Secure Boot |
| **HAL9000** | Notebook | Lenovo ThinkPad 25 | Nvidia (Optimus) | CPU-Undervolting, Autorandr/EDID |
| **BFG9000** | Arbeitslaptop | Lenovo X1 Extreme G3 | Nvidia (Optimus, open) | 4K-Skalierung, Ferdium GPU-Workaround |
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
