import zipfile
# entry-store-unsigned (09-28 08:29) - what abc did the store target produce this time?
z = zipfile.ZipFile(r'D:/uniterm/kaihongos/entry/build/store/outputs/store/entry-store-unsigned.hap')
d = z.read('ets/modules.abc')
print('store-unsigned abc size', len(d), 'ver[12:16]=', list(d[12:16]))
for f in z.namelist():
    print(f, z.getinfo(f).file_size)
