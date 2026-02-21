{
  config,
  lib,
  pkgs,
  ...
}:
let
  gns3extras = pkgs.callPackage ../../../packages/gns3extras { };

  gnspkgs = with pkgs; [
    gns3-gui
    inetutils
    #ciscoPacketTracer8
    gns3extras
  ];
  networkingpkgs = with pkgs; [
    arp-scan
    ethtool
    ipcalc
    netcat-gnu
    inetutils
    iputils
    iptraf-ng
    kismet
    nbtscan
    netdiscover
    #netsniff-ng BROKEN
    nmap
    #nomachine-client
    zenmap
  ];
 in
lib.mkIf config.local.features.networking
{
  #nixpkgs.overlays = [ 
  #  (import ../../../overlays/ciscoPacketTracer8) 
  #];
  environment.systemPackages = gnspkgs ++ networkingpkgs;

  # Run the gns3extras activation script on system activation so the
  # symlinks in /var/lib/gns3 are created/updated automatically. We keep
  # the invocation tolerant (|| true) so activation won't fail the whole
  # activation if something about gns3 extras can't be applied.
  system.activationScripts.gns3extras = {
    supportsDryActivation = true;
    text = ''
      #!/bin/sh
      # Only run if system uptime is at least 30 seconds
      if [ $(cat /proc/uptime | cut -d. -f1) -ge 30 ]; then
        # invoke activation script shipped inside the gns3extras package
        ${gns3extras}/bin/gns3-extras-activate || true
      else
        echo "gns3extras activation script skipped due to uptime < 30s"
      fi
    '';
  };

  services.atftpd.enable = true;

  services.gns3-server = {
    enable = true;
    dynamips.enable = false;
    ubridge.enable = true;
    vpcs.enable = true;
  };

  services.iperf3 = {
    enable = true;
    openFirewall = true;
    #port = 5201;
  };

  programs.wireshark = {
    enable = true;
    dumpcap.enable = true;
    usbmon.enable = true;
    package = pkgs.wireshark;
  };
  local.userExtraGroups = [ "wireshark" ];

  programs.iftop.enable = true;

  programs.mtr.enable = true;

  programs.winbox = {
    enable = true;
    openFirewall = true;
    package = pkgs.winbox4;
  };
}

