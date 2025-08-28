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
                      ./hardware-configuration.nix
                      ./modules/hardware/lenovo-tp25
                      ./modules/hardware/bluetooth
                      ./modules/hardware/keyboard
                      ./modules/hardware/mouse/logitech-wireless
                      ./modules/user/muhackel
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
