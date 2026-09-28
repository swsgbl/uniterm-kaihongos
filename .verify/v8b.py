import subprocess, os, zipfile
# pull iter8b from device? no - it exists locally. Verify its abc version: hybrid injection path
p = r'D:/uniterm/kaihongos/entry/build/store/outputs/store/entry-iter8b-signed.hap'
z = zipfile.ZipFile(p)
d = z.read('ets/modules.abc')
print('size', len(d), 'ver bytes [12:16]=', list(d[12:16]), 'hex head', d[:20].hex())
# parity reference
zp = zipfile.ZipFile(r'D:/uniterm/dist/uniterm-kaihongos-v1.0.0-parity.hap')
dp = zp.read('ets/modules.abc')
print('parity size', len(dp), 'ver bytes [12:16]=', list(dp[12:16]))
