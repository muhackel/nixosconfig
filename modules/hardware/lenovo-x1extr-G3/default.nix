{ config, lib, pkgs, ... }:
let
  # Extra Packages for the Lenovo X1 Extreme Gen 3 hardware as installed packages
  x1epkgs = with pkgs; [
    intel-gpu-tools
    vdpauinfo
    libva-utils
    modem-manager-gui
  ];
  # Extra Graphics Packages for the Lenovo TP25 hardware as installed hardware modules
  x1egfxpkgs = with pkgs; [
    intel-media-driver
    libvdpau-va-gl
  ];
in
{
  imports = [
    ./boot.nix
    ./boot-x1e.nix
    ./hardware-configuration.nix
    ./powermgmt.nix
  ];
  # Additional filesystems supported by the system
  #boot.supportedFilesystems = [ "zfs" ];
  # Additional Kernel Modules for the initrd (available during boot)
  boot.initrd.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod"];
  # Additional Kernel Modules for the system
  boot.kernelModules = [ "kvm-intel" "vfio_pci" "vfio" "vfio_iommu_type1" ];
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

  # Enable nvidia Optimus support and install extra hardware modules and or packages
  hardware.nvidiaOptimus.disable = false;
  hardware.graphics.extraPackages = x1egfxpkgs;

  hardware.nvidia = {
    #package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    open = true;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      nvidiaBusId = "PCI:1:0:0";
      intelBusId =  "PCI:0:2:0";
    };
  };
  # Override the default package configuration for ferdium to disable gpu acceleration, which causes issues on optimus systems
  nixpkgs.config.packageOverrides = pkgs: {
    ferdium = pkgs.ferdium.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
      postInstall = (oldAttrs.postInstall or "") + ''
        wrapProgram $out/bin/ferdium \
          --add-flags "--disable-gpu --disable-software-rasterizer"
      '';
    });
  };
  # set the xserver video drivers
  services.xserver.videoDrivers = [
    #  "intel"
	  "modesetting"
    "nvidia"
  ];
  # set the media acceleration drivers
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    VDPAU_DRIVER = "va_gl";
    vblank_mode = "0";
    __GL_SYNC_TO_VBLANK = "0";
    __GL_SHADER_DISK_CACHE=1;
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1;
    __GL_SHADER_DISK_CACHE_PATH="/tmp/.glshadercache";
    _JAVA_OPTIONS="-Dsun.java2d.uiScale=2"; #Scale Java Apps on 4k Displays
    #GDK_SCALE=2;
  };
  # Enable cpu microcode updates
  hardware.cpu.intel.updateMicrocode = true;
  
  # Install and enable the systemd services for wwan module
  systemd.packages = [
    pkgs.modemmanager
  ];
  systemd.services = {
    ModemManager.wantedBy = [ "multi-user.target" ];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    wireplumber.enable = true;
    pulse.enable = true;
  };
  # Fingerprint reader configuration is broken under KDE Plasma, explicitly for kwallet keyring integration, therefore disabled here
  services.fprintd.enable = false;
  users.groups.plugdev = {};
  local.userExtraGroups = [ "plugdev" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="138a", ATTRS{idProduct}=="0097", MODE="0660", GROUP="plugdev"
  '';
  environment.systemPackages = x1epkgs;
}