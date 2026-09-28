import zipfile
# compare module.json of parity (good) vs default-unsigned (bad)
for tag, p in [('PARITY', r'D:/uniterm/dist/uniterm-kaihongos-v1.0.0-parity.hap'), ('DEFAULT', r'D:/uniterm/kaihongos/entry/build/default/outputs/default/entry-default-unsigned.hap')]:
    z = zipfile.ZipFile(p)
    print('=====', tag)
    print(z.read('module.json').decode('utf-8'))
