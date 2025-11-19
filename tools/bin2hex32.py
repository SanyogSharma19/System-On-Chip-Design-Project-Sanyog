#!/usr/bin/env python3
import sys

if len(sys.argv) != 3:
    print("Usage: bin2hex32.py input.bin output.hex")
    sys.exit(1)

inp = sys.argv[1]
out = sys.argv[2]

data = open(inp, "rb").read()

# pad to multiple of 4 bytes
if len(data) % 4 != 0:
    data += b"\x00" * (4 - (len(data) % 4))

with open(out, "w") as f:
    # each line = 32-bit little-endian word
    for i in range(0, len(data), 4):
        w0 = data[i + 0]
        w1 = data[i + 1]
        w2 = data[i + 2]
        w3 = data[i + 3]
        word = w0 | (w1 << 8) | (w2 << 16) | (w3 << 24)
        f.write(f"{word:08x}\n")