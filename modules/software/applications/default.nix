{ config, lib, pkgs, wantsHamradio, wantsNetworking, wantsNfc, wantsPtls, wantsGames, ... }:
let
  apppkgs = with pkgs; [
    # BROKEN CMAKE bambu-studio
    # BROKEN cura
    audacity
    alacritty
    camunda-modeler
    # darktable
    eagle
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
    ioquake3
    kitty
    kicad
    mpv
    meld
    freecad
    gpu-viewer
    gparted
    vscode
    mcp-nixos
    gimp3
    yed
    virt-manager
    virt-viewer
    adoptopenjdk-icedtea-web
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
    broot
    plantuml
    dysk
    minicom
    fwupd
    git
    git-lfs
    mesa-demos
    htop
    nvtopPackages.full
    oh-my-posh
    i7z
    killall
    nixfmt-rfc-style
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
  ];
  communicationpkgs = with pkgs; [ signal-desktop ferdium discord hexchat teamspeak3 ];
  devpackages = with pkgs; [ cmake automake python3 ghc nodePackages.nodejs ];
in
{
  # Imports der spezialisierten Module basierend auf wants-Variablen
  imports = lib.optionals wantsHamradio [ ./hamradio.nix ]
           ++ lib.optionals wantsNetworking [ ./networking.nix ]
           ++ lib.optionals wantsNfc [ ./nfc.nix ]
           ++ lib.optionals wantsPtls [ ./ptls.nix ]
           ++ lib.optionals wantsGames [ ./games.nix ];
  environment.systemPackages = apppkgs ++ clipkgs ++ communicationpkgs ++ devpackages;
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
  programs.direnv = {
    enable = true;
  };
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
  };
  programs.noisetorch = {
    enable = true;
  };

  services.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
  };
  services.syncthing = {
      enable = true;
  };
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
