{ config, lib, pkgs, ... }:
let
  # Extra Packages for the Lenovo TP25 hardware as installed packages
  tp25pkgs = with pkgs; [
    intel-gpu-tools
    vdpauinfo
    libva-utils
    modem-manager-gui
  ];
  # Extra Graphics Packages for the Lenovo TP25 hardware as installed hardware modules
  tp25gfxpkgs = with pkgs; [
    intel-media-driver
    libvdpau-va-gl
  ];
in
{
  imports = [
    ./boot.nix
    ./boot-tp25.nix
    ./hardware-configuration.nix
    ./nfc.nix
    ./powermgmt.nix
  ];
  # Additional filesystems supported by the system
  # boot.supportedFilesystems = [ "zfs" ];
  # Additional Kernel Modules for the initrd (available during boot)
  boot.initrd.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod"];
  # Additional Kernel Modules for the system
  boot.kernelModules = [ "kvm-intel" "vfio_pci" "vfio" "vfio_iommu_type1" ];
  boot.extraModulePackages = [ ];
  boot.resumeDevice = "/dev/disk/by-uuid/5ceff991-6a93-42b9-9c14-c241dd958a94";
  #boot.zfs.allowHibernation = true;

  #boot.kernelPackages = pkgs.linuxPackages_6_16;

  #location.provider = "manual";
  #location.latitude = "48.790457";
  #location.longitude = "9.204377";
  services.geoclue2 = {
    enable = true;
    enableWifi = true;
    enableModemGPS = true;
  };

  hardware.graphics.enable = true;  # Before 24.11: hardware.opengl.driSupport
  hardware.graphics.enable32Bit = true;  # Before 24.11: hardware.opengl.driSupport32Bit

  # Enable nvidia Optimus support and install extra hardware modules and or packages
  hardware.nvidiaOptimus.disable = false;
  hardware.graphics.extraPackages = tp25gfxpkgs;

  hardware.nvidia = {
    open = false;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      nvidiaBusId = "PCI:2:0:0";
      intelBusId =  "PCI:0:2:0";
    };
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
  };
  # Enable cpu microcode updates
  hardware.cpu.intel.updateMicrocode = true;
  

  # System monitor configuration for the Lenovo TP25 unplugged and docked at home
  services.autorandr = {
      enable = config.services.xserver.enable;
      matchEdid = true;
      profiles = {
        "undocked" = {
          config = {
            DP-1.enable = false;
            HDMI-1.enable = false;
            DP-2.enable = false;
            HDMI-2.enable = false;
            eDP-1 = {
              enable = true;
              crtc = 0;
              mode = "1920x1080";
              position = "0x0";
              primary = true;
              rate = "60.01";
              #gamma = "1.0:0.833:0.714";
            };
          };
          fingerprint = {
            eDP-1 = "00ffffffffffff0006af3d1000000000001a0104951f117802c32592575a942a22505400000001010101010101010101010101010101143780b2703828403064310035ad100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe004231343048414b30312e30200a00bd";
          };
        };
        "docked_at_home" = {
          config = {
            DP-2-1 = {
              enable = true;
              crtc = 1;
              mode = "1920x1080";
              position = "0x0";
              primary = true;
              rate = "60.00";
              #gamma = "1.0:0.833:0.714";
            };
            DP-2-2.enable = false;
            DP-2-3.enable = false;
            eDP-1.enable = false;
            DP-1.enable = false;
            HDMI-1.enable = false;
            DP-2.enable = false;
            HDMI-2.enable = false;
          };
          fingerprint = {
            DP-2-1 ="00ffffffffffff00220e4535010000001d1c010380351e782ac020a656529c270f5054a10800d1c0a9c081c0b3009500810081800101023a801871382d40582c45000f282100001e000000fd00304b1e5612000a202020202020000000fc004850203234660a202020202020000000ff0033434d383239313139592020200160020320b149901f0413031201021165030c001000681a00000101304bede2002b023a801871382d40582c45000f282100001e2a4480a070382740302035000f282100001a011d007251d01e206e2855000f282100001e011d00bc52d01e20b82855400f282100001e8c0ad08a20e02d10103e96000f28210000180000000000c2";
          };
        };
      };
    };

  # Install and enable the systemd services for wwan module
  systemd.packages = [
    pkgs.modemmanager
  ];
  systemd.services = {
    ModemManager.wantedBy = [ "multi-user.target" ];
  };
    
  networking = {
    hostName = "HAL9000";
    hostId = "DEADBEEF";
    networkmanager = {
      enable = true;
    };
    usePredictableInterfaceNames = false;
    #proxy = {
      #default = "http://user:password@proxy:port/";
      #noProxy = "127.0.0.1,localhost,internal.domain";
    #};
    firewall.enable = false;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    wireplumber.enable = true;
    pulse.enable = true;
  };
  # Validity fingerprint reader configuration is totally broken under linux ... it needs aditional python-validity to exchange TLS Keys with the sensor
  # services.fprintd.enable = true;
  # users.groups.plugdev = {};
  # users.users.muhackel.extraGroups = [ "plugdev" ]; # ersetze youruser
  # services.udev.extraRules = ''
  #   SUBSYSTEM=="usb", ATTRS{idVendor}=="138a", ATTRS{idProduct}=="0097", MODE="0660", GROUP="plugdev"
  # '';
  environment.systemPackages = tp25pkgs;
}