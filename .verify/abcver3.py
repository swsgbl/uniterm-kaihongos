import zipfile
# abc version check: bytes 4-8 of abc header are version (e.g. 12.0.6.0)
for p in [r'D:/uniterm/kaihongos/entry/build/default/intermediates/loader_out/default/ets/modules.abc']:
    d = open(p, 'rb').read(16)
    print(p.split('/')[-1], 'magic', d[:4], 'ver', '.'.join(str(b) for b in d[4:8]))
z = zipfile.ZipFile(r'D:/uniterm/dist/uniterm-kaihongos-v1.0.0-parity.hap')
d = z.read('ets/modules.abc')[:16]
print('parity abc ver', '.'.join(str(b) for b in d[4:8]), 'size', len(z.read('ets/modules.abc')))
z2 = zipfile.ZipFile(r'D:/uniterm/kaihongos/entry/build/default/outputs/default/entry-default-unsigned.hap')
d2 = z2.read('ets/modules.abc')[:16]
print('default-unsigned abc ver', '.'.join(str(b) for b in d2[4:8]), 'size', len(z2.read('ets/modules.abc')))
