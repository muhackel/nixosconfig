{ config, lib, pkgs, ... }:
let
  apppkgs = with pkgs; [
    audacity
    bambu-studio
  ];
  clipkgs = with pkgs; [
    aspell
    aspellDicts.de
    aspellDicts.en
    broot
    caffeine-ng
    camunda-modeler
    fwupd
  ];
  communicationpkgs = with pkgs; [
    signal-desktop
    ferdium
    discord
  ];
in
{
  environment.systemPackages = apppkgs ++ clipkgs ;
  programs.ausweisapp = {
    enable = true;
    openFirewall = true;
  };
}