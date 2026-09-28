#!/system/bin/sh
hilog -x 2>/dev/null | grep -iE 'uniterm|libssh|SSH2Napi' | tail -60
echo ====DONE
