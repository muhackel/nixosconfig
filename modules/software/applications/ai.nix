{ config, lib, pkgs, ... }:
let
  aipkgs = with pkgs; [
    llm-agents.opencode
    llm-agents.claude-code
    llm-agents.ccusage
    llm-agents.codex
    codexbar-plasma
    llm-agents.t3code # t3
    llm-agents.t3code-desktop
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
