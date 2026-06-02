final: prev:
let
  nixpkgs-25_11-src = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/25f538306313eae3927264466c70d7001dcea1df.tar.gz";
    sha256 = "0ml5dr3n887vyr5j4hh05d83yw05xlgrkmw5bv0zdqk9d0m2phk6";
  };
  pkgs25_11 = import nixpkgs-25_11-src {
    localSystem = prev.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "qtwebengine-5.15.19"
      ];
    };
  };
in {
  ts3-legacy = pkgs25_11.teamspeak3;
}
