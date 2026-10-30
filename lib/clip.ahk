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

SetClipboardFileDrop(filePath) {
    if !FileExist(filePath)
        return false

    pathBytes := (StrLen(filePath) + 2) * 2
    totalSize := 20 + pathBytes

    hMem := DllCall("GlobalAlloc", "uint", 0x0042, "uptr", totalSize, "ptr")
    if !hMem
        return false

    pMem := DllCall("GlobalLock", "ptr", hMem, "ptr")
    if !pMem {
        DllCall("GlobalFree", "ptr", hMem)
        return false
    }

    NumPut("uint", 20, pMem, 0)
    NumPut("int", 0, pMem, 4)
    NumPut("int", 0, pMem, 8)
    NumPut("int", 0, pMem, 12)
    NumPut("int", 1, pMem, 16)

    StrPut(filePath, pMem + 20, StrLen(filePath) + 1, "UTF-16")
    NumPut("ushort", 0, pMem + 20 + (StrLen(filePath) * 2))

    DllCall("GlobalUnlock", "ptr", hMem)

    opened := false
    Loop 5 {
        if DllCall("OpenClipboard", "ptr", A_ScriptHwnd) {
            opened := true
            break
        }
        Sleep(30)
    }
    if !opened {
        DllCall("GlobalFree", "ptr", hMem)
        return false
    }

    DllCall("EmptyClipboard")
    DllCall("SetClipboardData", "uint", 15, "ptr", hMem)
    DllCall("CloseClipboard")
    return true
}

GetOrSaveTempClipboardImage() {
    global lastClipSeq, lastClipImagePath
    seq := DllCall("GetClipboardSequenceNumber", "uint")
    if (seq != 0 && seq = lastClipSeq && lastClipImagePath != "" && FileExist(lastClipImagePath))
        return lastClipImagePath

    tempPath := A_Temp "\snip-" FormatTime(, "MMdd-HHmmss") ".png"
    if SaveClipboardImageToFile(tempPath) {
        lastClipSeq := seq
        lastClipImagePath := tempPath
        return tempPath
    }
    return ""
}

CleanupTempFiles() {
    cutoff := DateAdd(A_Now, -24, "Hours")
    Loop Files, A_Temp "\snip-*.png" {
        if (DateDiff(A_LoopFileTimeModified, cutoff, "Seconds") < 0)
            try FileDelete(A_LoopFileFullPath)
    }
    Loop Files, A_Temp "\text-*.txt" {
        if (DateDiff(A_LoopFileTimeModified, cutoff, "Seconds") < 0)
            try FileDelete(A_LoopFileFullPath)
    }
}

OnClipChange(dataType) {
    if (dataType = 2)
        SetTimer(() => HasClipboardImageOnly() ? GetOrSaveTempClipboardImage() : 0, -200)
}
