{ config, lib, pkgs, ... }:
let

in
{
  services.printing.enable = true;
  # CUPS braucht colord für ICC-Profile, sonst DBus-Errors pro Boot.
  services.colord.enable = true;
}