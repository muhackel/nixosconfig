{ config, lib, ... }:

{
  options.local.features = {
    xmonad = lib.mkEnableOption "xmonad X11/Xserver desktop environment";
    plasma6 = lib.mkEnableOption "KDE Plasma 6 Wayland desktop environment";
    hamradio = lib.mkEnableOption "ham radio software";
    networking = lib.mkEnableOption "networking tools";
    nfc = lib.mkEnableOption "NFC tools";
    ptls = lib.mkEnableOption "PTLS tools";
    games = lib.mkEnableOption "gaming software";
    vmwareHost = lib.mkEnableOption "VMware host virtualisation";
    docker = lib.mkEnableOption "Docker container runtime";
    winboat = lib.mkEnableOption "Winboat tools";
    virtualbox = lib.mkEnableOption "VirtualBox virtualisation";
    libvirt = lib.mkEnableOption "libvirt virtualisation";
    kmtVpnVm = lib.mkEnableOption "lokale KMT-VPN-VM mit persistentem TAP";
    thinkpadBattery = lib.mkEnableOption "ThinkPad-Akkuwerkzeug (tlp + GUI)";
    plasmaManager = lib.mkEnableOption "plasma-manager verwaltet die Plasma-Konfiguration deklarativ";
    kwinXmonadLite = lib.mkEnableOption "kwin-xmonad-lite Layout-Controller (KWin-Skript)";
    sound = lib.mkEnableOption "PipeWire sound stack with DeepFilterNet noise suppression";
    bootloaderResyncAfterGc = lib.mkEnableOption "Bootloader/ESP nach automatischem nix-gc neu synchronisieren";
  };

  options.local.userExtraGroups = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Additional groups for user muhackel contributed by feature modules.";
  };

  config.assertions = [
    {
      assertion =
        !config.local.features.kwinXmonadLite
        || (config.local.features.plasma6 && config.local.features.plasmaManager);
      message = "local.features.kwinXmonadLite erfordert local.features.plasma6 und local.features.plasmaManager";
    }
  ];
}
