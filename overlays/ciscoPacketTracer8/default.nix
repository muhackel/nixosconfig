self: super: let pkgs = super; in {
  ciscoPacketTracer8 = pkgs.ciscoPacketTracer8.overrideAttrs (old: {
    #src = ./CiscoPacketTracer822_amd64_signed.deb;
    src = pkgs.fetchurl {
      url = "file://${builtins.toString ./CiscoPacketTracer822_amd64_signed.deb}";
      hash = "sha256-bNK4iR35LSyti2/cR0gPwIneCFxPP+leuA1UUKKn9y0=";
    };
  });
}