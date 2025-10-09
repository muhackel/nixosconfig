{
  config,
  lib,
  pkgs,
  wantsNetworking,
  ...
}:
let
  gns3extras = pkgs.callPackage ../../../packages/gns3extras { };

  gnspkgs = with pkgs; [
    gns3-gui
    inetutils
    ciscoPacketTracer8
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
    netsniff-ng
    nmap
    nomachine-client
    zenmap
  ];
 in
lib.mkIf wantsNetworking 
{
  nixpkgs.overlays = [ 
    (import ../../../overlays/ciscoPacketTracer8) 
  ];
  environment.systemPackages = gnspkgs ++ networkingpkgs;

  # Run the gns3extras activation script on system activation so the
  # symlinks in /var/lib/gns3 are created/updated automatically. We keep
  # the invocation tolerant (|| true) so activation won't fail the whole
  # activation if something about gns3 extras can't be applied.
  system.activationScripts.gns3extras = {
    text = ''
      #!/bin/sh
      # invoke activation script shipped inside the gns3extras package
      ${gns3extras}/bin/gns3-extras-activate || true
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
    package = pkgs.wireshark-qt;
  };
  users.users.muhackel.extraGroups = [ "wireshark" ];

  programs.iftop.enable = true;

  programs.mtr.enable = true;

  programs.winbox = {
    enable = true;
    openFirewall = true;
    package = pkgs.winbox4;
  };
}

