{ config, lib, pkgs, ... }:
let
  # Extra Packages for the Lenovo TP25 hardware as installed packages
  tp25pkgs = with pkgs; [ 
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

  ];
  # Additional filesystems supported by the system
  boot.supportedFilesystems = [ "zfs" ];
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
  # Additional Kernel Modules for the initrd (available during boot)
  boot.initrd.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" "zfs" ];
  # Additional Kernel Modules for the system
  boot.kernelModules = [ "kvm-intel" "vfio_pci" "vfio" "vfio_iommu_type1" ];
  boot.extraModulePackages = [ ];
  # Enable nvidia Optimus support and install extra hardware modules and or packages
  hardware.nvidiaOptimus.disable = false;
  hardware.graphics.extraPackages = tp25gfxpkgs;
  environment.systemPackages = tp25pkgs;
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
  };
  # Enable cpu microcode updates
  hardware.cpu.intel.updateMicrocode = true;
  # Install and enable the systemd services for wwan module
  systemd = {
    packages = [
      pkgs.modemmanager
    ];
    services = {
      ModemManager.wantedBy = [ "multi-user.target" ];
    };
    
  };

  # System monitor configuration for the Lenovo TP25 unplugged and docked at home
  services.autorandr = {
      enable = true;
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
}