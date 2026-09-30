#!/system/bin/sh
echo "=== VM build-profile sed-numbered ==="
sed -n '40,50p' /data/local/home/tmp/app/build-profile.json5
echo "=== md5 compare ==="
md5sum /data/local/home/tmp/app/build-profile.json5
head -c 16 /data/local/home/tmp/app/build-profile.json5 | od -c | head -3
echo DONE_R2_SEE2
