# BKM Micronic ConfigTool 2.0.1 (pyConfigTool), Python-/PySide6-Port des Xojo-Tools 1.45.
#
# Hersteller liefert ein Nuitka-Onefile: Bootstrap (nur libc) plus zstd-Payload, den er
# bei jedem Start nach $TMPDIR entpackt. Hier wird der Payload stattdessen zur Build-Zeit
# entpackt (unpack-nuitka.py) und mit autoPatchelfHook verdrahtet — kein 170-MB-Entpacken
# pro Start, Laufzeit-Libs fest aus dem Store.
#
# Quelle ist der Debian-Trixie-Build (Qt/PySide6 6.11, OpenSSL 3); der Bullseye-Build
# bündelt noch OpenSSL 1.1. Die beiden ignorierten Libs hängen nur an den Plugins
# eglfs-kms und qtiff, die auf dem Desktop nicht geladen werden.
#
# Upgrade: neue Datei ablegen, `src` und `version` anpassen. Bricht das Entpacken, hat
# BKM die Nuitka-Version gewechselt und das Payload-Format ist zu prüfen.
{ lib
, stdenvNoCC
, python3
, autoPatchelfHook
, makeDesktopItem
, copyDesktopItems
, stdenv
, zlib
, zstd
, brotli
, glib
, gtk3
, pango
, cairo
, atk
, gdk-pixbuf
, harfbuzz
, fontconfig
, freetype
, dbus
, cups
, libkrb5
, libdrm
, libgbm
, libglvnd
, wayland
, libxkbcommon
, libx11
, libxcb
, libxcb-cursor
, libxcb-util
, libxcb-image
, libxcb-keysyms
, libxcb-render-util
, libxcb-wm
}:

stdenvNoCC.mkDerivation {
  pname = "configtool";
  version = "2.0.1";

  src = ./pyConfigTool_2.0.1_Linux_x64_Trixie;
  dontUnpack = true;

  nativeBuildInputs = [
    (python3.withPackages (p: [ p.zstandard ]))
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
    zstd
    brotli
    glib
    gtk3
    pango
    cairo
    atk
    gdk-pixbuf
    harfbuzz
    fontconfig
    freetype
    dbus
    cups
    libkrb5
    libdrm
    libgbm
    libglvnd
    wayland
    libxkbcommon
    libx11
    libxcb
    libxcb-cursor
    libxcb-util
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libQt6EglFsKmsGbmSupport.so.6"
    "libtiff.so.5"
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "configtool";
      desktopName = "BKM ConfigTool";
      comment = "Konfigurationswerkzeug für BKM-Micronic-Sender und -Empfänger";
      exec = "configtool";
      icon = "configtool";
      categories = [ "Utility" ];
      terminal = false;
    })
  ];

  installPhase = ''
    runHook preInstall

    python3 -I ${./unpack-nuitka.py} "$src" "$out/libexec/configtool"

    mkdir -p "$out/bin"
    ln -s "$out/libexec/configtool/pyConfigTool.bin" "$out/bin/configtool"
    install -Dm644 "$out/libexec/configtool/resources/icon.png" \
      "$out/share/icons/hicolor/256x256/apps/configtool.png"

    runHook postInstall
  '';

  dontStrip = true;

  meta = {
    description = "BKM Micronic ConfigTool (pyConfigTool)";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfree;
    mainProgram = "configtool";
  };
}
