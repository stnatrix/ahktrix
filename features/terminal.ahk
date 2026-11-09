OpenAdminPowerShell() {
    targetDir := GetExplorerPath()
    if (targetDir == "" || !DirExist(targetDir))
        targetDir := EnvGet("USERPROFILE")

    psPath := A_WinDir "\System32\WindowsPowerShell\v1.0\powershell.exe"
    targetPID := 0
    try {
        Run('"' psPath '"', targetDir, , &targetPID)
    } catch {
        Run('*RunAs "' psPath '"', targetDir, , &targetPID)
    }
    if (targetPID && (hwnd := WinWait("ahk_pid " targetPID, , 2))) {
        WinActivate(hwnd)
        WinWaitActive(hwnd, , 2)
    }
}
