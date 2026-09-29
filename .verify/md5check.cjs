const fs = require('fs');
const crypto = require('crypto');
function md5lf(p) {
  let d = fs.readFileSync(p);
  d = d.toString('utf8').replace(/\r\n/g, '\n');
  return crypto.createHash('md5').update(d).digest('hex');
}
function md5file(p) {
  return crypto.createHash('md5').update(fs.readFileSync(p)).digest('hex');
}
const p = 'D:/uniterm/kaihongos/entry/src/main/ets/service/PgService.ets';
console.log('host PgService md5(LF normalized):', md5lf(p));
console.log('host PgService md5(file as-is):   ', md5file(p));
console.log('VM  PgService md5:               34a6ab55202cdf2adbfbe5dbd7cf1f93');
console.log('match:', md5lf(p) === '34a6ab55202cdf2adbfbe5dbd7cf1f93');
