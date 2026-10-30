#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook true
Persistent(true)

global APP_NAME := "ahktrix"
global APP_VERSION := "1.0.0-alpha.20"

SetWorkingDir(A_ScriptDir)

if (!A_IsAdmin && !InStr(DllCall("GetCommandLine", "Str"), "/restart")) {
    try {
        Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"', A_ScriptDir)
        ExitApp()
    }
}

InstallKeybdHook(true, true)
InstallMouseHook(true, true)

#Include "lib\notify.ahk"
#Include "lib\clip.ahk"
#Include "lib\explorer.ahk"
#Include "features\secrets.ahk"
#Include "features\extract.ahk"
#Include "features\terminal.ahk"
#Include "features\rtss.ahk"
#Include "features\paste_file.ahk"

InitConfig()
SetupTrayMenu()
CleanupTempFiles()
OnClipboardChange(OnClipChange)

#Include "layer.ahk"

InitConfig() {
    global CFG_EMAIL, CFG_PWD_LEN, CFG_7ZIP, CFG_RTSS
    iniPath := A_ScriptDir "\config.ini"
    if !FileExist(iniPath) {
        IniWrite("natrix852@gmail.com", iniPath, "General", "email")
        IniWrite("16", iniPath, "General", "password_length")
        IniWrite("", iniPath, "Paths", "seven_zip")
        IniWrite("", iniPath, "Paths", "rtss")
    }
    CFG_EMAIL := IniRead(iniPath, "General", "email", "natrix852@gmail.com")
    CFG_PWD_LEN := Integer(IniRead(iniPath, "General", "password_length", "16"))
    CFG_7ZIP := IniRead(iniPath, "Paths", "seven_zip", "")
    CFG_RTSS := IniRead(iniPath, "Paths", "rtss", "")
}

SetupTrayMenu() {
    tray := A_TrayMenu
    tray.Delete()
    tray.Add(APP_NAME " " APP_VERSION, (*) => "")
    tray.Disable(APP_NAME " " APP_VERSION)
    tray.Add()
    helpMenu := Menu()
    helpMenu.Add("Ctrl+Shift+V  - Paste as File / Stage File", (*) => "")
    helpMenu.Add("Ctrl+V (Dlg)   - Paste Screenshot Path", (*) => "")
    helpMenu.Add("Caps + 1       - Type Email", (*) => "")
    helpMenu.Add("Caps + 2       - Generate & Copy Password", (*) => "")
    helpMenu.Add("Caps + MButton - Quick Extract to Folder", (*) => "")
    helpMenu.Add("Caps + 3       - Admin PowerShell Here", (*) => "")
    helpMenu.Add("Caps + 4       - Show RTSS", (*) => "")
    for idx in [1, 2, 3, 4, 5, 6, 7]
        helpMenu.Disable(idx "&")
    tray.Add("Hotkeys Cheatsheet", helpMenu)
    tray.Add()
    tray.Add("Reload", (*) => Reload())
    tray.Add("Exit", (*) => ExitApp())
    A_IconTip := APP_NAME " " APP_VERSION
}
