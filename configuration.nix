# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  usedOverlays = [ 
    (import ./overlays/osm-gps-map) 
    (import ./overlays/ciscoPacketTracer8)
    (import ./overlays/proxmark3)
  ];
  usedPermittedInsecurePackages = [
      "libxml2-2.13.8"
      "libsoup-2.74.3"
      "qtwebengine-5.15.19"
      "ventoy-1.1.07"
    ];
in
{
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    permittedInsecurePackages = usedPermittedInsecurePackages;
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
  #system.stateVersion = config.system.stateVersion;
}

