{ config, lib, pkgs, ... }:
let
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
    enable = false;
    enableCtrlAltBackspace = true;

    windowManager.xmonad = {
        enable = config.services.xserver.enable;
        enableContribAndExtras = true;
        enableConfiguredRecompile = true;
        config = ./xmonad.hs;
    };
  };

  services.picom = {
    enable = config.services.xserver.enable;
    opacityRules = [
      "80:class_g = 'Alacritty' && focused"
      "80:class_g = 'Alacritty' && !focused"
    ];
  };

  services.libinput = {
        enable = true;
  };

  # only add these packages when the X server is enabled
  environment.systemPackages = lib.optionals config.services.xserver.enable (xsupportpkgs ++ xmonadpkgs);
}