from PIL import Image
 
WIDTH = 800
HEIGHT = 480
 
y_array = [[0.0 for _ in range(WIDTH)] for _ in range(HEIGHT)]
cb_array = [[0.0 for _ in range(WIDTH)] for _ in range(HEIGHT)]
cr_array = [[0.0 for _ in range(WIDTH)] for _ in range(HEIGHT)]
data = []
 
for y in range(HEIGHT):
    for x in range(WIDTH):
        yv = 127
        cb = 0#x % 256
        cr = x % 230 + 10 
        data.extend([yv, cb, cr])
 
image = Image.frombytes('YCbCr', (WIDTH, HEIGHT), bytes(data))
image.save('image.jpeg')

