角色与使命:uniterm KaihongOS M3 棒 3a:**连接体验强化四件套**(编码/退格/保活/收藏)。M3-1/M3-2 已全部终验通过。断点事实源 D:\uniterm\evidence\M3\RESUME-STATE.md。纪律继承;产物只落 kaihongos 与 evidence\M3。

任务(每项独立可验,做完一项验一项):
1. **GBK 编码**:主机 encoding 字段生效——native 读循环当前按 UTF-8 处理,需按主机 encoding 配置解码(iconv 链路:libssh so 已链 libcrypto,加 iconv 或直接在 napi 层用 Windows?不,统一在 native 层用 iconv API;若 OHOS NDK 无 iconv,自实现 GBK↔UTF-8 表或链接 glibc iconv,选型写报告)。写方向同理(输入 UTF-8→GBK)。验收:WSL 侧 `export LANG=zh_CN.GBK` + `echo 中文测试` 输出,App encoding=gbk 主机显示正确中文;utf-8 主机回归不受影响。
2. **backspaceKey 三模式**:del(\x7f)/bs(\x08)/vt220,表单下拉,终端输入生效(hilog 写入字节可证)。验收:退格在 WSL `stty erase` 对应行为正确。
3. **keepalive**:native 层 ssh_keepalive 周期(默认 30s,配置留参),断网存活改善。验收:hilog keepalive sent 计数 ≥2(挂 90s 会话),连接不断。
4. **最近连接/收藏**:列表顶部"最近"区(按最后连接时间排序,存 preferences)+ 主机收藏星标(置顶);重启保持。验收:连两台→最近区顺序正确→收藏一台→重启→置顶保持。

验收与归档(evidence\M3\r3a\):截图≥5(GBK 中文显示/退格行为/收藏置顶/最近区)、hilog、REPORT-relay3a.md、RESUME-STATE.md 更新(标注 M3-3a 完成)。

红线:GBK 解码必须在 native/数据层真实转换(禁止 UI 端假装);每项完成后真机验证再进下一项;发现既有 bug 顺手修但单独列报。

回复要求:≤14 行:四项各一行(✅/❌+关键观测)、iconv 选型一行、修复清单、遗留(SFTP 留棒3b)。
