import zipfile
z = zipfile.ZipFile(r'D:/uniterm/dist/uniterm-kaihongos-v1.0.0-parity.hap')
for f in z.namelist():
    print(f, z.getinfo(f).file_size)
