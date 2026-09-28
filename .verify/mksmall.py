from PIL import Image
im = Image.open(r'D:/uniterm/evidence/M5/relay2/cur6-right.png')
# downscale to fit and save as jpg for the vision model
im2 = im.resize((im.width // 2, im.height // 2))
im2.save(r'D:/uniterm/evidence/M5/relay2/cur6-right-small.jpg', quality=88)
print(im2.size)
