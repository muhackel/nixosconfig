{ config, lib, pkgs, ... }:
let
  # Upstream legt alle Provider-CLIs in den PATH-Wrapper, grok und cursor-agent werden nicht gebraucht
  t3code = pkgs.llm-agents.t3code.override {
    providerPackages = with pkgs.llm-agents; [ codex claude-code opencode ];
  };
  aipkgs = with pkgs; [
    llm-agents.opencode
    llm-agents.claude-code
    llm-agents.ccusage
    llm-agents.codex
    codexbar-plasma
    t3code # t3
    t3code.desktop
    llm-agents.cli-proxy-api
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
