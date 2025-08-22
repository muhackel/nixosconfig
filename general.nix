{ config, lib, pkgs, ... }:

{
  powerManagement.enable = true;

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    # max-jobs = 4; #seems not to work ...
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 30d";
  };
  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "de_DE.UTF-8/UTF-8"
    "de_DE/ISO-8859-1"
    "de_DE@euro/ISO-8859-15"
  ];
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    permittedInsecurePackages = [
      "libxml2-2.13.8"
      "libsoup-2.74.3"
    ];
  };

  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  programs.zsh.enable = true;
  fonts = {
    packages = with pkgs; [
      nerd-fonts.hack
      xkcd-font
    ];
  };
}