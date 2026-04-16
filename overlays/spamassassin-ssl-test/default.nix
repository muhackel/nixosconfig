# Workaround: SpamAssassin t/spamd_ssl.t schlägt mit neuem Perl/OpenSSL fehl
# SSL-Handshake-Tests scheitern in der Nix-Sandbox (analog zu spamd_ssl_accept_fail.t
# das upstream bereits ausgeschlossen ist).
# Kann entfernt werden wenn der Test upstream gefixt oder deaktiviert wird.
final: prev: {
  spamassassin = prev.spamassassin.overrideAttrs (old: {
    preCheck = builtins.replaceStrings
      [ "-not -name spamd_ssl_accept_fail.t" ]
      [ "-not -name spamd_ssl_accept_fail.t -not -name spamd_ssl.t" ]
      (old.preCheck or "");
  });
}
