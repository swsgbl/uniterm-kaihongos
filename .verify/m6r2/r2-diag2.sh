#!/system/bin/sh
# r2: inspect hvigor log + .ohos state
echo "=== hvigor log tail ==="
tail -30 /data/local/home/tmp/app/.hvigor/pack_hap_hvigor.log 2>/dev/null
echo "=== .ohos ==="
ls /data/local/home/.ohos/ 2>/dev/null
echo "=== sdk dirs ==="
ls /data/local/home/.ohos/sdk 2>/dev/null || ls /data/local/home/sdk 2>/dev/null
echo "=== home tmp ==="
ls /data/local/home/tmp/ | head -20
echo DONE_R2_DIAG2
