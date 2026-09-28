import zipfile, shutil, os
SRC = r'D:\uniterm\.verify\r3vm\vm-native-unsigned.hap'
OUT = r'D:\uniterm\.verify\r3vm\uniterm-vm-native-7so-unsigned.hap'
HAR = r'D:\uniterm\kaihongos\thirdparty\libssh-x86_64-har\libs\x86_64'
E2  = r'D:\uniterm\kaihongos\entry\libs\x86_64'
so_list = [
    (HAR, 'libssh_ohos_napi.so'),
    (HAR, 'libcrypto.so.3'),
    (HAR, 'libssh.so.4'),
    (HAR, 'libssl.so.3'),
    (HAR, 'libc++_shared.so'),
    (E2,  'liblocalpty.so'),
    (E2,  'librdpproxy.so'),
]
zin = zipfile.ZipFile(SRC)
if os.path.exists(OUT): os.remove(OUT)
zout = zipfile.ZipFile(OUT, 'w', zipfile.ZIP_STORED)
for item in zin.infolist():
    if item.filename.startswith('libs/'):
        continue  # no libs present anyway
    zout.writestr(item, zin.read(item.filename))
for d, n in so_list:
    p = os.path.join(d, n)
    assert os.path.exists(p), f'missing {p}'
    with open(p, 'rb') as f:
        zout.writestr(f'libs/x86_64/{n}', f.read())
    print('injected', n, os.path.getsize(p))
zout.close()
# verify
z = zipfile.ZipFile(OUT)
print('--- final ---')
for n in z.namelist():
    print(f'{n} | {z.getinfo(n).file_size}')
abc = z.read('ets/modules.abc')
print('abc ver:', list(abc[12:16]))
print('OUT size:', os.path.getsize(OUT))
