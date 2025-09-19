{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "gns3extras";
  version = "1";

  # source tree (relative path inside the repo)
  src = ./gns3;

  # no build needed, we just install the files into the output
  buildPhase = ''
    : # no-op
  '';

  installPhase = ''
    mkdir -p $out/var/lib/gns3
  # copy everything from the local sources/gns3 into the store output
  cp -a --preserve=mode,timestamps ${./gns3}/. $out/var/lib/gns3/

    mkdir -p $out/bin
    # copy the activation script into the package and mark executable
    install -m755 ${./gns3-extras-activate.sh} $out/bin/gns3-extras-activate
  '';

  meta = {
    description = ''Packaged auxiliary files for GNS3 (maps into /var/lib/gns3)
      Installs the contents of the repository's sources/gns3 into the
      Nix store and provides a small activation script that creates
      symlinks from /var/lib/gns3 to the store files. Symlinks are
      overwritten, regular files are left untouched.'';
    platforms = pkgs.lib.platforms.linux;
  };
}
