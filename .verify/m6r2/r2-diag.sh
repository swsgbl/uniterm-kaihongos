#!/system/bin/sh
# r2: diagnose SDK component missing
echo "=== full pack log ==="
cat /data/local/tmp/r2-pack.log
echo "=== env ==="
export PATH=/data/local/home/.local/bin:$PATH
which pack_hap
echo "=== hvigor-config ==="
cat /data/local/home/tmp/app/hvigor/hvigor-config.json5
echo DONE_R2_DIAG
