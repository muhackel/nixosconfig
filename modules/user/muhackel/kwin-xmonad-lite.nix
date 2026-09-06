# Home-Manager-Modul: kwin-xmonad-lite auf Hosts einschalten, die das
# Feature-Flag gesetzt haben.
#
# Das Projektmodul selbst kommt über `home-manager.sharedModules` aus
# `lib/default.nix` und bleibt ohne dieses `enable` wirkungslos. Gelesen wird
# `osConfig.local.features` — dasselbe Muster wie `home.stateVersion` in
# `home.nix`.
{ config, lib, pkgs, osConfig, ... }:

let
  features = osConfig.local.features;
in
lib.mkIf (features.plasma6 && features.kwinXmonadLite) {
  programs.kwin-xmonad-lite = {
    enable = true;
    # `settings` bleibt bei den Vorgabewerten des Projektmoduls; es schreibt
    # ohnehin immer alle sechs Schlüssel nach [Script-kwin-xmonad-lite].
  };

  # ── Konfliktauflösung der KDE-Tastenkürzel ──
  #
  # Sie steht ausschließlich hier und nicht im Projektmodul
  # (`relocateKdeShortcuts` bleibt aus): die Shortcut-Politik gehört in die
  # Host-Konfiguration und soll nur dort gelten, wo der Controller läuft.
  #
  # Livebefund vom 2026-09-06 auf SPIELKISTE: beim Registrieren der zwölf
  # `xml-*`-Aktionen standen `Lock Session=Screensaver\tMeta+L` und
  # `Edit Tiles=Meta+T` bereits in `kglobalshortcutsrc`. In **beiden** Fällen
  # gewann der vorhandene Eintrag — `Meta+L` sperrte die Sitzung, `Meta+T`
  # öffnete den Kachel-Editor. Ursache: `registerShortcut` ruft
  # `KGlobalAccel::setShortcut` ohne `NoAutoloading` und liefert trotzdem
  # immer `true`, meldet die Kollision also nicht. Die zehn konfliktfreien
  # Tasten funktionierten im selben Lauf alle.
  #
  # Das Umlegen ist damit keine Kosmetik, sondern Voraussetzung dafür, dass
  # `xml-expand` (Meta+L) und `xml-sink` (Meta+T) ihre Taste überhaupt
  # bekommen. Sitzung sperren bleibt über `Ctrl+Alt+L` erreichbar.
  programs.plasma.shortcuts.ksmserver."Lock Session" = [ "Screensaver" "Ctrl+Alt+L" ];
  programs.plasma.shortcuts.kwin."Edit Tiles" = [ ];

  # ── Web-Suchkürzel ──
  #
  # Steht hier, weil es ohne diesen Host-Zweig gar nicht anfiele: das
  # Projektmodul setzt `programs.plasma.enable`, und damit wird auch
  # plasma-managers Modul `search-plugins/web-search-keywords.nix` wirksam.
  # Dessen `config`-Block hängt an keinem `mkIf` — es schreibt seine fünf
  # Schlüssel nach `kuriikwsfilterrc [General]`, sobald plasma-manager
  # überhaupt läuft, und ein `null` heißt dort **Schlüssel löschen**
  # (`script/write_config.py`, `remove_value`).
  #
  # Ohne die folgenden Zeilen verschwände also das eingestellte
  # Standard-Suchkürzel beim ersten `switch`. Statt den fremden Schreibvorgang
  # mit `persistent` zu blockieren, wird der Zustand hier bewusst festgelegt.
  programs.plasma.searchPlugins.webSearchKeywords = {
    default = "duckduckgo";
    preferred = [
      "duckduckgo"
      "wikipedia"
      "archwiki"
      "archpkg"
      "nixpkgs"
      "github"
      "rfc"
    ];
  };
}
