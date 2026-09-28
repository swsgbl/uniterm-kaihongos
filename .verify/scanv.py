from PIL import Image
im = Image.open(r'D:/uniterm/evidence/M5/relay2/cur6.png')
px = im.load()
# scan left column x=100 vertical for structure boundaries
prev = None
for y in range(0, 900, 6):
    c = px[100, y]
    if prev and (abs(c[0]-prev[0]) + abs(c[1]-prev[1]) + abs(c[2]-prev[2]) > 60):
        print('y=%d %s -> %s' % (y, prev, c))
    prev = c
