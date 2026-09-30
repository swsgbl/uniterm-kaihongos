#!/system/bin/sh
grep -E "^[0-9]+ ERROR|ArkTS:ERROR" /data/local/tmp/r2-pack.log | head -30
echo "=== contexts ==="
grep -A2 "ArkTS:ERROR" /data/local/tmp/r2-pack.log | head -80
echo DONE_R2_ERR2
