角色与使命:你是 uniterm KaihongOS 桌面版适配开发的执行工程师。上级编排者(ZCode)负责指挥、审核、验收;你负责全部实际开发工作。本次是第一阶段:分析与选型。

环境事实(已由编排者核实,直接采信,不要重复验证):
- 上游源码:D:\uniterm\upstream(uniterm,Go + Wails v2,前端 Vite/TS,30+ 协议终端/连接管理器,Apache-2.0)
- 目标设备:QEMU 虚拟机里的 KaihongOS 5.0.2.57,x86_64,OpenHarmony API 24,桌面形态
- 设备连接:hdc 目标 127.0.0.1:5555,当前已开机、hdc 已连通,可直接 shell/file send
- 宿主机装有 DevEco Studio SDK:C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony(含 toolchains\hdc.exe)
- 新项目工作区:D:\uniterm\kaihongos(KaihongOS 版源码将来放这里,先不要创建产品代码)

阶段任务(本提示词只做"分析与选型",禁止编写产品代码):

1. 源码通读:梳理 D:\uniterm\upstream 的前后端职责边界;重点提取:
   - 连接配置数据模型(主机/分组/凭据/协议类型的 JSON schema,给出真实字段示例)
   - SSH 会话的前后端接口面(方法名、事件、数据流)
   - 前端哪些 UI 逻辑/TS 代码理论上可复用,哪些强依赖浏览器/Wails API 必须重写
2. 总体适配方案:KaihongOS 桌面版应以 HAP(ArkTS/ArkUI)为载体。你必须论证并明确推荐一条 SSH 实现路线,候选至少覆盖:
   a) 纯 TS/ArkTS 实现 SSH2 协议栈(@ohos.net.socket + @ohos.security.cryptoFramework)
   b) OpenHarmony TPC / ohpm 生态中现成的 ssh 相关三方库(实际检索 ohrp/ohpm 与 gitee OpenHarmony-TPC 组织,给出包名与证据;没有就说没有)
   c) Go 后端静态交叉编译(x86_64、CGO_ENABLED=0)在设备侧以独立进程运行、HAP 与之本地通信(必须评估 OHOS 应用沙箱能否 spawn/连接独立进程、能否持久驻留,给出结论)
   推荐必须给出可行性/工作量/风险三维依据,不允许"都可以"。
3. 里程碑计划 M1–M4,每个里程碑:交付物清单 + 可机检的验收标准(验收方式= hdc 安装 + 真机 UI 截图 + 功能点核验)。M1 必须是"连接管理器"(主机 CRUD、分组、兼容导入 uniterm 原版配置文件)。M4 必须是"签名发布件 + 安装到 VM + 端到端验收"。
4. 构建链路探明(只探明记录,不构建产品):在本机找到 hvigorw / ohpm / 签名与打包工具的实际路径与版本;确认能否纯命令行构建出 x86_64 / API 24 的 HAP;记录你计划使用的命令行。若宿主机 SDK 版本与 API 24 不匹配,写明应对办法。

交付物:完整设计书写入 D:\uniterm\docs\ADAPTATION_DESIGN.md(中文),结构:①上游架构摘要 ②数据模型 ③SSH 路线对比与推荐 ④总体架构图(文字版) ⑤M1–M4 里程碑与验收标准 ⑥构建链路记录 ⑦给编排者的风险清单与待拍板决策点。
回复要求:最后输出 ≤30 行摘要(推荐路线一句话、里程碑列表、风险 Top3)。
