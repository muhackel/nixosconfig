{ lib, pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "configtool";
  version = "1.45";

  src = ./ConfigTool.zip;

  nativeBuildInputs = with pkgs; [
    unzip
    autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    gtk3
    pango
    cairo
    atk
    gdk-pixbuf
    glib
    libx11
    libunwind
    libcxx
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    unzip $src -d .
  '';

  installPhase = ''
    mkdir -p $out
    cp -r ConfigTool $out/ConfigTool

    chmod +x "$out/ConfigTool/ConfigTool"
    chmod +x "$out/ConfigTool/Tools/x64/Emulator"

    mkdir -p $out/bin
    ln -s "$out/ConfigTool/ConfigTool" $out/bin/configtool
  '';

  meta = {
    description = "PTLS ConfigTool";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
