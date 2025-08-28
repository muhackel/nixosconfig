{ config, lib, pkgs, ... }:

{
  services.xserver.xkb.extraLayouts = 
  {
    fancy_us = {
      description = "English (US) Apple";
      symbolsFile = pkgs.writeText "custom-apple.xkb" (builtins.readFile ../../../sources/xkb/custom-apple-symbols.xkb);
      languages = [ "en" ]; 
    };
  };

  services.xserver.xkb.layout = "fancy_us";
  services.xserver.xkb.variant = "";
  services.xserver.xkb.options = "altgr-intl,altgr:altgr,terminate:ctrl_alt_bksp";
}