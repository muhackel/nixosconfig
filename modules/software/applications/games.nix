{ config, lib, pkgs, wantsGames, ... }:

lib.mkIf wantsGames {
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamescope.enable = true;
  programs.gamescope.capSysNice = true;
  programs.gamemode = {
    enable = true;
    enableRenice = true;
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
  environment.systemPackages = with pkgs; [ 
    lutris
    #heroic
    mangohud
    wineWowPackages.stable #waylandFull
    winetricks
    unigine-valley
    unigine-heaven
    #unigine-tropics
    #unigine-sanctuary
    #unigine-superposition
  ];

  users.users.muhackel.extraGroups = [ "gamemode" ];

  systemd.user.extraConfig = ''
  DefaultLimitNOFILE=524288:1048576
  '';
}