# opencode ohne Bundle-Splitting bauen.
#
# nixpkgs baut opencode mit bun 1.4.2, obwohl upstream bun ^1.3.14 verlangt —
# die Versionsprüfung patcht nixpkgs bewusst zur bloßen Warnung herunter. Der
# Bundler von bun 1.4.x erzeugt zusammen mit `splitting: true` (in
# packages/opencode/script/build.ts) eine kaputte Chunk-Initialisierungsreihenfolge:
# im Layer-Graph (packages/core/src/effect/layer-node.ts) ist eine Dependency zur
# Auswertungszeit `undefined`. Jeder Prompt scheitert dadurch schon beim Aufbau des
# System-Prompts mit "TypeError: undefined is not an object (evaluating 'a.name')",
# nach außen sichtbar als "UnknownError: Unexpected server error".
#
# Siehe NixOS/nixpkgs#563241. Ein Versions-Bump hilft nicht, 1.18.31 enthält den
# Fix nicht.
#
# Entfernen, sobald nixpkgs den Fix übernimmt (Splitting aus oder der Upstream-PR
# anomalyco/opencode#48397) oder wieder mit bun < 1.4 baut.
final: prev: {
  opencode = prev.opencode.overrideAttrs (old: {
    postPatch = old.postPatch + ''
      substituteInPlace packages/opencode/script/build.ts \
        --replace-fail 'splitting: true,' 'splitting: false,'
    '';
  });
}
