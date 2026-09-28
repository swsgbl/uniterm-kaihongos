const { execFileSync } = require('child_process');
// pack source-only tar (exclude build/, .hvigor, oh_modules, dist, downloads, thirdparty/out, har libs arm64 src mirror)
const srcTar = 'D:/uniterm/.verify/r3-src.tar.gz';
const files = execFileSync('powershell', ['-NoProfile', '-Command',
  "$roots=@('AppScope','entry\\src','entry\\libs','entry\\oh-package.json5','entry\\build-profile.json5','entry\\hvigorfile.ts','entry\\oh-package-lock.json5','build-profile.json5','hvigorfile.ts','oh-package.json5','oh-package-lock.json5','thirdparty\\libssh-x86_64-har','thirdparty\\signing\\oh-community','scripts'); foreach($r in $roots){ if(Test-Path (Join-Path 'D:\\uniterm\\kaihongos' $r)){ $r } }"],
  { encoding: 'utf8' }).split(/\r?\n/).filter(Boolean);
console.log('roots:'); console.log(files.join('\n'));
const tarArgs = ['-czf', srcTar, '-C', 'D:/uniterm/kaihongos',
  '--exclude=thirdparty/libssh-x86_64-har/src/main/cpp/thirdparty',
  ...files];
console.log('\ntar', tarArgs.join(' '));
const { status } = require('child_process').spawnSync('tar', tarArgs, { stdio: 'inherit' });
console.log('tar exit', status);
const st = require('fs').statSync(srcTar);
console.log('size MB:', (st.size / 1048576).toFixed(1));
