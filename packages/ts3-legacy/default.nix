# Legacy-Pin für TeamSpeak 3.6.2 aus nixos-25.11.
#
# nixpkgs entfernte teamspeak3 am 2026-04-26, weil der Client von der
# nicht mehr regulär gewarteten Qt5-WebEngine abhängt. Der isolierte
# Paketbaum hält diese Laufzeitabhängigkeit bewusst fest und erlaubt nur
# das unfreie Paket teamspeak3 sowie qtwebengine-5.15.19 als unsicher.
#
# Der Pin bringt seine eigene glibc (2.40) mit. Der System-Mesa-Treiber
# unter /run/opengl-driver ist gegen eine neuere glibc gebaut und lässt
# sich in diesen Prozess nicht laden („Could not initialize GLX“, SIGABRT,
# seit glibc 2.44 / Mesa 26.2.4 im System). Deshalb bekommt der Client
# das Mesa aus demselben Pin vorgeschaltet; LIBGL_DRIVERS_PATH verhindert,
# dass libglvnd auf /run/opengl-driver/lib/dri zurückfällt.
#
# Bewusst symlinkJoin + wrapProgram statt overrideAttrs: ein Neubau der
# teamspeak3-Derivation braucht qtwebengine-5.15.19-dev, das nicht im
# Binärcache liegt und nach einem GC Chromium aus den Quellen zöge.
#
# Entfernen, wenn:
#   - TeamSpeak 3 ohne Qt5-WebEngine verfügbar ist, oder
#   - die Paketliste auf teamspeak6-client umgestellt wird.
{ lib, stdenv }:
let
  nixpkgs-25_11-src = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/25f538306313eae3927264466c70d7001dcea1df.tar.gz";
    sha256 = "0ml5dr3n887vyr5j4hh05d83yw05xlgrkmw5bv0zdqk9d0m2phk6";
  };
  pkgs25_11 = import nixpkgs-25_11-src {
    localSystem = stdenv.hostPlatform.system;
    config = {
      allowUnfreePredicate = pkg: lib.getName pkg == "teamspeak3";
      permittedInsecurePackages = [
        "qtwebengine-5.15.19"
      ];
    };
  };
  inherit (pkgs25_11) teamspeak3 mesa;
in
pkgs25_11.symlinkJoin {
  name = "teamspeak3-${teamspeak3.version}";
  paths = [ teamspeak3 ];
  nativeBuildInputs = [ pkgs25_11.makeWrapper ];
  postBuild = ''
    rm $out/bin/ts3client
    makeWrapper ${teamspeak3}/bin/ts3client $out/bin/ts3client \
      --prefix LD_LIBRARY_PATH : ${mesa}/lib \
      --set LIBGL_DRIVERS_PATH ${mesa}/lib/dri
  '';
  inherit (teamspeak3) meta;
}
