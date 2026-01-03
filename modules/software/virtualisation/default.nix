{ config, lib, pkgs, wantsVMwareHost, wantsVirtualbox, wantsLibvirt, wantsDocker, ... }:
let
  winboatpkgs = with pkgs; [
    winboat
  ];
in
{
  virtualisation.vmware.host.enable = wantsVMwareHost;

  virtualisation.virtualbox.host = {
    enable = wantsVirtualbox;
    enableExtensionPack = true;
  };

  virtualisation.libvirtd.enable = wantsLibvirt;

  virtualisation.docker.enable = wantsDocker;
  environment.systemPackages = lib.mkIf wantsDocker winboatpkgs;
}