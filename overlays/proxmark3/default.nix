self: super: let pkgs = super; in {
  proxmark3 = pkgs.proxmark3.override {
    standalone = "HF_COLIN";
    withBlueshark = true;
  };
}
