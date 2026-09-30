#!/system/bin/sh
hdc -t 127.0.0.1:15566 file send D:/uniterm/kaihongos/entry/src/main/ets/pages/Index.ets /data/local/home/tmp/app/entry/src/main/ets/pages/Index.ets >/dev/null
hdc -t 127.0.0.1:15566 file send D:/uniterm/kaihongos/entry/src/main/ets/pages/ConnList.ets /data/local/home/tmp/app/entry/src/main/ets/pages/ConnList.ets >/dev/null
hdc -t 127.0.0.1:15566 file send D:/uniterm/kaihongos/entry/src/main/ets/components/AISidebar.ets /data/local/home/tmp/app/entry/src/main/ets/components/AISidebar.ets >/dev/null
hdc -t 127.0.0.1:15566 file send D:/uniterm/kaihongos/entry/src/main/ets/components/SettingsTab.ets /data/local/home/tmp/app/entry/src/main/ets/components/SettingsTab.ets >/dev/null
echo SENT_4_FILES
