from PIL import Image
im = Image.open(r'D:/uniterm/evidence/M5/relay2/cur6.png')
# The app window seems to start around x=266. Take a wide center crop at full resolution
im.crop((266, 0, 1600, 460)).save(r'D:/uniterm/evidence/M5/relay2/cur6-A.png')
im.crop((266, 460, 1600, 900)).save(r'D:/uniterm/evidence/M5/relay2/cur6-B.png')
print('ok')
