# Gewünschte RDV4-Variante für das „Knopf“-Script: HF_COLIN-Standalone-Firmware
# mit BlueShark/BTADDON. Behalten, solange nixpkgs diese Kombination nicht als
# Standard oder eigenes Paketattribut liefert.
final: prev: {
  proxmark3 = prev.proxmark3.override {
    standalone = "HF_COLIN";
    withBlueshark = true;
  };
}
