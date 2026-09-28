#!/system/bin/sh
uitest dumpLayout -p /data/local/tmp/r3-term.json >/dev/null 2>&1
echo "rc=$?"
grep -o '"text" *: *"[^"]*"' /data/local/tmp/r3-term.json | tail -40
echo ====MARKER
