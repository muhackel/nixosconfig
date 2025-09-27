{ config, lib, pkgs, wantsGames, ... }:

lib.mkIf wantsGames {
  programs.steam.enable = true;
  
  environment.systemPackages = with pkgs; [ 
    lutris
    unigine-valley
    unigine-heaven
    unigine-tropics
    unigine-sanctuary
    unigine-superposition
  ];
}