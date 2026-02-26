{ config, lib, pkgs, ... }:

let 
  crossover = pkgs.callPackage ../../../packages/crossover { };
  cfg = config.local.features;
  wantedGames = with pkgs; [
    (bottles.override { removeWarningPopup = true; })
    ioquake3
    heroic
    mangohud
    openra
    steamtinkerlaunch
    wineWow64Packages.stable #waylandFull
    winetricks
    wowup-cf
  ];
  wantedBenchmarks = with pkgs; [
    #unigine-valley
    #unigine-heaven
    #unigine-tropics
    #unigine-sanctuary
    #unigine-superposition
  ];
in 
{
  programs.steam = {
    enable = cfg.games;
    gamescopeSession.enable = cfg.games;
  };
  programs.gamescope = {
    enable = cfg.games;
    capSysNice = cfg.games;
  };
  programs.gamemode = {
    enable = cfg.games;
    enableRenice = true;
  };

  environment.systemPackages = lib.optionals cfg.games wantedGames ++ lib.optionals cfg.games wantedBenchmarks;

  local.userExtraGroups = [ "gamemode" ];

  systemd.user.extraConfig = ''
  DefaultLimitNOFILE=524288:1048576
  '';
}