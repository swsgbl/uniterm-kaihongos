# uniTerm KaihongOS 应用商店上架手册(环境与流程)

日期:2026-09-20 | 维护:ZCode(编排者) | 状态:**等待用户完成账号侧动作**,工程侧已就绪
更新:2026-09-20 深夜——已研读官方《开鸿行业应用市场白皮书》(48页)与《桌面版北向应用开发指导书》(58页),流程修正如下。

## 0. 总路线(白皮书+操作手册双实证版,2026-09-21 修订)

1. 登录开发服务平台 → **应用接入开发工作台** → 新建应用:选应用类型(KaihongOS 应用)、输入**应用名称+包名**——⚠️ **包名即最终 bundleName,创建即锁定,必须在此时定名**(候选 net.uniterm.term)→ 系统同时创建一个应用版本
2. 完善基本信息(图标/支持产品/一句话简介/介绍/分类/标签/预览截图——市场展示用)
3. 工作台**「开鸿应用签名管理」→ 创建开鸿应用签名**:得到**应用 Profile 文件(.p7b)+签名证书**,**下载至本地工程、配置进 build-profile.json5 的 signingConfigs 参与编译**(操作手册原文:"将该文件下载至本地的工程文件中,参与软件包的编译")→ 本地 hvigor 构建出**含开鸿签名的 .hap** → 打包 **.app(App Pack)**
4. 工作台完善版本信息(发布版本软件包 .app、兼容 KaihongOS 版本、隐私声明、版权信息)→ 上传 → **提交审核**
5. 运营平台审核(**含重签名**)→ 应用市场上架;支持撤销审核/申请下架;有分发看板+用户看板

### 工程侧对应改造(M4 执行清单)
- build-profile.json5 增加 release signingConfig(certpath=.cer / profile=.p7b / storeFile=.p12 / signAlg SHA256withECDSA,官方指导书 2.5.3 示例同构)
- `pack-app` 步骤:hvigor assembleApp 产出 .app(所有 .hap + pack.info)
- 提审材料:图标、预览截图、隐私声明 URL、版权信息、兼容 KaihongOS 版本声明(API14)

### 三个关键实证发现(白皮书 3.1.1 / 指导书 2.3.1)
1. **签名获取方式修正**:平台在工作台直接"创建开鸿应用签名并下载到开发者本地",提供调试+发布两套——**不是** AGC 式 CSR 提交为主。我们的 make-release-csr.cmd 降级为备用(仅当平台组织级证书要求 CSR 时用)。
2. **上架包格式 = App Pack(.app)**:应用包含的所有 .hap 需打包为 .app(内含 pack.info);云端分发/端侧安装仍以 HAP 为单位。→ M4 增加 `pack-app` 步骤(hvigor assembleApp 产 .app,再上传)。
3. **官方推荐工具链**:桌面版指导书推荐 DevEco Studio 4.1 Release(OpenHarmony 4.1/API11 时代);门户另提供 DevEco配套SDK(arm64,API 11/14/18/20)。我们用的新链(API26 编译/兼容24)已在 5.0.2.57 模拟器实测可用,调试不受影响;上架的 API14 兼容待 Public SDK 到手实测(store flavor)。

## 1. 仅限用户完成的动作(工程侧无法代办)

| # | 动作 | 入口 | 产出 |
|---|---|---|---|
| U1 | 注册开鸿开发者账号(实名/企业认证) | developer.kaihong.com 右上角"登录/注册" | 可登录账号 |
| U2 | 申请 **KaihongOS Public SDK**(API 14)。**只申请这一个**:Full SDK 面向系统应用开发者(系统 API + OEM 资质),本项目全部用公开 API,用不到且门槛更高 | 资源下载页 →"申请获取" | SDK 包(发我路径) |
| U3 | 下载《北向应用开发指导书》《VSCode插件指南》,**以及 Meta 栏《开鸿行业应用市场白皮书》《开鸿行业应用市场操作手册》(上架流程官方文档,直下)** | 资源下载页(登录后"立即下载") | 官方流程细节(发我) |
| U4 | 用 `thirdparty\signing\release\uniterm-release.csr` 申请**发布证书**(注意:先用真实主体重新生成 CSR,见 §2) | 平台"证书/Profile"控制台(登录后可见) | uniterm-release-cert.cer/.p7b |
| U5 | 申请**发布 Profile**(bundleName 以平台最终定名为准,见 §3) | 同上 | uniterm-release-profile.p7b |
| U6 | 提审资料:应用图标/截图/简介/隐私政策 URL、开发者主体信息 | 应用发布控制台 | 上架申请 |

## 2. 工程侧已就绪(2026-09-20)

- ✅ `scripts\make-release-csr.cmd`:一键生成发布密钥(ECC NIST-P-256)+CSR;**当前生成的是占位主体**——拿到账号后用真实主体名重跑(先删旧 p12):`make-release-csr.cmd "C=CN,O=<实名/企业名>,CN=<实名/企业名>"`
- ✅ `scripts\sign-release.cmd`:证书+Profile 到位后一键签名出 `entry-release-signed.hap`(内置 verify-app 校验)
- ✅ 构建链(build.cmd)成熟;M4 会加 release flavor(见 §4)
- ⏳ 依赖 U2-U5 的:正式签名、商店规格包

## 3. bundleName 注意事项

商店包名须与 Profile 申请一致,且 DevEco 工具链强制 ≥3 段。候选:**net.uniterm.term**(倾向)/ net.uniterm.hap。**M4 发布定名后同步改三处**(AppScope/app.json5、签名 Profile、module.json5 如有引用)。当前调试包 net.uniterm.poc 不受影响。

## 4. API 版本风险(M4 处理)

商店 Public SDK 为 **API 14**,而我们调试链为 API 26 编译/兼容 24。上架包可能需要 `compatibleSdkVersion=14` 的 store flavor:
- 我们用到的 ArkTS 能力(页面/列表/输入/网络/NAPI)API 12 即有,理论可降;
- 待 U2 的 Public SDK 到手后,开 `store` 构建变体实测编译+模拟器回归,**以平台文档为准**。

## 5. 上架前检查单(M4 终验)

- [ ] release HAP 经 verify-app 通过,且用平台证书(非自签)
- [ ] store flavor 在 API14 SDK 下编译通过并装机回归
- [ ] 图标/启动页/应用名(uniTerm)符合商店规范
- [ ] 版本号/版本名策略(versionCode 递增)
- [ ] 隐私政策 URL 可访问,权限申请最小化(INTERNET 一项)
- [ ] 第三方开源声明(libssh LGPL-2.1:以动态链接 HAR 集成,随包提供开源声明与源码获取方式;THIRD_PARTY_NOTICES 参考上游)
- [ ] 提审材料齐备(截图按商店尺寸要求)

## 6. 已知边界

- 华为 AppGallery 不收 x86 OpenHarmony 应用 → 只走深开鸿市场,不双投。
- 该门户所有下载/文档/SDK 申请均需登录;文档中心整站登录可见。
- 若商店要求 HMS 无关的纯 OH 包,我们的依赖(@ohos/libssh HAR + 自编 x86_64 so)均无 HMS 依赖,满足。
