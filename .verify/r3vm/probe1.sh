#!/system/bin/sh
# r3 probe: VM toolchain + project state
echo "== env.sh =="; sed -n '1,40p' /data/local/home/env.sh 2>&1
echo "== OHOS_HOME tree =="; ls /data/local/home/.ohos 2>&1
echo "== sdk versions =="; ls /data/local/home/.ohos/sdk 2>&1
echo "== signature =="; ls /data/local/home/.ohos/signature 2>&1
echo "== tools on PATH =="
command -v hvigorw; command -v hvigor; command -v ohos_packing_tool; command -v hap-sign-tool; command -v node; command -v cmake; command -v ninja; command -v clang
echo "== tmp dir =="; ls /data/local/home/tmp 2>&1
echo "== fix-hap.cjs =="; ls -l /data/local/home/tmp/fix-hap.cjs 2>&1
echo "== app/entry libs =="; ls -R /data/local/home/tmp/app/entry/libs 2>&1 | sed -n '1,20p'
echo "== app/entry cpp =="; ls /data/local/home/tmp/app/entry/src/main/cpp 2>&1
echo "== thirdparty har =="; ls /data/local/home/tmp/app/thirdparty/libssh-x86_64-har 2>&1
echo "== har module.json5 =="; sed -n '1,30p' /data/local/home/tmp/app/thirdparty/libssh-x86_64-har/module.json5 2>&1
echo "== har oh-package =="; sed -n '1,20p' /data/local/home/tmp/app/thirdparty/libssh-x86_64-har/oh-package.json5 2>&1
echo "== prior build projects (028) =="
ls -d /data/local/home/tmp/*/ 2>&1
ls /data/local/home/tmp/app/.hvigor 2>&1
echo "== app.json5 =="; sed -n '1,20p' /data/local/home/tmp/app/AppScope/app.json5
echo "== entry module.json5 (head) =="; sed -n '1,40p' /data/local/home/tmp/app/entry/src/main/module.json5
echo "== disk =="; df -h /data 2>&1 | sed -n '1,3p'
echo "== ets imports of libssh (sample) =="
grep -rn "libssh_ohos_napi\|@ohos/libssh" /data/local/home/tmp/app/entry/src/main/ets --include=*.ets -l 2>/dev/null | sed -n '1,15p'
echo "== node ver =="; node -v 2>&1
echo "== hvigor home wrapper =="; ls /data/local/home/.ohos/hvigor_user_home/wrapper/tools 2>&1
echo DONE
