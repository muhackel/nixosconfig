{ config, lib, pkgs, ... }:

{
  imports = [
    ../../hardware/lenovo-x1extr-G3
    ../../hardware/bluetooth
    ../../hardware/keyboard
    ../../hardware/mouse/logitech-wireless
    ../../hardware/printer
    ../../hardware/printer/HP
    ../../hardware/printer/HP/hplj4100
  ];
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  programs.gamemode = {
    settings = {
      general = {
        renice = 10;
        igpu_desiredgov = "performance";
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 2;
        nv_powermizer_mode = 1;
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };

  networking = {
    hostName = "BFG9000";
    hostId = "DEADBEEF";
    networkmanager.enable = true;
    usePredictableInterfaceNames = false;
    #proxy = {
      #default = "http://user:password@proxy:port/";
      #noProxy = "127.0.0.1,localhost,internal.domain";
    #};
    firewall.enable = false;
  };
}