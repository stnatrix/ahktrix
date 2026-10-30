global ARCHIVE_EXT := "zip|rar|7z|tar|gz|tgz|bz2|tbz|tbz2|xz|txz|zst|tzst|iso|cab|arj|lzh|lha|wim|001|z01|r00"

IsExtractable(path) {
    global ARCHIVE_EXT
    if !FileExist(path) || DirExist(path)
        return false
    SplitPath(path, , , &ext, &stem)
    if !RegExMatch(ext, "i)^(" ARCHIVE_EXT ")$")
        return false
    if RegExMatch(stem, "i)\.part0*(\d+)$", &m) && (m[1] + 0) != 1
        return false
    if RegExMatch(ext, "i)^([zr])0*(\d+)$", &m) && (m[2] + 0) != 0 && (m[2] + 0) != 1
        return false
    if RegExMatch(ext, "i)^0*(\d+)$", &m) && (m[1] + 0) != 1
        return false
    return true
}

Find7ZipGui() {
    global CFG_7ZIP
    if (CFG_7ZIP != "" && FileExist(CFG_7ZIP))
        return CFG_7ZIP

    for pf in [EnvGet("ProgramFiles"), EnvGet("ProgramFiles(x86)"), EnvGet("LocalAppData") "\Programs"] {
        if (pf != "") {
            gui := pf "\7-Zip\7zG.exe"
            if FileExist(gui)
                return gui
        }
    }
    for root in ["HKLM", "HKCU"] {
        try {
            regPath := RegRead(root "\SOFTWARE\7-Zip", "Path")
            if (regPath != "" && FileExist(RTrim(regPath, "\") "\7zG.exe"))
                return RTrim(regPath, "\") "\7zG.exe"
        }
    }
    return ""
}
