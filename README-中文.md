# Campfire Under Stars / 星空篝火

受《Outer Wilds》氛围启发的原创 Connect IQ 表盘，面向 **Garmin fēnix 7 Pro（47 mm，260 × 260 MIP）**。星空下的松林、远方带环星球、烤棉花糖的小木棍和一簇篝火，配上偏户外仪表风格的大号粗体数字。

![新版模拟器预览](preview.png)

[查看动态预览](preview-animated.gif) · [查看休眠画面](preview-sleep.png)

## 新版的画面与数据

- 稀疏星星、阶梯远山、两侧松树和有冷暖对比的像素营地。
- 时间采用 Garmin 原生粗体数字（`FONT_NUMBER_HOT`），信息小字采用简洁的 `FONT_XTINY`。
- 显示时间、星期与月日、电量、当天步数、心率、海拔、当地气温与英文天气状态。电池图标后的数字为电量百分比。
- 移除顶部 `UNDER THE STARS`，用这一区域显示气温和天气；海拔显示在日期下方。
- 时间遵循手表的 12/24 小时设置；12 小时模式显示 AM/PM。
- 日期遵循手表本地时间，格式为 `FRI 10.09`（星期五、10 月 9 日）。
- 抬腕后，系统每秒更新一次火焰与火星；休眠时保留静态营地，系统每分钟更新时间。
- 数据在清醒时每 5 秒读取一次，在休眠时随每分钟更新读取；跨分钟会刷新日期。
- 心率先读取系统当前值；当前值不可用时，最多采用最近 5 分钟内的一条有效记录。无有效数据时显示 `--`。表盘不主动开启传感器测量。
- 步数缺失时显示 `--`，零步显示 `0`。
- 电量不高于 20% 时，电池图标和数字变为橙色。

画面由 Monkey C 绘图与 Garmin 原生字体构成，配色使用 MIP 的 64 色 RGB 色阶，无游戏贴图或高频定时器。

## 海拔、气温和天气

海拔优先读取 `Activity.getActivityInfo().altitude`，为空时读取最近五分钟内的海拔历史样本；单位跟随手表的海拔设置，支持米和英尺。零值和低于海平面的负值正常显示，没有有效测量时显示 `ALT -- m` 或 `ALT -- ft`。清单增加 `SensorHistory` 权限用于读取历史样本。

