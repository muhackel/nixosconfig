# Commlink6-Updater 1.0.3 — Shadowrun-6-Charakterverwaltung (commlink.rocks),
# gleicher Autor wie Genesis.
#
# Upstream liefert ausschließlich diesen Updater; er lädt die eigentliche Anwendung
# zur Laufzeit nach ~/CommLink6 und hält sie dort aktuell. Dieses Paket macht also nur
# den Bootstrap deklarativ — die App selbst bleibt selbstaktualisierend im Home. Das
# ist Upstream-Design und lässt sich nicht wegpaketieren.
#
# Quelle ist das offizielle Debian-Paket mit dem kompletten jpackage-Bundle (nativer
# Launcher, gebündelte Java-Runtime, JavaFX) samt Icon. Wie bei Genesis läuft das
# Bundle unverändert aus dem Store, und wie dort braucht JavaFX das GTK3/X11-Lib-Bündel
# unter steam-run.
#
# Der Launcher heißt mit Leerzeichen "Commlink6 Updater" und muss so heißen: jpackage
# sucht die zugehörige "Commlink6 Updater.cfg" über den eigenen Programmnamen.
#
# Upgrade: version + hash anpassen, Downloads unter https://commlink.rocks/download
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
  # Identisches, getestetes Lib-Set wie beim Genesis-Paket (siehe packages/genesis).
  libPath = lib.makeLibraryPath [
    gtk3 glib pango cairo gdk-pixbuf atk freetype fontconfig
    libx11 libxtst libxxf86vm libxext libxrender
  ];

  desktopItem = makeDesktopItem {
    name = "commlink6";
    desktopName = "Commlink6";
    comment = "Commlink6 — Charakterverwaltung für Shadowrun 6 (JavaFX)";
    exec = "commlink6";
    icon = "commlink6";
    categories = [ "Game" "RolePlaying" ];
    keywords = [ "Commlink6" "Shadowrun" "RPG" "Rollenspiel" ];
    terminal = false;
    startupNotify = false;
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "commlink6-updater";
  version = "1.0.3";

  src = fetchurl {
    url = "https://www.rpgframework.de/commlink6-builds/linux/Commlink6-Updater-${finalAttrs.version}.deb";
    hash = "sha256-vgdLXJv+aswEa778UC+yNKVKRgE39IFJ9lhXOLb+Hs4=";
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
    cp -r opt/commlink6-updater $out/share/commlink6-updater

    install -Dm444 $out/share/commlink6-updater/lib/Commlink6_Updater.png \
      $out/share/pixmaps/commlink6.png

    # Einfache Anführungszeichen: makeWrapper setzt --add-flags unverändert in das
    # generierte Skript ein, ohne sie zerfiele der Pfad am Leerzeichen in zwei Argumente.
    makeWrapper ${lib.getExe steam-run} $out/bin/commlink6 \
      --prefix LD_LIBRARY_PATH : "${libPath}" \
      --add-flags "'$out/share/commlink6-updater/bin/Commlink6 Updater'"

    runHook postInstall
  '';

  meta = {
    description = "Updater/Launcher für Commlink6, die Shadowrun-6-Charakterverwaltung";
    homepage = "https://commlink.rocks/";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode binaryBytecode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "commlink6";
  };
})
