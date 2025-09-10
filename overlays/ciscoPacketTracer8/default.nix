self: super: let pkgs = super; in {
  ciscoPacketTracer8 = pkgs.ciscoPacketTracer8.overrideAttrs (old: {
    src = ./CiscoPacketTracer822_amd64_signed.deb;
    #src = pkgs.fetchurl {
    #  url = "file://${builtins.toString ./CiscoPacketTracer822_amd64_signed.deb}";
    #  sha256 = "0bgplyi50m0dp1gfjgsgbh4dx2f01x44gp3gifnjqbgr3n4vilkc";
    #};
  });
}