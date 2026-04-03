# Pin claude-code auf aktuelle npm-Version
# nixpkgs hat eine Version die von npm unpublished wurde (404)
# Kann entfernt werden sobald nixpkgs eine aktuelle Version hat.
final: prev: {
  claude-code = prev.buildNpmPackage (finalAttrs: {
    pname = "claude-code";
    version = "2.1.91";

    src = prev.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${finalAttrs.version}.tgz";
      hash = "sha256-u7jdM6hTYN05ZLPz630Yj7gI0PeCSArg4O6ItQRAMy4=";
    };

    npmDepsHash = "sha256-0ppKP+XMgTzVVZtL7GDsOjgvSPUDrUa7SoG048RLaNg=";

    strictDeps = true;

    postPatch = ''
      cp ${./package-lock.json} package-lock.json
      substituteInPlace cli.js \
        --replace-fail '#!/bin/sh' '#!/usr/bin/env sh'
    '';

    dontNpmBuild = true;

    env.AUTHORIZED = "1";

    postInstall = ''
      wrapProgram $out/bin/claude \
        --set DISABLE_AUTOUPDATER 1 \
        --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
        --set DISABLE_INSTALLATION_CHECKS 1 \
        --unset DEV \
        --prefix PATH : ${
          prev.lib.makeBinPath [
            prev.procps
            prev.bubblewrap
            prev.socat
          ]
        }
    '';

    meta = {
      description = "Agentic coding tool";
      homepage = "https://github.com/anthropics/claude-code";
      license = prev.lib.licenses.unfree;
      mainProgram = "claude";
    };
  });
}
