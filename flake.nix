{
  description = "System Configuration Flake";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://numtide.cachix.org"
      "https://cache.numtide.com"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
    trusted-users = [ "root" "muhackel" ];
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # plasma-manager steht hier als eigener Input, damit der Pin dieses Flakes
    # und der des kwin-xmonad-lite-Flakes zusammenfallen. Ohne das `follows`
    # unten wertete der Projektcheck eine andere plasma-manager-Version aus als
    # der Host tatsächlich importiert.
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # Layout-Controller als KWin-Skript, eingebunden über sein
    # Home-Manager-Modul (lib/default.nix -> home-manager.sharedModules).
    # Aktiv nur, wo local.features.plasmaManager und local.features.kwinXmonadLite
    # zusammen gesetzt sind. plasma-manager selbst hängt allein am ersten Flag —
    # so bleibt die Plasma-Konfiguration auch bei abgeschaltetem Controller
    # verwaltet und die KDE-Vorgaben werden zurückgeschrieben.
    kwin-xmonad-lite = {
      url = "github:muhackel/kwin-xmonad-lite";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.plasma-manager.follows = "plasma-manager";
    };
    codexbar-plasma-nix = {
      url = "github:muhackel/codexbar-plasma-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # KI-Agents (claude-code, codex, opencode, t3code, ccusage) mit täglichen
    # Updates, unabhängig vom nixpkgs-Kanal. Bewusst OHNE nixpkgs.follows: nur
    # gegen den eigenen nixpkgs-Pin treffen die Pakete cache.numtide.com.
    # Aktualisieren: nix flake update llm-agents
    llm-agents.url = "github:numtide/llm-agents.nix";
    # ArtCraft Launcher (installiert und aktualisiert die *Craft-Apps selbst).
    # Vorbereitet, Paket in apppkgs noch auskommentiert: der Upstream-Build
    # (b827fed) scheitert, Details in CLAUDE.md. nixpkgs.follows ist dabei
    # Voraussetzung, mit dem eigenen nixpkgs-Pin bricht schon das Vendoring.
    artcraft-launcher = {
      url = "github:storytold/craft-launcher";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #claude-desktop = {
    #  url = "github:aaddrick/claude-desktop-debian";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    # flake-utils.url = "github:numtide/flake-utils";  # for future use (multi-arch outputs etc.)
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, plasma-manager, kwin-xmonad-lite, codexbar-plasma-nix, llm-agents, artcraft-launcher, ... }:
    let
      lib    = nixpkgs.lib;
      myLib  = import ./lib { inherit lib home-manager plasma-manager kwin-xmonad-lite codexbar-plasma-nix llm-agents artcraft-launcher self; };

      # ── Feature-Set für alle Desktop-Hosts ──
      commonFeatures = {
        plasma6    = true;
        ai         = true;
        hamradio   = true;
        networking = true;
        nfc        = true;
        ptls       = true;
        games      = true;
        docker     = true;
        winboat    = true;
        virtualbox = true;
        libvirt    = true;
        sound      = true;
        bootloaderResyncAfterGc = true;
      };

    in {
      nixosConfigurations = {

        HAL9000 = myLib.mkHost {
          hostModule = ./modules/host/HAL9000;
          features   = commonFeatures // {
            thinkpadBattery = true;
            plasmaManager   = true;
            kwinXmonadLite  = true;
          };
        };

        SPIELKISTE = myLib.mkHost {
          hostModule   = ./modules/host/SPIELKISTE;
          features     = commonFeatures // {
            kmtVpnVm = true;
          };
          extraModules = [
            lanzaboote.nixosModules.lanzaboote
            { boot.loader.systemd-boot.enable = lib.mkForce false;
              boot.lanzaboote = {
                enable    = true;
                pkiBundle = "/var/lib/sbctl";
              };
            }
          ];
        };

        BFG9000 = myLib.mkHost {
          hostModule = ./modules/host/BFG9000;
          features = commonFeatures // {
            hamradio = false;
            kmtVpnVm = true;
            thinkpadBattery = true;
          };
        };

      };

      checks.x86_64-linux = {
        HAL9000    = self.nixosConfigurations.HAL9000.config.system.build.toplevel;
        SPIELKISTE = self.nixosConfigurations.SPIELKISTE.config.system.build.toplevel;
        BFG9000    = self.nixosConfigurations.BFG9000.config.system.build.toplevel;

        kwinXmonadLite-disabled =
          let
            hal9000 = self.nixosConfigurations.HAL9000.extendModules {
              modules = [
                { local.features.kwinXmonadLite = lib.mkForce false; }
              ];
            };
            home = hal9000.config.home-manager.users.muhackel;
            controllerPackage = toString home.programs.kwin-xmonad-lite.package;
            installedPackages = map toString home.home.packages;
            shortcuts = home.programs.plasma.configFile."kglobalshortcutsrc";
            xmlShortcuts = lib.filterAttrs (name: _: lib.hasPrefix "xml-" name) shortcuts.kwin;
            xmlNames = builtins.attrNames xmlShortcuts;
            allXmlShortcutsDisabled = lib.all (
              name: xmlShortcuts.${name}.value == "none,,"
            ) xmlNames;
          in
          assert home.programs.plasma.enable;
          assert !home.programs.kwin-xmonad-lite.enable;
          assert !builtins.elem controllerPackage installedPackages;
          assert home.programs.plasma.configFile."kwinrc".Plugins."kwin-xmonad-liteEnabled".value == false;
          assert builtins.length xmlNames == 12;
          assert allXmlShortcutsDisabled;
          assert home.programs.plasma.shortcuts.ksmserver."Lock Session" == [ "Screensaver" "Meta+L" ];
          assert home.programs.plasma.shortcuts.kwin."Edit Tiles" == [ "Meta+T" ];
          nixpkgs.legacyPackages.x86_64-linux.runCommand "kwin-xmonad-lite-disabled" { } ''
            touch "$out"
          '';
      };
    };
}
