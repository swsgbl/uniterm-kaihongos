角色与使命:继续 uniterm KaihongOS 桌面版 M1a,你是第 3 棒。前两棒已完成待办 1–3(napi getServerBanner、x86_64 五件套入 HAR、entry 挂本地 HAR),编排者已独立核验属实。断点事实源:D:\uniterm\evidence\M1a\RESUME-STATE.md(直接采信,禁止重复探索)。

本棒目标(只做三件事,其余不做):
A. 写 scripts\build.cmd:调用项目 hvigorw assembleHap 产出 HAP(注意 PATH 里加 ohpm/node;ohpm install 已就绪不必重跑,除非构建报缺依赖)。
B. 写 scripts\sign.cmd 与 scripts\deploy.cmd:
   - sign.cmd 按 RESUME-STATE.md 已核实的 hap-sign-tool 用法,全新自建调试签名链(CA 根证书→应用证书→debug profile→签名 HAP,p12 口令 123456,材料放 thirdparty\signing\,bundleName=net.uniterm)。
   - deploy.cmd:hdc -t 127.0.0.1:5555 install <signed.hap> + aa start -a EntryAbility -b net.uniterm。
   - 两个脚本先"写好+参数自洽",本棒不要求真装机。
C. 首页 UI(entry/src/main/ets/pages/Index.ets 或工程默认入口页):
   - 标题"uniTerm KaihongOS M1a"+构建号(常量即可,标明来源是构建时间);
   - 「SSH PoC 连接 10.0.2.2:22」按钮:调 @ohos/libssh 客户端(按其官方 demo 用法;连接→取 getServerBanner→断开),成功把 banner 原文渲染到页面结果区;失败把错误码/错误串渲染到结果区;
   - 「失败路径测试 10.0.2.2:2222」按钮:预期连接失败,页面显示错误且不 crash;
   - hilog tag=uniterm.poc 结构化输出(开始/成功+banner/失败+原因)。
   写法参考 thirdparty/ohos_ssh-src 的 ArkTS demo(只读)。

完成 A/B/C 后必须做的闭环验证(本棒的验收线):
- 真跑 build.cmd → 产出 HAP(路径记录);
- 真跑 sign.cmd → 产出 *-signed.hap;若 hvigor 已自动产出 signed 版,说明并二选一归档;
- 把两步日志(裁剪关键行)追加到 D:\uniterm\evidence\M1a\xbuild-hap.log;
- 更新 RESUME-STATE.md(本棒成果+新踩坑);
- 不装机、不截图——那是第 4 棒的事。

纪律(上两棒均死于上下文耗尽,从严):
- 一次一件事;命令输出只看关键行;不重读大文件;不改 D:\uniterm\upstream 与 thirdparty/ohos_ssh-src;
- hvigor 构建报错时,只修本工程问题;若涉及 SDK 级不可解障碍,固化断点+如实上报,不得硬凑;
- 预感上下文将尽:先更新 RESUME-STATE.md 再收束。

回复要求:≤20 行:A/B/C 各一行结论(✅/❌+一句话)、build/sign 实跑结果各一行(HAP 产物路径+大小)、新踩坑、遗留。
