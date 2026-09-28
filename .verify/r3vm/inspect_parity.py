import zipfile, sys
z = zipfile.ZipFile(r'D:\uniterm\dist\uniterm-kaihongos-v1.0.0-parity.hap')
names = z.namelist()
print('total entries:', len(names))
for n in names:
    if n.endswith('.so') or n.endswith('.abc') or 'profile' in n or n in ('module.json','pack.info','p7b'):
        i = z.getinfo(n)
        print(f'{n} | size={i.file_size} compress={i.compress_type} crc={i.CRC:08x}')
abc = z.read('ets/modules.abc')
print('abc ver[12:16]:', list(abc[12:16]), 'magic:', abc[0:4])
