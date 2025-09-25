{ config, lib, pkgs, ... }:

{
  powerManagement.enable = true;
  services.undervolt = {
    enable = true;
    coreOffset = -75;
    analogioOffset = -75;
    gpuOffset = -75;
    uncoreOffset = -75;
  };
}