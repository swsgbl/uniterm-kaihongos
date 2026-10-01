# 一站AI终端管理系统 V1.1.0 — 软著申请材料

> 本件为申请人自备材料包;正式提交以中国版权保护中心(register.ccopyright.com.cn)在线填报为准。

## 一、软件基本信息(申请表填报要点)
- 软件全称:**一站AI终端管理系统**
- 软件简称:一站AI终端(英文名 One AI Term)
- 版本号:V1.1.0
- 开发完成日期:2026-10-01(以最后功能提交日为准,可按实际调整)
- 首次发表日期:未发表(选"未发表"可省公开发表材料)
- 开发方式:独立开发
- 著作权人:(申请人姓名,个人)
- 开发环境:DevEco Studio / OpenHarmony SDK(API14)/ ArkTS/ArkUI
- 运行环境:KaihongOS 5.0+(x86_64,内存≥2GB)
- 编程语言:ArkTS(TypeScript 方言)/ C++(NDK)
- 源程序量:约 1.1 万行(ArkTS 约 9 千行 + C++ 约 2 千行)
- 软件功能概述(申请表"软件简介"栏,300 字内):
  > 本软件是面向 KaihongOS 桌面环境的一站式 AI 终端管理软件,集成 SSH/SFTP/Telnet 远程连接、本地终端、PostgreSQL/Redis 数据库客户端、VNC/RDP 远程桌面、系统监控,并内置可操作终端的 AI 智能体内核(支持工具调用、分级审批、会话审计),支持深浅双主题与多语言界面。软件对连接凭据采用 PBKDF2 密钥派生与 AES-256-GCM 加密存储。

## 二、鉴别材料

### 1. 源程序(已生成:`dist/ruanzhu-source-60p.txt`)
- 前 30 页 + 后 30 页,每页 50 行,共 60 页 3000 行(总 4814 行,中略段标注)
- 选材为**完全原创**模块:AI 智能体内核(AgentKernel/HarnessClient/AIDock)、自研协议栈(PgService/RedisService/TelnetService/VncTab/RdpTab/SpiceClient)、原生模块(localpty.cpp/rdpproxy.cpp)、加密存储(EncCrypto/CredentialManager)、界面外壳(Index/AppTheme/GuideOverlay)
- **提交格式**:转为 PDF(每页页眉带软件名+版本号,页脚带页码,宋体/Courier 小四或五号,行距固定值)
- ⚠️ 如审查补正要求 60 页不足,可追加 ConnStore/SessionService/SftpPanel 等文件

### 2. 文档(二选一,建议操作说明书)
- `docs/ruanzhu-manual.md`(见材料包)——图文操作说明书:安装启动/新建连接/终端操作/SFTP/数据库/远程桌面/AI 智能体(含审批)/设置(主题/语言/模型/AI 审批/增强模式)/关于与开源声明
- 配图:深浅双主题界面截图(evidence/M6/relay4/after 与 relay5 截图,选 12-16 张插入)
- 同样转 PDF,页眉页脚规范同上

## 三、申请表关键项对照
| 栏目 | 建议填法 |
|---|---|
| 软件全称 | 一站AI终端管理系统 |
| 简称 | 一站AI终端 |
| 版本 | V1.1.0 |
| 开发完成日期 | 2026-10-01 |
| 发表状态 | 未发表 |
| 开发方式 | 独立开发 |
| 权利取得方式 | 原始取得 |
| 编程语言 | TypeScript(ArkTS)、C++ |
| 源程序行数 | 11000 |
| 功能与技术特点 | 见上"软件简介";技术特点可补:自研 PG v3/RESP/RFB/IAC 协议栈、NAPI 原生 PTY/RDP 桥、AI 工具调用内核 |

## 四、流程与费用(个人申请)
1. 官网注册账号(register.ccopyright.com.cn)→ 实名(身份证+人脸)
2. 在线填报"计算机软件著作权登记申请"
3. 上传/邮寄材料(申请表打印签字 + 源程序 60 页 + 文档)
4. 规费约 290 元(受理后缴费)
5. 周期约 30-60 工作日(可代理加急,费用另计)
6. 制证发证

## 五、合规注意(务必遵守)
- 软件包含开源组件(uniterm Apache-2.0、libssh LGPL-2.1、OpenSSL):应用内"关于"页已作二次开发声明与许可展示——**登记不要求披露,但商业发布须持续保留**;
- 登记内容为申请人独创部分(界面、协议栈、内核等均为原创重写);
- 如后续升级版本(V1.2 等)可做变更/补充登记。
