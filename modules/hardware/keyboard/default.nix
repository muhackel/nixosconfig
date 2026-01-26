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
  ### WICHTIG!!! Unter KDE Plasma muss man in den Systemsettings unter Keyboard -> Keyboard oben rechts auf Keybindings gehen und den Key to Choose the 3rd Level auf right_Alt setzen, sonst funktioniert AltGr nicht! ###
}