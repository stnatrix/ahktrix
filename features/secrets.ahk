TypeEmail() {
    global CFG_EMAIL
    if (CFG_EMAIL != "")
        SendText(CFG_EMAIL)
}

GenerateAndCopyPassword() {
    global CFG_PWD_LEN
    len := (CFG_PWD_LEN > 0) ? CFG_PWD_LEN : 16
    pwd := CryptoGeneratePassword(len)
    A_Clipboard := pwd
    NotifyQoL("Password Generated", "Copied " len " chars to clipboard")
}

CryptoGeneratePassword(length := 16) {
    lower := "abcdefghijklmnopqrstuvwxyz"
    upper := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    digits := "0123456789"
    symbols := "!@#$%^&*()_+-=[]{}|;:,.<>?"
    allChars := lower . upper . digits . symbols

    pwd := CryptoPickChar(lower)
         . CryptoPickChar(upper)
         . CryptoPickChar(digits)
         . CryptoPickChar(symbols)

    Loop (length - 4) {
        pwd .= CryptoPickChar(allChars)
    }

    arr := StrSplit(pwd)
    n := arr.Length
    Loop n {
        i := n - A_Index + 1
        j := CryptoRandomInt(1, i)
        tmp := arr[i]
        arr[i] := arr[j]
        arr[j] := tmp
    }

    shuffled := ""
    for char in arr
        shuffled .= char
    return shuffled
}

CryptoRandomInt(minVal, maxVal) {
    if (minVal >= maxVal)
        return minVal
    range := maxVal - minVal + 1
    buf := Buffer(4, 0)
    limit := 0xFFFFFFFF - Mod(0xFFFFFFFF, range)
    loop {
        DllCall("advapi32\SystemFunction036", "ptr", buf, "uint", 4)
        val := NumGet(buf, 0, "uint")
        if (val < limit)
            return minVal + Mod(val, range)
    }
}

CryptoPickChar(charset) {
    idx := CryptoRandomInt(1, StrLen(charset))
    return SubStr(charset, idx, 1)
}
