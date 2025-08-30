{ config, lib, pkgs, ... }:
let
  
in
{
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "de_DE.UTF-8/UTF-8"
    "de_DE/ISO-8859-1"
    "de_DE@euro/ISO-8859-15"
  ];
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
}