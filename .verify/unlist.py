import zipfile
z = zipfile.ZipFile(r'D:/uniterm/kaihongos/entry/build/default/outputs/default/entry-default-unsigned.hap')
for f in z.namelist():
    print(f, z.getinfo(f).file_size)
