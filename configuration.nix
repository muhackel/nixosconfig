# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let

in
{
  nixpkgs.overlays = [ 
    (import ./overlays/osm-gps-map.nix) 
    (import ./overlays/ciscoPacketTracer8/default.nix)
    #(import ./overlays/v4l2loopback-fix.nix)
    ];

  system.stateVersion = "25.11"; # Did you read the comment?
}

