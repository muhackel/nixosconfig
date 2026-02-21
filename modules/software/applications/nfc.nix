{ config, lib, pkgs, ... }:
let
  nfcpkgs = with pkgs; [
    proxmark3
  ];
in
lib.mkIf config.local.features.nfc {
  environment.systemPackages = nfcpkgs;
}