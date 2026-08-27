# Helden-Software 5.5.3 — Heldenverwaltung für "Das Schwarze Auge" 4.1 (helden-software.de).
#
# Reines Java-Swing-Programm (Main-Class helden.Helden, kein JavaFX, keine nativen Libs
# im JAR) — verifiziert mit openjdk 21 unter Xvfb, startet und liest bestehende Daten
# aus ~/helden. Kein steam-run/LD_LIBRARY_PATH-Bündel nötig wie bei Genesis/Commlink6.
#
# Quelle ist bewusst das offizielle Debian-Paket aus dem Hersteller-Repo statt der nackten
# helden.jar von der Download-Seite: es enthält dasselbe JAR (sha256 identisch geprüft)
# UND die hicolor-Icons für den Menüeintrag. Der SHA256 stammt aus dem signierten
# Packages-Index des Repos (https://online.helden-software.de/rep).
#
# `-hsDebianMode` ist ein echtes Programm-Flag (im JAR nachgewiesen) und markiert die
# distributionsseitige Installation — das JAR liegt read-only im Store und darf sich
# nicht selbst überschreiben. Die JVM-Heap-Werte sind die des Hersteller-Launchers
# (/usr/games/helden-software aus dem .deb).
#
# Upgrade: version + hash anpassen; die aktuelle Version steht auf
# https://www.helden-software.de/index.php/download/
{ lib
, stdenvNoCC
, fetchurl
, dpkg
, makeWrapper
, makeDesktopItem
, copyDesktopItems
, jre
}:

let
  desktopItem = makeDesktopItem {
    name = "helden-software";
    desktopName = "Helden-Software";
    comment = "Heldenverwaltung für das Pen-&-Paper-Rollenspiel „Das Schwarze Auge“ 4.1";
    exec = "helden-software";
    icon = "helden-software";
    categories = [ "Game" "RolePlaying" ];
    terminal = false;
    startupNotify = false;
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "helden-software";
  version = "5.5.3";

  src = fetchurl {
    url = "https://online.helden-software.de/rep/pool/main/h/helden-software/helden-software_${finalAttrs.version}-0_all.deb";
    hash = "sha256-S8CBGK4eeJQr6lQzON4a2hfCHr20t/nhCJEN8LqBWgQ=";
  };

  nativeBuildInputs = [ dpkg makeWrapper copyDesktopItems ];

  desktopItems = [ desktopItem ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm444 usr/lib/heldensoftware/helden5.jar \
      $out/share/helden-software/helden5.jar
    install -Dm444 usr/share/doc/helden-software/copyright \
      $out/share/doc/helden-software/copyright

    cp -r usr/share/icons $out/share/icons

    makeWrapper ${lib.getExe' jre "java"} $out/bin/helden-software \
      --add-flags "-Xms40m -Xmx256m" \
      --add-flags "-jar $out/share/helden-software/helden5.jar" \
      --add-flags "-hsDebianMode"

    runHook postInstall
  '';

  meta = {
    description = "Heldenverwaltung für das Rollenspiel „Das Schwarze Auge“ 4.1";
    homepage = "https://www.helden-software.de/";
    # „Dieses Programm darf frei verteilt, jedoch nicht verändert werden.“ (copyright im .deb)
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.linux;
    mainProgram = "helden-software";
  };
})
