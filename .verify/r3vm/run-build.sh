#!/system/bin/sh
# r3: run pack_hap build (release) in background, log to file
cd /data/local/home/tmp/app
rm -f /data/local/home/tmp/r3-build.log /data/local/home/tmp/r3-build.rc
nohup sh -c 'timeout 280 /data/local/home/.local/bin/pack_hap -m release /data/local/home/tmp/app; echo RC=$? > /data/local/home/tmp/r3-build.rc' > /data/local/home/tmp/r3-build.log 2>&1 &
echo "bg pid=$!"
sleep 3
tail -5 /data/local/home/tmp/r3-build.log
