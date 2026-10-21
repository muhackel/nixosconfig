# Home-Manager-Modul: Steam-Input-Blacklist für Controller, die Steam nicht
# anfassen soll (`controller_blacklist` in `config.vdf`).
#
# Warum ein Aktivierungsskript und kein `home.file`: Steam schreibt
# `config.vdf` bei jedem Beenden komplett neu, ein Symlink in den Store würde
# dabei ersetzt. Das Skript setzt oder ersetzt deshalb nur die eine Zeile und
# lässt den Rest der Datei in Ruhe. Format und Position (eine Ebene unter
# `InstallConfigStore`, ein Tab davor, zwei dahinter, VID/PID hex ohne `0x`)
# entsprechen dem, was Steam selbst schreibt — am 2026-10-21 auf SPIELKISTE
# aus der von Steam erzeugten Datei gelesen.
#
# Grenzen: Läuft Steam während der Aktivierung, wird nur gewarnt; der Eintrag
# kommt beim nächsten Lauf ohne Steam. Ändert Steam die Formatierung der
# Zeile, erkennt das Skript sie nicht mehr und hängt eine zweite an.
{ lib, pkgs, osConfig, ... }:

let
  features = osConfig.local.features;
  controllerBlacklist = [
    "054c/05c4" # Sony DualShock 4 (v1)
  ];
  blacklistValue =
    assert lib.assertMsg
      (lib.all (id: builtins.match "[0-9a-f]{4}/[0-9a-f]{4}" id != null) controllerBlacklist)
      "controllerBlacklist: Einträge müssen die Form vvvv/pppp (hex, klein) haben";
    lib.concatStringsSep "," controllerBlacklist;
in
lib.mkIf features.games {
  home.activation.steamControllerBlacklist = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    steamConfig="$HOME/.local/share/Steam/config/config.vdf"
    if [[ ! -f $steamConfig ]]; then
      verboseEcho "Steam: $steamConfig fehlt, controller_blacklist übersprungen"
    elif ${pkgs.procps}/bin/pgrep -x steam > /dev/null; then
      warnEcho "Steam läuft, controller_blacklist nicht gesetzt. Steam beenden und erneut aktivieren."
    else
      current=$(sed -n 's/^\t"controller_blacklist"\t\t"\(.*\)"$/\1/p' "$steamConfig")
      if [[ $current == "${blacklistValue}" ]]; then
        verboseEcho "Steam: controller_blacklist aktuell"
      elif [[ -n $current ]]; then
        warnEcho "Steam: controller_blacklist \"$current\" wird durch \"${blacklistValue}\" ersetzt"
        run sed -i 's|^\t"controller_blacklist"\t\t".*"$|\t"controller_blacklist"\t\t"${blacklistValue}"|' "$steamConfig"
      elif [[ $(tail -n 1 "$steamConfig") == "}" ]]; then
        run sed -i '$i\\t"controller_blacklist"\t\t"${blacklistValue}"' "$steamConfig"
      else
        warnEcho "Steam: $steamConfig endet nicht mit }, controller_blacklist übersprungen"
      fi
    fi
  '';
}
