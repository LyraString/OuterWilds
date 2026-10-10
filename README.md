# Outer Wilds

An original pixel campfire watch face inspired by *Outer Wilds*, for the **Garmin fēnix 7 Pro (47 mm)**.

![Watch face preview](preview.png)

[Animated preview](preview-animated.gif) · [Sleeping display](preview-sleep.png) · [中文说明](README-中文.md)

- A breathing star field, blue planet, pine forest, and six-frame campfire animation.
- Centered 12/24-hour time, date, altitude, temperature, and weather.
- Steps and heart rate on one row, with battery charge below.
- Static artwork during sleep; designed for the 260 × 260, 64-color MIP display.

Copy [OuterWilds-fenix7pro.prg](dist/OuterWilds-fenix7pro.prg) to the watch's `GARMIN/APPS` folder via USB, disconnect, then select **Outer Wilds** in the watch face menu.

To build on Windows, install the Connect IQ SDK, fēnix 7 Pro device package, and a developer key:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build.ps1
```

The script discovers the SDK and VS Code key configuration. Use `-DebugBuild` for a simulator build or `-Test` for unit tests. See the [Chinese guide](README-中文.md) for setup, preview, updates, and data behavior. Build intermediates stay in the ignored `bin/` directory; `dist/` contains the install package.

The Rajdhani Medium and SemiBold fonts by Indian Type Foundry are included under the [SIL Open Font License 1.1](tools/assets/rajdhani/OFL.txt). Font resources are included, so normal builds do not require Python.

This is an unofficial project with original code-drawn artwork and no game assets. Only the listed device is supported; battery life has not been measured. Changes stay local until the user requests publication. Release history is in [CHANGELOG.md](CHANGELOG.md) and Git tags.
