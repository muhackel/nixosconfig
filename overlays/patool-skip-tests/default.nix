# Workaround: python-patool 4.0.5 Test-Suite schlägt fehl (12 von 82) — reine
# Test-Environment-Probleme, keine Library-Logik:
#   - test_mime_*: libmagic liefert application/x-bzip2 statt x-tar für .tar.bz2.foo
#   - test_tar_*/test_pytarfile_*: "could not find list_bzip2/list_xz/list_lzma/
#     list_lzip" — Archiv-Programme fehlen im Test-PATH (Packaging-Regression).
# patool ist ein Leaf-Archivtool (via bottles); 70 Logik-Tests bleiben grün.
# Über pythonPackagesExtensions, damit alle Python-Versionen erfasst sind.
# Kann entfernt werden wenn nixpkgs die Test-Inputs/den Check upstream fixt.
final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyfinal: pyprev: {
      patool = pyprev.patool.overridePythonAttrs (_: {
        doCheck = false;
      });
    })
  ];
}
