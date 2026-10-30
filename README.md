# ahktrix

Modular AutoHotkey v2 QoL utilities and CapsLock modifier layer for Windows.

## Hotkeys

| Hotkey | Description |
| :--- | :--- |
| `Ctrl+Shift+V` | Paste clipboard text/image directly as file in Explorer, or stage `CF_HDROP` virtual file in other apps |
| `Ctrl+V` (File Dialogs) | Paste screenshot temp path into standard file pickers |
| `Caps + 1` | Auto-type email from `config.ini` |
| `Caps + 2` | Generate cryptographically strong password (CSPRNG via `RtlGenRandom`) and copy to clipboard |
| `Caps + MButton` | Quick archive extract into folder matching archive name via `7zG.exe` |
| `Caps + 3` | Open elevated dark PowerShell in active directory |
| `Caps + 4` | Restore / activate RivaTuner Statistics Server (RTSS) |
| `CapsLock` (tap) | Standard toggle on release without chord trigger |

## Architecture

- `main.ahk`: Application entrypoint, auto-elevation (`*RunAs`), tray menu cheatsheet
- `config.ini`: User configuration
- `layer.ahk`: Custom CapsLock modifier chord state machine
- `lib/clip.ahk`: Clipboard image detection, GDI+ encoder, virtual `CF_HDROP` generator
- `lib/explorer.ahk`: Active tab folder detection and file selection reader
- `lib/notify.ahk`: Modern dark OSD HUD
- `features/extract.ahk`: 7-Zip subfolder extractor
- `features/paste_file.ahk`: File creation and dialog path injector
- `features/rtss.ahk`: RTSS window activator
- `features/secrets.ahk`: Email auto-type and CSPRNG generator
- `features/terminal.ahk`: Administrator PowerShell launcher
