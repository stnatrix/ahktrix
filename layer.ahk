global capsUsed := false

*CapsLock::
{
    global capsUsed
    capsUsed := false
    KeyWait("CapsLock")
    if (!capsUsed && A_PriorKey == "CapsLock") {
        SetCapsLockState(!GetKeyState("CapsLock", "T"))
    }
}

#HotIf GetKeyState("CapsLock", "P")
*1::
{
    global capsUsed := true
    TypeEmail()
}

*2::
{
    global capsUsed := true
    GenerateAndCopyPassword()
}

*3::
{
    global capsUsed := true
    OpenAdminPowerShell()
}

*4::
{
    global capsUsed := true
    ShowRTSS()
}

*MButton::
{
    global capsUsed := true
    ExtractSelectedArchive()
}
#HotIf

^+v::HandlePasteAsFile()

#HotIf ShouldPasteImagePath()
$^v::PasteClipboardImagePath()
#HotIf
