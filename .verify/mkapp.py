from PIL import Image
im = Image.open(r'D:/uniterm/evidence/M5/relay2/cur6.png')
# full-frame small jpg
im2 = im.resize((im.width // 2, im.height // 2))
im2.save(r'D:/uniterm/evidence/M5/relay2/cur6-small.jpg', quality=88)
# app window only: from the y=450 edge scan, app content starts ~x=266
im3 = im.crop((266, 0, 1600, 900))
im3.save(r'D:/uniterm/evidence/M5/relay2/cur6-app.png')
im3.resize((im3.width // 2, im3.height // 2)).save(r'D:/uniterm/evidence/M5/relay2/cur6-app-small.jpg', quality=88)
print('ok')
