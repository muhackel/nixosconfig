# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
 
in
{
  imports =
    [ # Include the results of the hardware scan.

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
  
  #sound.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.desktopManager.plasma6 = {
    enable = true;
  };

  services.xserver = {
      enable = false;
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

  services.libinput = {
        enable = true;
  };

  services.picom = {
    enable = true;
    opacityRules = [
      "80:class_g = 'Alacritty' && focused"
      "80:class_g = 'Alacritty' && !focused"
    ];
  };

  services.syncthing = {
      enable = true;
  };

  services.blueman = {
      enable = false;
  };
  services.pipewire = {
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

  services.printing = {
    enable = true;
  };

  services.geoclue2 = {
    enable = false;
    enableWifi = true;
    enableModemGPS = true;
  };

  services.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
  };
  services.fstrim = {
    enable = true;
  };
  services.fwupd = {
    enable = true;
  };
  services.fprintd = {
    enable = true;
    tod= {
      enable = false;
      driver = pkgs.libfprint-2-tod1-vfs0090;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ###system/basic




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
    nixfmt-rfc-style

    ###system/*ui
    ranger
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
    #redshift
    i3lock-fancy
    xss-lock
    lxappearance

    ### Messaging

    vscode

    libreoffice-fresh
    gimp3
    google-chrome
    ausweisapp
    mate.caja
    mpv
    freecad

    python311Full
    python311Packages.tkinter

    #steam-run
    drawio
    yed
    plantuml
    texliveFull
    virt-manager
    nixos-generators
    #lutris
    kdePackages.yakuake
    kdePackages.filelight
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
  programs.vscode = {
    enable = true;
  };

  programs.steam = {
    enable = false;
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
  system.stateVersion = "25.11"; # Did you read the comment?
}

