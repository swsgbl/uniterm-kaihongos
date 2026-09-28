import zipfile, sys
z = zipfile.ZipFile(r'D:\uniterm\.verify\r3vm\vm-native-unsigned.hap')
print('total entries:', len(z.namelist()))
for n in z.namelist():
    i = z.getinfo(n)
    print(f'{n} | {i.file_size}')
abc = z.read('ets/modules.abc')
print('abc ver[12:16]:', list(abc[12:16]), 'magic:', abc[0:4])
import json
mj = json.loads(z.read('module.json'))
print('app:', {k:v for k,v in mj.get('app',{}).items() if k in ('bundleName','minAPIVersion','targetAPIVersion','apiReleaseType')})
print('deviceTypes:', mj['module']['deviceTypes'])
