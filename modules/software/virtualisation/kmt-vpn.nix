{ config, lib, pkgs, ... }:
let
  cfg = config.local.features;
in
lib.mkIf cfg.kmtVpnVm {
  networking.networkmanager.unmanaged = [
    "interface-name:kmt-bue"
  ];

  systemd.network = {
    enable = true;
    wait-online.enable = false;

    netdevs."20-kmt-bue" = {
      netdevConfig = {
        Name = "kmt-bue";
        Kind = "tap";
      };

      tapConfig = {
        Group = "libvirtd";
        KeepCarrier = false;
      };
    };

    networks."20-kmt-bue" = {
      matchConfig.Name = "kmt-bue";
      linkConfig.RequiredForOnline = false;

      networkConfig = {
        DHCP = "no";
        ConfigureWithoutCarrier = false;
        IgnoreCarrierLoss = false;
        LinkLocalAddressing = "no";
        IPv6AcceptRA = false;
      };

      addresses = [
        {
          Address = "90.101.0.158/24";
        }
      ];

      routes = [
        {
          Destination = "90.0.0.0/8";
          Gateway = "90.101.0.1";
        }
        {
          Destination = "224.0.0.0/4";
        }
      ];
    };
  };
}
