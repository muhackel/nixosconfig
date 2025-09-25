{ config, lib, pkgs, ... }:

{
  hardware.nfc-nci.enable = true;
  services.pcscd.enable = true;
}