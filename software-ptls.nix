{ config, lib, pkgs, ... }:
let
  ptlspkgs = with pkgs; [
    configtool
  ];
  configtool = pkgs.callPackage ./configtool.nix { };
in
{
  programs.nix-ld = {
    enable = true;
    libraries =  with pkgs; [
      gtk3
      pango
      cairo
      atk
      gdk-pixbuf
      glib
      xorg.libX11
      libunwind
    ];
  };
  environment.systemPackages = ptlspkgs;
}