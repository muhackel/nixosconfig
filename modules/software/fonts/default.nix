{ config, lib, pkgs, ... }:
let
  nerdfonts = with pkgs.nerd-fonts; [
    adwaita-mono
    hack
    open-dyslexic
    sauce-code-pro
    ubuntu
    ubuntu-mono
    ubuntu-sans
  ];
  usedFonts = with pkgs; [
    adwaita-fonts
    xkcd-font
    liberation_ttf
  ];
in
{
  fonts = {
    enableDefaultPackages = true;
    enableGhostscriptFonts = true;
    packages = usedFonts ++ nerdfonts;
  };
}