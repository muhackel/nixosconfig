{
  description = "System Configuration Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable-small";

    # use the following for unstable:
    # nixpkgs.url = "nixpkgs/nixos-unstable";

    # or any branch you want:
    # nixpkgs.url = "nixpkgs/{BRANCH-NAME}";
  };

  outputs = { self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        HAL9000 = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./configuration.nix 
                      ./boot-tp25.nix
                      ./general.nix
                      ./hardware-configuration.nix
                      ./hardware-lenovo-tp25.nix
                      ./hardware-bluetooth.nix
                      ./hardware-keyboard.nix
                      ./hardware-mouse.nix
                      ./user-muhackel.nix
                      ./software-network.nix
                      ./software-nfc.nix
                      ./software-ptls.nix
                      ./software-hamradio.nix
                      ./software-virtualisation.nix
          ];
      };
    };
  };
}