{ config, lib, pkgs, ... }:

{
  imports = [
    ../../hardware/datengrab
    ../../hardware/keyboard
    ../../hardware/printer
    ../../hardware/printer/HP
    ../../hardware/printer/HP/hplj4100
  ];
}