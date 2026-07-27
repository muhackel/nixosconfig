# Deklarativer Wrapper für die imperativ installierte JavaFX-App "Genesis".
#
# Genesis liegt root-installiert unter `genesisPath` (Default /opt/Genesis-7.0.5) und
# startet über ein gebündeltes JRE mit JavaFX. In der reinen steam-run-FHS-Umgebung
# fehlen die GTK3/X11-Libs (libgtk-3.so, libXtst.so.6 …) -> JavaFX crasht sofort mit
# `UnsupportedOperationException: Internal Error` in GtkApplication.<init>.
#
# Fix (verifiziert): steam-run mit LD_LIBRARY_PATH auf ein GTK3/X11-Lib-Bündel starten.
# Kein Wayland-Workaround nötig (XWayland läuft, GDK_BACKEND=x11 ändert nichts).
#
# Bei Genesis-Upgrade nur `genesisPath` (bzw. die Version im Feature-Modul) anpassen.
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
, genesisPath ? "/opt/Genesis-7.0.5"
}:

let
  # Getestetes Lib-Set. gtk3 zieht glib/pango/cairo/gdk-pixbuf/atk transitiv, sie sind
  # der Klarheit halber explizit gelistet; libx11/libxtst/libxxf86vm/libxext/libxrender
  # decken den JavaFX-GTK-Backend-Bedarf ab.
  libPath = lib.makeLibraryPath [
    gtk3 glib pango cairo gdk-pixbuf atk freetype fontconfig
    libx11 libxtst libxxf86vm libxext libxrender
  ];

  genesis = writeShellApplication {
    name = "genesis";
    runtimeInputs = [ steam-run ];
    text = ''
      export LD_LIBRARY_PATH="${libPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      exec steam-run ${lib.escapeShellArg "${genesisPath}/bin/Genesis"} "$@"
    '';
  };

  desktopItem = makeDesktopItem {
    name = "Genesis";
    desktopName = "Genesis";
    comment = "Genesis RPG-Framework (JavaFX)";
    exec = "${genesis}/bin/genesis";
    icon = "preferences-desktop-tablet";
    categories = [ "Game" "RolePlaying" ];
    terminal = false;
    startupNotify = false;
  };
in
symlinkJoin {
  name = "genesis-wrapper";
  paths = [ genesis desktopItem ];
  meta = {
    description = "Deklarativer Wrapper + Desktop-Eintrag für die imperativ installierte JavaFX-App Genesis (/opt)";
    platforms = lib.platforms.linux;
    mainProgram = "genesis";
  };
}
