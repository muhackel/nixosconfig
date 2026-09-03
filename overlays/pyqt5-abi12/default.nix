# PyQt5 5.15.11 mit dem letzten kompatiblen SIP-Codegenerator für ABI v12.
#
# SIP 6.16.1 baut PyQt5 unter Python 3.14 nicht mit der angeforderten ABI v12.
# Das betrifft unter anderem HPLIP und Asymptote aus texliveFull.
#
# Entfernen, sobald nixpkgs wieder eine kompatible PyQt5/SIP-Kombination liefert.
final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (_python-final: python-prev: let
      sipForPyQt5 = python-prev.sip.overridePythonAttrs (_old: rec {
        version = "6.15.3";
        src = final.fetchPypi {
          pname = "sip";
          inherit version;
          hash = "sha256-uyUWmD+fcW0yHlFXwA0N4MEkIuunO49DpEYQoPZiJDg=";
        };
      });
    in {
      pyqt5 = (python-prev.pyqt5.override { sip = sipForPyQt5; }).overrideAttrs (old: rec {
        version = "5.15.11";
        src = final.fetchPypi {
          pname = "PyQt5";
          inherit version;
          hash = "sha256-/aRXQ+u0ontLGlHG2O9FXEwbXWEMkNKTTHgCtcFVfFI=";
        };
        patches = builtins.tail old.patches;
        postPatch = old.postPatch + ''
          substituteInPlace project.py \
            --replace-fail \
              "args = ['pkg-config', '--cflags-only-I', '--libs dbus-1']" \
              "args = ['pkg-config', '--cflags-only-I', '--libs dbus-1', 'dbus-python']"
        '';
      });
    })
  ];
}
