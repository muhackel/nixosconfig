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
  settings = {
    general = {
      renice = 10;
      #igpu_desiredgov = "performance";
    };
    gpu = {
      #apply_gpu_optimisations = "accept-responsibility";
      #gpu_device = 2;
      #nv_powermizer_mode = 1;
    };
    custom = {
      start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
      end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
    };
  };
}