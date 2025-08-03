{ config, lib, pkgs, ... }:


{
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Sink,Media,Socket";
        Disable = "Headset,Source";
      };
    };
    input = {
      General = {
        LEAutoSecurity = "true";
      };
    };
  };
}