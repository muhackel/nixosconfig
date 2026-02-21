{
  description = "System Configuration Flake";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://numtide.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    ];
    trusted-users = [ "root" "muhackel" ];
  };
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, lanzaboote, ... }:
    let
      lib = nixpkgs.lib;

      # ── Gemeinsame Module für alle Desktop-Hosts ──
      commonModules = [
        ./modules/options.nix
        ./configuration.nix
        ./modules/user/muhackel
        ./modules/software/fonts
        ./modules/software/localisation
        ./modules/software/applications
        ./modules/software/virtualisation
        ./modules/software/displaymanager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.muhackel = import ./modules/user/muhackel/home.nix;
        }
      ];

      # ── Helper: Desktop-Host erzeugen ──
      mkHost = {
        hostModule,
        stateVersion ? "26.05",
        features,
        extraModules ? [],
      }:
      lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { system.stateVersion = stateVersion;
            local.features = features;
          }
          hostModule
        ] ++ extraModules ++ commonModules;
      };

    in {
      nixosConfigurations = {

        HAL9000 = mkHost {
          hostModule = ./modules/host/HAL9000;
          features = {
            wayland = true;
            plasma6 = true;
            hamradio = true;
            networking = true;
            nfc = true;
            ptls = true;
            games = true;
            docker = true;
            winboat = true;
            virtualbox = true;
            libvirt = true;
          };
        };

        SPIELKISTE = mkHost {
          hostModule = ./modules/host/SPIELKISTE;
          features = {
            wayland = true;
            plasma6 = true;
            hamradio = true;
            networking = true;
            nfc = true;
            ptls = true;
            games = true;
            docker = true;
            winboat = true;
            virtualbox = true;
            libvirt = true;
          };
          extraModules = [
            lanzaboote.nixosModules.lanzaboote
            { boot.loader.systemd-boot.enable = lib.mkForce false;
              boot.lanzaboote = {
                enable = true;
                pkiBundle = "/var/lib/sbctl";
              };
            }
          ];
        };

        BFG9000 = mkHost {
          hostModule = ./modules/host/BFG9000;
          features = {
            wayland = true;
            plasma6 = true;
            hamradio = true;
            networking = true;
            nfc = true;
            ptls = true;
            games = true;
            docker = true;
            winboat = true;
            virtualbox = true;
            libvirt = true;
          };
        };

      };
    };
}