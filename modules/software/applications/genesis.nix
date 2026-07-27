{ config, lib, pkgs, ... }:

let
  cfg = config.local.features;
  # Imperativ installierter Pfad (root, /opt) — bei Upgrade hier anpassen.
  genesis = pkgs.callPackage ../../../packages/genesis {
    genesisPath = "/opt/Genesis-7.0.5";
  };
in
lib.mkIf cfg.genesis {
  environment.systemPackages = [ genesis ];
}
