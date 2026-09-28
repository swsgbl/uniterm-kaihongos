#!/system/bin/sh
# r3: rewrite project build-profile.json5 to API14/OpenHarmony (028 parity-proven form)
set -e
P=/data/local/home/tmp/app/build-profile.json5
cp -f "$P" "$P.bak-mainline" 2>/dev/null || true
cat > "$P" <<'EOF'
{
  "app": {
    "signingConfigs": [],
    "products": [
      {
        "name": "default",
        "signingConfig": "default",
        "compileSdkVersion": 14,
        "compatibleSdkVersion": 14,
        "targetSdkVersion": 14,
        "runtimeOS": "OpenHarmony",
        "buildOption": {
          "strictMode": {
            "caseSensitiveCheck": true,
            "useNormalizedOHMUrl": true
          }
        }
      }
    ],
    "buildModeSet": [
      { "name": "debug" },
      { "name": "release" }
    ]
  },
  "modules": [
    {
      "name": "entry",
      "srcPath": "./entry",
      "targets": [
        { "name": "default", "applyToProducts": [ "default" ] }
      ]
    },
    {
      "name": "library",
      "srcPath": "./thirdparty/libssh-x86_64-har",
      "targets": [
        { "name": "default", "applyToProducts": [ "default" ] }
      ]
    }
  ]
}
EOF
echo "--- new build-profile written ---"
sed -n '1,20p' "$P"
echo OK
