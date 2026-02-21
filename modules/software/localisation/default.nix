{ config, lib, pkgs, ... }:
let
  
in
{
  time.timeZone = "Europe/Berlin";

  i18n = {
    defaultLocale = "en_US.UTF-8"; # Die Sprache der Menüs
    extraLocales = [
      "de_DE.UTF-8/UTF-8"
      "de_AT.UTF-8/UTF-8"
      "de_CH.UTF-8/UTF-8"
      "de_LU.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
      "en_AU.UTF-8/UTF-8"
      "en_CA.UTF-8/UTF-8"
      "en_NZ.UTF-8/UTF-8"
      "en_IE.UTF-8/UTF-8"
      "en_ZA.UTF-8/UTF-8"
    ];
    supportedLocales = [
      "de_DE.UTF-8/UTF-8"
      "de_AT.UTF-8/UTF-8"
      "de_CH.UTF-8/UTF-8"
      "de_LU.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
      "en_AU.UTF-8/UTF-8"
      "en_CA.UTF-8/UTF-8"
      "en_NZ.UTF-8/UTF-8"
      "en_IE.UTF-8/UTF-8"
      "en_ZA.UTF-8/UTF-8"
    ];
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