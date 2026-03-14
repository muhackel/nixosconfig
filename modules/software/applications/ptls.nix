{ config, lib, pkgs, ... }:
let
  configtool = pkgs.callPackage ../../../packages/configtool { };
in
lib.mkIf config.local.features.ptls
{
  environment.systemPackages = [ configtool ];
}
