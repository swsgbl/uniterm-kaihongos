#!/system/bin/sh
hilog -x 2>/dev/null | grep -E 'uniterm\.session|uniterm\.term' | tail -25
echo ====MARKER
