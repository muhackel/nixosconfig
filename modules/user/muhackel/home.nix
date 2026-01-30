{ config, pkgs, lib, ... }:
let

in
{
  home.stateVersion = "26.05";
  programs.mpv = {
    enable = true;
    config = {
      gpu-context = "wayland";
      hwdec = "vaapi"; # maybe vulkan in the future
    };
  };
  xdg.configFile."plasma-localerc" = {
    text = ''
      [Formats]
      LANG=en_US.UTF-8
      LC_ADDRESS=de_DE.UTF-8
      LC_MEASUREMENT=de_DE.UTF-8
      LC_MONETARY=de_DE.UTF-8
      LC_NAME=de_DE.UTF-8
      LC_NUMERIC=de_DE.UTF-8
      LC_PAPER=de_DE.UTF-8
      LC_TELEPHONE=de_DE.UTF-8
      LC_TIME=de_DE.UTF-8

      [Translations]
      LANGUAGE=en_US
    '';
    # Force sorgt dafür, dass Home Manager die Datei überschreibt, 
    # falls Plasma sie vorher selbst angelegt hat.
    force = true;
  };
  home.sessionVariables = {
    # DICPATH sagt Hunspell, wo die Wörterbücher liegen
    DICPATH = "${config.home.homeDirectory}/.nix-profile/share/hunspell:/run/current-system/sw/share/hunspell";
    
    # ASPELL_CONF setzt die Standard-Sprache für Aspell
    ASPELL_CONF = "lang de_DE";
  };

}