# 任务书 030:M5 棒2 — UI 一比一对标修复(官方外壳 P0)

## 背景(重要,先读懂)
用户对当前 UI 提出批评:**与官方 uniterm 界面完全不一样,不是一比一**。编排者核查结论:
- parity 线只拷贝了组件文件,**Index.ets(9-20 旧版)从未重接外壳**——其 028 文档把"官方外壳接入"列在 P0 待办第 0 条,RELEASE-NOTES 却虚报为已完成;
- 你 VM(15566,注意现在是 **KaihongOS 5.0.2.58**)上跑的是旧移动端布局(浅色卡片列表),差官方(深色 PC 桌面范式)极远。

## 一比一基准(必须以这些为准,不许自由发挥)
1. **官方截图全集**:`D:/uniterm/upstream/docs/imgs/*.webp`(24 视图×深/浅两套)。关键:start_tab.webp(外壳主视图)、new_connection.webp、workspace.webp、sftp.webp、shortcuts.webp。webp 用 node sharp 无则 python Pillow 转 png 查看;
2. **用户对标图**:`D:/uniterm/evidence/ui-parity/ref-official.png`(官方深色主界面,以此为主基准);
3. **精确样式来源**:上游 Vue 源码+CSS 变量——`upstream/frontend/src/style.css`(:root 主题 token)、`App.vue`、`components/layout/`(AppHeader/Sidebar/TabsList 等的实际结构/尺寸/间距)、`components/connection/`(连接树行样式)。**尺寸、间距、颜色、字号逐项从源码抄,不凭感觉**。

## 任务:实现官方外壳 P0(028 文档的 P0 清单,以源码为准)
1. **Index.ets 重写为外壳宿主**:顶栏 AppHeader(高≈38px:左连接切换钮→水平 TabsList[图标+名+×,+新建]→AI 按钮→设置下拉[主题/语言/密钥代理/隧道/导入导出/设置/关于])+左侧 Sidebar(宽≈280px:搜索框→7 视图切换图标→类型过滤→新建菜单→**高密度分组树**[行高 26-28px、★收藏、协议徽标、▸折叠])+主区 tab 内容路由;
2. **主题系统**:官方 token 全量移植(--bg-base #14171d/--bg-elevated #191c24/--bg-surface #1f222b/--accent #22d3ee/--text-primary #e6e8ed 等,以 style.css 实测为准),AppStorage 驱动,深/浅两套(浅色对照 official *_light.webp);
3. **StartTab**(默认欢迎页,对照 start_tab.webp:最近连接/快速新建/入口卡);
4. **tab 承载**:terminal(现有 TerminalPage 嵌入)/sftp/settings(现有 SettingsTab/各 Tab 组件)接入 TabsList;双击侧栏连接→开终端 tab(028 P0 第 0 条的接线,注意 ConnStore 初始化时序);
5. **i18n**:zh-CN/en 双语(复用官方 `frontend/src/i18n` 词汇)。

## 验证循环(每轮必须)
build → sign(oh-community 链,参考 evidence/M5/relay1 的签名命令/产物)→ `hdc -t 127.0.0.1:15566 install -r` → 启动 → 截图(与 ref-official.png **同视角**:StartTab+连接侧栏)存 `evidence/M5/relay2/iterN.png` → 自查差距清单(布局/颜色/密度逐项)→ 下一轮。**至少 3 轮迭代**,直到与基准"肉眼难分"级别;每轮截图+差距清单留档。

## 收尾
- SSH 回归一次(uterm@10.0.2.2:2222,WSL sshd:2222 编排者已拉起);
- REPORT-relay2.md:实现清单(逐组件对照源码行号)+各轮截图对比结论+遗留;
- 红线:M1-M4 已验收行为不回退;429/上下文将尽写 RESUME-STATE-RELAY2.md 再退;不动签名材料;hdc 5555 模拟器不在线,一切装机验证走 15566。
