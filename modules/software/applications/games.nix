{ config, lib, pkgs, ... }:

let 
  crossover = pkgs.callPackage ../../../packages/crossover { };
  helden-software = pkgs.callPackage ../../../packages/helden-software { };
  genesis = pkgs.callPackage ../../../packages/genesis { };
  commlink6 = pkgs.callPackage ../../../packages/comlink6 { };
  cfg = config.local.features;
  wantedGames = with pkgs; [
    (bottles.override { removeWarningPopup = true; })
    commlink6
    genesis
    ioquake3
    helden-software
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

  systemd.user.settings.Manager.DefaultLimitNOFILE = "524288:1048576";
}