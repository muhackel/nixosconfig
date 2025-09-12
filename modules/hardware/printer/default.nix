{ config, lib, pkgs, ... }:
let

in
{
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];
}