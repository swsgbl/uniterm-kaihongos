import zipfile
# compare module.json: iter8b (good, hybrid-injected) vs store-unsigned
for tag, p, n in [
    ('ITER8B', r'D:/uniterm/kaihongos/entry/build/store/outputs/store/entry-iter8b-signed.hap', 'module.json'),
    ('STORE-UN', r'D:/uniterm/kaihongos/entry/build/store/outputs/store/entry-store-unsigned.hap', 'module.json'),
]:
    z = zipfile.ZipFile(p)
    print('=====', tag)
    print(z.read(n).decode('utf-8')[:700])
