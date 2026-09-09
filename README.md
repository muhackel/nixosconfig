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
| plasma-manager | `nix-community/plasma-manager` | Deklarative Plasma-Konfiguration (follows nixpkgs, home-manager) |
| kwin-xmonad-lite | `muhackel/kwin-xmonad-lite` | KWin-Layout-Controller (follows nixpkgs, home-manager, plasma-manager) |
| codexbar-plasma-nix | `github:muhackel/codexbar-plasma-nix` | Plasma-6-Widget und Laufzeitabhängigkeiten via `overlays.default` |

## Hosts

| Host | Rolle | Hardware | GPU | Besonderheiten |
|------|-------|----------|-----|----------------|
| **SPIELKISTE** | Hauptrechner / Gaming-PC | Framework Desktop | AMD (RDNA) | Lanzaboote Secure Boot, LACT GPU-Tuning |
| **HAL9000** | Notebook | Lenovo ThinkPad 25 | Nvidia (Optimus) | CPU-Undervolting, NFC-Reader, Autorandr/EDID |
| **BFG9000** | Arbeitslaptop | Lenovo X1 Extreme G3 | Nvidia (Optimus, open) | 4K-Skalierung, kein Hamradio, lokale KMT-VPN-VM |
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
| kmtVpnVm | Persistentes TAP für die lokale KMT-VPN-VM | ✗ | ✗ | ✓ |
| plasmaManager | plasma-manager verwaltet die Plasma-Konfiguration | ✗ | ✓ | ✗ |
| kwinXmonadLite | KWin-Layout-Controller im XMonad-Stil (braucht `plasmaManager`) | ✗ | ✓ | ✗ |
| winboat | Winboat-Tools | ✓ | ✓ | ✓ |
| xmonad | Xmonad X11 Desktop | ✗ | ✗ | ✗ |
| vmwareHost | VMware Host | ✗ | ✗ | ✗ |

### Deklarative Plasma-Konfiguration (`plasmaManager`)

Schaltet `programs.plasma.enable`: plasma-manager schreibt die Plasma-Konfiguration.
Aktiv nur auf HAL9000. Das Flag ist bewusst **vom Controller getrennt** — plasma-manager
an heißt nicht Controller an. Nur so gibt es einen verwalteten Aus-Zustand: hinge
`programs.plasma.enable` am Controller-Flag, schriebe plasma-manager nach dessen
Abschalten gar nichts mehr (sein Schreibvorgang hängt an einem `home.activation`-Skript
unter `mkIf plasmaCfg.enable`), und mit `overrideConfig = false` bliebe der alte Stand
inklusive umgelegtem `Meta+L` einfach stehen.

An diesem Flag hängt auch das Standard-Suchkürzel
(`programs.plasma.searchPlugins.webSearchKeywords`) — plasma-manager schreibt
`kuriikwsfilterrc` ungefragt, sobald es läuft.

### KWin-Layout-Controller (`kwinXmonadLite`)

