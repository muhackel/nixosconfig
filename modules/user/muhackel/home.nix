{ config, pkgs, lib, ... }:
let

in
{
  home.stateVersion = "25.11";
  programs.mpv = {
    enable = true;
    config = {
      gpu-context = "wayland";
      hwdec = "vaapi";
    };
  };

}