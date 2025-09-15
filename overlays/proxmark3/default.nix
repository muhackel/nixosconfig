self: super: let pkgs = super; in {
  proxmark3 = pkgs.proxmark3.overrideAttrs (old: {
    standalone = "HF_COLIN";
    withBlueshark = true;
  });
}