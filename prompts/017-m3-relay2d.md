角色与使命:uniterm KaihongOS M3 棒 2d(收尾棒):**身份库 E2E 五步验证**。背景:M3-2 其余全部终验通过(互导四方向铁案);身份库代码已审计齐全(IdentityStore/IdentityManager/materialize),只差实机验证。断点事实源 D:\uniterm\evidence\M3\RESUME-STATE.md(M3-2 完成标注+环境事实)。

环境(棒2c已备好):WSL 靶机 uterm@10.0.2.2:2222 密码 uterm-pw-735,明文密钥 r2c-m3key-plain.pem(其公钥已在 authorized_keys);设备已装最新包(10:10 build)。

本棒任务:
1. 允许一处小增量:给 WantParams 增加 identityParams want 通道(完全沿用 credSetup/importText 模式,驱动 IdentityStore.createIdentity+刷新),避免密码框 IME 双写坑。若你判断 UI 驱动更快也可走 UI(keyText 身份的 PEM TextArea 不双写),二选一,报告说明。
2. 身份库 E2E 五步(全部实机+证据):
   ① 建两个身份:id-pw(密码型,username=uterm,password=uterm-pw-735)、id-key(keyText 型,username=uterm,PEM=r2c-m3key-plain.pem);
   ② 两台主机分别 authType=identity 引用 → 连接 → hilog authMethod=password/publickey 证据 + 终端提示符截图;
   ③ 重启应用 → credUnlock → 两台 identity 主机仍可连(凭据经 seal/reveal 物化);
   ④ 删除 id-pw → 引用它的主机显示"身份缺失"标注,连接给出明确错误不 crash;
   ⑤ 该主机改绑 id-key → 恢复可连。
3. 证据:截图≥4、hilog、更新 RESUME-STATE.md 标注 M3-2 全部完成(含身份 E2E)、把结果并入 REPORT-relay2.md。

红线:身份凭据必须走 seal/reveal 加密链(不允许明文落盘绕过);"身份缺失"判定必须来自真实数据层;产物只落 kaihongos 与 evidence\M3。

回复要求:≤12 行:通道选择一行、五步各一行(✅/❌+关键观测)、证据路径、踩坑、遗留。
