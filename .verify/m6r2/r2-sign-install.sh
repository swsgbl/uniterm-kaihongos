#!/system/bin/sh
# r2: sign + install (rebrand build, bundle=com.oneaiterm.terminal)
. /data/local/home/env.sh >/dev/null 2>&1
SIG="$OHOS_HOME/signature"
IN=/data/local/tmp/oat-r2-unsigned.hap
OUT=/data/local/tmp/oat-r2-signed.hap
BUNDLE=com.oneaiterm.terminal
hap-sign-tool sign-app -keyAlias "OpenHarmony Application Release" -signAlg SHA256withECDSA -mode localSign -appCertFile "$SIG/OpenHarmonyApplication.pem" -profileFile "$SIG/app1-profile-release.p7b" -inFile "$IN" -keystoreFile "$SIG/OpenHarmony.p12" -outFile "$OUT" -keyPwd 123456 -keystorePwd 123456
ls -l "$OUT"
bm uninstall -n net.uniterm.poc 2>/dev/null
bm uninstall -n $BUNDLE 2>/dev/null
bm install -p "$OUT"
echo DONE_R2_SIGN_INSTALL
