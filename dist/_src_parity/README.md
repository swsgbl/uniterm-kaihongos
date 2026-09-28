# uniterm for KaihongOS(uniTerm KaihongOS 适配版)

[uniTerm](https://gitee.com/ys-l/uniterm)(Apache-2.0,轻量级一站式终端软件)在 **KaihongOS 桌面版(x86)** 上的适配版本。与官方同源同格式:配置文件(connections.json / .utm)与官方版双向互导互通。

> 定位:与官方 uniterm 一致,仅做 KaihongOS 系统环境适配。

## 当前版本能力(1.0.0)

- **SSH 远程终端**:完整交互终端(ANSI 颜色/键盘映射/窗口自适应/会话保活);密码、密钥(keyText)、身份库三种认证
- **SFTP 文件传输**:远程目录浏览、上传、下载(复用终端连接的 SSH 会话)
- **连接管理**:分组/收藏/最近连接;兼容官方 connections.json 与 .utm(含加密 .utm)导入导出
- **凭据安全**:主密码 + PBKDF2(600k)→ AES-256-GCM 本地加密,密文落盘,与官方格式互认
- **细节**:GBK 编码主机、退格键三模式(del/bs/vt220)、终端编码选项

官方完整版的 30+ 协议(RDP/VNC/数据库/Kubernetes/AI 助手等)将按官方路线图在后续版本逐步适配。

## 技术路线

ArkTS/ArkUI(HAP)+ [@ohos/libssh](https://gitcode.com/openharmony-tpc)(libssh 0.11.1 HAR,NAPI)作 SSH/SFTP 引擎;加密原语走自带 OpenSSL 3.5.4(libcrypto.so.3)的 NAPI 封装(模拟器 cryptoFramework KDF 不可用)。

```
kaihongos/                     # 工程根(bundleName: net.uniterm.poc, 开发态)
  entry/                       # ArkTS 应用(pages/components/store/service)
  thirdparty/
    libssh-x86_64-har/         # libssh/libssl/libcrypto HAR(x86_64+arm64 双 ABI)
    build-napi-x86_64.sh       # WSL 交叉编译链(clang, sysroot=DevEco SDK)
    build-napi-arm64.sh
  scripts/                     # build/sign/deploy/build-store/sign-store 一键脚本
prompts/                       # 开发任务书(分棒接力,可追溯)
docs/                          # 设计书/上架手册/API14 审计等工程文档
```

## 构建

环境:DevEco Studio(SDK 含 x86_64/arm64 sysroot)、WSL(clang+lld,用于 native 重编)。

```bat
cd kaihongos
scripts\build.cmd          # 构建 HAP(双 ABI)
scripts\sign.cmd           # 自签调试链(仅开发模拟器)
scripts\deploy.cmd         # 安装到 hdc 目标
scripts\build-store.cmd    # API14 兼容 store 版(compatibleSdkVersion=5.0.2(14))
```

正式签名需 KaihongOS 平台签发的证书/Profile(开发者向深开鸿申请)。

## 许可与合规

- 本仓库适配代码遵循上游 **Apache-2.0**
- @ohos/libssh(LGPL-2.1)以动态链接(HAR 内 so)方式使用,未修改库源码,仅调用其 API
- OpenSSL 3.5.4:Apache-2.0

## 相关文档

- [适配设计书](docs/ADAPTATION_DESIGN.md)
- [上架手册](docs/STORE_SUBMISSION.md)
- [API14 合规审计](docs/M4-API14-AUDIT.md)
