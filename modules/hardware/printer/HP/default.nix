{ config, lib, pkgs, ... }:
let

in
{
  services.printing.drivers = [ pkgs.hplip ];
}