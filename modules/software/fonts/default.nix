{ config, lib, pkgs, ... }:
let
  usedFonts = with pkgs; [
      nerd-fonts.hack
      xkcd-font
      liberation_ttf
  ];
in
{
  fonts = {
    packages = usedFonts;
  };
}