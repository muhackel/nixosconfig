{ config, lib, ... }:
# Synchronisiert ESP/Bootloader-Einträge nach automatischem nix-gc.
#
# Problem: `nix-collect-garbage -d` räumt das System-Profil, fasst aber die ESP
# nicht an — verwaiste Bootmenü-Einträge bleiben bis zum nächsten switch/boot.
#
# Lösung: nach erfolgreichem nix-gc.service den offiziellen installBootLoader-Schritt
# des laufenden Systems erneut ausführen. Bootloader-agnostisch:
#   - Lanzaboote (SPIELKISTE): lzbt install … signiert die UKIs neu und räumt die ESP.
#   - systemd-boot (BFG9000):  systemd-boot-builder erzeugt die ESP-Einträge neu.
let
  cfg = config.local.features;
in
lib.mkIf (cfg.bootloaderResyncAfterGc && config.nix.gc.automatic) {
  systemd.services.bootloader-resync = {
    description = "Bootloader/ESP nach nix-gc neu synchronisieren";
    serviceConfig = {
      Type = "oneshot";
      # /run/current-system: das laufende, GC-geschützte System.
      ExecStart = ''${config.system.build.installBootLoader} /run/current-system'';
    };
  };

  # An den GC-Service hängen: läuft nur nach dessen erfolgreichem Abschluss.
  # --no-block: GC-Service wartet nicht auf den Resync (kein Deadlock).
  systemd.services.nix-gc.serviceConfig.ExecStartPost =
    "${config.systemd.package}/bin/systemctl --no-block start bootloader-resync.service";
}
