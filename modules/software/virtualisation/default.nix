{ config, lib, pkgs, wantsVMwareHost, wantsVirtualbox, wantsLibvirt, wantsDocker, ... }:

{
  virtualisation.vmware.host.enable = wantsVMwareHost;

  virtualisation.virtualbox.host = {
    enable = wantsVirtualbox;
    enableExtensionPack = true;
  };

  virtualisation.libvirtd.enable = wantsLibvirt;

  virtualisation.docker.enable = wantsDocker;
}