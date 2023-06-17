from PIL import Image

WIDTH = 800
HEIGHT = 480

y_array = [[0.0 for _ in range(WIDTH)] for _ in range(HEIGHT)]
cb_array = [[0.0 for _ in range(WIDTH)] for _ in range(HEIGHT)]
cr_array = [[0.0 for _ in range(WIDTH)] for _ in range(HEIGHT)]
data = []

for y in range(HEIGHT):
    for x in range(WIDTH):
        x %= 256
        y %= 256

        yv = 0
        cb = x
        cr = x

        data.extend([yv, cb if x % 2 == 0 else last_cb, cr if x % 2 == 0 else last_cr])
        last_cb = cb
        last_cr = cr

image = Image.frombytes('YCbCr', (WIDTH, HEIGHT), bytes(data))
image.save('output.jpeg')
