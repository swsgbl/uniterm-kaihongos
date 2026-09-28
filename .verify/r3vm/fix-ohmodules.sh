#!/system/bin/sh
# r3: repair entry/oh_modules on VM (junctions lost in tar transfer)
set -e
OM=/data/local/home/tmp/app/entry/oh_modules
rm -rf "$OM"
mkdir -p "$OM/@ohos"
# @ohos/libssh -> HAR source tree (real dir copy is heavy; symlink is what ohpm itself creates on linux)
ln -s /data/local/home/tmp/app/thirdparty/libssh-x86_64-har "$OM/@ohos/libssh"
# dev deps: types dirs
ln -s /data/local/home/tmp/app/entry/src/main/cpp/types/localpty "$OM/liblocalpty.so"
ln -s /data/local/home/tmp/app/entry/src/main/cpp/types/rdpproxy "$OM/librdpproxy.so"
# obfuscation-rules.txt
cat > /data/local/home/tmp/app/entry/obfuscation-rules.txt <<'EOF'
# Define project specific obfuscation rules here.
# (obfuscation disabled in build-profile; file kept for structure parity)
EOF
# project-level oh_modules/.ohpm marker (hvigor looks for it)
mkdir -p /data/local/home/tmp/app/oh_modules/.ohpm
echo ok > /data/local/home/tmp/app/oh_modules/.ohpm/.ohpm
ls -l "$OM" "$OM/@ohos"
echo OK
