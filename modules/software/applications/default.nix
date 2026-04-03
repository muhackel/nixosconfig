{ config, lib, pkgs, ... }:
let
  jnlpApp = pkgs.adoptopenjdk-icedtea-web;
  javawsWrapper = pkgs.writeScriptBin "javaws" ''
    #!${pkgs.bash}/bin/bash
    export JAVAWS_BIN="${jnlpApp}/bin/javaws"
    export PATH="${pkgs.jdk8}/bin:$PATH"
    export JAVA_HOME="${pkgs.jdk8}"
    echo "DEBUG: Verwende Java: $(${pkgs.jdk8}/bin/java -version 2>&1 | head -n 1)"
    exec "$JAVAWS_BIN" "$@"
  '';
  apppkgs = with pkgs; [
    # BROKEN CMAKE bambu-studio
    # BROKEN cura
    audacity
    alacritty
    camunda-modeler
    # darktable
    #eagle
    freefilesync
    inkscape
    # BROKEN CMAKE rclone-browser
    libreoffice-fresh
    librecad
    qcad
    qdirstat
    drawio
    github-desktop
    google-chrome
    kitty
    kicad
    mpv
    meld
    freecad
    gpu-viewer
    gparted
    vscode
    #mcp-nixos BROKEN
    gimp3
    yed
    virt-manager
    virt-viewer
    remmina
    #rpi-imager
    transmission_4-qt6
    obsidian
    veracrypt
    vlc
    # qutebrowser
  ];
  clipkgs = with pkgs; [
    alsa-utils
    aspell
    aspellDicts.de
    aspellDicts.en
    hunspell
    hunspellDicts.de_DE
    hunspellDicts.en_US
    broot
    plantuml
    dysk
    #minicom depency lrzsz is broken
    fwupd
    git
    git-lfs
    mesa-demos
    nvd
    htop
    nvtopPackages.full
    oh-my-posh
    i7z
    killall
    nixfmt
    nixos-generators
    pciutils
    ranger
    glances
    rclone
    hexyl
    unzip
    usbutils
    wget
    texliveFull
    yt-dlp
    yewtube
    ventoy-full
    testdisk
    exfat
    exfatprogs
    witr # Why is this runneng?
    claude-code
    (callPackage ../../../packages/mcpvault {})
    (callPackage ../../../packages/better-sqlite3 {})
  ];

  communicationpkgs = with pkgs; [
    signal-desktop
    element-desktop
    ferdium
    discord
    hexchat
    libsForQt5.qt5.qtwebengine # aus kompatibilitätsgründen mit collect-garbage? need to watch ... dependency von teamspeak3
    teamspeak3
  ];
  devpackages = with pkgs; [ cmake automake python3 ghc ];
in
{
  imports = [
    ./hamradio.nix
    ./networking.nix
    ./nfc.nix
    ./ptls.nix
    ./games.nix
  ];
  environment.systemPackages = apppkgs ++ clipkgs ++ communicationpkgs ++ devpackages ++ [ javawsWrapper ];
  programs.nix-ld = {
    enable = true;
  };
  programs.vscode = {
    enable = true;
  };
  programs.java = {
    enable = true;
  };
  programs.ausweisapp = {
    enable = true;
    openFirewall = true;
  };
  programs.git = {
    enable = true;
  };
  programs.evolution = {
    enable = true;
  };
  programs.gnupg = {
    agent.enable = true;
    package = pkgs.gnupg;
  };
  programs.direnv = {
    enable = true;
  };
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = with pkgs.obs-studio-plugins; [ 
      obs-backgroundremoval 
    ];
  };
  programs.noisetorch = {
    enable = true;
  };

  services.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
  };
  # disable syncthing ... switch to homemanager config
  #services.syncthing = {
  #    enable = true;
  #    user = "muhackel";
  #    group = "users";
  #    #systemService = false;
  #    openDefaultPorts = true;
  #    configDir = "/home/muhackel/.config/syncthing";
  #    dataDir = "/home/muhackel";
  #};
  # Claude Code erwartet ~/.claude.json, die eigentliche Datei liegt in ~/.claude/
  system.activationScripts.claudeJsonSymlink = ''
    if [ $(cat /proc/uptime | cut -d. -f1) -ge 30 ]; then
      src="/home/muhackel/.claude/claude.json"
      dst="/home/muhackel/.claude.json"
      if [ -f "$src" ]; then
        echo "Claude: Symlink $dst -> $src"
        ln -sf "$src" "$dst"
      else
        echo "Claude: $src nicht gefunden, überspringe Symlink"
      fi
    else
      echo "Claude: Symlink-Aktivierung übersprungen (uptime < 30s)"
    fi
  '';

  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
