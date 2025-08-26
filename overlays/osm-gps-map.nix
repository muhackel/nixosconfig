self: super: let pkgs = super; in {
  osm-gps-map = pkgs.osm-gps-map.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
      pkgs.automake
      pkgs.autoconf
      pkgs.libtool
      pkgs.pkg-config
      pkgs.m4
      pkgs.perl
      pkgs.gtk-doc
    ];
    preConfigure = (old.preConfigure or "") + ''
      autoreconf -vfi
    '';
  });
}