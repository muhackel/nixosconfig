# Workaround fuer winboat Go 1.26 Cross-Compilation Bug (upstream Go#75734)
# _cgo_stub_export symbol not defined bei mingw32 Cross-Compilation
# Electron-41-Fix ist upstream angekommen und wurde entfernt.
# Kann komplett deaktiviert werden sobald auch der Go-Fix in nixpkgs ist.
final: prev:
let
  mingwW64' = prev.pkgsCross.mingwW64.extend (mfinal: mprev: {
    go = mprev.go_1_25;
    buildGoModule = mprev.buildGo125Module;
  });
in {
  winboat = prev.winboat.override {
    pkgsCross = prev.pkgsCross // { mingwW64 = mingwW64'; };
  };
}
