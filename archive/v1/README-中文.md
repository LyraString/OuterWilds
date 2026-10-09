# Campfire Under Stars / 星空篝火（Fēnix 7 Pro）

给 Garmin fēnix 7 Pro 制作的私人 Connect IQ 表盘原型：黑色星空、简约时间、篝火火焰与稀疏火星。

## 第 1 步：安装开发工具

1. 安装 Visual Studio Code：https://code.visualstudio.com/
2. 安装 Garmin Connect IQ SDK Manager：https://developer.garmin.com/connect-iq/sdk/
3. 在 SDK Manager 中登录 Garmin 账号，下载安装最新 Connect IQ SDK 以及 fēnix 7 Pro 的设备资料。
4. 在 VS Code 扩展里安装 Garmin 发布的 `Monkey C`。
5. 运行命令面板（Windows Ctrl+Shift+P / macOS Cmd+Shift+P）中的 `Monkey C: Verify Installation`。
6. 如果提示没有开发者密钥，运行 `Monkey C: Generate a Developer Key` 并妥善保管密钥文件。

## 第 2 步：打开与模拟运行

1. 解压本项目，VS Code → File → Open Folder → 选择 `CampfireUnderStars` 文件夹。
2. 打开 `source/CampfireFace.mc`，确保它是当前选中的代码编辑窗口。
3. VS Code 菜单 Run → Run Without Debugging（macOS Cmd+F5 / Windows Ctrl+F5）。
4. 在设备列表选择 `fēnix 7 Pro`（或与你实际型号相符的 `fēnix 7 Pro – Solar Edition (no Wi-Fi)`）。
5. 模拟器里测试当前时间与火焰；用模拟器的手表抬腕/低功耗状态控制测试 `onExitSleep` 和 `onEnterSleep`。

## 第 3 步：编译为 .prg

1. VS Code 命令面板运行 `Monkey C: Build for Device`。
2. 设备选择与你手表相同的 `fēnix 7 Pro` 变体。
3. 选择电脑上一个导出文件夹，生成用于侧载的 `.prg` 文件。
4. 注意 `.iq` 商店发布包和 `.prg` 手表侧载包不是同一个文件；这里应该复制 `.prg`。

## 第 4 步：USB 侧载到手表

1. 用支持数据传输的 USB 线把手表接到电脑。
2. Windows：在文件资源管理器里打开 Garmin 设备。
   macOS：如果 Finder 看不到手表，通常需要能访问 MTP 的文件传输工具（例如 OpenMTP）；先确保设备能显示 Garmin 文件夹。
3. 把导出的 `.prg` 复制到手表的 `GARMIN/APPS` 目录（如果目录名是 `Garmin/Apps` 则以真实路径为准）。
4. 安全弹出手表并断开连接，等待安装/索引完成。
5. 在手表表盘页长按左中 UP/MENU →「表盘/Watch Face」→ 寻找 `Campfire Under Stars` → START →「应用/Apply」。

注意：部分 Garmin 设备会在安装后把 `.prg` 移进不可见的受保护存储空间；再次打开 `GARMIN/APPS` 找不到刚复制的文件，不一定是安装失败。

## 第 5 步：怎么判断动态有效？

本版**不使用高频定时器**。设备在抬腕进入高功耗模式时，会每秒调度 `onUpdate()`；代码根据当前秒数切换 4 种火焰轮廓及火星，每秒一帧。低功耗状态会保持静态火焰，每分钟更新一次时间。

> 动画是否顺畅要以真实手表为准，模拟器的流畅程度不代表实机。MIP 屏颜色/对比度与电脑屏幕也不同。

## 视觉改动入口

- 字体/时间位置：`source/CampfireFace.mc` → `drawTime()`
- 星星数量、位置：`drawStars()` 的 `stars` 数组
- 火焰颜色：`drawFire()` 里的 `setColor(0x......, ...)`
- 火焰形状：`drawFire()` 里的 `fillPolygon(...)`
- 火焰帧姿态：`drawFire()` 里的 `tips` 和 `sway`
- 是否闪烁/飘火星：`drawFire()` 里 `second % 4/7` 的条件

## 当前限制

- 此压缩包是**源代码项目，不是已编译 `.prg`**。需在你的电脑上使用 Garmin 官方 SDK 编译和签名。
- 尚未在连接的 Garmin 实机上测试；不同版本 SDK 可能发出编译警告或需要微调。
- 手表需要是 fēnix **7 Pro（260 × 260）**。7S Pro / 7X Pro 分辨率不同，暂未适配。
- 这是一款受《Outer Wilds》氛围启发的非官方原创样式，不含游戏素材。

官方开发教程：https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/
官方表盘刷新文档：https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/WatchFace.html
