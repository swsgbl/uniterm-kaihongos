#!/system/bin/sh
echo "=== profile bundle-name check ==="
grep -o '"bundle-name"[^,]*' "$OHOS_HOME/signature/app1-profile-release.p7b" 2>/dev/null | head -2
. /data/local/home/env.sh >/dev/null 2>&1
echo "OHOS_HOME=$OHOS_HOME"
ls "$OHOS_HOME/signature/" 2>/dev/null
echo DONE_R2_PROFILE_CHECK
