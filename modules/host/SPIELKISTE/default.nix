{ config, lib, pkgs, ... }:

{
  imports = [
    ../../hardware/frameworkdesktop
    ../../hardware/bluetooth
    ../../hardware/keyboard
    ../../hardware/mouse/logitech-wireless
    ../../hardware/printer
    ../../hardware/printer/HP
    ../../hardware/printer/HP/hplj4100
  ];
  programs.gamemode = {
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 1;
        amd_performance_level = "high";
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };
}