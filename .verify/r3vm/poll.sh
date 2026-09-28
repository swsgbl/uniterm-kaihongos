#!/system/bin/sh
B=/data/local/home/tmp/r3-build.log
R=/data/local/home/tmp/r3-build.rc
echo "== tail =="; tail -6 "$B" 2>&1
echo "== rc =="; test -f "$R" && sed -n '1p' "$R" || echo RUNNING
echo "== size =="; wc -c < "$B" 2>/dev/null
echo "== hap =="; ls -l /data/local/home/tmp/app/out_release.hap 2>&1
echo "== hvigorlog tail =="; tail -4 /data/local/home/tmp/app/.hvigor/pack_hap_hvigor.log 2>&1
echo DONE
