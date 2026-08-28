{ config, lib, pkgs, ... }:
let
  cfg = config.local.features;
  libvirtpkgs = with pkgs; [
      passt
  ];
  winboatpkgs = with pkgs; [
    winboat
  ];
in
{
  imports = [
    ./kmt-vpn.nix
  ];

  local.userExtraGroups =
    lib.optionals cfg.docker [ "docker" ]
    ++ lib.optionals cfg.libvirt [ "libvirtd" ]
    ++ lib.optionals cfg.virtualbox [ "vboxusers" ];

  virtualisation.vmware.host.enable = cfg.vmwareHost;

  virtualisation.virtualbox.host = {
    enable = cfg.virtualbox;
    enableExtensionPack = true;
  };

  virtualisation.libvirtd.enable = cfg.libvirt;

  virtualisation.docker.enable = cfg.docker;
  environment.systemPackages = lib.optionals cfg.libvirt libvirtpkgs ++ lib.optionals cfg.winboat winboatpkgs;
}
