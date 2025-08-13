{ config, lib, pkgs, ... }:

{
  boot.plymouth = {
    enable = true;
    logo = ./bg-hd-hal9000.png;
    theme = "spinner";
  };
}