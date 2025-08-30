{ config, lib, pkgs, ... }:
let
  usedFonts = with pkgs; [
      nerd-fonts.hack
      xkcd-font
  ];
in
{
  fonts = {
    packages = usedFonts;
  };
}