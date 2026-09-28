import zipfile, re, os
# iter7 signed lived under default outputs (older flow). find it
cands = [
 r'D:/uniterm/kaihongos/entry/build/default/outputs/default/entry-iter7-signed.hap',
]
for p in cands:
    if not os.path.exists(p):
        print('missing', p); continue
    z = zipfile.ZipFile(p)
    d = z.read('ets/modules.abc')[:80]
    m = re.search(rb'\d+\.\d+\.\d+\.\d+', d)
    print(p.split('/')[-1], d[:24].hex(), m.group().decode() if m else 'nf')
# list any iter7 artifacts anywhere
for root in [r'D:/uniterm/kaihongos/entry/build']:
    for r, ds, fs in os.walk(root):
        for f in fs:
            if 'iter7' in f or 'relay' in f.lower():
                print(os.path.join(r, f))
