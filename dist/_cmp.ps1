$A = 'D:\uniterm\kaihongos\entry\src\main\ets'
$B = 'D:\uniterm\dist\_src_parity\kaihongos\entry\src\main\ets'
$ha = @{}; $hb = @{}
if (Test-Path $A) {
  Get-ChildItem $A -Recurse -File -Include *.ets, *.ts | ForEach-Object {
    $rel = $_.FullName.Substring($A.Length + 1)
    $ha[$rel] = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
  }
}
if (Test-Path $B) {
  Get-ChildItem $B -Recurse -File -Include *.ets, *.ts | ForEach-Object {
    $rel = $_.FullName.Substring($B.Length + 1)
    $hb[$rel] = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
  }
}
Write-Output '=== ONLY_IN_A ==='
$ha.Keys | Where-Object { -not $hb.ContainsKey($_) } | Sort-Object
Write-Output '=== ONLY_IN_B ==='
$hb.Keys | Where-Object { -not $ha.ContainsKey($_) } | Sort-Object
Write-Output '=== DIFF_HASH ==='
$ha.Keys | Where-Object { $hb.ContainsKey($_) -and ($ha[$_] -ne $hb[$_]) } | ForEach-Object {
  "{0} A:{1} B:{2}" -f $_, $ha[$_].Substring(0,12), $hb[$_].Substring(0,12)
} | Sort-Object
Write-Output '=== TOP_FILES ==='
$names = @(
  'entry\build-profile.json5',
  'entry\src\main\module.json5',
  'build-profile.json5',
  'oh-package.json5',
  'AppScope\app.json5',
  'hvigorfile.ts',
  'entry\src\main\cpp\CMakeLists.txt'
)
foreach ($n in $names) {
  $pa = 'D:\uniterm\kaihongos\' + $n
  $pb = 'D:\uniterm\dist\_src_parity\kaihongos\' + $n
  $eA = Test-Path $pa
  $eB = Test-Path $pb
  if ($eA -and $eB) {
    if ((Get-FileHash $pa -Algorithm SHA256).Hash -eq (Get-FileHash $pb -Algorithm SHA256).Hash) {
      Write-Output ("{0} SAME" -f $n)
    } else {
      Write-Output ("{0} DIFF" -f $n)
    }
  } elseif ($eB) {
    Write-Output ("{0} ONLY_B" -f $n)
  } else {
    Write-Output ("{0} ONLY_A" -f $n)
  }
}
Write-Output '=== CPP_ONLY_B ==='
$ca = 'D:\uniterm\kaihongos\entry\src\main\cpp'
$cb = 'D:\uniterm\dist\_src_parity\kaihongos\entry\src\main\cpp'
$fa = @{}
if (Test-Path $ca) {
  Get-ChildItem $ca -Recurse -File | ForEach-Object { $fa[$_.FullName.Substring($ca.Length + 1)] = $true }
} else { Write-Output 'CPP_A_MISSING' }
if (Test-Path $cb) {
  Get-ChildItem $cb -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($cb.Length + 1)
    if (-not $fa.ContainsKey($rel)) { Write-Output $rel }
  }
} else { Write-Output 'CPP_B_MISSING' }
Write-Output '=== LIBS_ONLY_B ==='
$la = 'D:\uniterm\kaihongos\entry\libs'
$lb = 'D:\uniterm\dist\_src_parity\kaihongos\entry\libs'
$fl = @{}
if (Test-Path $la) {
  Get-ChildItem $la -Recurse -File | ForEach-Object { $fl[$_.FullName.Substring($la.Length + 1)] = $true }
} else { Write-Output 'LIBS_A_MISSING' }
if (Test-Path $lb) {
  Get-ChildItem $lb -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($lb.Length + 1)
    if (-not $fl.ContainsKey($rel)) { Write-Output $rel }
  }
} else { Write-Output 'LIBS_B_MISSING' }
