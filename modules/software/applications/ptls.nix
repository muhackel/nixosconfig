{ config, lib, pkgs, wantsPtls, ... }:
let
  configtool = pkgs.callPackage ../../../packages/configtool { };
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
in
lib.mkIf wantsPtls 
{
  programs.nix-ld = {
    enable = true;
    libraries = nixldlibs;
  };
  environment.systemPackages = ptlspkgs;
}
