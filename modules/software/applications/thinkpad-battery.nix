{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.local.features.thinkpadBattery {
    # services.tlp bleibt bewusst aus: power-profiles-daemon behält die
    # Power-Verwaltung, tlp wird nur als Werkzeug für die Batteriepflege-Kommandos
    # (setcharge, fullcharge, recalibrate) installiert.
    environment.systemPackages = [
      pkgs.tlp
      (pkgs.callPackage ../../../packages/thinkpad-battery { })
    ];

    # Keine Kosmetik: ohne /etc/tlp.conf sourct tlp die zusammengeführte
    # Runtime-Config nicht (read_config in share/tlp/tlp-func-base überspringt
    # bei rc=5 das `. "$_conf_tmp"`) — dann fehlen die Vendor-Presets, auf denen
    # fullcharge und recalibrate beruhen.
    environment.etc."tlp.conf".text = ''
      # TLP läuft auf diesem System nicht als Dienst (power-profiles-daemon
      # übernimmt die Power-Verwaltung). Diese Datei existiert nur, damit die
      # Batteriepflege-Kommandos (tlp setcharge/fullcharge/recalibrate) ihre
      # Defaults und Vendor-Presets laden.
      #
      # TLP_ENABLE=1 ist dafür zwingend: check_tlp_enabled (tlp-func-base) bricht
      # sonst JEDES Kommando mit "TLP power save is disabled" ab, nicht nur den
      # Dienststart. Es schaltet hier nichts automatisch scharf — ohne
      # services.tlp.enable existieren weder tlp.service/tlp-sleep.service noch
      # die udev-Regeln, die tlp start auslösen würden.
      TLP_ENABLE=1
    '';
  };
}
