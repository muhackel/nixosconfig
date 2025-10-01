{ config, lib, pkgs, wantsGames, ... }:

lib.mkIf wantsGames {
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamescope.enable = true;
  programs.gamescope.capSysNice = true;
  programs.gamemode.enable = true;
  programs.gamemode.enableRenice = true;

  environment.systemPackages = with pkgs; [ 
    lutris
    mangohud
    wineWowPackages.stable #waylandFull
    winetricks
    unigine-valley
    unigine-heaven
    #unigine-tropics
    #unigine-sanctuary
    #unigine-superposition
  ];
  systemd.user.extraConfig = ''
  DefaultLimitNOFILE=524288:1048576
'';
}