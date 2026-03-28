# Workaround fuer zwei winboat-Bugs:
# 1) Go 1.26 Cross-Compilation Bug (upstream Go#75734)
#    _cgo_stub_export symbol not defined bei mingw32 Cross-Compilation
# 2) Electron 41 node-abi Inkompatibilitaet
#    node-abi kennt Electron 41 noch nicht, Pin auf 40
# Kann deaktiviert werden sobald nixpkgs beide Fixes enthaelt.
final: prev:
let
  mingwW64' = prev.pkgsCross.mingwW64.extend (mfinal: mprev: {
    go = mprev.go_1_25;
    buildGoModule = mprev.buildGo125Module;
  });
in {
  winboat = prev.winboat.override {
    electron = prev.electron_40;
    pkgsCross = prev.pkgsCross // { mingwW64 = mingwW64'; };
  };
}
