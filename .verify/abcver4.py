import zipfile
def ver(p, name):
    z = zipfile.ZipFile(p)
    d = z.read(name)[:16]
    return '.'.join(str(b) for b in d[4:8]), len(z.read(name))

# compare hybrid2 (worked) vs loader_out abc
print('hybrid2 hap ets/modules.abc:', ver(r'D:/uniterm/kaihongos/entry/build/default/outputs/default/entry-m5r2-hybrid2.hap', 'ets/modules.abc'))
print('iter6 signed:', ver(r'D:/uniterm/kaihongos/entry/build/default/outputs/default/entry-iter6-signed.hap', 'ets/modules.abc'))
print('parity:', ver(r'D:/uniterm/dist/uniterm-kaihongos-v1.0.0-parity.hap', 'ets/modules.abc'))
