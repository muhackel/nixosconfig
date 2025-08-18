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
  ];
  networkingpkgs = with pkgs; [
    arp-scan
    ethtool
    ipcalc
    netcat-gnu
    iputils
    iptraf-ng
    kismet
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

  programs.iftop.enable = true;

  programs.winbox = {
    enable = true;
    openFirewall = true;
    package = pkgs.winbox4;
  };
}
