{ config, lib, pkgs, ... }:

{
  # Configuration of the Boot Loader
  boot.loader = {
    timeout = null;
    systemd-boot = {
      enable = true;
      memtest86.enable = true;
      netbootxyz.enable = true;
    };
    efi.canTouchEfiVariables = true;
  };

  # Steam/Wine triggern massenhaft Bus-Lock-Traps (x86/split lock detection).
  # "off" statt "warn" (Default): kein dmesg-Spam, keine Prozess-Stalls beim Traps.
  boot.kernelParams = [ "split_lock_detect=off" ];
}