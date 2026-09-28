#!/system/bin/sh
# r3: deep poll - check hvigor process alive, cache dirs growing
B=/data/local/home/tmp/r3-build.log
R=/data/local/home/tmp/r3-build.rc
echo "== rc =="; test -f "$R" && sed -n '1p' "$R" || echo RUNNING
echo "== procs =="; ps -A 2>/dev/null | tail -n +2 | while read _p _pp _u _r _s _w _t _cmd; do
  case "$_cmd" in *hvigor*|*node*|*pack_hap*) echo "$_p $_cmd";; esac
done
echo "== arkts cache =="; du -sk /data/local/home/tmp/app/entry/build 2>/dev/null
echo "== hvigorlog mtime/size =="; ls -l /data/local/home/tmp/app/.hvigor/pack_hap_hvigor.log
echo "== hvigorlog tail =="; tail -5 /data/local/home/tmp/app/.hvigor/pack_hap_hvigor.log 2>&1
echo DONE
