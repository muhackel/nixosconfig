# Home-Manager-Modul: plasma-manager einschalten und darauf aufbauend
# kwin-xmonad-lite auf Hosts, die das jeweilige Feature-Flag gesetzt haben.
#
# Die Datei heißt weiterhin nach dem Controller, weil sie allein seinetwegen
# entstanden ist; seit der Trennung der Flags besitzt sie zusätzlich die
# Aktivierung von plasma-manager.
#
# **Warum zwei Flags.** `programs.plasma.enable` kam vorher aus dem
# Projektmodul und hing damit am Controller-Flag. Fiel `kwinXmonadLite`, ging
# plasma-manager mit aus — und weil dessen gesamter Schreibvorgang an einem
# `home.activation`-Skript unter `mkIf plasmaCfg.enable` hängt, wurde gar
# nichts mehr geschrieben. Mit `overrideConfig = false` blieb der alte Stand
# einfach stehen (`Lock Session=Ctrl+Alt+L`, `Edit Tiles=none`), es gab also
# keinen verwalteten Aus-Zustand. `plasmaManager` läuft deshalb unabhängig vom
# Controller: nur so lässt sich das Abschalten des Controllers überhaupt
# deklarativ vollziehen.
#
# Das Projektmodul selbst kommt über `home-manager.sharedModules` aus
# `lib/default.nix` und bleibt ohne dieses `enable` wirkungslos. Gelesen wird
# `osConfig.local.features` — dasselbe Muster wie `home.stateVersion` in
# `home.nix`.
{ lib, osConfig, ... }:

let
  features = osConfig.local.features;
in
lib.mkMerge [

  # ── plasma-manager (unabhängig vom Controller) ──
  (lib.mkIf (features.plasma6 && features.plasmaManager) {
    programs.plasma.enable = true;

    # ── Web-Suchkürzel ──
    #
    # Steht hier, weil es ohne plasma-manager gar nicht anfiele: mit
    # `programs.plasma.enable` wird auch dessen Modul
    # `search-plugins/web-search-keywords.nix` wirksam. Dessen `config`-Block
    # hängt an keinem `mkIf` — es schreibt seine fünf Schlüssel nach
    # `kuriikwsfilterrc [General]`, sobald plasma-manager überhaupt läuft, und
    # ein `null` heißt dort **Schlüssel löschen** (`script/write_config.py`,
    # `remove_value`).
    #
    # Ohne die folgenden Zeilen verschwände also das eingestellte
    # Standard-Suchkürzel beim ersten `switch`. Statt den fremden
    # Schreibvorgang mit `persistent` zu blockieren, wird der Zustand hier
    # bewusst festgelegt. Der Block gehört an das plasma-manager-Flag, nicht
    # an den Controller.
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
  })

  # ── Controller an ──
  (lib.mkIf (features.plasma6 && features.plasmaManager && features.kwinXmonadLite) {
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
  })

  # ── Controller aus, plasma-manager an ──
  (lib.mkIf (features.plasma6 && features.plasmaManager && !features.kwinXmonadLite) {
    # Die beiden umgelegten Kürzel wieder auf die KDE-Vorgabe stellen. Ohne
    # diesen Zweig gäbe es kein Zurück: plasma-manager läuft mit
    # `overrideConfig = false` und löscht nicht mehr deklarierte Schlüssel
    # nicht, ein weggefallenes `Lock Session` bliebe also auf `Ctrl+Alt+L`
    # stehen und `Meta+L` sperrte nie wieder.
    #
    # Die Werte sind **nicht geraten**: sie sind der am 2026-09-06 auf
    # SPIELKISTE aus `kglobalshortcutsrc` gelesene Ist-Stand **vor** der
    # Registrierung der `xml-*`-Aktionen — `Lock Session` mit den beiden
    # Belegungen `Screensaver` und `Meta+L`, `Edit Tiles` mit `Meta+T`.
    programs.plasma.shortcuts.ksmserver."Lock Session" = [ "Screensaver" "Meta+L" ];
    programs.plasma.shortcuts.kwin."Edit Tiles" = [ "Meta+T" ];
  })

]
