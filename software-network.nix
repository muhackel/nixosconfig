{
  config,
  lib,
  pkgs,
  ...
}:
let
  gnspkgs = with pkgs; [
    gns3-gui
    inetutils
    ciscoPacketTracer8
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
{


  environment.systemPackages = gnspkgs ++ networkingpkgs;

  services.atftpd.enable = true;

  services.gns3-server = {
    enable = true;
    dynamips.enable = true;
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

  programs.iftop.enable = true;

  programs.mtr.enable = true;

  programs.winbox = {
    enable = true;
    openFirewall = true;
    package = pkgs.winbox4;
  };
}
