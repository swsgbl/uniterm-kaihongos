const fs = require('fs');
const p = 'D:\\uniterm\\kaihongos\\entry\\src\\main\\ets\\pages\\SftpPanel.ets';
let c = fs.readFileSync(p, 'utf8');
const before = c;
c = c.replace('@Link connIdIn: string', "@Prop connIdIn: string = ''");
if (c === before) { console.error('NO CHANGE'); process.exit(1); }
fs.writeFileSync(p, c, 'utf8');
const v = fs.readFileSync(p, 'utf8');
const m = v.match(/@(Link|Prop) connIdIn[^\n]*/);
console.log('now:', m && m[0]);
// also verify TerminalPage
const tp = fs.readFileSync('D:\\uniterm\\kaihongos\\entry\\src\\main\\ets\\pages\\TerminalPage.ets', 'utf8');
const m2 = tp.match(/@(Link|Prop) connIdIn[^\n]*/);
console.log('TerminalPage:', m2 && m2[0]);
