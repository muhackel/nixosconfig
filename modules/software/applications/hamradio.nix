{ config, lib, pkgs, ... }:
let
  hampkgs = with pkgs; [
    hackrf
    gqrx
    wsjtx
  ];
in
lib.mkIf config.local.features.hamradio {
  users.groups.ham = {};
  users.users.muhackel.extraGroups = [ "ham" ];
  environment.systemPackages = hampkgs;
  services.udev.extraRules = ''
    # original RTL2832U vid/pid (hama nano, for example)
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2832", ENV{ID_SOFTWARE_RADIO}="1", MODE="0660", GROUP="ham"
    #HackRF
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6089", ENV{ID_SOFTWARE_RADIO}="1", MODE="0660", GROUP="ham"

  '';
  systemd.user.services.virtual-sdr-sink = {
    description = "Create PipeWire virtual sink for SDR (VirtualSDR)";
    after = [ "pipewire.service" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.pulseaudio}/bin/pactl load-module module-null-sink sink_name=VirtualSDR sink_properties=device.description=VirtualSDR || true
      '';
      RemainAfterExit = "yes";
    };
  };
}