# r2: stage VM source tree for relay2 (rebrand+layout)
$ErrorActionPreference = 'Stop'
$src = 'D:\uniterm\kaihongos'
$stage = 'D:\uniterm\.verify\m6r2\stage'
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Path "$stage\app" | Out-Null

# root files (build-profile replaced with API14-ized single-product template for VM SDK)
Copy-Item "$src\hvigorfile.ts", "$src\oh-package.json5", "$src\.gitignore" "$stage\app\"
$bpLines = @(
  '{',
  '  "app": {',
  '    "signingConfigs": [],',
  '    "products": [',
  '      {',
  '        "name": "default",',
  '        "signingConfig": "default",',
  '        "compatibleSdkVersion": 14,',
  '        "compileSdkVersion": 14,',
  '        "targetSdkVersion": 14,',
  '        "runtimeOS": "OpenHarmony",',
  '        "buildOption": {',
  '          "strictMode": {',
  '            "caseSensitiveCheck": true,',
  '            "useNormalizedOHMUrl": true',
  '          }',
  '        }',
  '      }',
  '    ],',
  '    "buildModeSet": [',
  '      { "name": "debug" },',
  '      { "name": "release" }',
  '    ]',
  '  },',
  '  "modules": [',
  '    {',
  '      "name": "entry",',
  '      "srcPath": "./entry",',
  '      "targets": [',
  '        {',
  '          "name": "default",',
  '          "applyToProducts": [ "default" ]',
  '        }',
  '      ]',
  '    },',
  '    {',
  '      "name": "library",',
  '      "srcPath": "./thirdparty/libssh-x86_64-har",',
  '      "targets": [',
  '        {',
  '          "name": "default",',
  '          "applyToProducts": [ "default" ]',
  '        }',
  '      ]',
  '    }',
  '  ]',
  '}',
  ''
)
$bp = $bpLines -join "`n"
[System.IO.File]::WriteAllText("$stage\app\build-profile.json5", $bp)
try { $null = $bp | ConvertFrom-Json; Write-Host 'BP_JSON_OK' } catch { Write-Host "BP_JSON_FAIL: $($_.Exception.Message)"; exit 1 }

New-Item -ItemType Directory -Path "$stage\app\hvigor" | Out-Null
Copy-Item "$src\hvigor\hvigor-config.json5" "$stage\app\hvigor\"

# AppScope (bundleName + label i18n)
robocopy "$src\AppScope" "$stage\app\AppScope" /E /NFL /NDL /NJH /NJS /NP | Out-Null

# entry: src + libs + config files
New-Item -ItemType Directory -Path "$stage\app\entry" | Out-Null
Copy-Item "$src\entry\build-profile.json5", "$src\entry\hvigorfile.ts", "$src\entry\oh-package.json5", "$src\entry\oh-package-lock.json5", "$src\entry\obfuscation-rules.txt" "$stage\app\entry\" -ErrorAction SilentlyContinue
robocopy "$src\entry\src" "$stage\app\entry\src" /E /NFL /NDL /NJH /NJS /NP | Out-Null
robocopy "$src\entry\libs" "$stage\app\entry\libs" /E /NFL /NDL /NJH /NJS /NP | Out-Null

# API14 syscap fix: deviceTypes -> ["default"] (VM SDK has no phone/2in1 syscaps)
$mj = "$stage\app\entry\src\main\module.json5"
$mjc = [System.IO.File]::ReadAllText($mj)
$mjc = $mjc -replace '"deviceTypes":\s*\[[^\]]*\]', '"deviceTypes": [ "default" ]'
[System.IO.File]::WriteAllText($mj, $mjc)
Write-Host ("DEVICETYPES: " + ([regex]::Match($mjc, 'deviceTypes[^\]]*\]')).Value)

# HAR tree
robocopy "$src\thirdparty\libssh-x86_64-har" "$stage\app\thirdparty\libssh-x86_64-har" /E /NFL /NDL /NJH /NJS /NP /XD build .preview node_modules oh_modules | Out-Null

# tar
if (Test-Path 'D:\uniterm\.verify\m6r2\r2-src.tar') { Remove-Item 'D:\uniterm\.verify\m6r2\r2-src.tar' -Force }
tar -C $stage -cf D:\uniterm\.verify\m6r2\r2-src.tar app
'{0:N1} MB tar' -f ((Get-Item 'D:\uniterm\.verify\m6r2\r2-src.tar').Length/1MB)
