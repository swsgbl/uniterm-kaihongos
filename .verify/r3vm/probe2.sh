#!/system/bin/sh
. /data/local/home/env.sh >/dev/null 2>&1
echo "PATH=$PATH" | tr ':' '\n' | sed -n '1,12p'
echo "== tools =="
for t in hvigorw hvigor ohos_packing_tool hap-sign-tool node cmake ninja clang; do
  printf '%s: ' "$t"; command -v "$t" 2>/dev/null || echo MISSING
done
echo "== sdk14 native =="
ls /data/local/home/.ohos/sdk/14 2>&1
ls /data/local/home/.ohos/sdk/14/native 2>&1 | sed -n '1,12p'
echo "== native bin =="
ls /data/local/home/.ohos/sdk/14/native/llvm/bin 2>&1 | sed -n '1,10p'
echo "== build-tools =="
ls /data/local/home/.ohos/sdk/14/build-tools 2>&1
echo DONE
