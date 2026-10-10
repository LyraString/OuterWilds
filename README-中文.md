# Outer Wilds

受《Outer Wilds》氛围启发的 Garmin fēnix 7 Pro 像素篝火表盘，使用原创绘图，不含游戏素材。

![表盘预览](preview.png)

[动态预览](preview-animated.gif) · [休眠画面](preview-sleep.png)

## 画面与数据

- 星空、蓝色圆形星球、松林、篝火和烤棉花糖。抬腕时星星按 12 秒周期呼吸，火焰和火星变化；休眠时画面静止，每分钟更新时间。
- 时间数字独立居中，遵循手表的 12/24 小时设置；AM/PM 放在数字右侧。天气、海拔、时间和日期沿中线排列。
- 步数与心率同一行，数字和图标对齐底线；电量居中在下一行，竖向电池内部用连续柱条表示电量。电量不高于 20% 时变为橙色。
- 最多完整显示五位步数，超出时缩写为 `100k`、`1M` 等；无有效步数或心率时显示 `--`。
- 当前支持 **47 mm fēnix 7 Pro（fenix7pro）**：260 × 260、64 色 MIP。其他型号尚未适配。

气温与天气读取 Garmin 已缓存的当地天气，需要手机 Garmin Connect 同步；已知观测超过两小时显示 `STALE`，缺失或未知天气显示 `N/A`。`P.CLOUDY` 表示局部多云，`CLEAR` 表示晴朗，`CLOUDY` 表示多云；带 `?` 的标签表示可能出现该天气。

海拔优先读取当前测量值，不可用时读取最近五分钟的海拔历史。心率优先读取当前值，不可用时读取最近五分钟的有效样本。单位跟随手表设置，支持米／英尺、摄氏／华氏；表盘不主动启动 GPS 或传感器测量。

## 安装与更新

1. 用 USB 数据线连接手表和电脑。
2. 在文件资源管理器中打开手表，把 [OuterWilds-fenix7pro.prg](dist/OuterWilds-fenix7pro.prg) 复制到内部存储的 `GARMIN/APPS`。
3. 复制完成后断开连接，等待手表处理。
4. 长按左侧中间的 UP/MENU →「表盘」→ **Outer Wilds** → START →「应用」。

更新已有的侧载版本时，先切换到自带表盘，沿用上次成功安装时的 `.prg` 文件名复制新版；如果提示同名文件，选择替换，断开连接后重新应用表盘。安装后 `.prg` 可能进入受保护存储，目录里看不到它不代表安装失败。`.prg` 用于 USB 侧载，`.iq` 用于商店发布。

## 构建与预览

需要 Garmin Connect IQ SDK、`fenix7pro` 设备资料、VS Code 的 Monkey C 扩展，以及自己的开发者密钥。构建脚本自动读取 SDK Manager 的当前 SDK 配置和 VS Code 的 `monkeyC.developerKeyPath`。

在项目目录运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build.ps1
```

| 参数 | 输出 |
| --- | --- |
| 无 | `dist/OuterWilds-fenix7pro.prg`，用于侧载 |
| `-DebugBuild` | `bin/OuterWilds.prg`，用于模拟器调试 |
| `-Test` | `bin/OuterWilds-tests.prg`，包含单元测试 |

可用 `-SdkPath` 和 `-DeveloperKey` 显式指定 SDK 与密钥路径。编译中间文件统一放在已忽略的 `bin/` 中，`dist/` 只保留当前安装包。

在 VS Code 打开 `source/CampfireApp.mc`，选择 **Preview: fenix 7 Pro**，按 **Ctrl+F5**。模拟器通过 **Settings → Display Mode → High Power / Always-Active** 切换清醒和休眠；通过 **File → Save Screen Capture** 保存画面。

## 测试与字体

启动 Connect IQ 模拟器后运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build.ps1 -Test
$taskSdk = (Get-Content "$env:APPDATA\Garmin\ConnectIQ\current-sdk.cfg" -Raw).Trim()
& "$taskSdk\bin\monkeydo.bat" .\bin\OuterWilds-tests.prg fenix7pro /t
```

四项测试覆盖温度与海拔换算、缺失值、天气标签和两小时有效期边界。以控制台 `RESULTS` 为准；`monkeydo` 的退出码不能单独判断测试是否通过。正常构建不包含测试函数。

时间数字采用 Rajdhani Medium，步数和心率采用 Rajdhani SemiBold 的 14 像素单色笔画，避免小字号的灰色碎边；字体版权归 Indian Type Foundry，使用 [SIL Open Font License 1.1](tools/assets/rajdhani/OFL.txt)。生成好的字体位于 `resources/fonts/`，正常编译无需 Python。修改字体时，安装 Pillow 后运行 `python tools/generate-time-font.py`；源字体与许可证位于 `tools/assets/rajdhani/`。

## 项目结构

| 路径 | 用途 |
| --- | --- |
| `source/CampfireApp.mc` | 应用入口 |
| `source/CampfireFace.mc` | 数据读取、时间格式和信息布局 |
| `source/CampfireScene.mc` | 星空、星球、山林与篝火动画 |
| `source/CampfireConditions.mc` | 天气标签、单位换算和有效期判定 |
| `source/tests/` | 天气与单位换算测试 |
| `resources/` | 应用名称、启动图标与字体 |
| `tools/` | 构建脚本、字体生成脚本和源字体 |
| `dist/` | 当前侧载包 |

已在 Connect IQ SDK 9.2.0 和 fēnix 7 Pro 模拟器检查编译、单位换算、动画及数据布局；步数和心率的字体修正已获用户实机确认。续航尚未量化，模拟器画面不能替代实机的亮度和耗电测试。

历史版本通过 Git 提交和标签回溯，变更见 [CHANGELOG.md](CHANGELOG.md)。本地修改和验证完成后，等待用户明确要求发布再推送 GitHub、创建正式版本标签。
