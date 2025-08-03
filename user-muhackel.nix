{ config, lib, pkgs, ... }:

{
  users.users.muhackel = {
    isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
        "libvirtd"
        "networkmanager"
        "vboxusers"
        "uucp"
      ];
      shell = pkgs.zsh;
      linger = true;
      initialPassword = "1qaz!QAZ";
      packages = with pkgs; [

        ];
  };
}