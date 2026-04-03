{ lib, buildNpmPackage, fetchFromGitHub, python3, node-gyp }:

buildNpmPackage rec {
  pname = "better-sqlite3";
  version = "12.8.0";

  src = fetchFromGitHub {
    owner = "WiseLibs";
    repo = "better-sqlite3";
    rev = "v${version}";
    hash = "sha256-B9SHvlSK9Heqhp3maCPRf08tatXzLi5m2zcnU5o2Y0E=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-Tr1/GLm9oxUblpOZF6HvBK+XCArQsVPVKXRfg99Jxac=";

  nativeBuildInputs = [ python3 node-gyp ];

  buildPhase = ''
    runHook preBuild
    npx --offline node-gyp rebuild --release
    runHook postBuild
  '';

  dontNpmPrune = true;

  postInstall = ''
    local dest="$out/lib/node_modules/better-sqlite3"
    cp -r build "$dest/build"
  '';

  meta = with lib; {
    description = "Schnellste und einfachste SQLite3-Bibliothek für Node.js";
    homepage = "https://github.com/WiseLibs/better-sqlite3";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
