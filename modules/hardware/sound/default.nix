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

    extraConfig.pipewire."92-deepfilter-loop" = {
      "context.properties"."context.data-loops" = [
        {
          "thread.name" = "data-loop.0";
          "loop.class" = [ "data.rt" ];
        }
        {
          "thread.name" = "data-loop.deepfilter";
          "loop.class" = [ "data.deepfilter" ];
        }
      ];
      "stream.rules" = [
        {
          matches = [
            { "node.name" = "capture.deepfilternet_source"; }
            { "node.name" = "deepfilternet_source"; }
          ];
          actions.update-props."node.loop.name" = "data-loop.deepfilter";
        }
      ];
    };

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
