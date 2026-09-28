#!/system/bin/sh
uitest dumpLayout -p /data/local/home/tmp/r3-launch.json >/dev/null 2>&1
echo "uitest rc=$?"
# window / foreground
echo "== screen session =="
screenlayer -l 2>/dev/null | head -20 || true
echo "== app proc =="
ps -A | grep -i uniterm || echo "NO uniterm process"
echo "== top ability =="
dumpsys ability 2>/dev/null | grep -iE 'uniterm|foreground|active' | head -10
echo DONE
