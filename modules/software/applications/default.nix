{ config, lib, pkgs, ... }:
let
  apppkgs = with pkgs; [
    audacity
    alacritty
    camunda-modeler
    darktable
    eagle
    freefilesync
    inkscape
    rclone-browser
    libreoffice-fresh
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
    #pamixer
    #pasystray
    vscode
    gimp3
    yed
    virt-manager
    adoptopenjdk-icedtea-web
    remmina
    rpi-imager
    transmission_4-qt6
    #unigine-heaven
  ];
  clipkgs = with pkgs; [
    alsa-utils
    aspell
    aspellDicts.de
    aspellDicts.en
    broot
    caffeine-ng
    plantuml
    dysk
    minicom
    fwupd
    git
    gitAndTools.git-lfs
    glxinfo
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
    plantuml
    texliveFull
  ];
  communicationpkgs = with pkgs; [
    signal-desktop
    ferdium
    discord
    hexchat
  ];
  devpackages = with pkgs; [
    cmake
    automake
    python3
    ghc
    #haskellPackages.hls
    #haskellPackages.ghcup 
  ];
in
{
  environment.systemPackages = apppkgs ++ clipkgs ++ communicationpkgs ++ devpackages;
  programs.vscode = {
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
    enableVirtualCamera = false;
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
