{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "mpt3sas" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/c48b53c7-5627-4afe-9b1a-b8d1c64e909b";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/8BE2-80B8";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/bootbackup" =
    { device = "/dev/disk/by-uuid/8BED-DFB2";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/media" =
    { device = "pool/media";
      fsType = "zfs";
    };

  fileSystems."/media/backup" =
    { device = "pool/media/backup";
      fsType = "zfs";
    };

  fileSystems."/media/raws" =
    { device = "pool/media/raws";
      fsType = "zfs";
    };

  fileSystems."/media/serien" =
    { device = "pool/media/serien";
      fsType = "zfs";
    };

  fileSystems."/media/filme" =
    { device = "pool/media/filme";
      fsType = "zfs";
    };

  fileSystems."/media/pr0n" =
    { device = "pool/media/pr0n";
      fsType = "zfs";
    };

  fileSystems."/media/temp" =
    { device = "pool/media/temp";
      fsType = "zfs";
    };

  fileSystems."/media/syncthing" =
    { device = "pool/media/syncthing";
      fsType = "zfs";
    };

  fileSystems."/media/videos" =
    { device = "pool/media/videos";
      fsType = "zfs";
    };

  fileSystems."/media/musik" =
    { device = "pool/media/musik";
      fsType = "zfs";
    };

  fileSystems."/media/books" =
    { device = "pool/media/books";
      fsType = "zfs";
    };

  fileSystems."/media/isos" =
    { device = "pool/media/isos";
      fsType = "zfs";
    };

  fileSystems."/media/warez" =
    { device = "pool/media/warez";
      fsType = "zfs";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/cfa76d28-97ad-425b-9bf9-c64ff003ae32"; }
      { device = "/dev/disk/by-uuid/982c6c56-9214-4665-a486-7f599adbabca"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.swraid.enable = true;
}