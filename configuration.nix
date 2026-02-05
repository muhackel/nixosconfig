{ config, lib, pkgs, ... }:

let
  usedOverlays = [ 
    (import overlays/osm-gps-map) 
    (import overlays/proxmark3)
  ];
  usedPermittedInsecurePackages = [
      "libxml2-2.13.8"
      "libsoup-2.74.3"
      "qtwebengine-5.15.19"
      "ventoy-1.1.10"
      "dotnet-sdk-6.0.428"
      "dotnet-runtime-6.0.36"
    ];
in
{
  hardware.enableAllFirmware = true;
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    permittedInsecurePackages = usedPermittedInsecurePackages;
  };
  nixpkgs.overlays = usedOverlays;
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://numtide.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    ];
    trusted-users = [ "root" "muhackel" ];
  };
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 30d";
  };
  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  programs.zsh.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;
  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };
  #system.activationScripts.diff = {
  #  supportsDryActivation = true;
  #  text = ''
  #    export PATH="${pkgs.nix}/bin:$PATH"
  #    if [ -e /run/current-system ]; then
  #      echo "--- PAKET-ÄNDERUNGEN (nvd) ---"
  #      ${pkgs.nvd}/bin/nvd diff /run/current-system "$systemConfig"
  #      echo "------------------------------"
  #    else
  #      echo "Kein Referenzsystem (/run/current-system) gefunden."
  #    fi
  #  '';
  #};
  #system.stateVersion = config.system.stateVersion;
}

