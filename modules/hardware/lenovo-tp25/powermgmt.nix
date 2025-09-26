{ config, lib, pkgs, ... }:

{
  powerManagement.enable = true;
  services.undervolt = {
    enable = true;
    coreOffset = -75;
    analogioOffset = -75;
    gpuOffset = -70;
    uncoreOffset = -75;
  };
}