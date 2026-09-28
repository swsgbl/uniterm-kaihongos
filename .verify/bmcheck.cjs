const fs = require('fs');
const raw = fs.readFileSync('D:/uniterm/.verify/_hapold/bm-installed.json', 'utf8');
const cleaned = raw.replace(/^net\.uniterm\.poc:\s*/m, '');
const j = JSON.parse(cleaned);
console.log('versionCode:', j.versionCode);
console.log('appProvisionType:', j.applicationInfo && j.applicationInfo.appProvisionType);
console.log('appDistributionType:', j.applicationInfo && j.applicationInfo.appDistributionType);
console.log('apiCompatibleVersion:', j.apiCompatibleVersion);
console.log('installTime:', j.installTime);
