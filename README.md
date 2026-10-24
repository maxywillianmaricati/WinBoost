# WinBoost 2.0

Windows 10/11 performance toolkit in a single `.bat` file. Bilingual: **English / Português (Brasil)**.
Toolkit de desempenho para Windows 10/11 em um único `.bat`.

## Features / Recursos

| Page / Página | What it does / O que faz |
|---|---|
| Input Lag | Mouse acceleration off, pointer speed, faster keyboard, no Sticky Keys popup, USB never sleeps |
| FPS & Gaming / FPS e Jogos | Game Mode, Game DVR off, MMCSS priority, timer resolution, HAGS, Nagle, network throttling |
| Energy / Energia | Max performance power plan, CPU min 100%, unparked cores, turbo, EPP, PCIe, Fast Startup |
| Memory / Memória | RAM compression (by RAM size), kernel in RAM, SysMain (SSD only), NDU leak fix, free standby RAM |
| Cleaning / Limpeza | Temp files, WU cache, shader caches, browser caches, dumps, DNS, TRIM, recycle bin, font cache, event logs, thumbnail cache, deep `cleanmgr` |
| Privacy / Privacidade 🆕 | Telemetry, Cortana, location, advertising ID, activity history, feedback, cloud voice, ink/typing personalization, Delivery Optimization |
| System / Sistema 🆕 | File extensions, long paths, instant menus, no startup delay, no balloons, no low-disk warnings, reserved storage, best-performance visuals, faster service shutdown |
| Advanced / Avançado 🆕 ⚠️ | bcdedit (Hyper-V off, dynamic tick off, legacy boot, quiet boot, timeout 3s), Spectre/Meltdown off, USB storage block, MSI mode GPU, 8.3 filenames, last-access off |
| Debloat 🆕 | Removes ~30 bundled Appx apps, disables telemetry scheduled tasks, disables Chrome/Edge/Firefox telemetry agents, removes `Windows.old` |
| Repair / Reparo 🆕 | Winsock reset, TCP/IP reset, TCP tuning, force SSD TRIM, `sfc /scannow`, `DISM /RestoreHealth`, `DISM /ResetBase` |
| Backup & Revert / Reverter | Undo everything, restore point, System Restore, backup and log folders |

- **Apply ALL recommended / Aplicar TODAS**: one key at the main menu (or `A` inside a page). Skips advanced `!` items.
- **Undo / Desfazer**: `U` undoes a whole page, `U 2` undoes item 2, `U` at the main menu undoes everything.
- Items marked `!` are advanced and ask for confirmation. They never enter "Apply ALL".
- Debloat, Cleaning and Repair pages are **one-time actions** (no undo) — they tell you so before running.
- Hardware aware: only offers what makes sense for your RAM, disk type, laptop/desktop and Windows build.
- Bilingual UI **EN / PT-BR**, saved to `%ProgramData%\WinBoost\lang.txt` after first pick.

## How the backup works / Como funciona o backup

Before changing any value, WinBoost reads the original and saves it to
`%ProgramData%\WinBoost\manifest.json`. Undo puts the original back (or removes the value if it did not exist).
A Windows restore point is also attempted before the first change. Logs: `%ProgramData%\WinBoost\logs`.

Registry, power settings, services and memory-compression state are all tracked. Command-line actions (`DISM`, `SFC`, `bcdedit`, `netsh`, Appx removal) are **not** reversible through the manifest — restore point and manual reinstall are the fallbacks.

## Usage / Uso

1. Download `WinBoost.bat`.
2. Double-click it (it asks for administrator rights automatically).
3. Pick your language and a page.

Requires Windows 10 1809+ or Windows 11 and PowerShell 5.1 (included).

## Roadmap

GPU driver tweaks, startup manager, per-app network rules, HDR/display page.

## License

MIT, see [LICENSE](LICENSE). Provided as is, use at your own risk.