{ config, lib, pkgs, ... }:
let
  ptlspkgs = with pkgs; [
    configtool
  ];
  nixldlibs =  with pkgs; [
    gtk3
    pango
    cairo
    atk
    gdk-pixbuf
    glib
    xorg.libX11
    libunwind
  ];
  configtool = pkgs.callPackage ./configtool.nix { };
in
{
  programs.nix-ld = {
    enable = true;
    libraries = nixldlibs;
  };
  environment.systemPackages = ptlspkgs;
}