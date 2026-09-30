#!/system/bin/sh
# r2: see full compile errors
grep -n "ERROR" /data/local/tmp/r2-pack.log | head -30
echo "=== around SftpPanel ==="
grep -B2 -A4 "SftpPanel" /data/local/tmp/r2-pack.log | head -40
echo DONE_R2_ERR
