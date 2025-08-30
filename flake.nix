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
  };
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        HAL9000 = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./configuration.nix 
                      ./hardware-configuration.nix
                      ./modules/hardware/lenovo-tp25
                      ./modules/hardware/bluetooth
                      ./modules/hardware/keyboard
                      ./modules/hardware/mouse/logitech-wireless
                      ./modules/user/muhackel
                      ./modules/software/fonts
                      ./modules/software/localisation
                      ./modules/software/applications
                      ./modules/software/applications/hamradio.nix
                      ./modules/software/applications/networking.nix
                      ./modules/software/applications/nfc.nix
                      ./modules/software/applications/ptls.nix
                      ./modules/software/virtualisation
                      ./modules/software/displaymanager
          ];
      };
    };
  };
}
