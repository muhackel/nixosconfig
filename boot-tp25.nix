{ config, lib, pkgs, ... }:

{
  boot.plymouth = {
    enable = true;
    logo = ./sources/backgrounds/bg-hd-hal9000.png;
    theme = "spinner";
  };
}