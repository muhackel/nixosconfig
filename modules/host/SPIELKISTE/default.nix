{ config, lib, pkgs, ... }:

{
  imports = [
    ../../hardware/frameworkdesktop
    ../../hardware/bluetooth
    ../../hardware/keyboard
    ../../hardware/mouse/logitech-wireless
    ../../hardware/mouse/logitech-g502
    ../../hardware/printer
    ../../hardware/printer/HP
    ../../hardware/printer/HP/hplj4100
  ];
  #boot.kernelPackages = pkgs.linuxPackages_6_18;
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

  # Baloo indexierte das ganze Home samt versteckter Ordner (Steam, .cache, Worktrees):
  # 23 GB Index, 11,7 GB RAM, über 1 GB Swap. Der Speicherdruck lagerte PipeWire-Seiten
  # aus und löste am USB-Headset harte Tonausfälle aus (2026-10-24, siehe CLAUDE.md).
  # ~/.config/baloofilerc setzt den Schlüssel nicht, daher greift dieser Systemdefault.
  environment.etc."xdg/baloofilerc".text = ''
    [Basic Settings]
    Indexing-Enabled=false
  '';

  networking = {
    hostName = "SPIELKISTE";
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