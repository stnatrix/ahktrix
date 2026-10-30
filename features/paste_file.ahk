HandlePasteAsFile() {
    if (DllCall("IsClipboardFormatAvailable", "uint", 15) && !HasClipboardImage())
        return

    stamp := FormatTime(, "MMdd-HHmmss")
    explorerDir := GetExplorerPath()

    isImg := HasClipboardImage()
    isTxt := (A_Clipboard != "")

    if (!isImg && !isTxt) {
        NotifyQoL("Clipboard Empty", "Nothing to paste as file.")
        return
    }

    ext := isImg ? "png" : "txt"
    prefix := isImg ? "snip" : "text"
    fileName := prefix "-" stamp "." ext

    if (explorerDir != "") {
        filePath := explorerDir "\" fileName
        saved := isImg ? SaveClipboardImageToFile(filePath) : SaveClipboardTextToFile(filePath)
        if saved
            NotifyQoL("File Created", fileName)
        else
            NotifyQoL("Save Failed", fileName)
        return
    }

    tempPath := A_Temp "\" fileName
    saved := isImg ? SaveClipboardImageToFile(tempPath) : SaveClipboardTextToFile(tempPath)
    if (saved && SetClipboardFileDrop(tempPath)) {
        NotifyQoL("File Ready to Paste", fileName)
    } else {
        NotifyQoL("Save Failed", fileName)
    }
}

ShouldPasteImagePath() {
    if !HasClipboardImageOnly()
        return false
    if !WinActive("ahk_class #32770")
        return false
    try {
        ctrl := ControlGetFocus("A")
        if ctrl {
            cls := ControlGetClassNN(ctrl)
            if RegExMatch(cls, "^Edit\d+$")
                return true
        }
        if ControlGetHwnd("Edit1", "A")
            return true
    }
    return false
}

PasteClipboardImagePath() {
    path := GetOrSaveTempClipboardImage()
    if (path = "") {
        SendInput("^v")
        return
    }

    try {
        ctrl := ControlGetFocus("A")
        if ctrl {
            cls := ControlGetClassNN(ctrl)
            if RegExMatch(cls, "^Edit\d+$") {
                EditPaste(path, cls, "A")
                return
            }
        }
    }

    if WinActive("ahk_class #32770") {
        try {
            ControlFocus("Edit1", "A")
            ControlSetText("", "Edit1", "A")
            EditPaste(path, "Edit1", "A")
            return
        }
    }

    SendText(path)
}
