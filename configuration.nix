{ config, lib, pkgs, ... }:

let
  usedOverlays = [
    # (import overlays/go-pin)              # Workaround: winboat Go 1.25 Pin (Go#75734 gefixt in 1.26)
    # (import overlays/claude-code-pin)     # Pin: npm-Version
    # (import overlays/sdl3-test-timeout)   # Workaround: SDL3 CTest-Timeouts in Sandbox
    (import overlays/spamassassin-ssl-test) # Workaround: spamd_ssl.t SSL-Test-Failure
    (import overlays/openldap-flaky-test)   # Workaround: test017-syncreplication-refresh flaky
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
  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
  environment.variables.NIXPKGS_ALLOW_BROKEN = "1";
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
  # Pipewire/Wireplumber brauchen rtkit-daemon für Realtime-Scheduling.
  security.rtkit.enable = true;
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

