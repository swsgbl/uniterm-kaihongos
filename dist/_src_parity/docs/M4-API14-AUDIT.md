# M4 预研:API14(Stan) 合规审计 — 2026-09-22(编排者)

## 结论
uniterm KaihongOS 版 ArkTS 层**全部系统 API 均为 API ≤12 期基础接口**,对 KaihongOS Public SDK(API 14,Stan 5.0.1)向下兼容风险**极低**。无需改代码即可出 store flavor。

## 证据(对照 docs/api-ref-stan/,KaihongOS 5.0.1 Stan. API 参考离线版)

代码只用 6 类 @kit 导入(grep 全量 38 条 import 去重),逐一在 Stan 参考中在位且有版本标注:

| 代码导入 | 底层接口 | Stan 文档 | 起始版本 |
|---|---|---|---|
| @kit.AbilityKit | UIAbility/Want/common | apis-ability-kit(标准) | 9 |
| @kit.CoreFileKit | fileIo(@ohos.file.fs) | js-apis-file-fs.md | 8/9 |
| @kit.CoreFileKit | picker(DocumentViewPicker) | js-apis-file-picker.md | 9 |
| @kit.PerformanceAnalysisKit | hilog | js-apis-hilog.md | 7 |
| @kit.ArkUI | router | js-apis-router.md | 8 |
| @kit.ArkUI | display / window | js-apis-display.md / js-apis-window.md | 8/9 |
| @kit.ArkUI | MeasureText | js-apis-measure.md | 9 |
| @kit.ArkTS | util(Base64 等) | js-apis-util.md | 9 |
| @ohos/libssh | 自带 HAR(napi+libssh+libcrypto 打包) | —(三方 HAR,非系统能力) | 无关 |

注:cryptoFramework 仅存在于历史注释,实际加密走 native OpenSSL(自带 .so),无系统能力依赖 → 无 API14 风险。

## M4 真正的风险点(不是 API,是 ABI)
1. **store flavor 需 arm64 .so**:当前 thirdparty/libssh-x86_64-har 只编了 x86_64(桌面 QEMU 用)。上架包面向 Stan(RK3568/RK3588 ARM64)须新增 `build-napi-arm64.sh`(WSL 同链,--target aarch64-linux-ohos,sysroot 换 SDK arm64)产出 arm64 .so。
2. **单 HAP 多 ABI 或双产物**:hvigor `abiFilters`(build-profile.json5)可把 x86_64+arm64 两份 .so 打进同一 HAP;或按设备形态出两个 HAP 进同一 .app(pack.info 列举)。**到时先用 abiFilters 单 HAP 双 ABI 方案**,简单且 .app 规范友好。
3. Public SDK 到手后实测:compileSdk=14/compatibleSdk=14 编译过一遍即为最终实证(本审计已把理论风险清零)。
4. 上架材料(图标/截图/隐私声明/应用描述)是用户侧+内容侧工作,无技术风险。

## 备注
- Stan 5.0.1 = OpenHarmony 5.0.2.123 系,API 参考与 Public SDK(API14)同源。
- api-ref-stan 共 2274 md,Kit 目录结构与 @kit 导入一一对应,后续任何新增 API 引用都可在此离线核查。
