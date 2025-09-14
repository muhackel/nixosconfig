{ config, lib, pkgs, ... }:

{
  imports = [
    ../../hardware/lenovo-tp25
    ../../hardware/bluetooth
    ../../hardware/keyboard
    ../../hardware/mouse/logitech-wireless
    ../../hardware/printer
    ../../hardware/printer/HP
    ../../hardware/printer/HP/hplj4100
  ];
}