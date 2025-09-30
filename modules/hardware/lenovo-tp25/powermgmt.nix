{ config, lib, pkgs, ... }:

{
  powerManagement.enable = true;
  services.undervolt = {
    enable = true;
    coreOffset = -80;
    analogioOffset = -70;
    gpuOffset = -60;
    uncoreOffset = -75;
  };
}