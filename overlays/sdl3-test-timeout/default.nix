# Workaround: SDL3 CTest-Timeouts x3 fuer Nix-Sandbox
# testrwlock (und aehnliche Threading-Tests) laufen bei parallelen Builds
# in der Sandbox in Timeouts. Kein echter SDL3-Bug.
# Kann entfernt werden wenn nixpkgs die Timeouts selbst anpasst.
final: prev: {
  sdl3 = prev.sdl3.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ prev.perl ];
    postPatch = (old.postPatch or "") + ''
      # Alle NONINTERACTIVE_TIMEOUT-Werte in test/ verdreifachen
      find test -name 'CMakeLists.txt' -exec \
        perl -pi -e 's/NONINTERACTIVE_TIMEOUT\s+(\d+)/"NONINTERACTIVE_TIMEOUT " . ($1 * 3)/ge' {} +
    '';
  });
}
