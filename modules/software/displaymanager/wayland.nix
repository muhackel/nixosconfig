{ config, lib, pkgs, ... }:
let
  waylandpkgs = with pkgs; [
    kdePackages.yakuake
    kdePackages.filelight
    kdePackages.partitionmanager
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
  environment.systemPackages = waylandpkgs;
}