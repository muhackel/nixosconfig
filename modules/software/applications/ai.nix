{ config, lib, pkgs, ... }:
let
  # Upstream legt alle Provider-CLIs in den PATH-Wrapper, grok und cursor-agent werden nicht gebraucht
  t3code = pkgs.llm-agents.t3code.override {
    providerPackages = with pkgs.llm-agents; [ codex claude-code opencode ];
  };
  # Electron muss aus dem System-nixpkgs kommen: das Electron aus llm-agents hängt an
  # dessen älterer glibc und kann das System-Mesa nicht laden (GLIBC_2.43 fehlt).
  # Ohne Mesa greift glvnd auf Optimus-Hosts zur Nvidia-EGL, KWin auf Intel kann deren
  # dmabufs nicht importieren und t3code-desktop stirbt mit einem Wayland-Protokollfehler.
  # Nur der Wrapper wird ersetzt, t3code.unwrapped bleibt unverändert aus dem Cache.
  t3codeElectron = pkgs.electron_44;
  t3codeDesktop = pkgs.runCommand "t3code-desktop-${t3code.version}" {
    nativeBuildInputs = with pkgs; [ makeBinaryWrapper jq ];
  } ''
    upstream=$(jq -r '.dependencies.electron' ${t3code.src}/apps/desktop/package.json)
    upstream=''${upstream#^}
    if (( ''${upstream%%.*} > ${lib.versions.major t3codeElectron.version} )); then
      echo "error: t3code erwartet Electron $upstream, System-nixpkgs liefert ${t3codeElectron.version}" >&2
      exit 1
    fi
    mkdir -p "$out/bin"
    makeWrapper ${lib.getExe t3codeElectron} "$out/bin/t3code-desktop" \
      --add-flags ${t3code.unwrapped.desktop}/libexec/t3code/apps/desktop \
      --prefix PATH : ${lib.escapeShellArg (lib.makeBinPath t3code.providerPackages)} \
      --inherit-argv0
    ln -s ${t3code.unwrapped.desktop}/share "$out/share"
  '';
  aipkgs = with pkgs; [
    llm-agents.opencode
    llm-agents.claude-code
    llm-agents.ccusage
    llm-agents.codex
    codexbar-plasma
    t3code # t3
    t3codeDesktop # statt t3code.desktop, siehe oben
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
