# Workaround: libnfc-nci linkt nfcDemoApp ohne libstdc++/libm
#
# Das Autotools-Buildsystem von linux_libnfc-nci linkt das finale Binary mit
# gcc statt g++. Solange die Toolchain libstdc++ implizit mitzog, fiel das nicht
# auf; mit dem nixpkgs-Stand vom 2026-08-02 (binutils 2.46) bricht der Link:
#   undefined reference to `operator delete(void*, unsigned long)'
#   undefined reference to `vtable for __cxxabiv1::__class_type_info'
#   undefined reference to `lrint'
#
# Fix: libstdc++ und libm explizit an den Linker geben.
#
# Gezogen wird das Paket ueber hardware.nfc-nci.enable (nur HAL9000, siehe
# modules/hardware/lenovo-tp25/nfc.nix).
#
# Entfernen wenn:
#   - nixpkgs bzw. upstream den Link-Schritt auf g++ (CXXLD) umstellt.
# Test: Overlay-Import in configuration.nix auskommentieren, nix flake check.
final: prev:
{
  libnfc-nci = prev.libnfc-nci.overrideAttrs (old: {
    env = (old.env or { }) // {
      NIX_LDFLAGS = "-lstdc++ -lm";
    };
  });
}
