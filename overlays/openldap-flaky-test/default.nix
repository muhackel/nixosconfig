# Workaround: mehrere openldap-Tests sind in der Sandbox flaky, weil sie feste
# Sekunden-Waits gegen zeitabhängiges Verhalten setzen — unter Build-Last reicht
# das Timing nicht:
#   - test017/test019 (syncrepl): warten 7s/15s auf Replikation, Provider/Consumer
#     divergieren.
#   - test046-dds (Dynamic Directory Services, RFC 2589 entryTTL): wartet 15s auf
#     das Ablaufen einer dynamischen Entry, danach "Comparison failed" (die
#     ldapmodify/-delete "failed (50)"-Zeilen sind erwartete Negativtests).
# Folgt dem Pattern aus nixpkgs (preCheck entfernt bereits andere flaky Tests).
# Kann entfernt werden wenn nixpkgs die Tests selbst skippt oder upstream fixt.
final: prev: {
  openldap = prev.openldap.overrideAttrs (old: {
    preCheck = (old.preCheck or "") + ''
      rm -f tests/scripts/test017-syncreplication-refresh
      rm -f tests/scripts/test019-syncreplication-cascade
      rm -f tests/scripts/test046-dds
    '';
  });
}
