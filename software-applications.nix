{ config, lib, pkgs, ... }:
let
  apppkgs = with pkgs; [
    audacity
    alacritty
    bambu-studio
    camunda-modeler
    #cura
    rclone-browser
    libreoffice-fresh
    drawio
    github-desktop
    google-chrome
    mpv
    freecad
    gparted
    #pamixer
    #pasystray
    vscode
    gimp3
    yed
    virt-manager
  ];
  clipkgs = with pkgs; [
    alsa-utils
    aspell
    aspellDicts.de
    aspellDicts.en
    broot
    caffeine-ng
    dysk
    fwupd
    git
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
    rclone
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
  ];
  devpackages = with pkgs; [
    cmake
    python3
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

  services.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
  };
  services.syncthing = {
      enable = true;
  };

}
