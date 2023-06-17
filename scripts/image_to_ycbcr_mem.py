from PIL import Image
import sys


image = Image.open(sys.argv[1]).convert('YCbCr')
image_bytes = []
for y in range(120):
    for x in range(200):
        yv, cb, cr = image.getpixel((x, y))
        image_bytes.extend([yv << 16 | cb << 8 | cr])

with open('output.mem', 'w') as f:
    for b in image_bytes:
        f.write(f'{b:02x} ')
