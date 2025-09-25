{ config, lib, pkgs, ... }:

{
  # Configuration of the Boot Loader
  boot.loader = {
    timeout = null;
    systemd-boot = {
      enable = true;
      memtest86.enable = true;
      netbootxyz.enable = true;
    };
    efi.canTouchEfiVariables = true;
  }; 
}