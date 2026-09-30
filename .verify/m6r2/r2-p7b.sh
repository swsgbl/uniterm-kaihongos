#!/system/bin/sh
# r2: inspect p7b binary for bundle names + find profile generation scripts
. /data/local/home/env.sh >/dev/null 2>&1
SIG="$OHOS_HOME/signature"
echo "=== strings in p7b ==="
strings "$SIG/app1-profile-release.p7b" 2>/dev/null | grep -i -E "bundle|uniterm|oneaiterm" | head -10
echo "=== home scripts ==="
ls /data/local/home/*.sh 2>/dev/null
ls /data/local/home/bin/ 2>/dev/null | head
grep -rl "profile-release" /data/local/home/ --include="*.sh" 2>/dev/null | head -5
echo DONE_R2_P7B
