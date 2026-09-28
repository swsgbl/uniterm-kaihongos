# 任务书 027:M4 棒 — API14 兼容 flavor 预备(装进用户真机的第一步)

目标:让工程能产出 **compatibleSdkVersion≤14** 的包(用户真机 KaihongOS 5.0.2.57 = API14,拒装 API24-min 包)。

## 现状
- 本机 DevEco SDK 只有 API26(`sdk/default/openharmony`,ets apiVersion 26)。
- API14 组件来源(编排者已确认,无需等 Public SDK 批复):官网 freedownload「DevEco配套SDK(arm64)」直接下载(含 API 11/14/18/20),**用户即将下载**,预计落点 `D:\uniterm\sdk-kaihongos\`(若不同以编排者通知为准)。

## 本棒任务
1. **建 store flavor**:kaihongos 根 build-profile.json5 增加 product(如 `store`):compatibleSdkVersion 用 API14 对应字符串(按配套 SDK 里 ets/oh-uni-package.json 的实际版本串填,可能是 "5.0.2(14)" 形式);compileSdkVersion 指向配套 SDK 路径(hvigor 多 SDK 配置方式:工程级 build-profile 的 sdkSection/customSDK 或环境变量,查 hvigor 文档确认正确做法并记录)。
2. **先用现有 API26 SDK 试探性构建一次** compatibleSdkVersion=14(或 "5.0.2(14)"),**把 hvigor 的确切报错原文存证**(`evidence/M4/relay4/api14-probe-error.txt`)——证明缺什么,给 SDK 落地后对照。
3. 预写好构建脚本 `scripts\build-store.cmd`(flavor 构建+签名链),SDK 落地即可一键出包。
4. 若 hvigor 允许 compileSdk26+compatible14 直接构建成功(概率低但先试):直接出 store-debug HAP 并在 5555 模拟器装验(模拟器 API24>14 应能装),全流程存证。

## 红线
- 不改产品 ArkTS/native 代码;只动构建配置/脚本。
- 产物与证据落 `evidence/M4/relay4/`;上下文将尽写断点再退。
- 环境:hdc 5555(模拟器)、勿动 22/2222。用户真机 15566 已 tconn,但**本棒不需要碰它**(签名未解决,装了也会被拒)。
