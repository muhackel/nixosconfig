{ config, lib, pkgs, ... }:

let
  cfg = config.local.features;
  # Imperativ installierter Pfad (root, /opt) — bei Upgrade hier anpassen.
  comlink6 = pkgs.callPackage ../../../packages/comlink6 {
    comlinkPath = "/opt/commlink6-updater";
  };
in
lib.mkIf cfg.comlink6 {
  environment.systemPackages = [ comlink6 ];
}
