# Deklarativer Wrapper für den imperativ installierten JavaFX-Updater "Commlink6".
#
# Commlink6 (Shadowrun-6-Charakterverwaltung, gleicher Autor wie Genesis) liegt
# root-installiert unter `comlinkPath` (Default /opt/commlink6-updater) und startet über
# die gebündelte jpackage-ELF-Binary `bin/Commlink6 Updater` (eigene GraalVM-17-Runtime).
# Wie Genesis fehlen in der reinen steam-run-FHS-Umgebung die GTK3/X11-Libs -> JavaFX
# crasht beim GtkApplication-Init.
#
# Fix (verifiziert): identisches Lib-Bündel wie Genesis via LD_LIBRARY_PATH, dann
# steam-run. Der Updater lädt die eigentliche App nach ~/CommLink6 und startet sie.
#
# Bei Upgrade nur `comlinkPath` anpassen (der Updater versioniert sich selbst).
{ lib
, writeShellApplication
, makeDesktopItem
, symlinkJoin
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
, comlinkPath ? "/opt/commlink6-updater"
}:

let
  # Identisches, getestetes Lib-Set wie beim Genesis-Wrapper (siehe packages/genesis).
  libPath = lib.makeLibraryPath [
    gtk3 glib pango cairo gdk-pixbuf atk freetype fontconfig
    libx11 libxtst libxxf86vm libxext libxrender
  ];

  comlink6 = writeShellApplication {
    name = "comlink6";
    runtimeInputs = [ steam-run ];
    text = ''
      export LD_LIBRARY_PATH="${libPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      exec steam-run ${lib.escapeShellArg "${comlinkPath}/bin/Commlink6 Updater"} "$@"
    '';
  };

  desktopItem = makeDesktopItem {
    name = "Commlink6";
    desktopName = "Commlink6";
    comment = "Commlink6 — Charakterverwaltung für Shadowrun 6 (JavaFX)";
    exec = "${comlink6}/bin/comlink6";
    icon = "preferences-desktop-tablet";
    categories = [ "Game" "RolePlaying" ];
    terminal = false;
    startupNotify = false;
  };
in
symlinkJoin {
  name = "comlink6-wrapper";
  paths = [ comlink6 desktopItem ];
  meta = {
    description = "Deklarativer Wrapper + Desktop-Eintrag für den imperativ installierten JavaFX-Updater Commlink6 (/opt)";
    platforms = lib.platforms.linux;
    mainProgram = "comlink6";
  };
}
