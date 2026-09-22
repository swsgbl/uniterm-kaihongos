# 任务书 025:M3-4 — 遗留修复(groups 持久化 + vt220 单测)

M4 棒1(arm64/双 ABI/.app)已收官。本棒清 M3 遗留两项,是**最后一支功能开发棒**,范围严格限定。

## 背景(来自 evidence/M3 各 REPORT)
1. **groups=0 持久化缺陷**:relay-3a 收尾发现 canonical payload 里的 groups 导入后设备 connections.json `groups=0`(未持久化)。上游语义:`D:/uniterm/upstream/backend/store/connection_store.go`(groups 数组随 connections 一起存取;ConnImporter 的分组归属 groupId 字段)。排查点:kaihongos ConnStore 保存/加载是否包含 groups 字段、ConnImporter 是否解析 groups、ConnList UI 折叠行的数据源。
2. **vt220 前缀单测缺失**:backspaceKey=vt220 = 0x7F 主字节 + `\x1b[3~` 前缀映射(3a 只实证了 bs/del 二态)。补 native 或 ArkTS 层单测(仿 gbk_test.cpp 的 WSL 宿主侧测试模式),断言三态映射表完整:bs→0x08、del→0x7F、vt220→`\x1b[3~`+0x7F。

## 验收判据
1. groups:导入含 2 分组的 payload→设备 connections.json 里 groups=2 且条目 groupId 正确;列表页分组折叠正常;**重启后仍在**(want 通道或应用内导出核验+落盘抽查)。
2. vt220:单测 3/3 断言通过,输出映射字节序列存证;如有可 E2E 的低成本路径(od 法,同 3a)则跑一次 vt220 主机连接实证,成本高就单测为准并说明。
3. 完成写 `evidence/M4/relay2/REPORT-relay2.md`(或 evidence/M3/m4-relay2/,沿用 M4 目录即可)+ 更新断点。

## 红线
- 改动范围:ConnStore/ConnImporter/ConnList(groups)+ 映射表测试;不碰 SSH/SFTP/加密链路。
- 修了必须重建重装重验(构建时间戳核对);工具链坑见 evidence/M3/r3a/REPORT-relay3a.md 第五条 8 项。
- 环境:hdc 5555、uterm@10.0.2.2:2222、主密码 mp-735、勿动 22/2222。
- 429/上下文将尽:写 RESUME-STATE 再退。
