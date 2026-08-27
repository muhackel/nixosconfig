# Genesis 7.0.5 — Charakterverwaltung für Pen-&-Paper-Rollenspiele (rpgframework.de).
#
# Quelle ist das offizielle Debian-Paket des Herstellers; es enthält das komplette
# jpackage-Bundle (nativer Launcher, gebündelte Java-17-Runtime, JavaFX-Module) samt
# Icon. Der Launcher leitet sein $ROOTDIR aus dem eigenen Pfad ab, das Bundle läuft
# daher unverändert aus dem Store — bin/Genesis findet lib/app/Genesis.cfg relativ.
#
# Start weiterhin über steam-run + LD_LIBRARY_PATH statt autoPatchelf: JavaFX packt
# seine nativen Libs erst zur Laufzeit aus den javafx-*-linux.jar aus, autoPatchelf
# erreicht die also gar nicht. In der reinen FHS-Umgebung fehlen zusätzlich die
# GTK3/X11-Libs -> JavaFX crasht mit `UnsupportedOperationException: Internal Error`
# in GtkApplication.<init>. Das Lib-Bündel unten ist der verifizierte Fix.
#
# Upgrade: version + hash anpassen, Downloads unter
# https://www.rpgframework.de/de/downloads/genesis-2/
{ lib
, stdenvNoCC
, fetchurl
, dpkg
, makeWrapper
, makeDesktopItem
, copyDesktopItems
, steam-run
, gtk3
, glib
, pango
, cairo
, gdk-pixbuf
, atk
, freetype
, fontconfig
, libx11
, libxtst
, libxxf86vm
, libxext
, libxrender
}:

let
  # Getestetes Lib-Set. gtk3 zieht glib/pango/cairo/gdk-pixbuf/atk transitiv, sie sind
  # der Klarheit halber explizit gelistet; libx11/libxtst/libxxf86vm/libxext/libxrender
  # decken den JavaFX-GTK-Backend-Bedarf ab. Identisch im Commlink6-Paket.
  libPath = lib.makeLibraryPath [
    gtk3 glib pango cairo gdk-pixbuf atk freetype fontconfig
    libx11 libxtst libxxf86vm libxext libxrender
  ];

  desktopItem = makeDesktopItem {
    name = "genesis";
    desktopName = "Genesis";
    genericName = "RPG Character Management";
    comment = "Software zur Verwaltung von Rollenspiel-Charakteren (JavaFX)";
    exec = "genesis";
    icon = "genesis";
    categories = [ "Game" "RolePlaying" ];
    keywords = [ "Genesis" "RPG" "Rollenspiel" ];
    terminal = false;
    startupNotify = true;
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "genesis";
  version = "7.0.5";

  src = fetchurl {
    url = "https://www.rpgframework.de/downloads/linux/genesis_${finalAttrs.version}-1_amd64.deb";
    hash = "sha256-uLun0Git0qv6kH+O8qQIKNsXsr18MTRyqBAgkWm2I9I=";
    # Upstream-Zertifikat ist seit 2026-08-20 abgelaufen (kein Alternativhost). Die
    # Integrität sichert der Hash dieser Fixed-Output-Derivation. Zeile entfernen,
    # sobald das Zertifikat erneuert ist.
    curlOptsList = [ "--insecure" ];
  };

  nativeBuildInputs = [ dpkg makeWrapper copyDesktopItems ];

  desktopItems = [ desktopItem ];

  # jpackage-Bundle: Launcher und gebündelte Runtime laufen unter steam-run in einer
  # FHS-Umgebung, ihre RPATHs dürfen nicht angefasst werden.
  dontPatchELF = true;
  dontStrip = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r opt/genesis $out/share/genesis

    install -Dm444 $out/share/genesis/lib/Genesis.png $out/share/pixmaps/genesis.png

    makeWrapper ${lib.getExe steam-run} $out/bin/genesis \
      --prefix LD_LIBRARY_PATH : "${libPath}" \
      --add-flags "$out/share/genesis/bin/Genesis"

    runHook postInstall
  '';

  meta = {
    description = "Charakterverwaltung für Pen-&-Paper-Rollenspiele (JavaFX)";
    homepage = "https://www.rpgframework.de/";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode binaryBytecode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "genesis";
  };
})
