# 任务书 029:M5 棒1 — parity 线合并回主线 + OH 社区签名装机

## 背景(编排者已核实,照此执行)
并行 parity 线(028 任务书,在用户 VM 内原生构建)已产出:
- 源码快照:`D:/uniterm/dist/_src_parity/`(我们 M1-M4 树的 fork,新增 28 个 ets/ts:官方外壳布局/Telnet/本地终端/Redis/Pg/MySQL/K8s/VNC/RDP/SPICE/AI 侧栏/监控/设置/主题 + localpty.cpp + rdpproxy.cpp)
- 已签名 HAP:`D:/uniterm/dist/uniterm-kaihongos-v1.0.0-parity.hap`(含 libs/x86_64 预编 so,可提取复用)
- **签名链已到手**:`kaihongos/thirdparty/signing/oh-community/`(OpenHarmony.p12 + OpenHarmonyApplication.pem + app1-profile-release.p7b,keyAlias "OpenHarmony Application Release",两道口令均 123456)——**用户 VM(15566)信任此链**(实测 parity 包可装,我们自签链仍被拒 9568393)

## 任务
### A. 合并源码
1. 逐文件 diff 共有的 18 个 ets/ts(parity vs 主线 kaihongos):parity 的改动凡与主线已验收行为冲突,以主线为准并记录;纯新增功能代码照搬;
2. 复制 parity 新增的 28 文件 + cpp(localpty/rdpproxy)进主线工程;
3. 构建配置对齐:module.json5(deviceTypes 含 default/tablet)、build-profile、CMakeLists(localpty/rdpproxy 模块);
4. native so:优先从 parity HAP 提取现成 liblocalpty.so/librdpproxy.so 复用(解包 dist HAP);主线 WSL 链重编作为后备。
### B. 主线构建+OH 社区签名
1. 新增 `scripts/sign-oh.cmd`:hap-sign-tool sign-app 用 oh-community 三件套(参数照上;兼容 -compatibleVersion 14 的 store 包);
2. 构建(双 ABI 或先 x86_64)→ sign-oh 签名;
3. **装 15566**(hdc -t 127.0.0.1:15566;当前装的是 parity 版,同签名链可覆盖升级)→ 启动验证。
### C. 验收取证(evidence/M5/relay1/)
1. 截图:新外壳(顶栏 Tabs+侧栏 7 视图+深色主题)——dump/截图断言前台;
2. 回归:SSH 连接 uterm@10.0.2.2:2222 + 终端交互 + SFTP 打开(主线核心不回退);
3. 新能力抽查(每项至少一条证据,能测多测验多少):本地终端(/bin/sh)、Telnet(WSL 起 telnetd 或 busybox)、设置页主题切换;
4. REPORT-relay1.md:合并 diff 摘要(18 文件冲突裁决清单)+ 构建/签名链记录 + 验收结果。

## 红线
- 主线已验收行为(M1-M4)不得回退;冲突逐条记录留给编排者复核。
- 签名材料**不入 git**(.gitignore 已挡 *.p12/*.pem/*.p7b——放 signing/oh-community 即安全)。
- 环境:hdc 5555(模拟器回归)+ 15566(真机装机);靶机 uterm@10.0.2.2:2222;勿动 22/2222。
- 上下文将尽/429:写 evidence/M5/RESUME-STATE-RELAY1.md 再退。
