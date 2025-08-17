{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    
  ];
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
}