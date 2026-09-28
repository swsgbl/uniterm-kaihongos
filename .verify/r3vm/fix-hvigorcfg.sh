#!/system/bin/sh
set -e
mkdir -p /data/local/home/tmp/app/hvigor
cat > /data/local/home/tmp/app/hvigor/hvigor-config.json5 <<'EOF'
{
  "modelVersion": "5.0.0",
  "dependencies": {}
}
EOF
echo written; sed -n '1,5p' /data/local/home/tmp/app/hvigor/hvigor-config.json5
echo OK
