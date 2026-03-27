# NixOS-Konfiguration

Multi-Host NixOS-Flake für die Verwaltung mehrerer NixOS-Maschinen (Desktop, Notebooks, Server).

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

## Hosts

| Host | Rolle | Hardware |
|------|-------|----------|
| SPIELKISTE | Hauptrechner / Gaming-PC | Framework Desktop |
| HAL9000 | Notebook | Lenovo ThinkPad 25 |
| BFG9000 | Arbeitslaptop | Lenovo X1 Extreme G3 |
| datengrab | Heimserver (WIP) | — |

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
