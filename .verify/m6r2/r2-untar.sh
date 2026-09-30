#!/system/bin/sh
# r2: untar relay2 source tree on VM + verify
cd /data/local/home/tmp || exit 1
rm -rf app
mv r2-src.tar r6-src.tar 2>/dev/null
tar -xf r6-src.tar || exit 1
echo "BUNDLE: $(grep -o 'com.oneaiterm.terminal' app/AppScope/app.json5 | head -1)"
echo "LABEL_ZH: $(grep -o '一站AI终端' app/AppScope/resources/zh_CN/element/string.json | head -1)"
echo "LABEL_EN: $(grep -o 'One AI Term' app/AppScope/resources/en_US/element/string.json | head -1)"
echo "TAGS: $(grep -rc 'oat\.' app/entry/src/main/ets/service/SessionService.ets)"
echo "OLDTAG: $(grep -rc 'uniterm\.session' app/entry/src/main/ets/service/SessionService.ets)"
echo DONE_R2_UNTAR
