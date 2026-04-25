# Workaround: openldap syncreplication-Tests sind in der Sandbox flaky.
# Tests warten feste Sekunden (7s/15s) auf Syncrepl-Replikation — unter Build-Last
# reicht das nicht, Provider und Consumer divergieren, Tests schlagen fehl.
# Folgt dem Pattern aus nixpkgs (preCheck entfernt bereits andere flaky Tests).
# Kann entfernt werden wenn nixpkgs die Tests selbst skippt oder upstream fixt.
final: prev: {
  openldap = prev.openldap.overrideAttrs (old: {
    preCheck = (old.preCheck or "") + ''
      rm -f tests/scripts/test017-syncreplication-refresh
      rm -f tests/scripts/test019-syncreplication-cascade
    '';
  });
}
