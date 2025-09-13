{ config, lib, pkgs, wantsWayland, ... }:  # wantsWayland als Parameter hinzufügen
let
  waylandpkgs = with pkgs; [
    kdePackages.yakuake
    kdePackages.filelight
    kdePackages.partitionmanager
    kdePackages.ksystemlog
    kdePackages.krdc
    # BROKEN 
    #kdePackages.umbrello
    kdePackages.marble
  ];
in
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.desktopManager.plasma6 = {
    enable = true;
  };
  environment.systemPackages = lib.optionals wantsWayland waylandpkgs;
}