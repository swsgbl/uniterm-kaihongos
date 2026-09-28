#!/system/bin/sh
hilog -x 2>/dev/null | grep -iE 'uniterm|AceContainer|SIGABRT|Cannot find|libssh|JsApp|ability' | tail -50
echo ====DONE
