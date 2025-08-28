{ config, pkgs, lib, ... }:

# Leeres NixOS-Modul als Platzhalter für einen Displaymanager
let
in
{
  imports = [ ./wayland.nix ./xserver.nix ];
}