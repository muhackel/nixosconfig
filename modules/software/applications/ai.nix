{ config, lib, pkgs, ... }:
let
  managementKey = "/var/lib/cliproxyapi-secrets/management-key";
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

  services.cliproxyapi = {
    enable = true;
    package = pkgs.llm-agents.cli-proxy-api;
    settings = {
      host = "127.0.0.1";
      port = 8317;
      remote-management = {
        allow-remote = false;
        secret-key._secret = managementKey;
      };
    };
  };

  # Management-Key fürs Webinterface einmalig pro Host erzeugen, nicht im Store
  systemd.services.cliproxyapi-management-key = {
    description = "Generate CLIProxyAPI management key";
    before = [ "cliproxyapi.service" "cliproxyapi-panel.service" ];
    requiredBy = [ "cliproxyapi.service" "cliproxyapi-panel.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      if [ ! -s ${managementKey} ]; then
        install -d -m 0700 ${dirOf managementKey}
        (umask 077; ${pkgs.openssl}/bin/openssl rand -hex 24 > ${managementKey})
      fi
      (umask 077; echo "CPA_MANAGEMENT_KEY=$(cat ${managementKey})" > ${managementKey}.env)
    '';
  };

  # Webinterface ohne Key-Eingabe: setzt den Management-Key für localhost-Anfragen selbst ein
  systemd.services.cliproxyapi-panel = {
    description = "CLIProxyAPI management panel without key prompt";
    after = [ "cliproxyapi.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.caddy} run --adapter caddyfile --config ${pkgs.writeText "cliproxyapi-panel.caddyfile" ''
        {
          admin off
          auto_https off
          persist_config off
        }
        http://127.0.0.1:8318 {
          bind 127.0.0.1
          @management path /v0/management/* /v8/management/*
          request_header @management Authorization "Bearer {env.CPA_MANAGEMENT_KEY}"
          reverse_proxy 127.0.0.1:8317
        }
      ''}";
      EnvironmentFile = "${managementKey}.env";
      DynamicUser = true;
      StateDirectory = "cliproxyapi-panel";
      Environment = [ "XDG_DATA_HOME=/var/lib/cliproxyapi-panel" "XDG_CONFIG_HOME=/var/lib/cliproxyapi-panel" ];
      Restart = "on-failure";
    };
  };
}
