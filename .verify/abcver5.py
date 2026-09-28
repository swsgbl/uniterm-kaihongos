import zipfile
def hd(p, name='ets/modules.abc'):
    z = zipfile.ZipFile(p)
    d = z.read(name)[:24]
    print(p.split('/')[-1], d.hex(' '))
    # candidate version fields
    print('  [4:8]=', list(d[4:8]), ' [8:12]=', list(d[8:12]))

hd(r'D:/uniterm/dist/uniterm-kaihongos-v1.0.0-parity.hap')
hd(r'D:/uniterm/kaihongos/entry/build/default/outputs/default/entry-m5r2-hybrid2.hap')
hd(r'D:/uniterm/kaihongos/entry/build/default/outputs/default/entry-default-unsigned.hap')
d = open(r'D:/uniterm/kaihongos/entry/build/default/intermediates/loader_out/default/ets/modules.abc','rb').read(24)
print('loader_out', d.hex(' '), list(d[4:8]), list(d[8:12]))
