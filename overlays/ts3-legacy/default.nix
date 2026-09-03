# Legacy-Pin für TeamSpeak 3.6.2 aus nixos-25.11.
#
# nixpkgs entfernte teamspeak3 am 2026-04-26, weil der Client von der
# nicht mehr regulär gewarteten Qt5-WebEngine abhängt. Der isolierte
# Paketbaum hält diese Laufzeitabhängigkeit bewusst fest und erlaubt nur
# das unfreie Paket teamspeak3 sowie qtwebengine-5.15.19 als unsicher.
#
# Entfernen, wenn:
#   - TeamSpeak 3 ohne Qt5-WebEngine verfügbar ist, oder
#   - die Paketliste auf teamspeak6-client umgestellt wird.
final: prev:
let
  nixpkgs-25_11-src = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/25f538306313eae3927264466c70d7001dcea1df.tar.gz";
    sha256 = "0ml5dr3n887vyr5j4hh05d83yw05xlgrkmw5bv0zdqk9d0m2phk6";
  };
  pkgs25_11 = import nixpkgs-25_11-src {
    localSystem = prev.stdenv.hostPlatform.system;
    config = {
      allowUnfreePredicate = pkg: prev.lib.getName pkg == "teamspeak3";
      permittedInsecurePackages = [
        "qtwebengine-5.15.19"
      ];
    };
  };
in {
  ts3-legacy = pkgs25_11.teamspeak3;
}
