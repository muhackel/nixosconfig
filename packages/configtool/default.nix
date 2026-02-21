{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "configtool";
  version = "1.45";

  src = ./ConfigTool.zip;

  nativeBuildInputs = [ pkgs.unzip ];

  unpackPhase = ''
    unzip $src -d .
  '';

  installPhase = ''
    mkdir -p $out
    cp -r . $out/

    # Hauptbinary ausführbar machen
    chmod +x $out/ConfigTool/ConfigTool

    # Alle .so, .so.*, .bce, Emulator ausführbar machen
    find $out -type f -name "*.so" -exec chmod +x {} \;
    find $out -type f -name "*.so.*" -exec chmod +x {} \;
    find $out -type f -name "*.bce" -exec chmod +x {} \;
    find $out -type f -name "Emulator" -exec chmod +x {} \;
    echo "Set executable flags and patched binaries"
    mkdir -p $out/bin
    ln -s $out/ConfigTool/ConfigTool $out/bin/configtool
  '';

  meta = {
    description = "ConfigTool ZIP unpacker";
    platforms = pkgs.lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}