气温和天气读取 [`Weather.getCurrentConditions()`](https://developer.garmin.com/connect-iq/api-docs/Toybox/Weather.html) 的系统缓存，气温是当地天气的空气温度。摄氏度／华氏度跟随手表的温度设置。天气状态包括 `CLEAR`、`P.CLOUDY`、`CLOUDY`、`RAIN`、`SHOWERS`、`SNOW`、`WINDY`、`FOG`、`STORM` 等；带 `?` 的状态表示可能出现该天气。

天气更新依赖手机 Garmin Connect 的同步及其天气数据来源。若长时间不更新，请检查手机与手表的连接及 Garmin Connect 的定位权限，参考 [Garmin 天气排查说明](https://support.garmin.com/en-US/?faq=Mxs4eRXzRdAYJ0h7yyWaj9)。表盘不自行请求天气服务，也不主动启动 GPS 或传感器。

气温缺失显示 `--°C` / `--°F`；天气为空或未知显示 `N/A`。若已知观测时间距现在超过两小时，隐藏旧气温并显示 `STALE`，避免将旧观测当作当前天气。

## 直接安装这一版

已编译的侧载文件：[`dist/CampfireUnderStars-fenix7pro.prg`](dist/CampfireUnderStars-fenix7pro.prg)。

1. 用支持数据传输的 USB 线连接手表。
2. Windows 文件资源管理器中打开 Garmin 设备，把上述 **一个 `.prg` 文件**复制到 `GARMIN/APPS`。
3. 安全弹出并断开连接，等待手表完成索引。
4. 表盘页长按 UP/MENU →「表盘」→ `Campfire Under Stars` → START →「应用」。

侧载包是 `.prg`，商店发布包是 `.iq`。安装后文件可能移入设备的受保护存储，目录里看不到它不一定表示安装失败。

当前清单只包含已安装设备资料并完成编译的 `fenix7pro`。**7S Pro、7X Pro 和 no-Wi-Fi 变体没有在这一版中验证。**

## 在本机继续 vibe coding

本机已有 Garmin Connect IQ SDK、fēnix 7 Pro 设备资料、VS Code Monkey C 扩展配置和开发者密钥。密钥保留在你现有的位置，不复制进项目。

在项目目录的 PowerShell 中编译正式侧载包：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build.ps1
```

脚本会读取 Garmin SDK Manager 的当前 SDK 配置与 VS Code 的 `monkeyC.developerKeyPath`。也可以明确传入路径：

```powershell
.\tools\build.ps1 -DeveloperKey 'D:\你的密钥目录\developer_key' -SdkPath 'C:\你的SDK目录'
```

生成用于模拟器调试的版本：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build.ps1 -DebugBuild
```

输出为 `bin/CampfireUnderStars.prg`。在 VS Code 用「Run Without Debugging / Ctrl+F5」，设备选择 `fēnix 7 Pro`。SDK 9.2 的模拟器可通过 **Settings → Display Mode → High Power / Always-Active** 切换清醒与低功耗显示，检查火焰动态和静止效果。

运行天气和单位换算的单元测试（先启动 Connect IQ 模拟器）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build.ps1 -Test
$taskSdk = (Get-Content "$env:APPDATA\Garmin\ConnectIQ\current-sdk.cfg" -Raw).Trim()
& "$taskSdk\bin\monkeydo.bat" .\bin\CampfireUnderStars-tests.prg fenix7pro /t
```

测试使用 Garmin 的 `(:test)` 注解，正常编译时不包含测试函数。以控制台的 `RESULTS` 为准；模拟器报告测试失败时，`monkeydo` 仍可能返回零退出码。

## 改动入口

| 文件 | 内容 |
| --- | --- |
| `source/CampfireFace.mc` | 数据读取、时间格式、原生字体及所有信息布局 |
| `source/CampfireScene.mc` | 星星、星球、山林、篝火、六帧火焰、火星与配色 |
| `source/CampfireConditions.mc` | 天气英文标签、气温／海拔单位换算、过期判定 |
| `source/tests/CampfireConditionsTests.mc` | 缺失值、零值、负值、单位换算和天气有效期测试 |
| `tools/build.ps1` | 自动发现本机 SDK 和密钥，生成调试、测试或正式包 |
| `archive/v1/` | 重做前的源码、说明、预览和已编译文件 |

旧版已备份，后续修改直接在 `source/` 中进行。预览图片来自 Garmin 模拟器；修改源码后需要重新编译、运行，并用模拟器的 File → Save Screen Capture 更新图片。

## 验证与实际限制

2026-10-09 使用本机 **Connect IQ SDK 9.2.0** 编译，正式包、调试包与测试包均无编译警告。四项单元测试全部通过，覆盖温度和海拔单位换算、缺失值、零值、负值、天气标签与两小时有效期边界。

已在 fēnix 7 Pro 模拟器检查 12/24 小时显示、日期、步数、心率及缺失心率、摄氏／华氏温度、米／英尺海拔和清醒／休眠切换；对比连续截图验证清醒时火焰变化、休眠时火焰静止。预览中的数值来自模拟器数据。

没有实现每秒低功耗局部更新，模拟器诊断数字不能当作真实耗电测试。

尚未在实体手表上验证色彩、抬腕表现和续航。MIP 实机的亮度、对比度取决于环境光，电脑预览更鲜艳。这个项目是受游戏氛围启发的非官方原创作品。

## 官方资料与同题材表盘

- [Garmin 兼容设备与屏幕规格](https://developer.garmin.com/connect-iq/compatible-devices/)
- [WatchFace 刷新与睡眠回调](https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/WatchFace.html)
- [天气数据](https://developer.garmin.com/connect-iq/api-docs/Toybox/Weather/CurrentConditions.html)
- [海拔历史](https://developer.garmin.com/connect-iq/api-docs/Toybox/SensorHistory.html)
- [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/)

Connect IQ 商店里能找到 `Bonfire Woods Falling Leaves`（[LXWATCH 的作品列表](https://apps.garmin.com/el-GR/developer/823222d1-80b8-4e9b-934f-bf667f4dc896/apps)）与 `Campfire Middle Forest Full Moon`（[LXTHEMES 的作品列表](https://apps.garmin.com/ja-JP/developer/7c5c1986-7fb2-460a-a2f8-4a5b4b554626/apps)）。截至本次检索，没有找到明确的《Outer Wilds》主题表盘；这不代表商店里一定没有。上述作品与 fēnix 7 Pro 的兼容性请以手机 Connect IQ 应用选中设备后的结果为准。
