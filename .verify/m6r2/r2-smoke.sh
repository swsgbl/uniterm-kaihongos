#!/system/bin/sh
# r2: smoke check - hilog for new bundle + screenshot
hilog -x | grep -E "oat\.|oneaiterm" | tail -8
echo "=== app proc ==="
ps -ef | grep oneaiterm | grep -v grep | head -3
echo DONE_R2_SMOKE
