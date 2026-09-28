# 任务书 031:M5 棒3 — 在 VM 上以 API14 工具链原生重编(修 napi 断裂)

## 已确诊(编排者 SSH 回归实证,evidence/M5/relay2/_zj-ssh-regress3.cjs 输出)
iter8b(混合注入包)SSH 引擎断裂:`SSH2Napi` 导出名缺失(ets 与 so 导出面不匹配)。UI 外壳正常,但 `connectNow` 无 session 日志——SSH 模块加载即失败。**根因**:5.0.2.58 只支持 abc ≤12;我们 hvigor(API26)产 v24;混合注入导致 abc/so 不配套。

## 正确路径(028 配方,parity 线已验证可跑通)
**在 VM(15566)上用其自带 KaihongOS API14 工具链原生构建合并源码**:
1. 源码上传:把 `D:/uniterm/kaihongos`(合并后工程)打包 push 到 VM `/data/local/home/tmp/app/`(参考 028:uniterm-kaihongos-main/kaihongos);或用 Quickemu 的 9P 共享(WSL /home/hongfu ↔ VM 挂载点,`sudo mount -t 9p -o trans=virtio,... Public-hongfu ~/hongfu`)直拷更快;
2. VM 构建(028 记录的坑都要遵守):
   - build-profile 已是 OpenHarmony/14;
   - `timeout 280 /data/local/home/.local/bin/pack_hap .`(java ENOENT 可忽略,C++ 打包接管);
   - so 不入包时:`node /data/local/home/tmp/fix-hap.cjs out_release.hap <libs dir> uniterm-fixed-unsigned.hap`(node=/data/local/home/dsh-pack/node/bin/node);
   - native so 用主线双 ABI 产物(x86_64 必须含 libssh_ohos_napi.so+libcrypto/libssh/libssl+libc++_shared;parity 的 4-so 精简包曾缺 libcrypto/libssh——**这正是导出面断裂嫌疑之一,重编时以 HAR libs 全集为准**);
3. 签名:hap-sign-tool + `kaihongos/thirdparty/signing/oh-community/` 三件套(keyAlias "OpenHarmony Application Release",双口令 123456);
4. `bm install` → `aa start` → **SSH 回归**(先 `--ps credSetup mp-735` 建库,再 credUnlock+importText($(cat 文件)+connectNow;payload 用 evidence/M5/relay2/_sshreg.json 模式;靶机 uterm@10.0.2.2:2222 密码 uterm-pw-735;**VM 内 10.0.2.2=WSL,sshd:2222 已在跑**);
5. UI 外壳回归:同视角截图(顶栏/侧栏/StartTab)与 `evidence/ui-parity/ref-official.png` 比对,确认外壳未回退;
6. abc 版本自检:解包产物 `ets/modules.abc` 头部 ver[12:16] 必须=[12,0,6,0](REPORT-relay2 有判据脚本 .verify/v8b.py);
7. 写 `evidence/M5/relay3/REPORT-relay3.md`。

## 红线
- 产物必须**单一来源原生构建**,不许再混合注入;
- 每次装机前记录当前包(可回滚);429/上下文将尽写 RESUME-STATE-RELAY3.md 再退;
- hdc 操作先 `hdc tconn 127.0.0.1:15566`(本机 hdc 可能丢注册)。
