from PIL import Image
im = Image.open(r'D:/uniterm/evidence/M5/relay2/cur6.png')
px = im.load()
# horizontal scan at y=450 to find sidebar boundary
prev = None
edges = []
for x in range(0, 1600, 2):
    c = px[x, 450]
    if prev and (abs(c[0]-prev[0]) + abs(c[1]-prev[1]) + abs(c[2]-prev[2]) > 60):
        edges.append((x, prev, c))
    prev = c
print('y=450 edges:', edges[:12])
# what's the background left of x=300 at multiple rows?
for y in [100, 300, 700, 850]:
    print('row', y, [px[x, y] for x in [10, 100, 200, 290, 320, 400]])
