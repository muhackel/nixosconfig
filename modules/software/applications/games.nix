{ config, lib, pkgs, wantsGames, ... }:

lib.mkIf wantsGames {
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamescope.enable = true;
  programs.gamescope.capSysNice = true;
  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };
  environment.systemPackages = with pkgs; [
    (bottles.override { removeWarningPopup = true; })
    ioquake3
    #lutris
    heroic
    mangohud
    openra
    steamtinkerlaunch
    wineWow64Packages.stable #waylandFull
    winetricks
    wowup-cf
    #unigine-valley
    #unigine-heaven
    #unigine-tropics
    #unigine-sanctuary
    #unigine-superposition
  ];

  users.users.muhackel.extraGroups = [ "gamemode" ];

  systemd.user.extraConfig = ''
  DefaultLimitNOFILE=524288:1048576
  '';
}