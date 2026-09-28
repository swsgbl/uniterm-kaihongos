from PIL import Image
im = Image.open(r'D:/uniterm/evidence/M5/relay2/cur6.png')
im.crop((266, 460, 1600, 900)).resize(((1600-266)//2, (900-460)//2)).save(r'D:/uniterm/evidence/M5/relay2/cur6-Bs.jpg', quality=90)
im.crop((266, 100, 1100, 460)).save(r'D:/uniterm/evidence/M5/relay2/cur6-L.png')
print('ok')
