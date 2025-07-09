{ config, lib, pkgs, ... }:
let
  hampkgs = with pkgs; [
    hackrf
    gqrx
    wsjtx
  ];
in
{
  users.groups.ham = {};
  users.users.muhackel.extraGroups = [ "ham" ];
  environment.systemPackages = hampkgs;
  services.udev.extraRules = ''
    # original RTL2832U vid/pid (hama nano, for example)
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2832", ENV{ID_SOFTWARE_RADIO}="1", MODE="0660", GROUP="ham"
    #HackRF
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6089", ENV{ID_SOFTWARE_RADIO}="1", MODE="0660", GROUP="ham"

  '';
}