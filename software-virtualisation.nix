{ config, lib, pkgs, ... }:

{
  virtualisation = {
    vmware.host = {
      enable = false;
    };
    virtualbox = {
      host = {
        enable = true;
        enableExtensionPack = true;
      };
    };
    libvirtd = {
      enable = true;
    };
    docker = {
      enable = true;
    };
  };
}