{ config, pkgs, lib, ... }:
let

in
{
  home.stateVersion = "26.05";
  programs.mpv = {
    enable = true;
    config = {
      gpu-context = "wayland";
      hwdec = "vaapi"; # maybe vulkan in the future
    };
  };

}