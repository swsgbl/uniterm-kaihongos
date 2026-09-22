const fs = require('fs');
const path = 'D:/uniterm/kaihongos/entry/src/main/ets/pages/ConnList.ets';
let t = fs.readFileSync(path, 'utf8');
// The import Row overflows the 1320px pane (4 buttons). Switch to Flex wrap.
const a = `Row({ space: 8 }) {
          Text('\u5bfc\u5165:')`;
const b = `Flex({ wrap: FlexWrap.Wrap, direction: FlexDirection.Row }) {
          Text('\u5bfc\u5165:')
            .fontSize(13)
            .fontColor(0x909399)
            .margin({ right: 8 })`;
if (!t.includes(a)) { console.error('A MISS'); process.exit(1); }
t = t.replace(a, b);
const c = `.width('100%')
        .padding({ left: 20, right: 20, bottom: 10 })`;
if (!t.includes(c)) { console.error('C MISS'); process.exit(1); }
t = t.replace(c, `.width('100%')
        .padding({ left: 20, right: 20, bottom: 10 })`);
// also add small gaps between wrapped rows
const d = `          Button('\u5f00\u53d1\u8005\u5bfc\u5165')
            .fontSize(13)
            .backgroundColor(0x909399)
            .onClick(() => {
              this.devImport();
            })`;
const e = `          Button('\u5f00\u53d1\u8005\u5bfc\u5165')
            .fontSize(13)
            .backgroundColor(0x909399)
            .margin({ right: 8, bottom: 4 })
            .onClick(() => {
              this.devImport();
            })`;
if (!t.includes(d)) { console.error('D MISS'); process.exit(1); }
t = t.replace(d, e);
fs.writeFileSync(path, t);
console.log('FLEX OK');
