{ config, lib, pkgs, ... }:
let
  # Extra Packages
  hwpkgs = with pkgs; [
    #intel-gpu-tools
    vdpauinfo
    libva-utils
    clinfo
    sbctl
    framework-tool
    #modem-manager-gui
  ];
  # Extra Graphics Packages
  gfxpkgs = with pkgs; [
    #amdvlk
  ];
  gfxpkgs32 = with pkgs; [
    #driversi686Linux.amdvlk
  ];
in
{
  imports = [
    ./boot.nix
    ./boot-fwd.nix
    ./hardware-configuration.nix
  ];
  # Additional filesystems supported by the system
  #boot.supportedFilesystems = [ "zfs" ];
  # Additional Kernel Modules for the initrd (available during boot)
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.initrd.availableKernelModules = [ ];
  # Additional Kernel Modules for the system
  boot.kernelModules = [  ];
  boot.extraModulePackages = [ ];
  #boot.zfs.allowHibernation = true;


  location.provider = "manual";
  location.latitude = "48.790457";
  location.longitude = "9.204377";
  services.geoclue2 = {
    enable = true;
    enableWifi = true;
    enableModemGPS = true;
  };


  services.avahi = {
    enable = true;
    openFirewall = true;
  };

  hardware.graphics.enable = true;  # Before 24.11: hardware.opengl.driSupport
  hardware.graphics.enable32Bit = true;  # Before 24.11: hardware.opengl.driSupport32Bit
  hardware.graphics.extraPackages = gfxpkgs;
  hardware.graphics.extraPackages32 = gfxpkgs32;
  hardware.amdgpu = {
    overdrive.enable = false; # disable overdrive for stability (needs to be determined if it is cause of instability)
    initrd.enable = true;
    opencl.enable = true;
  };
  #nixpkgs.config.rocmSupport = true;
  services.lact.enable = true;
  services.xserver.videoDrivers = [
    "amdgpu" 
  ];
  # set the media acceleration drivers
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
    vblank_mode = "0";
    __GL_SYNC_TO_VBLANK = "0";
    __GL_SHADER_DISK_CACHE=1;
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1;
    __GL_SHADER_DISK_CACHE_PATH="/tmp/.glshadercache";
  };

  # Install and enable the systemd services with wwan module example
  systemd.packages = [
    #pkgs.modemmanager
  ];
  systemd.services = {
    #ModemManager.wantedBy = [ "multi-user.target" ];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    wireplumber.enable = true;
    pulse.enable = true;
  };

  environment.systemPackages = hwpkgs;
}