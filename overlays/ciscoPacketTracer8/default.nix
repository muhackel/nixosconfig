self: super: let pkgs = super; in {
  ciscoPacketTracer8 = pkgs.ciscoPacketTracer8.overrideAttrs (old: {
    src = ./CiscoPacketTracer822_amd64_signed.deb;
  });
}