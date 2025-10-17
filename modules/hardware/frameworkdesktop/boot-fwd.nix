{ config, lib, pkgs, ... }:

{
  boot.plymouth = {
    enable = true;
    theme = "spinner";
  };
}