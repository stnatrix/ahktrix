ShowRTSS() {
    DetectHiddenWindows(true)
    dummyHwnd := WinExist("RTSS ahk_exe RTSS.exe")
    if dummyHwnd {
        WinHide(dummyHwnd)
    }

    DetectHiddenWindows(false)
    guiHwnd := WinExist("RivaTunerStatisticsServer ahk_exe RTSS.exe")
    if guiHwnd {
        WinRestore(guiHwnd)
        WinActivate(guiHwnd)
        return
    }

    if dummyHwnd {
        PostMessage(0x8001, 0, 0x0202, , dummyHwnd)
        if WinWait("RivaTunerStatisticsServer ahk_exe RTSS.exe", , 1) {
            WinRestore("RivaTunerStatisticsServer ahk_exe RTSS.exe")
            WinActivate("RivaTunerStatisticsServer ahk_exe RTSS.exe")
            return
        }
    }

    rtssPath := FindRTSS()
    if (rtssPath != "") {
        Run('"' rtssPath '"')
    }
}

FindRTSS() {
    global CFG_RTSS
    if (CFG_RTSS != "" && FileExist(CFG_RTSS))
        return CFG_RTSS

    for root in ["HKLM", "HKCU"] {
        for subKey in ["SOFTWARE\WOW6432Node\Unwinder\RTSS", "SOFTWARE\Unwinder\RTSS"] {
            try {
                p := RegRead(root "\" subKey, "InstallPath")
                if (p != "" && FileExist(p))
                    return p
            }
        }
    }
    defPath := EnvGet("ProgramFiles(x86)") "\RivaTuner Statistics Server\RTSS.exe"
    if FileExist(defPath)
        return defPath
    return ""
}
