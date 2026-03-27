# NixOS-Konfiguration

Multi-Host NixOS-Flake für die Verwaltung mehrerer NixOS-Maschinen (Desktop, Notebooks, Server).

## Voraussetzungen

- NixOS mit aktivierten [Flakes](https://nixos.wiki/wiki/Flakes)
- Für **SPIELKISTE**: Secure-Boot-Keys müssen einmalig via `sbctl` enrollt werden (`/var/lib/sbctl`)
- Klonen nach `/home/muhackel/nixosconfig` (Pfade in Activation Scripts sind relativ zum Flake)

## Struktur

```
nixosconfig/
├── flake.nix              # Einstiegspunkt — Hosts, Inputs, Checks
├── configuration.nix      # Gemeinsame Basis (Overlays, Nix-Settings, GC)
├── lib/                   # Helper (mkHost, caches)
├── modules/
│   ├── options.nix        # Feature-Flags (local.features.*)
│   ├── host/              # Host-spezifische Module
│   ├── hardware/          # Hardware-Konfiguration
│   ├── software/          # Feature-Module (Applications, Display, etc.)
│   └── user/              # User-Konfiguration + Home Manager
├── overlays/              # Paket-Overlays
└── packages/              # Eigene Paket-Definitionen
```

## Inputs

| Input | Quelle | Beschreibung |
|-------|--------|--------------|
| nixpkgs | `nixos-unstable` | Rolling-Release Paketbasis |
| home-manager | `nix-community/home-manager` | User-Konfiguration (follows nixpkgs) |
| lanzaboote | `nix-community/lanzaboote` v1.0.0 | Secure Boot (nur SPIELKISTE, follows nixpkgs) |

## Hosts

| Host | Rolle | Hardware | GPU | Besonderheiten |
|------|-------|----------|-----|----------------|
| **SPIELKISTE** | Hauptrechner / Gaming-PC | Framework Desktop | AMD (RDNA) | Lanzaboote Secure Boot, LACT GPU-Tuning |
| **HAL9000** | Notebook | Lenovo ThinkPad 25 | Nvidia (Optimus) | CPU-Undervolting, NFC-Reader, Autorandr/EDID |
| **BFG9000** | Arbeitslaptop | Lenovo X1 Extreme G3 | Nvidia (Optimus, open) | 4K-Skalierung, kein Hamradio |
| **datengrab** | Heimserver (WIP) | — | — | ZFS, noch nicht in `flake.nix` |

## Feature-Flags

Features werden in `modules/options.nix` deklariert und in `flake.nix` pro Host aktiviert. Module unter `modules/software/` reagieren auf `config.local.features.<flag>`.

| Flag | Beschreibung | SPIELKISTE | HAL9000 | BFG9000 |
|------|-------------|:---:|:---:|:---:|
| plasma6 | KDE Plasma 6 (Wayland) | ✓ | ✓ | ✓ |
| games | Steam, GameMode, Wine, Heroic | ✓ | ✓ | ✓ |
| hamradio | SDR-Software (gqrx, HackRF, WSJTX) | ✓ | ✓ | ✗ |
| networking | GNS3, Wireshark, nmap, Winbox | ✓ | ✓ | ✓ |
| nfc | NFC-Tools | ✓ | ✓ | ✓ |
| ptls | PTLS-Tools | ✓ | ✓ | ✓ |
| docker | Docker Container Runtime | ✓ | ✓ | ✓ |
| virtualbox | VirtualBox + Extension Pack | ✓ | ✓ | ✓ |
| libvirt | libvirt/QEMU | ✓ | ✓ | ✓ |
| winboat | Winboat-Tools | ✓ | ✓ | ✓ |
| xmonad | Xmonad X11 Desktop | ✗ | ✗ | ✗ |
| vmwareHost | VMware Host | ✗ | ✗ | ✗ |

## Build & Deploy

### System neu bauen

```bash
# Auf dem jeweiligen Host (erkennt die Config automatisch am Hostnamen):
nixos-rebuild switch --sudo

# Remote-Compiling auf SPIELKISTE:
nixos-rebuild switch --sudo --build-host spielkiste
```

Nach dem Rebuild zeigt ein **nvd-Diff** automatisch die Paketänderungen an.

### Flake prüfen

```bash
nix flake check
```

Die Checks bauen die `system.build.toplevel`-Derivation jedes Hosts — damit ist sichergestellt, dass alle Konfigurationen evaluierbar sind.

## Designentscheidungen

### hostId `DEADBEEF`

Alle Desktop-Hosts teilen dieselbe `hostId`. ZFS nutzt diese als Import-Guard — da USB-ZFS-Datenträger bewusst zwischen Rechnern gewechselt werden, ermöglicht eine gemeinsame ID den automatischen Import ohne Force-Flag.

### userExtraGroups-Pattern

Feature-Module fügen ihre benötigten Gruppen über `local.userExtraGroups` hinzu (z.B. `docker`, `wireshark`, `ham`, `gamemode`). Die User-Konfiguration sammelt diese und setzt sie zentral — Module ändern nie direkt den User.

### Activation Scripts

- **nvd diff** — Zeigt Paketänderungen nach jedem Rebuild (erst ab Uptime > 30s, um den initialen Boot nicht zu blockieren)
- **GNS3-Extras** — Symlinks unter `/var/lib/gns3` werden bei Activation aktualisiert

## Gemeinsame Peripherie

Alle Desktop-Hosts teilen folgende Hardware-Konfiguration:

- **Drucker:** HP LaserJet 4100 (CUPS + `hplip`)
- **Bluetooth:** Aktiviert auf allen Hosts
- **Tastatur:** Generische Konfiguration
- **Maus:** Logitech G502 + Wireless-Support (Solaar)
- **Speichermedien:** USB-Automount via udisks2 (mountet unter `/media/`)

## Eigene Pakete (`packages/`)

| Paket | Beschreibung |
|-------|-------------|
| **mcpvault** | MCP-Server für Obsidian-Vault-Zugriff |
| **better-sqlite3** | Native Node.js SQLite-Modul |
| **crossover** | Wine-basierter Windows-Runner (für Gaming) |
| **gns3extras** | Symlink-Manager für GNS3-Pfade |
| **configtool** | Konfigurationstool |

## Overlays (`overlays/`)

| Overlay | Beschreibung |
|---------|-------------|
| **proxmark3** | RFID/NFC-Tool (HF_COLIN-Firmware + Blueshark-Addon) |
| **osm-gps-map** | OpenStreetMap-Kartenrendering |

(`ciscoPacketTracer8` ist vorhanden aber aktuell nicht aktiv eingebunden.)

## Binary Caches

Konfiguriert in `lib/caches.nix` und gespiegelt in `flake.nix:nixConfig`:

| Cache | Zweck |
|-------|-------|
| `cache.nixos.org` | Offizieller NixOS-Cache |
| `nix-community.cachix.org` | Community-Pakete (Home Manager, Lanzaboote, etc.) |
| `numtide.cachix.org` | Numtide-Projekte |

Trusted Users: `root`, `muhackel`

## Home Manager

User-spezifische Konfiguration läuft über Home Manager (`modules/user/muhackel/home.nix`). Wird als NixOS-Modul eingebunden — `useGlobalPkgs` und `useUserPackages` sind aktiviert, d.h. Home Manager nutzt die gleichen nixpkgs wie das System.

## Neuen Host anlegen

1. `modules/host/NEUER_HOST/default.nix` anlegen (Hardware-Module importieren, hostName/hostId setzen)
2. Hardware-Konfiguration nach `modules/hardware/...` (ggf. `nixos-generate-config` als Basis)
3. In `flake.nix` unter `nixosConfigurations` eintragen:
   ```nix
   NEUER_HOST = myLib.mkHost {
     hostModule = ./modules/host/NEUER_HOST;
     features   = commonFeatures // { ... };
   };
   ```
4. In `checks.x86_64-linux` eintragen

## Neues Feature-Flag anlegen

1. Flag in `modules/options.nix` deklarieren: `neuesFeature = lib.mkEnableOption "...";`
2. In `flake.nix` unter `commonFeatures` setzen (oder nur für bestimmte Hosts)
3. Modul unter `modules/software/` anlegen, das `config.local.features.neuesFeature` prüft
4. Modul in `modules/software/applications/default.nix` importieren (oder direkt in `commonModules`)
