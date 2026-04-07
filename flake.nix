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
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # flake-utils.url = "github:numtide/flake-utils";  # for future use (multi-arch outputs etc.)
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, ... }:
    let
      lib    = nixpkgs.lib;
      myLib  = import ./lib { inherit lib home-manager self; };

      # ── Feature-Set für alle Desktop-Hosts ──
      commonFeatures = {
        plasma6    = true;
        hamradio   = true;
        networking = true;
        nfc        = true;
        ptls       = true;
        games      = true;
        docker     = true;
        winboat    = true;
        virtualbox = true;
        libvirt    = true;
      };

    in {
      nixosConfigurations = {

        HAL9000 = myLib.mkHost {
          hostModule = ./modules/host/HAL9000;
          features   = commonFeatures;
        };

        SPIELKISTE = myLib.mkHost {
          hostModule   = ./modules/host/SPIELKISTE;
          features     = commonFeatures;
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
          features   = commonFeatures // { hamradio = false; };
        };

      };

      checks.x86_64-linux = {
        HAL9000    = self.nixosConfigurations.HAL9000.config.system.build.toplevel;
        SPIELKISTE = self.nixosConfigurations.SPIELKISTE.config.system.build.toplevel;
        BFG9000    = self.nixosConfigurations.BFG9000.config.system.build.toplevel;
      };
    };
}
