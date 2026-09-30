#!/system/bin/sh
# r2: check app1-profile-release.json bundle-name; patch to new bundle if needed
. /data/local/home/env.sh >/dev/null 2>&1
J="$OHOS_HOME/signature/app1-profile-release.json"
grep -o '"bundle-name"[^,}]*' "$J"
echo "---"
# p7b is binary; signing tool reads the json? No - reads p7b. Regenerate p7b from json via hap-sign-tool if bundle mismatch handled at sign time.
echo DONE_R2_PROFCHECK2
