{ config, lib, pkgs, ... }:
let
  
in
{
  time.timeZone = "Europe/Berlin";

  i18n = {
    defaultLocale = "en_US.UTF-8"; # Die Sprache der Menüs
    extraLocales = [ "all" ];
    supportedLocales = [ "all" ];
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_COLLATE = "de_DE.UTF-8";    # Sortierreihenfolge
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8"; # Metrisches System (Meter, KG)
      LC_MONETARY = "de_DE.UTF-8";    # Währung (Euro)
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";     # Zahlenformate (Komma statt Punkt)
      LC_PAPER = "de_DE.UTF-8";       # DIN A4 statt Letter
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";        # Datum (TT.MM.JJJJ) und 24h-Zeit
    };
  };

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };
}