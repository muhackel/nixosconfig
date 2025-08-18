{ config, lib, pkgs, ... }:

{
  virtualisation.vmware.host.enable = false;

  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };

  virtualisation.libvirtd.enable = true;

  virtualisation.docker.enable = true;
}