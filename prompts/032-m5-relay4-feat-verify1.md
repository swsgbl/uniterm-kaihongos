# 任务书 032:M5 棒4 — 功能深度验收 I(本地终端/监控/PG/Redis)

## 背景
M5 收官后,VM 上运行的是官方外壳+SSH 正常的原生构建(net.uniterm.poc 1.0.0,abc v12)。parity 线声明的其余功能从未实证——现在逐项把"声明"变"事实"。**验收铁律:每项必须有可复核的机器证据(hilog/dump/截图)+我方独立可重跑的脚本;测不过就修,修不了如实记录为 BLOCKED+原因。**

## 本棒四项(自包含+现成靶机优先)

### 1. 本地终端(liblocalpty.so,/bin/sh)
UI 路径:StartTab「Local Terminal」按钮(或侧栏入口)→ 开本地终端 tab。
判据:tab 打开出 shell 提示符;输入 `uname -a` 回显 Linux/KaihongOS 内核串;`echo LOCAL_OK` 屏显 LOCAL_OK(dump 文本提取);截图。

### 2. 监控面板(/proc)
UI 路径:侧栏 7 视图中的监控视图。
判据:面板打开,CPU/内存等指标有**非零实时值且刷新**(两次 dump 值不同);截图。

### 3. PostgreSQL(WSL 127.0.0.1:5432,现成)
**前置(WSL 侧,我来指定你执行)**:PG 现绑 127.0.0.1,VM 不可达。改可从 VM 访问:
`sudo sed -i "s/^#\?listen_addresses.*/listen_addresses='*'/" /etc/postgresql/*/main/postgresql.conf` + pg_hba.conf 加 `host all all 0.0.0.0/0 md5`(或 scram)+ `sudo systemctl reload postgresql`(或 service)。建测试库表:
`sudo -u postgres psql -c "CREATE USER uniterm PASSWORD 'uniterm-pg'; CREATE DATABASE unitermdb OWNER uniterm;" && sudo -u postgres psql -d unitermdb -c "CREATE TABLE t1(id int, note text); INSERT INTO t1 VALUES (1,'PG-PARITY-OK');"`
UI:新建连接类型 PostgreSQL,host 10.0.2.2 port 5432 user uniterm pw uniterm-pg db unitermdb。
判据:连接成功;`SELECT note FROM t1;` 结果含 PG-PARITY-OK(dump/截图);失败如报密码 scram 不支持,如实记录(可改 md5 重试一次)。

### 4. Redis(WSL 127.0.0.1:6379,现成)
前置:redis 绑 127.0.0.1+protected-mode。改 `/etc/redis/redis.conf`: `bind 0.0.0.0`、`protected-mode no`,重启 redis-server。写测试键:`redis-cli SET uniterm:key "REDIS-PARITY-OK"`。
UI:连接 10.0.2.2:6379;判据:`GET uniterm:key` 返回 REDIS-PARITY-OK。

## 环境
- hdc 先 tconn 127.0.0.1:15566;UI 自动化用 dumpLayout 找坐标(新外壳的视图图标/连接入口,坐标每次实测定);
- WSL 服务探针/重启命令可直接 `wsl -d Ubuntu -- bash -c "..."`;sshd:2222 已在(勿动);
- want 通道注入连接(credSetup/credUnlock 已建库 mp-735;importText 用 /data/local/tmp 文件+$(cat) 套路);
- 产物落 `evidence/M5/relay4/`:每项一节(脚本+dump+截图+hilog 摘录),最后 REPORT-relay4.md(四项 ✅/❌/BLOCKED 表)。
- 红线:不动签名材料/构建链;发现产品 bug 修了要在同棒重建重装重验(VM 原生链:pack_hap→7-so 注入→本地链签名);429/上下文将尽写 RESUME-STATE-RELAY4.md 再退。
