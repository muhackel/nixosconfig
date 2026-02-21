{ config, lib, pkgs, ... }:
let
  cfg = config.local.features;
  xsupportpkgs = with pkgs; [
    xorg.xinput
    xorg.xmodmap
    xorg.xbacklight
    arandr
  ];
  xmonadpkgs = with pkgs; [
    feh
    alacritty
    conky
    dzen2
    dmenu
    dunst
    caffeine-ng
    haskellPackages.xmobar
    i3lock-fancy
    lxappearance
    mate.caja
    networkmanagerapplet
    redshift
    rofi
    stalonetray
    trayer
    xss-lock
  ];
in
{
  services.xserver = {
    enable = cfg.xserver;
    enableCtrlAltBackspace = true;

    windowManager.xmonad = {
      enable = config.services.xserver.enable;  # Abhängig von enable machen
      enableContribAndExtras = true;
      enableConfiguredRecompile = true;
      config = ./sources/xmonad/xmonad.hs;
    };
  };

  services.picom = {
    enable = config.services.xserver.enable;  # Abhängig von enable machen
    opacityRules = [
      "80:class_g = 'Alacritty' && focused"
      "80:class_g = 'Alacritty' && !focused"
    ];
  };

  # only add these packages when the X server is enabled
  environment.systemPackages = lib.optionals config.services.xserver.enable (xsupportpkgs ++ xmonadpkgs);
}