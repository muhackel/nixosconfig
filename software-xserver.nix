{ config, lib, pkgs, ... }:
let
  xsupportpkgs = with pkgs; [
    xorg.xinput
  ];
  xmonadpkgs = with pkgs; [
    alacritty
    conky
    dzen2
    dmenu
    dunst
    caffeine-ng
    haskellPackages.xmobar
    i3lock-fancy
    lxappearance
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

  environment.systemPackages = xsupportpkgs ++ xmonadpkgs;
}