Das Flag bindet [`kwin-xmonad-lite`](https://github.com/muhackel/kwin-xmonad-lite) als
KWin-Skript ein — Tall- und Full-Layout mit Tastensteuerung, im Stil der früheren
XMonad-Konfiguration. Aktiv **nur auf HAL9000**; SPIELKISTE bleibt Entwicklungsmaschine
und lädt das Skript weiterhin von Hand über `nix run`.

Eingebunden wird es über das Home-Manager-Modul des Projekts, das in
`lib/default.nix` unter `home-manager.sharedModules` liegt. Eingeschaltet wird es in
`modules/user/muhackel/kwin-xmonad-lite.nix`, sobald `plasma6`, `plasmaManager` **und**
`kwinXmonadLite` gesetzt sind. Die Konfiguration landet über plasma-manager in `kwinrc`, Gruppe
`[Script-kwin-xmonad-lite]` (alle sechs Schlüssel werden immer geschrieben).

**KDE-Shortcut-Politik:** Auf Hosts mit dem Flag ist „Sitzung sperren“ von `Meta+L` auf
`Ctrl+Alt+L` umgelegt und „Kachelung bearbeiten“ (`Meta+T`) auf keine Taste gesetzt.
Grund: `registerShortcut` in KWin ruft `KGlobalAccel::setShortcut` ohne `NoAutoloading`
und meldet trotzdem immer Erfolg — ein bereits in `kglobalshortcutsrc` stehender Eintrag
gewinnt also gegen die Erstbelegung des Skripts. Live gemessen: ohne die Umlegung sperrte
`Meta+L` die Sitzung und `Meta+T` öffnete den Kachel-Editor, statt `xml-expand` und
`xml-sink` auszulösen. Ohne das Controller-Flag stellt derselbe Modulzweig die
KDE-Vorgaben `Meta+L` (Sperren) und `Meta+T` (Kachelung bearbeiten) wieder her — die
Werte sind der vor der Registrierung gemessene Ist-Stand, nicht geraten.

Änderungen an `settings` werden erst nach erneuter Anmeldung wirksam: `switch` schreibt
zwar `kwinrc`, KWin lädt ein bereits geladenes Skript aber nicht neu.

Die Live-Abnahme auf HAL9000 vom 2026-09-06 bestand die Fälle 24–24e gegen den
Projekt-Pin `8f287d9`: alle zwölf Aktionen funktionierten per echtem Tastendruck, die
KDE-Kürzel und Einstellungen wurden korrekt umgelegt, und der Aus-Zustand gab die
Tasten wieder frei. Danach wurde HAL9000 vollständig auf Generation 584 zurückgebaut.
Der Branch ist mergefähig und pinnt den gemergten Re-Audit-Stand; der vollständige
`nix flake check` war grün.

Beim Abschalten bleiben die zuletzt geschriebenen Werte unter
`[Script-kwin-xmonad-lite]` in `kwinrc` stehen. Sie sind wirkungslos, solange das Plugin
deaktiviert ist und die zwölf `xml-*`-Tasten auf `none` stehen. Beim erneuten Aktivieren
überschreibt das Modul alle sechs Werte.

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

Die Checks bauen die `system.build.toplevel`-Derivation jedes Hosts. Der zusätzliche
Check `kwinXmonadLite-disabled` wertet HAL9000 mit abgeschaltetem Controller aus und
prüft den verwalteten Aus-Zustand einschließlich Plugin-Flag und Tastenkürzeln.

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

`codexbar-plasma` stammt inzwischen aus dem externen Flake-Input
`github:muhackel/codexbar-plasma-nix` und wird über dessen `overlays.default` in
`lib/default.nix` in `commonModules` eingebunden. Die Pflege des Upstreams läuft
automatisiert im externen Repository: Ein neuer Release landet dort zuerst als
geprüfter, automatisch erzeugter Update-Pull-Request. Erst die Übernahme dieses
Pull-Requests bewegt den Stand im externen Repository; anschließend holt ein
manuelles `nix flake update codexbar-plasma-nix` diesen Stand hierher. Der Befehl
zieht keine neue Upstream-Version direkt.

## Overlays (`overlays/`)

| Overlay | Beschreibung |
|---------|-------------|
| **pyqt5-abi12** | PyQt5 5.15.11 mit SIP 6.15.3 für ABI v12 |
| **ts3-legacy** | TeamSpeak 3.6.2 aus nixos-25.11 mit bewusst akzeptierter EOL-Qt5-WebEngine |
| **proxmark3** | RFID/NFC-Tool (HF_COLIN-Firmware + Blueshark-Addon) |

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

Über `home-manager.sharedModules` (in `lib/default.nix`) kommen zusätzlich die Module von
plasma-manager und kwin-xmonad-lite dazu. Beide bleiben wirkungslos, solange nichts sie
einschaltet — `programs.plasma.enable` hängt an `plasmaManager`, der Controller
zusätzlich an `kwinXmonadLite`; auf Hosts ohne diese Flags ist beides `false`.

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
