import zipfile
# check parity hap libs: are they v12-compatible (x86_64)?
z = zipfile.ZipFile(r'D:/uniterm/dist/uniterm-kaihongos-v1.0.0-parity.hap')
for f in z.namelist():
    if f.startswith('libs/'):
        print(f, z.getinfo(f).file_size)
