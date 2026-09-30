# 任务书 036:M6 棒2 — 品牌与布局差异化改版(一站AI终端)

## 定案(docs/REBRAND_DIFFERENTIATION_PLAN.md)
中文名**一站AI终端**/英文**One AI Term**/包名 **com.oneaiterm.terminal**/布局**选型①**/自有配色。目标:与官方 uniTerm 的视觉表达彻底切割,合规保留 Apache-2.0 声明。

## A. 品牌层
1. 改名:应用显示名(中文环境"一站AI终端"/en"One AI Term",i18n 双语);顶栏品牌字样、关于页、README/RELEASE-NOTES 同步;
2. 包名:net.uniterm.poc → **com.oneaiterm.terminal**(AppScope/app.json5 bundleName + module + 签名 Profile 绑定核对 + hdc/脚本中引用全局替换);注意:包名变更后旧包需卸载(want 通道脚本/harmony 工具配置同步改);
3. **原创图标**:弃 upstream appicon——新图标设计要求:识别度(终端+AI 意象,如对话气泡内嵌命令提示符/四向连接节点),深浅底两版,SVG 矿源+PNG 出 216/192/96/48;hmh 可用脚本生成几何构成(纯代码绘制,无版权风险);
4. 关于页:©2026 一站AI终端 + "基于开源项目 uniterm(Apache-2.0)二次开发"声明 + 协议文本入口;
5. 代码去 uniterm 化:UniTheme→AppTheme、hilog tag uniterm.*→oat.*、SessionService 等 API 命名审查(仅显示层与日志,不动已验收逻辑)。

## B. 布局①(命令栏+折叠坞+状态栏)
1. **顶栏改命令栏**:搜索框居中(Ctrl+K 唤起命令面板:可搜索命令/连接/设置项,回车执行)+左品牌+右窗口钮;
2. **左侧改可折叠导航坞**:窄态(仅图标 56px)⇄宽态(图标+文字 200px)双态,折叠钮;连接列表在坞内宽态显示(列表+分组标签,弃树形);
3. **底部状态栏**(24px):连接状态点/当前会话编码/传输速率/CapsLock/版本;
4. StartTab→**工作台首页**:最近连接卡片流+快速新建+收藏横排(布局与官方欢迎页显著差异);
5. **自有配色**:dark=#0F1220 底+accent #F5A524(琥珀)/light=#FAFAF7 暖白+同 accent;全部 token 换新命名(bgBase→surface 等),弃 #14171d/#22d3ee/#15191f/#0078d4 全系;
6. 图标库更换:现用字符图标换为统一线条风(可用系统符号+自绘几何,保证与官方图标集不同)。

## C. 验收
- 深浅双主题×主页面截图矩阵(工作台/终端/设置/AI);
- 与官方 ref 图并排自查:布局结构/配色/图标三项显著差异清单写入 REPORT;
- SSH 回归(192.168.161.1:2222,新拓扑)+ 包名变更后 want 通道脚本同步可用;
- Apache 声明页存在且可见;
- REPORT-relay2.md + commit。

## 红线
功能零回归;改包名后所有 hdc 命令/签名/装机脚本同步;429/上下文将尽写 RESUME-STATE-RELAY2.md 再退;构建走 VM 原生链(注意先推源码再 VM 构建——上棒教训)。
