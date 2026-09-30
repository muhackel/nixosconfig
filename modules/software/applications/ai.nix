{ config, lib, pkgs, ... }:
let
  # t3code 0.0.44 liefert node-pty (1.2.0-beta.15) nur noch als Upstream-Prebuild ohne
  # RPATH aus; bis 0.0.42 (node-pty 1.1.0) baute Nix es selbst und patchte den RPATH.
  # Electron ist – anders als nodejs – nicht gegen libstdc++ gelinkt (statisches libc++),
  # deshalb scheitert dlopen(prebuilds/linux-x64/pty.node) im Desktop-Backend-Child mit
  # "libstdc++.so.6: cannot open shared object file". Der Child stirbt mit code=1 und das
  # Fenster erscheint nie. Entfernen, sobald llm-agents.nix das Prebuild patcht.
  t3codeDesktop = pkgs.symlinkJoin {
    name = "t3code-desktop-libstdcxx";
    paths = [ pkgs.llm-agents.t3code-desktop ];
    nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
    postBuild = ''
      rm $out/bin/t3code-desktop
      makeWrapper ${pkgs.llm-agents.t3code-desktop}/bin/t3code-desktop $out/bin/t3code-desktop \
        --inherit-argv0 \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}
    '';
  };
  aipkgs = with pkgs; [
    llm-agents.opencode
    llm-agents.claude-code
    llm-agents.ccusage
    llm-agents.codex
    codexbar-plasma
    llm-agents.t3code # t3
    t3codeDesktop # llm-agents.t3code-desktop plus libstdc++ für node-pty
    defuddle
    obsidian # auch in apppkgs
    bun # JavaScript runtime depency for many claude-code 3rd party tools ... examples: bunx ccstatusline@lastest bunx get-shit-done-cc --claude --local
    (callPackage ../../../packages/mcpvault {})
    (callPackage ../../../packages/better-sqlite3 {})
  ];
  # Werkzeuge, die Agents direkt auf der Shell aufrufen (Auswertung der Claude-/Codex-Transkripte 2026-09-14)
  aisupportpkgs = with pkgs; [
    # meistgeladen per nix shell / nix-shell -p
    sqlite
    jq
    sshpass
    python3
    shellcheck
    # Suchen und Inspizieren
    ripgrep
    fd
    file
    tree
    yq-go
    # Netz und Git
    curl
    wget
    git
    git-lfs
    gh
    glab
    rsync
    # Runtimes und Formatierung
    nodejs
    uv
    shfmt
    nixfmt
    # Dokumente und Diagramme
    poppler-utils
    # mermaid-cli zu viel abhängigkeiten
    plantuml
    pandoc
    tesseract
    # Sonstiges
    tmux
    dpkg
    unzip
  ];
in
lib.mkIf config.local.features.ai
{
  environment.systemPackages = aipkgs ++ aisupportpkgs;
}
