"""Generate Daylist's geometric web icons using only Python's standard library."""
import math
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def render(path, size):
    scale = 3
    n = size * scale
    pixels = []
    rays = []
    for i in range(8):
        a = i * math.pi / 4
        rays.append(((50 + 30 * math.cos(a), 50 + 30 * math.sin(a)),
                     (50 + 36 * math.cos(a), 50 + 36 * math.sin(a))))
    segments = rays + [((40, 50), (47, 57)), ((47, 57), (61, 43))]

    def distance(x, y, a, b):
        dx, dy = b[0] - a[0], b[1] - a[1]
        t = max(0, min(1, ((x-a[0])*dx + (y-a[1])*dy)/(dx*dx+dy*dy)))
        return math.hypot(x-a[0]-t*dx, y-a[1]-t*dy)

    for y in range(n):
        row = []
        for x in range(n):
            px, py = (x+.5)*100/n, (y+.5)*100/n
            ink = abs(math.hypot(px-50, py-50)-21) <= 2.5
            ink = ink or any(distance(px, py, a, b) <= 2.5 for a, b in segments)
            row.append((41, 39, 25) if ink else (255, 212, 59))
        pixels.append(row)
    raw = bytearray()
    for y in range(size):
        raw.append(0)
        for x in range(size):
            for c in range(3):
                raw.append(round(sum(pixels[y*scale+j][x*scale+i][c]
                                     for j in range(scale) for i in range(scale))/(scale*scale)))

    def chunk(kind, data):
        return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind+data))

    data = b'\x89PNG\r\n\x1a\n'
    data += chunk(b'IHDR', struct.pack('>IIBBBBB', size, size, 8, 2, 0, 0, 0))
    data += chunk(b'IDAT', zlib.compress(bytes(raw))) + chunk(b'IEND', b'')
    (ROOT / path).write_bytes(data)


if __name__ == '__main__':
    render('web/favicon.png', 32)
    for size in (192, 512):
        render(f'web/icons/Icon-{size}.png', size)
        render(f'web/icons/Icon-maskable-{size}.png', size)
