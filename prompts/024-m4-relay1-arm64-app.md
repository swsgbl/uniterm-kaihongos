# 任务书 024:M4 棒1 — arm64 编译链 + 双 ABI HAP + .app 打包结构

M3 已收官(全部 REPORT 见 evidence/M3/)。本棒是 M4 发布工程第一棒,**不需要 Public SDK**(仍用现有 DevEco SDK API26 编译/API24 兼容)。编排者预研结论见 `D:/uniterm/docs/M4-API14-AUDIT.md`(先读:API 层零风险,风险全在 ABI)。

## 目标(三件套)
### A. arm64 native 编译链
1. 新建 `thirdparty/build-napi-arm64.sh`:复制 x86_64 版改 target=aarch64-linux-ohos(sysroot/头仍用 DevEco SDK libcxx-ohos,坑同 `std::__n1`);
2. openssl 的 libcrypto 也要 arm64(现有 x86_64 是 WSL 交叉编的,同链改 target 重编);
3. 产物落 `thirdparty/libssh-x86_64-har/libs/arm64-v8a/`(HAR 目录名不改,libs 下按 ABI 分目录)或按 hvigor HAR 规范调整——**先查 HAR/ohpm 对多 ABI libs 目录的约定**(x86_64 现在落在 libs/x86_64/,arm64 落 libs/arm64-v8a/ 是 OHOS 惯例)。
4. 验证:`llvm-readelf -h`(WSL 或 SDK toolchain)确认 ELF Machine=AArch64;**无 arm64 真机,运行时验证留待后续,如实记录**。

### B. 双 ABI HAP(abiFilters)
1. entry build-profile.json5 `buildOption.externalNativeOptions`/`abiFilters`(或 hvigor 对 HAR so 的等价配置)把 x86_64+arm64-v8a 两份 so 打进同一 HAP;
2. 验证:HAP unzip 后 libs/ 两 ABI 齐全;**装回 x86 模拟器冒烟**(启动→连接列表→SFTP 面板打开→一次真实连接)确认 x86_64 侧不受影响(设备旧包陷阱:核对构建时间戳)。

### C. .app(App Pack)打包结构
1. 先试 `hvigorw assembleApp`(命令行);若它强制要求 release Profile/签名材料(我们只有自签 debug 链+占位 release p12),**不硬拼**:退到手工组装 .app(zip:entry HAP(signed)+pack.info),pack.info 格式照 `docs/STORE_SUBMISSION.md` 研究结论(版本/包名/模块列表);
2. 产物放 `kaihongos/dist/` 下,`unzip -l` 清单存证;
3. 结论写清:正式 .app 等 Public SDK+工作台 Profile 后重出,本棒是**结构预演**。

## 验收证据
- readelf 两 ABI 输出、HAP libs 清单、装机冒烟 hilog/截图(断言前台)、.app 清单;
- `evidence/M4/relay1/REPORT-relay1.md`(各项 ✅/❌+证据清单+遗留)。

## 红线
- 不改任何产品行为代码;构建配置(build-profile/CMake/shell 脚本)是本棒主战场。
- 设备/靶机环境同前(hdc 5555、uterm@10.0.2.2:2222、mp-735、勿动 22/2222)。
- 429/上下文将尽:写 `evidence/M4/RESUME-STATE-RELAY1.md` 再退。
