# Campfire Under Stars / 星空篝火

受《Outer Wilds》氛围启发的私人原创 Connect IQ 表盘，面向 **Garmin fēnix 7 Pro（47 mm，260 × 260 MIP）**。星空下的松林、远方带环星球、烤棉花糖的小木棍和一簇篝火，配上清楚的大号像素时间。

![新版模拟器预览](preview.png)

[查看动态预览](preview-animated.gif) · [查看休眠画面](preview-sleep.png)

## 新版的画面与数据

- 自绘像素字体、稀疏星星、阶梯远山、两侧松树和有冷暖对比的营地。
- 显示时间、星期与月日、电量、当天步数、心率。电池图标后的数字为电量百分比。
- 时间遵循手表的 12/24 小时设置；12 小时模式显示 AM/PM。
- 日期遵循手表本地时间，格式为 `FRI 10.09`（星期五、10 月 9 日）。
- 抬腕后，系统每秒更新一次火焰与火星；休眠时保留静态营地，系统每分钟更新时间。
- 数据在清醒时每 5 秒读取一次，在休眠时随每分钟更新读取；跨分钟会刷新日期。
- 心率先读取系统当前值；当前值不可用时，最多采用最近 5 分钟内的一条有效记录。无有效数据时显示 `--`。表盘不主动开启传感器测量。
- 步数缺失时显示 `--`，零步显示 `0`；六位及以上步数会缩小字体。
- 电量不高于 20% 时，电池图标和数字变为橙色。

画面完全由 Monkey C 绘图代码构成，配色使用 MIP 的 64 色 RGB 色阶，无游戏贴图、联网请求或高频定时器。

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

## 改动入口

| 文件 | 内容 |
| --- | --- |
| `source/CampfireFace.mc` | 数据读取、时间格式、日期/电量、底部步数与心率布局 |
| `source/CampfireScene.mc` | 星星、星球、山林、篝火、六帧火焰、火星与配色 |
| `source/PixelFont.mc` | 自绘 5 × 7 字形、缩放与间距 |
| `tools/build.ps1` | 自动发现本机 SDK 和密钥，生成调试或正式包 |
| `archive/v1/` | 重做前的源码、说明、预览和已编译文件 |

旧版已备份，后续修改直接在 `source/` 中进行。预览图片来自 Garmin 模拟器；修改源码后需要重新编译、运行，并用模拟器的 File → Save Screen Capture 更新图片。

## 验证与实际限制

2026-10-09 使用本机 **Connect IQ SDK 9.2.0** 编译，正式包与调试包均无编译警告。已在 fēnix 7 Pro 模拟器检查 12/24 小时显示、日期、步数、缺失心率以及清醒/休眠切换；对比连续截图验证清醒时火焰变化、休眠时火焰静止。

模拟器报告运行内存约 26 KB，低于设备约 124 KB 的可用上限。没有实现每秒低功耗局部更新，诊断窗口中的相关数字不能当作真实耗电测试。

尚未在实体手表上验证色彩、抬腕表现和续航。MIP 实机的亮度、对比度取决于环境光，电脑预览更鲜艳。这个项目是受游戏氛围启发的非官方原创作品。

## 官方资料与同题材表盘

- [Garmin 兼容设备与屏幕规格](https://developer.garmin.com/connect-iq/compatible-devices/)
- [WatchFace 刷新与睡眠回调](https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/WatchFace.html)
- [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/)

Connect IQ 商店里能找到 `Bonfire Woods Falling Leaves`（[LXWATCH 的作品列表](https://apps.garmin.com/el-GR/developer/823222d1-80b8-4e9b-934f-bf667f4dc896/apps)）与 `Campfire Middle Forest Full Moon`（[LXTHEMES 的作品列表](https://apps.garmin.com/ja-JP/developer/7c5c1986-7fb2-460a-a2f8-4a5b4b554626/apps)）。截至本次检索，没有找到明确的《Outer Wilds》主题表盘；这不代表商店里一定没有。上述作品与 fēnix 7 Pro 的兼容性请以手机 Connect IQ 应用选中设备后的结果为准。
