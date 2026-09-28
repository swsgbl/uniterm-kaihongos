#!/system/bin/sh
set -e
F=/data/local/home/tmp/app/entry/src/main/module.json5
cp -f "$F" "$F.bak-r3" 2>/dev/null || true
sed -i 's/"deviceTypes": \[ "default", "phone", "tablet", "2in1" \]/"deviceTypes": [ "default", "tablet" ]/' "$F"
sed -n '5,9p' "$F"
echo OK
