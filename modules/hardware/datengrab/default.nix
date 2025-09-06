{ config, lib, pkgs, ... }:
let

in
{
  imports = [
    ./hardware-configuration.nix
  ];

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.requestEncryptionCredentials = true;
  boot.kernelParams = [ "zfs.zfs_arc_max=12884901888" ];

  networking.hostName = "datengrab"; # Define your hostname.
  networking.hostId = "D3ADB33F";
  networking.firewall.enable = false;

  time.timeZone = "Europe/Berlin";


  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 60d";
  };
  system.autoUpgrade = {
    enable = true;
    dates = "daily";
    channel = "https://nixos.org/channels/nixos-unstable";
    operation = "boot";
    flags = [ "--upgrade-all" "--fast" ];
  };
  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
  };

  security.sudo.wheelNeedsPassword = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.muhackel = {
    isNormalUser = true;
    description = "Sebastian Rädle";
    extraGroups = [ "wheel" "docker" "libvirtd" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtAb8GNqbdy/FaA7kI5Qeay1Z9Yfo7u/EMZFwMy7DZBOv4KjYgP/bC2KdcF4fr1+mNzEARw1e4Lriygi54bmjMQDbQBT/Oh9Dj6f3mIvfw3LDd9EOMLfB4jzBiisA0IjRysuwDmion5ny01KWYg4mQqmKsCnDN3Xpyqits8iW06jlvJlXwtsNpgfzg21uuhfRUCZOPqiIg0JSNLCVqN83PUvZXG42lJ0XKvvDOyb2egWjCWFtqB2EPWnGVYhD1SkRqDhvf77X4hl6stuHaKcOTPavyTmGwRRtK3LYqoFEzUrCu9leVVo+aYe9/eZZM5Rnuep79UDvpBkjgiunWNBiPw== muhackel@machackel-pro.ad.fh-albsig.de"
    ];
    initialPassword = "1qaz!QAZ";
    shell = pkgs.zsh;
  };
  
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    allowInsecure = true;
    permittedInsecurePackages = [
                "dotnet-sdk-6.0.428"
                "aspnetcore-runtime-6.0.36"
    ];
  };

  # $ nix search wget
  environment.systemPackages = with pkgs; [
    byobu
    docker-compose
    # docker-machine
    emacs
    htop
    oh-my-posh
    openssl
    #restic # backup
    screen
    tmux
    unzip
    vim_configurable
    wget
    zsh
    git
    ranger
    mc
    tlp
    powertop
  ];
  
  programs.zsh.enable = true;
  programs.nix-ld.enable = true;
  #services.vscode-server.enable = true;
  programs.direnv.enable = true;

  
  services.openssh.enable = true;
  services.zfs.autoScrub.enable = true;
  services.samba = {
    enable = true;
    openFirewall = true;
    #securityType = "user";
    settings = {
      global = {
        "min receivefile size" = "16384";
        "aio read size" = "16384";
        "use sendfile" = "true";
        "vfs objects" = "fruit streams_xattr";
        "aio write size" = "16384";
        "ea support" = "yes";
        "max log size" = "50";
        "auto services" = "media";
        "aio write behind" = "true";
        "workgroup" = "mhc";
        "socket options" = "SO_KEEPALIVE TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072";
        "default" = "media";
        "wins support" = "true";
        "os level" = "20";
        "dns proxy" = "no";
        "security" = "user";
        "max protocol" = "SMB3";
        "min protocol" = "SMB2";
        "server string" = "datengrab";
        "netbios name" = "datengrab";
      };
      "media" = {
        "path" = "/media";
        "create mode" = "0775";
	"read list" = "muhackel";
	"write list" = "muhackel";
        "directory mode" = "0775";
      };
    };
  };
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
#    user = "muhackel";
#    group = "users";
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
    user = "muhackel";
    group = "users";
  };
  services.radarr = {
    enable = true;
    openFirewall = true;
    user = "muhackel";
    group = "users";
  };
  services.lidarr = {
    enable = true;
    openFirewall = true;
    user = "muhackel";
    group = "users";
  };
  services.readarr = {
    enable = true;
    openFirewall = true;
    user = "muhackel";
    group = "users";
  };
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
  services.sabnzbd = {
    enable = true;
    openFirewall = true;
    user = "muhackel";
    group = "users";
  };
  services.plex = {
    enable = true;
    openFirewall = true;
    user = "muhackel";
    group = "users";
  };
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "muhackel";
    group = "users";
  };
  services.cockpit = {
    enable = true;
    openFirewall = true;
#    port = 1337;
  };
  services.uhub.local = {
    enable = true;
    settings = {
      hub_description = "muhackel's ADC hub hostet on datengrab";
      hub_name = "muhackel's Hub";
      max_users = 1024;
      server_bind_addr = "any";
      server_port = 1511;
    };
  };

  services.transmission = {
    enable = true;
    openFirewall = true;
    openRPCPort = true;
    user = "muhackel";
    group = "users";
    settings.rpc-bind-address = "0.0.0.0";
    settings.download-dir = "/media/temp/transmission/download";
    settings.incomplete-dir = "/media/temp/transmission/incomplete";
    settings.rpc-whitelist-enabled = false;
    settings.rpc-username = "muhackel";
    settings.rpc-password = "darwin";
    settings.rpc-authentication-required = true;
  };

  services.teamspeak3 = {
    enable = true;
    openFirewall = true;
  };

  services.factorio = {
    admins = [ "muhackel"];
    autosave-interval = 10;
    bind = "0.0.0.0";
    description = "muhackel's Factorio Server";
    enable = true;
    extraSettings = {
    };
    game-name = "[Dipl.Ing]";
    game-password = "jong";
    lan = true;
    loadLatestSave = true;
#    mods = [ "base" "elevated-rails" "quality" "quality" "AutoDeconstruct" "Bottleneck" "EvenMoreLight" "far-reach" "flib" "MegaBotStart" "Quick-Charge-Personal-Bots-Continued-Plus" "RateCalculator" "RitnLib" "RitnWaterfill" "Todo-List" "tree_collision" ];
    openFirewall = true;
    saveName = "server";
    token = "009a3d5a5321ffc1323e9767aa5f8b";
    username = "muhackel";
  };

  services.tlp = {
    enable = true;
    settings = {
      # CPU-Einstellungen
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      # Turbo-Boost deaktivieren (optional)
      CPU_BOOST_ON_AC = 0;
      CPU_BOOST_ON_BAT = 0;

      # PCIe ASPM NICHT aktivieren (wichtig für HBA)
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "default";

      # USB Autosuspend
      USB_AUTOSUSPEND = 1;
      USB_BLACKLIST = "usbhid"; # Maus/Tastatur nicht suspenden

      # SATA Link Power Management (ohne Spindown)
      SATA_LINKPWR_ON_AC = "med_power_with_dipm";
      SATA_LINKPWR_ON_BAT = "med_power_with_dipm";

      # Festplatten-APM/SPINDOWN deaktivieren
      DISK_DEVICES = "none";
      DISK_APM_LEVEL_ON_AC = "keep";
      DISK_APM_LEVEL_ON_BAT = "keep";
      DISK_SPINDOWN_TIMEOUT_ON_AC = "0";
      DISK_SPINDOWN_TIMEOUT_ON_BAT = "0";

      # Netzwerk: Wake-on-LAN nur falls benötigt
      # Nichts setzen = Standard bleibt

      # Audio-Powersave
      SOUND_POWER_SAVE_ON_AC = 1;
      SOUND_POWER_SAVE_ON_BAT = 1;

      # Radio-Module (falls nicht gebraucht)
      DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth wwan";

      # Powertop-Autotune beim Boot
      RESTORE_DEVICE_STATE_ON_STARTUP = 1;
    };
  };

  # Optional: Powertop als Service für weitere Optimierung
  powerManagement.powertop.enable = true;

  system.stateVersion = "25.11"; 
  system.activationScripts.cloneefi = ''
    rm -rf /bootbackup/*        #*/
    cp -r /boot/* /bootbackup   #*/
  '';

}