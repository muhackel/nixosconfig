{ config, lib, pkgs, wantsWayland, wantsPlasma6, ... }:  # wantsWayland als Parameter hinzufügen
let
  plasmapkgs = with pkgs; [
    kdePackages.yakuake
    kdePackages.filelight
    kdePackages.partitionmanager
    kdePackages.ksystemlog
    kdePackages.krdc
    # BROKEN 
    #kdePackages.umbrello
    kdePackages.marble
    kdePackages.krohnkite
  ];
in
{
  services.displayManager.sddm = {
    enable = wantsWayland;
    wayland.enable = true;
  };

  services.desktopManager.plasma6 = {
    enable = wantsPlasma6;
  };
  environment.systemPackages = lib.optionals wantsPlasma6 plasmapkgs;
}