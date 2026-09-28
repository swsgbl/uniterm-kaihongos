from PIL import Image
im = Image.open(r'D:/uniterm/evidence/M5/relay2/cur6-app.png')
# Center crop on the middle of the app (StartTab hero area), saved as PNG at full res
im.crop((0, 100, 700, 500)).save(r'D:/uniterm/evidence/M5/relay2/cur6-hero.png')
im.crop((0, 0, 700, 120)).save(r'D:/uniterm/evidence/M5/relay2/cur6-top.png')
print('ok')
