#!/system/bin/sh
# r2: inspect sdk/14 contents + compare build-profile vs r6 template
echo "=== sdk/14 ==="
ls /data/local/home/.ohos/sdk/14/
echo "=== r6 build-profile template (VM leftover) ==="
cat /data/local/home/tmp/r6-build-profile.json5
echo "=== current build-profile.json5 ==="
cat /data/local/home/tmp/app/build-profile.json5
echo DONE_R2_DIAG3
