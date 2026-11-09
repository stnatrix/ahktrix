---
name: ahktrix
description: >-
  Project passport, architecture reference, and development procedures for ahktrix (AutoHotkey v2 QoL utility suite & CapsLock modifier layer).
  Activate whenever modifying, debugging, adding hotkeys, testing, or committing code in the ahktrix / natrix.ahk project.
---

# Project Passport: ahktrix

## Overview
- **Name**: ahktrix (cosmetic identifier used in code, tray menu, tooltip; successor to natrixQoL).
- **Core Path**: `C:\Users\stnatrix\Documents\ahktrix`
- **Dev Sandbox**: `C:\Users\stnatrix\Documents\antigravity\natrix.ahk`
- **Stack**: AutoHotkey v2 (`#Requires AutoHotkey v2.0`), PowerShell 5.1 (dark conhost), 7-Zip, RTSS.
- **Repository**: `stnatrix/ahktrix` (GitHub, branch `main`, HTTPS + Git Credential Manager with `natrix852@gmail.com` / `natrix853@proton.me`, proxy `socks5://127.0.0.1:10808`).
- **Current Version**: `1.0.0-alpha.21` (alpha iteration scheme `1.0.0-alpha.X`).

## Mandatory Invariants
1. **Zero Comments in Code**: Comments (`//`, `;`, `/* */`) are strictly forbidden across all `.ahk` codebase files.
2. **Strictly Relative Paths**: All imports and configs must use `A_ScriptDir` relative paths (`#Include "lib\notify.ahk"`, `A_ScriptDir "\config.ini"`).
3. **Admin Auto-Elevation**: Script must restart as elevated if launched without admin privileges (`Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"', A_ScriptDir)`).
4. **Git Commit Farming**:
   - Atomic commits for every sub-feature.
   - Commit message style: lowercase, plain everyday English, simple and concise.
   - Large features in separate branches (`feature/...`), merged into `main` without `git worktree`.

## Architecture & Responsibilities
- `main.ahk`: Entrypoint, auto-elevation, tray setup, config loader, temp cleanup, `#Include "layer.ahk"` positioned last.
- `config.ini`: User settings (`[General]` `email`, `password_length`; `[Paths]` `seven_zip`, `rtss`).
- `layer.ahk`: CapsLock state machine modifier (tap toggles on release, hold + chord suppresses toggle) and key bindings.
- `lib/notify.ahk`: Dark OSD HUD window with DWM rounded corners.
- `lib/clip.ahk`: Clipboard PNG detection, GDI+ saving, virtual `CF_HDROP` builder, and temp cleaner (>24h).
- `lib/explorer.ahk`: Active tab folder resolver (with Win11 tab support and `DirExist` check) and selection extractor.
- `features/secrets.ahk`: Auto-type email and CSPRNG 16-char password generation via `advapi32\SystemFunction036` (`RtlGenRandom`).
- `features/extract.ahk`: Quick 7-Zip extraction into `<dir>\<stem>` subfolder via `7zG.exe x -aou -o"..."` filtered by `ARCHIVE_EXT`.
- `features/terminal.ahk`: Elevated dark PowerShell launcher (`A_WinDir "\System32\WindowsPowerShell\v1.0\powershell.exe"`).
- `features/rtss.ahk`: RTSS window restore and dummy message trigger (`0x8001`).
- `features/paste_file.ahk`: `Ctrl+Shift+V` direct save / `CF_HDROP` staging (`if (IsClipboardFormatAvailable(15) && !HasClipboardImage()) return`) and `#32770` dialog path injection.

## Hotkey Cheatsheet
| Hotkey | Target Action |
| :--- | :--- |
| `Ctrl+Shift+V` | Paste clipboard image/text directly to file (Explorer) or stage `CF_HDROP` (other apps) |
| `Ctrl+V` (Dialogs `#32770`) | Paste screenshot temp path directly into file picker |
| `Caps + 1` | Auto-type email (`SendText`) |
| `Caps + 2` | Generate CSPRNG password, copy to clipboard, display OSD |
| `Caps + MButton` | Extract selected archive to subfolder named after archive |
| `Caps + 3` | Open elevated dark PowerShell in current directory |
| `Caps + 4` | Restore / activate RTSS |
| `CapsLock` (tap) | Normal CapsLock toggle on key release |

## Validation & Verification Checklist
1. **Comment Scan**: `Get-ChildItem -Recurse *.ahk | Select-String -Pattern '^\s*;|\s+;'` (must return zero lines).
2. **AHK v2 Validation**: `& "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /validate main.ahk` (must exit code 0).
3. **Sync Check**: Files in `C:\Users\stnatrix\Documents\ahktrix` must match dev working copy.
