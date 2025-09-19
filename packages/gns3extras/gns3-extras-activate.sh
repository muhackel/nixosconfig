#!/bin/sh
set -euo pipefail

# This script creates symlinks in /var/lib/gns3 that point to the files
# packaged in this derivation. It will overwrite existing symlinks but
# will never overwrite existing non-symlink files (it will skip them).
#
# Usage:
#   gns3-extras-activate
# or
#   gns3-extras-activate /absolute/path/to/source-root

# Determine the store root by resolving the script location and walking
# up from .../bin/gns3-extras-activate to the package root. Then set the
# packaged files root under var/lib/gns3 within that store path.
# Resolve script path in a portable way (avoid readlink -f requirement)
case "$0" in
  /*) script_path="$0" ;;
  *) script_path="$(pwd -P)/$0" ;;
esac
# If the script path is a symlink, try to resolve it without readlink
if [ -L "$script_path" ]; then
  # cd to parent and use pwd -P to resolve
  script_dir=$(cd "$(dirname "$script_path")" >/dev/null 2>&1 && pwd -P || true)
  script_path="$script_dir/$(basename "$script_path")"
fi
pkg_root=$(dirname "$(dirname "$script_path")")
SRC_ROOT="$pkg_root/var/lib/gns3"

# allow overriding (useful for tests)
if [ "$#" -ge 1 ] && [ -n "$1" ]; then
  SRC_ROOT="$1"
fi

if [ ! -d "$SRC_ROOT" ]; then
  echo "Source root does not exist: $SRC_ROOT" >&2
  exit 1
fi

# iterate over all regular files and packaged symlinks; preserve filenames
# robustly using NUL separation
find "$SRC_ROOT" \( -type f -o -type l \) -print0 | while IFS= read -r -d '' src; do
  # compute path relative to SRC_ROOT using POSIX parameter expansion
  # (avoids requiring external tools like sed)
  relpath=${src#"$SRC_ROOT"/}
  dest="/var/lib/gns3/$relpath"
  destdir=$(dirname "$dest")
  mkdir -p "$destdir"

  if [ -L "$dest" ]; then
    # existing symlink: remove and recreate so it points to our packaged file
    rm -f "$dest"
    ln -s "$src" "$dest"
    chown -h gns3:gns3 "$dest" 2>/dev/null || chown --no-dereference gns3:gns3 "$dest" 2>/dev/null || true
    echo "(symlink overwritten) $dest -> $src"
  elif [ -e "$dest" ]; then
    # exists and is NOT a symlink -> do not touch
    echo "(skip existing non-symlink) $dest" >&2
  else
    # no file exists -> create symlink
    ln -s "$src" "$dest"
    chown -h gns3:gns3 "$dest" 2>/dev/null || chown --no-dereference gns3:gns3 "$dest" 2>/dev/null || true
    echo "(symlink created) $dest -> $src"
  fi
done

