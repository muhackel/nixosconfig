# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./general.nix
      ./hardware-configuration.nix
      ./hardware-lenovo-tp25.nix
      ./hardware-bluetooth.nix
      ./user-muhackel.nix
      ./software-ptls.nix
      ./software-hamradio.nix
      ./software-virtualisation.nix
    ];
  
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


  services.xserver.xkb.extraLayouts = 
    {
      fancy_us = {
        description = "English (US) Apple";
        symbolsFile = pkgs.writeText "custom-apple.xkb" (builtins.readFile ./custom-apple-symbols.xkb);
        languages = [ "en" ]; 
      };
    };

  services.xserver.xkb.layout = "fancy_us";
  services.xserver.xkb.variant = "";
  #services.xserver.xkb.options = "altgr-intl,altgr:altgr,terminate:ctrl_alt_bksp";
  services.xserver.xkb.options = "terminate:ctrl_alt_bksp";
  
  #sound.enable = true;
  services = {
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;

    desktopManager.plasma6.enable = true;
    xserver = {
      enable = true;
      enableCtrlAltBackspace = true;
      #deviceSection = ''
      #  Option "DRI" "3"
      #  Option "TearFree" "true"
      #'';
      #virtualScreen = {
      #  x=1920;
      #  y=1080;
      #};
      #displayManager.lightdm.enable = true;
      windowManager = { 
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
          enableConfiguredRecompile = true;
          config = ./xmonad.hs;
        };
      };
    };
    libinput = {
        enable = true;
    };
    picom = {
      enable = true;
      opacityRules = [
        "80:class_g = 'Alacritty' && focused"
        "80:class_g = 'Alacritty' && !focused"
      ];
    };
    syncthing = {
      enable = true;
    };
    blueman = {
      enable = false;
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
      };
      wireplumber = {
        enable = true;
      };
      pulse = {
        enable = true;
      };
    };
    printing = {
      enable = true;
    };
    geoclue2 = {
      enable = false;
      enableWifi = true;
      enableModemGPS = true;
    };
    emacs = {
      enable = true;
      package = pkgs.emacs-gtk;
    };
    fstrim = {
      enable = true;
    };
    fwupd = {
      enable = true;
    };
    fprintd = {
      enable = false;
      tod= {
        enable = false;
        driver = pkgs.libfprint-2-tod1-vfs0090;
      };
    };
    
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users = {
      test = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "docker"
          "libvirtd"
          "networkmanager"
          "vboxusers"
          "plugdev"
          "uucp"
        ];
        shell = pkgs.zsh;
        linger = true;
        initialPassword = "1qaz!QAZ";
        packages = with pkgs; [

        ];
      };
    };
  };

  

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ###system/basic
    fwupd
    zfs
    oh-my-posh
    arandr
    autorandr
    alacritty
    wget
    pciutils
    usbutils
    htop
    nvtopPackages.full
    dysk
    #xorg.xbacklight
    #brightnessctl
    rclone
    git
    alsa-utils
    killall
    i7z
    glxinfo
    xorg.xmodmap
    unzip

    ###system/*ui
    ranger
    solaar
    rclone-browser
    networkmanagerapplet
    github-desktop
    #pamixer
    #pasystray
    #libsForQt5.qt5ct
    #qt6ct

    ###xmonad tools
    dzen2
    conky
    dmenu
    rofi
    haskellPackages.xmobar
    stalonetray
    trayer
    dunst
    caffeine-ng
    #redshift
    i3lock-fancy
    xss-lock
    lxappearance

    ### Messaging
    signal-desktop
    ferdium
    discord
    vscode

    libreoffice
    google-chrome
    ausweisapp
    mate.caja
    mpv

    python311Full
    python311Packages.tkinter

    #steam-run
    drawio
    yed
    plantuml
    texliveFull
    virt-manager
    nixos-generators
    lutris
    jellyfin-media-player
    kdePackages.yakuake
    kdePackages.filelight
    camunda-modeler
    
    ### SDR Shit
    
    
    ### Proxmark/RFID Shit
    proxmark3
  ];
  fonts = {
    packages = with pkgs; [
      nerd-fonts.hack
      xkcd-font
    ];
  };
  

  

  #programs.light.enable = true;

  programs.git = {
    enable = true;
  };
  programs.evolution = {
    enable = true;
  };
  programs.zsh = {
    enable = true;
  };
  

  programs.steam = {
    enable = true;
  };
  programs.direnv.enable = true;

  programs.hyprland.enable = true;

  location.provider = "manual";
  location.latitude = "48.790457";
  location.longitude = "9.204377";
  qt = {
    enable = true;
    #style = "gtk2";
    platformTheme = "qt5ct";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
  security.sudo.wheelNeedsPassword = false;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}

