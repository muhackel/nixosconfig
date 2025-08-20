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
in
{
  environment.systemPackages = apppkgs ++ clipkgs ;
  programs.vscode = {
    enable = true;
  };
  programs.ausweisapp = {
    enable = true;
    openFirewall = true;
  };
}
