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
  };
}
