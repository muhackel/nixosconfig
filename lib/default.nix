{ lib, home-manager, self, claude-desktop }:
let
  commonModules = [
    { nixpkgs.overlays = [ claude-desktop.overlays.default ]; }
    "${self}/modules/options.nix"
    "${self}/configuration.nix"
    "${self}/modules/user/muhackel"
    "${self}/modules/software/fonts"
    "${self}/modules/software/localisation"
    "${self}/modules/software/applications"
    "${self}/modules/software/virtualisation"
    "${self}/modules/software/displaymanager"
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.muhackel = import "${self}/modules/user/muhackel/home.nix";
    }
  ];
in
{
  mkHost = { hostModule, stateVersion ? "26.05", features, extraModules ? [] }:
    lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        { system.stateVersion = stateVersion;
          local.features = features;
        }
        hostModule
      ] ++ extraModules ++ commonModules;
    };
}
