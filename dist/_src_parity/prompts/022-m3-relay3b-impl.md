# 任务书 022:M3 棒3b-实现(SFTP native 5 函数 + SftpPanel + E2E 五判据)

上一棒(侦察)已把全部设计固化在 `D:/uniterm/evidence/M3/RESUME-STATE-RELAY3B.md`——**先读它并严格照它执行**,本任务书不重复其内容。设备/靶机/构建链/已知坑全部以断点文件为准(hdc 用 127.0.0.1:5555,勿动 22/2222)。

## 执行序(断点文件已列 5 步,按序)
1. native:terminal_napi.cpp 增 SftpOpen/SftpList/SftpDownload/SftpUpload/SftpClose(复用 `s->session`;**SFTP 调用必须与 ReaderLoop 共用 chanMutex 短临界区**——libssh session 非线程安全,这是断点文件识别的头号风险)+ napi_init 注册 + Index.d.ts/Index.ets 声明;
2. WSL 重编:`wsl bash /mnt/d/uniterm/kaihongos/thirdparty/build-napi-x86_64.sh`(so 落 HAR libs/x86_64/)→ scripts\build.cmd → sign → deploy(构建时间戳核对,防旧包);
3. ArkTS:SftpPanel.ets(注册 main_pages)+ TerminalPage 入口按钮;下载落 `getContext().filesDir + '/sftp/'`;进度走 EventHub;
4. E2E 五判据取证(任务书 021 判据,断点文件已列):列目录≥5 项与 WSL ls 一致/导航/下载 md5 一致/上传 md5 一致/断连错误态不 crash;截图前 dump 断言前台 net.uniterm.poc;
5. 写 `evidence/M3/r3b/REPORT-relay3b.md`(各项 ✅/❌+关键 hilog 行+证据清单)。

## 红线
- 断点文件是本棒的设计权威;发现它与实际源码冲突时,以 `D:/uniterm/upstream` 源码为准并记录。
- 产品缺陷修了必须重建重装重验;429 或上下文将尽:更新 RESUME-STATE-RELAY3B.md 再退。
