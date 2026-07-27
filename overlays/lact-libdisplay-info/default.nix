# Workaround: lact gegen libdisplay-info 0.3.0 statt der globalen 0.4.0 bauen
#
# nixpkgs hat libdisplay-info auf 0.4.0 gehoben. lact 0.9.1 bindet den
# Rust-Crate libdisplay-info-sys 0.3.0, dessen build.rs per pkg-config hart
#   libdisplay-info >= 0.1.0, < 0.4.0
# verlangt -> Build-Panic:
#   "Requested 'libdisplay-info < 0.4.0' but version of libdisplay-info is 0.4.0"
#
# Fix: NUR lacts libdisplay-info-buildInput auf eine 0.3.0-Variante pinnen
# (lact hat libdisplay-info als direktes Funktions-Argument -> .override).
# Die GLOBALE libdisplay-info (0.4.0) bleibt unangetastet -> mesa/wlroots/
# gamescope etc. bauen weiter gegen 0.4.0.
#
# Das Buildsystem (meson/ninja) ist zwischen 0.3.0 und 0.4.0 identisch, daher
# reicht ein src-Override via overrideAttrs; keine eigenstaendige Derivation noetig.
#
# Entfernen wenn:
#   - nixpkgs lact auf einen Stand zieht, der libdisplay-info-sys >= 0.4 (bzw.
#     eine 0.4-kompatible Version) bindet, ODER
#   - nixpkgs libdisplay-info wieder auf < 0.4.0 zurueckzieht.
# Test: Overlay-Import in configuration.nix auskommentieren, nix flake check.
final: prev:
let
  libdisplay-info_0_3 = prev.libdisplay-info.overrideAttrs (_old: {
    version = "0.3.0";
    src = prev.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "emersion";
      repo = "libdisplay-info";
      rev = "0.3.0";
      hash = "sha256-nXf2KGovNKvcchlHlzKBkAOeySMJXgxMpbi5z9gLrdc=";
    };
  });
in
{
  lact = prev.lact.override { libdisplay-info = libdisplay-info_0_3; };
}
