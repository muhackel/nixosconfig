# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  usedOverlays = [ 
    (import ./overlays/osm-gps-map) 
    (import ./overlays/ciscoPacketTracer8)
    #(import ./overlays/v4l2loopback-fix.nix)
    ];
  usedFonts = with pkgs; [
      nerd-fonts.hack
      xkcd-font
    ];
in
{
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    permittedInsecurePackages = [
      "libxml2-2.13.8"
      "libsoup-2.74.3"
      "qtwebengine-5.15.19"
    ];
  };
  nixpkgs.overlays = usedOverlays;
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    # max-jobs = 4; #seems not to work ...
  };
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 30d";
  };
  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  programs.zsh.enable = true;

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

 fonts = {
    packages = usedFonts;
  };

  system.stateVersion = "25.11"; # Did you read the comment?
}

