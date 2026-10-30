global PNG_CLIP_FMT := DllCall("RegisterClipboardFormat", "str", "PNG", "uint")
global lastClipSeq := 0
global lastClipImagePath := ""

HasClipboardImage() {
    global PNG_CLIP_FMT
    hasPng := PNG_CLIP_FMT && DllCall("IsClipboardFormatAvailable", "uint", PNG_CLIP_FMT)
    hasBmp := DllCall("IsClipboardFormatAvailable", "uint", 2)
    return (hasPng || hasBmp)
}

HasClipboardImageOnly() {
    if DllCall("IsClipboardFormatAvailable", "uint", 13)
        return false
    if DllCall("IsClipboardFormatAvailable", "uint", 15)
        return false
    return HasClipboardImage()
}

SaveClipboardImageToFile(outPath) {
    global PNG_CLIP_FMT
    hasPng := PNG_CLIP_FMT && DllCall("IsClipboardFormatAvailable", "uint", PNG_CLIP_FMT)
    hasBmp := DllCall("IsClipboardFormatAvailable", "uint", 2)
    if (!hasPng && !hasBmp)
        return false

    opened := false
    Loop 5 {
        if DllCall("OpenClipboard", "ptr", A_ScriptHwnd) {
            opened := true
            break
        }
        Sleep(30)
    }
    if !opened
        return false

    saved := false
    if hasPng {
        hData := DllCall("GetClipboardData", "uint", PNG_CLIP_FMT, "ptr")
        if hData {
            pData := DllCall("GlobalLock", "ptr", hData, "ptr")
            sz := DllCall("GlobalSize", "ptr", hData, "uptr")
            if (pData && sz > 0) {
                try {
                    f := FileOpen(outPath, "w")
                    f.RawWrite(pData, sz)
                    f.Close()
                    saved := FileExist(outPath)
                }
            }
            if pData
                DllCall("GlobalUnlock", "ptr", hData)
        }
    }

    if (!saved && hasBmp) {
        hBm := DllCall("GetClipboardData", "uint", 2, "ptr")
        if hBm {
            DllCall("LoadLibrary", "str", "gdiplus", "ptr")
            tok := 0
            gsi := Buffer(24, 0)
            NumPut("uint", 1, gsi, 0)
            if (DllCall("gdiplus\GdiplusStartup", "ptr*", &tok, "ptr", gsi, "ptr", 0) = 0) {
                pBmp := 0
                if (DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "ptr", hBm, "ptr", 0, "ptr*", &pBmp) = 0 && pBmp) {
                    clsid := Buffer(16, 0)
                    DllCall("ole32\CLSIDFromString", "wstr", "{557CF406-1A04-11D3-9A73-0000F81EF32E}", "ptr", clsid)
                    DllCall("gdiplus\GdipSaveImageToFile", "ptr", pBmp, "wstr", outPath, "ptr", clsid, "ptr", 0)
                    DllCall("gdiplus\GdipDisposeImage", "ptr", pBmp)
                    saved := FileExist(outPath)
                }
                DllCall("gdiplus\GdiplusShutdown", "ptr", tok)
            }
        }
    }

    DllCall("CloseClipboard")
    return saved
}

SaveClipboardTextToFile(outPath) {
    txt := A_Clipboard
    if (txt == "")
        return false
    try {
        f := FileOpen(outPath, "w", "UTF-8")
        f.Write(txt)
        f.Close()
        return FileExist(outPath)
    }
    return false
}
