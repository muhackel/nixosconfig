{ config, lib, pkgs, ... }:

lib.mkIf config.local.features.sound {
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    wireplumber.enable = true;
    pulse.enable = true;

    configPackages = [
      (pkgs.callPackage ../../../packages/pipewire-deepfilternet { })
    ];

    # Avantree DG60P (Full-Speed USB, aptX-LL) underrunt bei <10ms Quantum unter DeepFilterNet-Last
    wireplumber.extraConfig."51-avantree-quantum" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            { "node.nick" = "Avantree DG60P"; }
          ];
          actions = {
            update-props = {
              "node.latency" = "1024/48000";
              "node.lock-quantum" = true;
            };
          };
        }
      ];
    };
  };
}
