{ config, lib, pkgs, ... }:

{
  hardware.nfc-nci.enable = true;
  services.pcscd.enable = true;

  # nxp-pn5xx installiert per eigenem Makefile-Target ohne modules_install, dadurch fehlt
  # die kmodigest-Signatur (pn5xx_i2c.ko.cer) und der Modul-Aggregator bricht ab
  # (seit NixOS/nixpkgs#571181). Entfernen, sobald NixOS/nixpkgs#578004 gemergt ist.
  boot.kernelPackages = pkgs.linuxPackages.extend (kfinal: kprev: {
    nxp-pn5xx = kprev.nxp-pn5xx.overrideAttrs (old: {
      installPhase = ''
        runHook preInstall
        make -C ${kprev.kernel.dev}/lib/modules/${kprev.kernel.modDirVersion}/build \
          M="$PWD" \
          ${lib.escapeShellArgs kprev.kernelModuleMakeFlags} \
          INSTALL_MOD_PATH="$out" \
          INSTALL_MOD_DIR=kernel/drivers/nfc \
          DEPMOD=true \
          modules_install
        runHook postInstall
      '';
    });
  });
}
