{ pkgs, ... }:

{
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "bevorzuge-tls-starlink" ''
        ACTION="$2"
        BEVORZUGTES_PROFIL="TLS-Starlink-mtic1"

        # Nur bei "up"-Events handeln
        [[ "$ACTION" != "up" ]] && exit 0

        # Nicht handeln wenn wir bereits auf dem bevorzugten Netz sind
        AKTIVES_PROFIL=$(${pkgs.networkmanager}/bin/nmcli -t -f NAME connection show --active | head -1)
        [[ "$AKTIVES_PROFIL" == "$BEVORZUGTES_PROFIL" ]] && exit 0

        # Kurz warten — 5GHz-AP braucht etwas nach dem Boot
        sleep 8

        # Pruefen ob TLS-Starlink-mtic1 jetzt sichtbar ist
        if ${pkgs.networkmanager}/bin/nmcli device wifi list --rescan yes 2>/dev/null \
            | grep -q "$BEVORZUGTES_PROFIL"; then
          ${pkgs.networkmanager}/bin/nmcli connection up "$BEVORZUGTES_PROFIL"
        fi
      '';
      type = "basic";
    }
  ];
}
