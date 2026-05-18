{ lib, stdenvNoCC, deepfilternet }:

let
  configText = ''
    context.modules = [
      { name = libpipewire-module-filter-chain
        args = {
          node.description = "DeepFilterNet Noise Suppression"
          media.name       = "DeepFilterNet Noise Suppression"
          filter.graph = {
            nodes = [
              { type   = ladspa
                name   = deepfilter
                plugin = libdeep_filter_ladspa
                label  = deep_filter_mono
              }
            ]
          }
          capture.props = {
            node.name      = "capture.deepfilternet_source"
            node.passive   = true
            audio.rate     = 48000
            audio.channels = 1
            audio.position = [ MONO ]
          }
          playback.props = {
            node.name        = "deepfilternet_source"
            node.description = "Noise-Suppressed Microphone"
            media.class      = "Audio/Source"
            audio.rate       = 48000
            audio.channels   = 1
            audio.position   = [ MONO ]
          }
        }
      }
    ]
  '';
in
stdenvNoCC.mkDerivation {
  pname = "pipewire-deepfilternet";
  version = "1";

  dontUnpack = true;
  dontBuild = true;

  passAsFile = [ "configText" ];
  inherit configText;

  installPhase = ''
    runHook preInstall
    install -Dm644 "$configTextPath" \
      "$out/share/pipewire/pipewire.conf.d/99-input-denoising.conf"
    runHook postInstall
  '';

  passthru.requiredLadspaPackages = [ deepfilternet ];

  meta = with lib; {
    description = "PipeWire filter-chain config: virtual mic source with DeepFilterNet noise suppression";
    platforms = platforms.linux;
  };
}
