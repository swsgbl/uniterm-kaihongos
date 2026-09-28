import zipfile
z = zipfile.ZipFile(r'D:/uniterm/kaihongos/entry/build/store/outputs/store/entry-iter8b-signed.hap')
for f in z.namelist():
    print(f, z.getinfo(f).file_size)
