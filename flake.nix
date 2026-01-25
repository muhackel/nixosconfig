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
    in {
      nixosConfigurations = {
        HAL9000 = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            wantsXserver = false;
            wantsWayland = true;
            wantsPlasma6 = true;
            wantsHamradio = true;
            wantsNetworking = true;
            wantsNfc = true;
            wantsPtls = true;
            wantsGames = true;
            wantsVMwareHost = false;
            wantsDocker = true;
            wantsVirtualbox = true;
            wantsLibvirt = true;
          };
          modules = [ { system.stateVersion = "26.05"; }
            ./configuration.nix
            ./modules/host/HAL9000
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
        };
        SPIELKISTE = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            wantsXserver = false;
            wantsWayland = true;
            wantsPlasma6 = true;
            wantsHamradio = true;
            wantsNetworking = true;
            wantsNfc = true;
            wantsPtls = true;
            wantsGames = true;
            wantsVMwareHost = false;
            wantsDocker = true;
            wantsVirtualbox = true;
            wantsLibvirt = true;
          };
          modules = [ { system.stateVersion = "26.05";
                        boot.loader.systemd-boot.enable = lib.mkForce false;
                        boot.lanzaboote = {
                          enable = true;
                          pkiBundle = "/var/lib/sbctl";
                        };
                      }
            lanzaboote.nixosModules.lanzaboote
            ./configuration.nix
            ./modules/host/SPIELKISTE
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
        };
        BFG9000 = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            wantsXserver = false;
            wantsWayland = true;
            wantsPlasma6 = true;
            wantsHamradio = true;
            wantsNetworking = true;
            wantsNfc = true;
            wantsPtls = true;
            wantsGames = true;
            wantsVMwareHost = false;
            wantsDocker = true;
            wantsVirtualbox = true;
            wantsLibvirt = true;
          };
          modules = [ { system.stateVersion = "26.05"; }
            ./configuration.nix
            ./modules/host/HAL9000
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
        };
      };
    };
}