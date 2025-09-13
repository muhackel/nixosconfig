{ config, lib, pkgs, wantsNfc, ... }:
let
  nfcpkgs = with pkgs; [
    proxmark3
  ];
in
lib.mkIf wantsNfc {
  environment.systemPackages = nfcpkgs;
}