{ config, lib, pkgs, ... }:

{
  imports = [
    ../../hardware/frameworkdesktop
    ../../hardware/bluetooth
    ../../hardware/keyboard
    ../../hardware/mouse/logitech-wireless
    ../../hardware/printer
    ../../hardware/printer/HP
    ../../hardware/printer/HP/hplj4100
  ];
}