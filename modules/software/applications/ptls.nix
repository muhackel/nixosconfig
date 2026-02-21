{ config, lib, pkgs, ... }:
let
  configtool = pkgs.callPackage ../../../packages/configtool { };
  ptlspkgs = with pkgs; [
    configtool
  ];
  nixldlibs =  with pkgs; [
    stdenv.cc.cc.lib
    glibc
    libcxx
    gtk3
    pango
    cairo
    atk
    gdk-pixbuf
    glib
    libx11
    libunwind
  ];
in
lib.mkIf config.local.features.ptls
{
  programs.nix-ld = {
    enable = true;
    libraries = nixldlibs;
  };
  environment.systemPackages = ptlspkgs;
}
