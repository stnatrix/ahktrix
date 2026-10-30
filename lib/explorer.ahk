GetExplorerPath() {
    hwnd := WinExist("A")
    if !hwnd
        return ""
    cls := WinGetClass(hwnd)
    if (cls = "Progman" || cls = "WorkerW")
        return DirExist(A_Desktop) ? A_Desktop : ""

    if (cls != "CabinetWClass" && cls != "ExploreWClass")
        return ""

    shell := ComObject("Shell.Application")
    activeTab := 0
    try activeTab := ControlGetHwnd("ShellTabWindowClass1", hwnd)

    for win in shell.Windows {
        try {
            if (win.hwnd != hwnd)
                continue
            if (activeTab) {
                static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"
                shellBrowser := ComObjQuery(win, IID_IShellBrowser, IID_IShellBrowser)
                if shellBrowser {
                    ComCall(3, shellBrowser, "uint*", &thisTab := 0)
                    if (thisTab != activeTab)
                        continue
                }
            }
            folderUrl := win.Document.Folder.Self.Path
            if (folderUrl != "" && DirExist(folderUrl))
                return folderUrl
        }
    }
    return ""
}

GetExplorerSelection() {
    paths := []
    hwnd := WinExist("A")
    if !hwnd
        return paths
    cls := WinGetClass(hwnd)
    shell := ComObject("Shell.Application")

    if (cls = "Progman" || cls = "WorkerW") {
        try {
            doc := shell.Windows.Item(ComValue(0x13, 8)).Document
            for item in doc.SelectedItems {
                p := item.Path
                if (p != "")
                    paths.Push(p)
            }
        }
        return paths
    }

    if (cls != "CabinetWClass" && cls != "ExploreWClass")
        return paths

    activeTab := 0
    try activeTab := ControlGetHwnd("ShellTabWindowClass1", hwnd)

    for win in shell.Windows {
        try {
            if (win.hwnd != hwnd)
                continue
            if (activeTab) {
                static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"
                shellBrowser := ComObjQuery(win, IID_IShellBrowser, IID_IShellBrowser)
                if shellBrowser {
                    ComCall(3, shellBrowser, "uint*", &thisTab := 0)
                    if (thisTab != activeTab)
                        continue
                }
            }
            for item in win.Document.SelectedItems {
                p := item.Path
                if (p != "")
                    paths.Push(p)
            }
            if (activeTab)
                break
        }
    }
    return paths
}
