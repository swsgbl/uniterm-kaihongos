#!/system/bin/sh
echo "=== full file ==="
cat /data/local/home/tmp/app/build-profile.json5
echo "=== od tail ==="
tail -c 32 /data/local/home/tmp/app/build-profile.json5 | od -c
echo DONE_R2_SEE3
