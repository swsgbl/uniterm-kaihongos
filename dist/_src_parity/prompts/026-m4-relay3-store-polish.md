# 任务书 026:M4 棒2 — 上架就绪打磨(分组去重 + 干净截图 + 占位图标)

开发功能已全线收口(M1-M4 棒1 全验收,见 evidence/M3、M4 各 REPORT)。本棒做上架前的打磨三件事,**不依赖 Public SDK/工作台**。

## A. 分组重复导入去重(修复 M3-4 记录的真缺陷)
现象:重复导入同 payload,groups 按 push 叠加(2→4→6…),connections 因按 name 生成新 id 同样膨胀。
修复:ConnList 的 `pendingImportGroups`/`mergeImport`(或 ConnStore 相应 upsert 逻辑)在 push 前按 **id 去重**(id 相同→更新而非追加);connections 的重复导入语义保持上游行为(上游按 name 生成新 id 追加——**不要改**,只修 groups)。
验收:同 payload 连导 2 次→`save ok groups=2`(不是 4);重启后仍 groups=2;单分组改名后再导→组名更新不新增。hilog 计数为证。

## B. 干净数据版上架截图(替代测试主机名版)
重置设备应用到**演示态**:卸载重装→credSetup(mp-735)→导入一套**演示主机**(命名专业、无测试痕迹,如:`docs`/`build-server`/`backup-nas`,含一个分组「生产」+一个收藏,主机可指向靶机但**名称/备注干净**;密码用靶机真密码以便截图时终端真实连接)。
拍 5 张截图(截图前 dump 断言前台 net.uniterm.poc):
1. 连接列表(分组+★收藏+顶栏)
2. 终端页(真实连接,屏幕内容干净——可跑 `neofetch` 或 `ls`/`htop` 类输出,若靶机无 neofetch 用 uname/ls -la --color)
3. SFTP 面板(列目录,状态 ok)
4. 主机编辑表单(编码/退格键下拉展开)
5. 身份管理或导入界面
存 `evidence/M4/store-shots/`(命名 shot-1-list.jpeg 等)。这些是商店上架截图候选。

## C. 占位应用图标(草案,用户终审)
生成 1 套简约文字型图标(如深色底+等宽字体 `>_` 或 `u_` 字样),1024x1024 PNG,放 `kaihongos/placeholder-icon/`。可用 node(canvas 不一定有,可手写 PNG 或用 SVG→PNG 简易路径;若环境不支持图像生成,输出 SVG 源+说明,注明需用户终审设计)。**不接入工程**(AppIcon 接入等用户拍板后在 M4 终棒做)。

## 红线
- A 只改分组去重逻辑;B/C 零产品代码改动(B 只动设备数据,C 只产出文件)。
- 环境:hdc 5555、uterm@10.0.2.2:2222、mp-735、勿动 22/2222;B 完成后设备保持演示态(别再导入测试 payload)。
- 429/上下文将尽:写 `evidence/M4/RESUME-STATE-RELAY3.md` 再退。
- 证据+汇报:`evidence/M4/relay3/REPORT-relay3.md`(A 的 hilog 链、B 的截图清单、C 的产物路径)。
