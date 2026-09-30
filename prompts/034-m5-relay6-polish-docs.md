# 任务书 034:M5 收官棒 — UI 细节终轮 + 对外文档务实化

## 背景
028 功能清单深度验收已全线闭环(八项全 PASS,证据 evidence/M4//M5/)。本棒是最后一支开发棒,两件事:

## A. UI 细节终轮(时间盒:一轮构建装机)
对照官方基准(evidence/ui-parity/ref-official.png + upstream/docs/imgs/*.webp)做最后一轮细节打磨:
1. 图标风格统一(侧栏 7 视图/类型徽标/按钮图标与官方视觉一致性);
2. StartTab 卡片间距/比例、连接树行高/字重微调;
3. **浅色主题对照**:切浅色主题截图 vs 官方 *_light.webp(start_tab_light 等),偏差大则修 token;
4. 一轮构建(VM 原生链)→装机→深浅两套截图存档 evidence/M5/relay6/。**不求像素级完美,达"同范式高质量"即收**。

## B. 对外文档务实化(重要,合规)
parity 线的 RELEASE-NOTES.md 虚报了能力("全协议 100% 对齐"),必须改为实证版:
1. 重写 RELEASE-NOTES.md:按深度验收真实结果列能力(SSH 终端/SFTP/本地终端/Telnet/PostgreSQL/Redis/VNC/RDP/AI 侧栏/监控/分组收藏/凭据加密/.utm 互导;注明 MySQL/K8s/X11/SPICE/Zmodem 等官方其余能力为后续路线);
2. README.md 功能清单同步更新(与仓库现状一致);
3. 版本号建议 1.1.0(功能版)。

## C. 交付
- evidence/M5/relay6/REPORT-relay6.md(截图对比+文档变更清单);
- 源码+文档 git 提交(编排者复核后推送)。

## 红线
- 功能零回归(不动已验收逻辑);VM 原生链构建;429/上下文将尽写 RESUME-STATE-RELAY6.md 再退。
