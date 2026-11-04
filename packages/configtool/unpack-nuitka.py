import os
import struct
import sys

import zstandard

binary, out = sys.argv[1], os.path.abspath(sys.argv[2])
data = open(binary, "rb").read()

shoff, = struct.unpack("<Q", data[0x28:0x30])
shentsize, shnum = struct.unpack("<HH", data[0x3A:0x3E])
start = shoff + shentsize * shnum
magic = data[start:start + 3]
if magic != b"KAY":
    sys.exit(f"kein Nuitka-Onefile-Payload hinter dem ELF (Magic {magic!r})")

payload = zstandard.ZstdDecompressor().decompressobj().decompress(data[start + 3:])

pos = count = 0
while True:
    end = payload.index(b"\0", pos)
    name = payload[pos:end].decode()
    pos = end + 1
    if not name:
        break
    flags = payload[pos]
    size, = struct.unpack("<Q", payload[pos + 1:pos + 9])
    pos += 9
    dst = os.path.normpath(os.path.join(out, name))
    if not dst.startswith(out + os.sep):
        sys.exit(f"Pfad außerhalb des Ziels: {name}")
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    with open(dst, "wb") as f:
        f.write(payload[pos:pos + size])
    os.chmod(dst, 0o755 if flags & 1 else 0o644)
    pos += size
    count += 1

if pos != len(payload):
    sys.exit(f"{len(payload) - pos} Bytes hinter dem Endmarker")
print(f"{count} Dateien entpackt")
