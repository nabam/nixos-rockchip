# Rewrites the RK3576 boot ROM header (v2, "RKNS") of a mainline u-boot-rockchip.bin
# into the layout of rkbin's RKBOOT/RK3576MINIALL.ini:
# the boost blob at 0x3ffc0000, the DDR blob at 0x3ff81000 (the address it is linked for),
# then U-Boot SPL at the boot ROM's default address.
# mkimage writes only the DDR blob and SPL, both at the default address.
#
# usage: idblock.py <u-boot-rockchip.bin> <boost.bin> <out>
import hashlib
import struct
import sys

SECTOR = 512
ALIGN = 8 * SECTOR
HEADER = 4 * SECTOR
ENTRIES = 0x78
ENTRY_SIZE = 0x58
HASH_OFFSET = 0x600

src, boost_path, out = sys.argv[1:]
data = open(src, "rb").read()
boost = open(boost_path, "rb").read()

magic, size_and_nimage, boot_flag = struct.unpack_from("<I4xII", data)
assert magic == 0x534E4B52, "not an RKNS header"
assert size_and_nimage >> 16 == 2, "expected mkimage's two images (DDR, SPL)"


def image(i):
    size_and_off = struct.unpack_from("<I", data, ENTRIES + i * ENTRY_SIZE)[0]
    off = (size_and_off & 0xFFFF) * SECTOR
    return data[off:off + (size_and_off >> 16) * SECTOR]


ddr, spl = image(0), image(1)
images = [(boost, 0x3FFC0000), (ddr, 0x3FF81000), (spl, 0xFFFFFFFF)]


def pad(b, n):
    return b + bytes(-len(b) % n)


hdr = bytearray(HEADER)
struct.pack_into("<I4xII", hdr, 0, magic, (len(images) << 16) | (HASH_OFFSET // 4), boot_flag)
body = bytearray()
off = ALIGN
for i, (blob, addr) in enumerate(images):
    blob = pad(blob, ALIGN)
    e = ENTRIES + i * ENTRY_SIZE
    struct.pack_into("<IIII", hdr, e, ((len(blob) // SECTOR) << 16) | (off // SECTOR), addr, 0, i + 1)
    hdr[e + 0x18:e + 0x18 + 32] = hashlib.sha256(blob).digest()
    body += blob
    off += len(blob)
hdr[HASH_OFFSET:HASH_OFFSET + 32] = hashlib.sha256(hdr[:HASH_OFFSET]).digest()

idb = pad(bytes(hdr), ALIGN) + bytes(body)
# U-Boot proper (the FIT) stays at its offset, after binman's 0xff fill.
fit = next(i for i in range(0, len(data), SECTOR) if data[i:i + 4] == b"\xd0\x0d\xfe\xed")
assert len(idb) <= fit, "idblock overlaps U-Boot proper"
open(out, "wb").write(idb + b"\xff" * (fit - len(idb)) + data[fit:])
