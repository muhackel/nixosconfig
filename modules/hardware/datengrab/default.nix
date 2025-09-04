{ config, lib, pkgs, ... }:
let

in
{
  imports = [
    ./hardware-configuration.nix
  ];
}