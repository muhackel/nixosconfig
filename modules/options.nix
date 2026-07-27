{ lib, ... }:

{
  options.local.features = {
    xmonad = lib.mkEnableOption "xmonad X11/Xserver desktop environment";
    plasma6 = lib.mkEnableOption "KDE Plasma 6 Wayland desktop environment";
    hamradio = lib.mkEnableOption "ham radio software";
    networking = lib.mkEnableOption "networking tools";
    nfc = lib.mkEnableOption "NFC tools";
    ptls = lib.mkEnableOption "PTLS tools";
    games = lib.mkEnableOption "gaming software";
    genesis = lib.mkEnableOption "Genesis JavaFX-App Wrapper (imperativ unter /opt)";
    comlink6 = lib.mkEnableOption "Commlink6 JavaFX-Updater Wrapper (imperativ unter /opt)";
    vmwareHost = lib.mkEnableOption "VMware host virtualisation";
    docker = lib.mkEnableOption "Docker container runtime";
    winboat = lib.mkEnableOption "Winboat tools";
    virtualbox = lib.mkEnableOption "VirtualBox virtualisation";
    libvirt = lib.mkEnableOption "libvirt virtualisation";
    sound = lib.mkEnableOption "PipeWire sound stack with DeepFilterNet noise suppression";
    bootloaderResyncAfterGc = lib.mkEnableOption "Bootloader/ESP nach automatischem nix-gc neu synchronisieren";
  };

  options.local.userExtraGroups = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Additional groups for user muhackel contributed by feature modules.";
  };
}
