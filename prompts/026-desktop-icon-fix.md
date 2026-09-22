# 任务书 026:桌面图标修复(module.json5 home 声明 + 官方图标)

用户反馈:**KaihongOS 虚拟机桌面上没有 uniTerm 快捷方式**。编排者已定位根因,本棒直接修。

## 根因(已确诊,勿再排查)
`entry/src/main/module.json5` 的 EntryAbility **缺两样**:
1. `"icon"` 字段(现在只有 startWindowIcon,Launcher 无图标可用);
2. `"skills"` 声明(`entities:["entity.system.home"]` + `actions:["action.system.home"]`)——没有它 Launcher 不认为这是桌面入口应用,故图标不上桌面、只能 `aa start` 拉起。

## 修改(全部在工程配置/资源层,不碰逻辑代码)
1. module.json5 abilities[EntryAbility] 增加:
   - `"icon": "$media:app_icon"`
   - `"skills": [ { "entities": [ "entity.system.home" ], "actions": [ "action.system.home" ] } ]`
2. 复制官方图标 `D:/uniterm/upstream/build/appicon.png` → `entry/src/main/resources/base/media/app_icon.png`(用户已拍板:图标与官方一致)。若 hvigor 对 icon 尺寸有告警,按需重采样(保留原图备份说明)。
3. 顺手改 `string.json` 的 `internet_permission_reason` 为面向用户的中文:"用于建立 SSH/SFTP 网络连接"(现值是开发期英文占位,权限弹窗可能展示给用户)。

## 验证(三重)
1. build+sign+deploy(时间戳核对防旧包);
2. **桌面可见**:回到 Launcher(`aa start -b com.ohos.launcher` 或 HOME 键),uitest dumpLayout 应出现 label=uniTerm 的图标节点;截图 `evidence/M4/relay3/desktop-icon.jpeg`(截图前 dump 断言含 uniTerm);
3. **点图标可启动**:按 dump 坐标点击桌面 uniTerm 图标 → 应用启动(连接管理页出现,hilog 进程启动证据);再截 `desktop-launch.jpeg`。
4. 若 Launcher 缓存旧包列表不刷新:force-stop launcher 进程或重启虚拟机后重验,如实记录所用的刷新手段。

## 产出
`evidence/M4/relay3/REPORT-relay3.md`:根因/修改 diff 摘要/桌面 dump+两截图/启动 hilog。红线:不碰 ArkTS/native 逻辑;环境同前(hdc 5555、勿动 22/2222);上下文将尽写断点再退。
