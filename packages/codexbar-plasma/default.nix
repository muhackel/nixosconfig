{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  autoPatchelfHook,
  bash,
  coreutils,
  curl,
  gnugrep,
  jq,
  kdePackages,
  libnotify,
  python3,
  sqlite,
}:

let
  cliVersion = "0.56.6";

  codexbarCli = stdenv.mkDerivation {
    pname = "codexbar-cli";
    version = cliVersion;

    src = fetchurl {
      url = "https://github.com/steipete/CodexBar/releases/download/v${cliVersion}/CodexBarCLI-v${cliVersion}-linux-x86_64.tar.gz";
      hash = "sha256-EGONJb7pSFh30HS2wM9x8xXVFo24B+kSzalALCvz9HA=";
    };

    sourceRoot = ".";

    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [
      curl
      sqlite
      stdenv.cc.cc.lib
    ];

    installPhase = ''
      runHook preInstall

      install -Dm755 CodexBarCLI "$out/libexec/codexbar/CodexBarCLI"
      install -Dm644 VERSION "$out/libexec/codexbar/VERSION"
      cp -r CodexBar_CodexBarCore.bundle "$out/libexec/codexbar/"
      mkdir -p "$out/bin"
      ln -s ../libexec/codexbar/CodexBarCLI "$out/bin/codexbar"

      runHook postInstall
    '';

    meta = {
      description = "Command-line interface for CodexBar";
      homepage = "https://github.com/steipete/CodexBar";
      license = lib.licenses.mit;
      mainProgram = "codexbar";
      platforms = [ "x86_64-linux" ];
    };
  };
in
stdenvNoCC.mkDerivation rec {
  pname = "codexbar-plasma";
  version = "0.2.31";

  src = fetchFromGitHub {
    owner = "Lucenx9";
    repo = "codexbar-plasma";
    rev = "v${version}";
    hash = "sha256-P3/YU6gFg+fMM6l5rRXw3IVSaavDVHUvdixWOol2/3U=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    appletDir="$out/share/plasma/plasmoids/app.codexbar.plasma"
    install -d "$appletDir/docs" "$appletDir/scripts"
    cp -r contents "$appletDir/"
    install -Dm644 metadata.json LICENSE NOTICE.md README.md "$appletDir/"
    install -Dm644 \
      docs/codexbar-plasma-overview.png \
      docs/codexbar-plasma-codex.png \
      "$appletDir/docs/"
    install -Dm755 scripts/update-widget.sh "$appletDir/scripts/update-widget.sh"
    patchShebangs "$appletDir/scripts/update-widget.sh"

    runHook postInstall
  '';

  propagatedUserEnvPkgs = [
    bash
    codexbarCli
    coreutils
    curl
    gnugrep
    jq
    kdePackages.kpackage
    kdePackages.plasma5support
    libnotify
    python3
  ];

  passthru = {
    inherit codexbarCli;
  };

  meta = {
    description = "KDE Plasma 6 widget for CodexBar";
    homepage = "https://github.com/Lucenx9/codexbar-plasma";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
