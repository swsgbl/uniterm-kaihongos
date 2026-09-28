# 任务书 021:M3 棒3b — SFTP 文件浏览器

M3 最后一棒:SFTP 远程文件浏览。前置状态:3a 已收官(见 `D:/uniterm/evidence/M3/REPORT-relay3a.md` 与 `RESUME-STATE-RELAY3A.md` 完结态),设备上是 build6-signed HAP + canonical 5 主机(A-gbk★/B-utf8/C-bs/D-vt220/E-plain),主密码 mp-735(want 通道 credSetup)。

## 目标(对齐上游能力子集)
在终端页(或连接详情)提供 SFTP 入口,浏览该连接的远端文件系统:列目录(名称/大小/权限/时间)、进入/返回目录、可下载文件到应用沙箱、可上传沙箱文件到远端当前目录。**参考上游**:`D:/uniterm/upstream/backend/session` 中 sftp 相关实现(接口语义以源码为准,引用行号),UI 参考上游前端 SFTP 双栏(本棒做**单栏远端浏览 + 传入手势**即可,双栏对齐列入 M4 以后)。

## 技术路线
- libssh HAR 已含 SFTP 支持(@ohos/libssh 基于 libssh 0.11.1,设计书 ③b 已证)。**先做 native 能力探针**:确认 HAR 现有 napi 封装是否暴露 sftp_init/opendir/readdir/read/write;缺则在 thirdparty/libssh-x86_64-har 增 napi 模块(**改 native 必须走 WSL 重编链 build-napi-x86_64.sh + build.cmd 重打包**,libc++ 用 SDK libcxx-ohos 头,坑见 RESUME-STATE 系列)。
- 传输进度走 EventHub 发 ArkTS;文件落沙箱 `files/` 或缓存目录;上传/下载完成后 hilog 记字节数+耗时。

## 验收判据(三重证据)
1. **列目录**:连接 A-gbk(或 B-utf8)→ 打开 SFTP 面板 → 显示 /home/uterm 下真实文件清单(与 WSL 侧 `ls -la` 比对≥5 项一致;dump 布局文本提取);截图 1。
2. **导航**:进入子目录再返回,列表正确刷新(hilog path 变更行);截图 2。
3. **下载**:选一个≥1KB 文本文件下载,hilog bytes+耗时,`hdc file recv` 拉回宿主与 WSL 原件 diff 一致(md5)。
4. **上传**:把宿主一个小文件 push 到设备沙箱→上传→WSL 侧 md5 一致。
5. **断连处置**:SFTP 面板打开时断开连接(杀会话),面板呈错误态不 crash(hilog 无 FATAL)。
截图前 dump 断言前台 net.uniterm.poc(3a 教训)。

## 红线与纪律
- 产品缺陷如实修+重建重装重验;设备旧包陷阱(构建时间戳核对)。
- 欲知上游行为以 upstream 源码为准(行号);工具链已知坑(inputText 安全键盘吞字、want 中文 GBK 损坏、hilog 50 块采样、终端视图不自动滚底)见 REPORT-relay3a.md「关键调试发现」8 条。
- 上下文将尽/429:写 RESUME-STATE-RELAY3B.md 固化断点再退(格式仿 3A)。
- 完成写 `evidence/M3/r3b/REPORT-relay3b.md`,汇报各项 ✅/❌+关键 hilog 行+证据清单。

## 环境
- hdc 127.0.0.1:5555;靶机 uterm@10.0.2.2:2222(target-relay 常驻,**勿动 22/2222 端口**);构建签名装机 scripts\{build,sign,deploy}.cmd。
