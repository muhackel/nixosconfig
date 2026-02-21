{ config, lib, pkgs, ... }:
let
  cfg = config.local.features;
  winboatpkgs = with pkgs; [
    winboat
  ];
in
{
  virtualisation.vmware.host.enable = cfg.vmwareHost;

  virtualisation.virtualbox.host = {
    enable = cfg.virtualbox;
    enableExtensionPack = true;
  };

  virtualisation.libvirtd.enable = cfg.libvirt;

  virtualisation.docker.enable = cfg.docker;
  environment.systemPackages = lib.mkIf cfg.winboat winboatpkgs;
}