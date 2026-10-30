global ARCHIVE_EXT := "zip|rar|7z|tar|gz|tgz|bz2|tbz|tbz2|xz|txz|zst|tzst|iso|cab|arj|lzh|lha|wim|001|z01|r00"

ExtractSelectedArchive() {
    selection := GetExplorerSelection()
    if (selection.Length = 0) {
        NotifyQoL("Nothing Selected", "Select an archive first.")
        return
    }

    archives := []
    for path in selection {
        if IsExtractable(path)
            archives.Push(path)
    }

    if (archives.Length = 0) {
        NotifyQoL("No Archive Selected", "Selected files are not recognized archives.")
        return
    }

    sevenPath := Find7ZipGui()
    if (sevenPath == "") {
        NotifyQoL("7-Zip Not Found", "Install 7-Zip or configure path in config.ini")
        return
    }

    for path in archives {
        SplitPath(path, &fileName, &dir, &ext, &nameNoExt)
        if (dir == "")
            dir := A_Desktop

        stem := RegExReplace(nameNoExt, "i)\.tar$", "")
        targetFolder := dir "\" stem

        cmd := '"' sevenPath '" x -aou -o"' targetFolder '" -- "' path '"'
        NotifyQoL("Extracting Archive", stem)
        Run(cmd, dir)
    }
}

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
