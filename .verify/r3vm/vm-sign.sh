#!/system/bin/sh
# r3: sign injected hap with VM-native chain (same as pack_hap.sh does)
set -e
. /data/local/home/env.sh >/dev/null 2>&1
SIG="$OHOS_HOME/signature"
IN=/data/local/home/tmp/uniterm-r3-native-unsigned.hap
OUT=/data/local/home/tmp/uniterm-r3-native-signed.hap
BUNDLE=net.uniterm.poc

sed -i "s/\"bundle-name\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"bundle-name\": \"$BUNDLE\"/" \
  "$SIG/app1-profile-release.json"
grep -o '"type"[[:space:]]*:[[:space:]]*"[^"]*"' "$SIG/app1-profile-release.json" | head -1

hap-sign-tool sign-profile \
  -keyAlias "OpenHarmony Application Release" \
  -signAlg SHA256withECDSA -mode localSign \
  -profileCertFile "$SIG/OpenHarmonyApplication.pem" \
  -inFile "$SIG/app1-profile-release.json" \
  -keystoreFile "$SIG/OpenHarmony.p12" \
  -outFile "$SIG/app1-profile-release.p7b" \
  -keyPwd 123456 -keystorePwd 123456

hap-sign-tool sign-app \
  -keyAlias "OpenHarmony Application Release" \
  -signAlg SHA256withECDSA -mode localSign \
  -appCertFile "$SIG/OpenHarmonyApplication.pem" \
  -profileFile "$SIG/app1-profile-release.p7b" \
  -inFile "$IN" -keystoreFile "$SIG/OpenHarmony.p12" \
  -outFile "$OUT" -keyPwd 123456 -keystorePwd 123456

ls -l "$OUT"
echo SIGNED_OK
