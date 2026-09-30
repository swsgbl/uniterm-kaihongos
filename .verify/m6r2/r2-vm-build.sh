#!/system/bin/sh
# r2: VM native build (pack_hap -m release)
export PATH=/data/local/home/.local/bin:$PATH
APP=/data/local/home/tmp/app
cd $APP || exit 1
rm -f out_release.hap
pack_hap -m release $APP > /data/local/tmp/r2-pack.log 2>&1
echo "PACK_EXIT=$?"
tail -5 /data/local/tmp/r2-pack.log
ls -la out_release.hap 2>&1
md5sum out_release.hap 2>&1
echo DONE_R2_BUILD
