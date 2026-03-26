{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "mcpvault";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "bitbonsai";
    repo = "mcpvault";
    rev = "32776a5f7fd62526863618b10a85e086deb22db8";
    hash = "sha256-3VCFumEz61m3kat4ACkmlKaoACyB6g5NXlwZBaPG+Rc=";
  };

  npmDepsHash = "sha256-Wcp053R388YGd7sdWtIgJ/DdMkepx+4aymev8jDA/VE=";

  npmBuildScript = "build";

  meta = with lib; {
    description = "Universal AI bridge for Obsidian vaults";
    homepage = "https://mcpvault.org";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
