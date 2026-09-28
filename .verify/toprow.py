from PIL import Image
im = Image.open(r'D:/uniterm/evidence/M5/relay2/cur6.png')
px = im.load()
for y in [2, 8, 15, 25, 35, 45]:
    row = [px[x, y] for x in range(60, 1600, 200)]
    print(y, row)
print('size', im.size)
