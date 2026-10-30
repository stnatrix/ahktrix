OpenAdminPowerShell() {
    targetDir := GetExplorerPath()
    if (targetDir == "" || !DirExist(targetDir))
        targetDir := EnvGet("USERPROFILE")

    psPath := A_WinDir "\System32\WindowsPowerShell\v1.0\powershell.exe"
    try {
        Run('"' psPath '"', targetDir)
    } catch {
        Run('*RunAs "' psPath '"', targetDir)
    }
}
