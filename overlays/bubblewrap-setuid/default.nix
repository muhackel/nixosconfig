# Workaround: bubblewrap mit -Dsupport_setuid=true bauen
#
# Seit bubblewrap 0.11.2 (April 2026, CVE-2026-41163) wird das Paket per
# default OHNE Support fuer setuid-Mode gebaut. Wird das Binary trotzdem
# als setuid gestartet, bricht es ab mit:
#   "setuid use of bubblewrap is not supported in this build"
#
# Trigger im Repo: programs.gamescope.capSysNice = true in
# modules/software/applications/games.nix laesst das nixpkgs Steam-Modul
# einen setuid-Wrapper fuer bwrap installieren (security.wrappers.bwrap,
# Kommentar dort: "needed or steam fails") -> Crash beim Steam-Start.
#
# Fallback (falls upstream den setuid-Pfad komplett entfernt und dieses
# Overlay nicht mehr baut):
#   in modules/software/applications/games.nix: capSysNice = false;
#   gamemode mit enableRenice=true uebernimmt dann das Renicing.
#
# Entfernen wenn:
#   - nixpkgs den setuid-Build wieder als Default anbietet, ODER
#   - das Steam-Modul nicht mehr auf setuid-bwrap angewiesen ist, ODER
#   - der Build mit -Dsupport_setuid=true upstream nicht mehr unterstuetzt wird
final: prev: {
  bubblewrap = prev.bubblewrap.overrideAttrs (oldAttrs: {
    mesonFlags = (oldAttrs.mesonFlags or [ ]) ++ [
      (prev.lib.mesonBool "support_setuid" true)
    ];
  });
}
