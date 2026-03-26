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
  nix.settings = (import ./lib/caches.nix) // {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
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
  system.activationScripts.z_diff = {
    supportsDryActivation = true;
    text = ''
      export PATH="${pkgs.nix}/bin:$PATH"
      if [ $(cat /proc/uptime | cut -d. -f1) -ge 30 ]; then
        if [ -e /run/current-system ]; then
          echo "--- PAKET-ÄNDERUNGEN (nvd) ---"
          ${pkgs.nvd}/bin/nvd diff /run/current-system "$systemConfig"
          echo "------------------------------"
        else
          echo "Kein Referenzsystem (/run/current-system) gefunden."
        fi
      else
        echo "nvd diff skipped due to uptime < 30s"
      fi
    '';
  };
  #system.stateVersion = config.system.stateVersion;
}

