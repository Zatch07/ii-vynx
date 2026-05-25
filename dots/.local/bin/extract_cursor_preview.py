#!/usr/bin/env python3
"""
extract_cursor_preview.py — Extract a preview PNG from an Xcursor file.
Usage: python3 extract_cursor_preview.py <cursor_file> <output_png> [target_size]
Exits 0 on success, non-zero on failure.
"""

import sys
import struct
import zlib
import os

def extract_xcursor_png(cursor_path, output_path, target_size=32):
    """Extract the best-matching frame from an Xcursor file and write a PNG."""
    try:
        with open(cursor_path, 'rb') as f:
            magic = f.read(4)
            if magic != b'Xcur':
                return False
            header_size, version, ntoc = struct.unpack('<III', f.read(12))

            chunks = []
            for _ in range(ntoc):
                chunk_type, subtype, position = struct.unpack('<III', f.read(12))
                chunks.append((chunk_type, subtype, position))

        IMAGE_TYPE = 0xFFFD0002
        image_chunks = [(t, s, p) for t, s, p in chunks if t == IMAGE_TYPE]
        if not image_chunks:
            return False

        # Pick the size closest to target_size (prefer larger if tied)
        best_chunk = min(image_chunks, key=lambda c: abs(c[1] - target_size))
        _, size, position = best_chunk

        with open(cursor_path, 'rb') as f:
            f.seek(position)
            # chunk header: header_size, type, chunk_size, version
            f.read(16)
            width, height, xhot, yhot, delay = struct.unpack('<IIIII', f.read(20))
            pixel_data = f.read(width * height * 4)

        # ARGB → RGBA conversion
        pixels = bytearray(width * height * 4)
        for i in range(width * height):
            argb = struct.unpack_from('<I', pixel_data, i * 4)[0]
            pixels[i*4]   = (argb >> 16) & 0xFF  # R
            pixels[i*4+1] = (argb >>  8) & 0xFF  # G
            pixels[i*4+2] =  argb        & 0xFF  # B
            pixels[i*4+3] = (argb >> 24) & 0xFF  # A

        # Build minimal PNG
        def png_chunk(ctype, data):
            body = ctype + data
            return struct.pack('>I', len(data)) + body + struct.pack('>I', zlib.crc32(body) & 0xFFFFFFFF)

        sig  = b'\x89PNG\r\n\x1a\n'
        ihdr = png_chunk(b'IHDR',
                         struct.pack('>II', width, height) + bytes([8, 6, 0, 0, 0]))
        raw  = b''.join(b'\x00' + bytes(pixels[r*width*4:(r+1)*width*4])
                        for r in range(height))
        idat = png_chunk(b'IDAT', zlib.compress(raw, 6))
        iend = png_chunk(b'IEND', b'')

        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with open(output_path, 'wb') as out:
            out.write(sig + ihdr + idat + iend)
        return True

    except Exception as e:
        return False


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <cursor_file> <output_png> [target_size]", file=sys.stderr)
        sys.exit(1)

    cursor_file = sys.argv[1]
    output_png  = sys.argv[2]
    target_size = int(sys.argv[3]) if len(sys.argv) > 3 else 32

    ok = extract_xcursor_png(cursor_file, output_png, target_size)
    sys.exit(0 if ok else 1)
