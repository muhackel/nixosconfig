{ lib, home-manager, plasma-manager, kwin-xmonad-lite, codexbar-plasma-nix, llm-agents, self }:
let
  # Zentral gepinnte stateVersion (system + home). Home Manager folgt via
  # osConfig.system.stateVersion. Letzte stable war 26.05 (mkHost-Default unten).
  stateVersion = "26.11";
  commonModules = [
    { nixpkgs.overlays = [
        codexbar-plasma-nix.overlays.default
        # pkgs.llm-agents.<name> aus den fertigen Paketen des Flakes, nicht über
        # overlays.shared-nixpkgs — sonst gäbe es nur bei gleichem nixpkgs-Pin Cache-Treffer.
        (final: prev: { llm-agents = llm-agents.packages.${prev.stdenv.hostPlatform.system}; })
      ];
    }
    "${self}/modules/options.nix"
    "${self}/configuration.nix"
    "${self}/modules/user/muhackel"
    "${self}/modules/hardware/sound"
    "${self}/modules/software/fonts"
    "${self}/modules/software/localisation"
    "${self}/modules/software/applications"
    "${self}/modules/software/virtualisation"
    "${self}/modules/software/displaymanager"
    "${self}/modules/software/maintenance"
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.muhackel = import "${self}/modules/user/muhackel/home.nix";
      # Module, die jede Home-Manager-Konfiguration dieses Hosts bekommt.
      # `homeModules`, nicht `homeManagerModules`: bei plasma-manager ist der
      # alte Name nur noch ein lib.warn-Wrapper (Deprecation-Warnung bei jeder
      # Auswertung), und Nix 2.34 kennt ihn gar nicht mehr als Flake-Output.
      # Beide Module bleiben ohne Wirkung, solange nichts sie einschaltet —
      # kwin-xmonad-lite hängt an local.features.kwinXmonadLite.
      home-manager.sharedModules = [
        plasma-manager.homeModules.plasma-manager
        kwin-xmonad-lite.homeModules.default
      ];
    }
  ];
in
{
  mkHost = { hostModule, hostStateVersion ? "26.05", features, extraModules ? [] }:
    lib.nixosSystem {
      modules = [
        { system.stateVersion = stateVersion;
          local.features = features;
          nixpkgs.hostPlatform = "x86_64-linux";
        }
        hostModule
      ] ++ extraModules ++ commonModules;
    };
}
