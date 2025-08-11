{ config, lib, pkgs, ... }:
let
  nfcpkgs = with pkgs; [
    proxmark3
  ];
in
{
  environment.systemPackages = nfcpkgs;
}