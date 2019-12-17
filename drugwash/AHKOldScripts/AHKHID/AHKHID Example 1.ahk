/* TheGood
    AHKHID - An AHK implementation of the HID functions.
    AHKHID Example 1
    
    List all the HID devices connected to the computer.
    This example shows how to use all the HID_GetDev functions (like HID_GetDevInfo()).
    _________________________________________________
    1. Simply run the script.
    2. Press Ctrl+c on a selected item to copy its name.
*/

;You have to put the #Include line in the auto-execute section if you want to use the constants
#Include %A_ScriptDir%\AHKHID.ahk

;Create GUI
Gui +Resize -MaximizeBox -MinimizeBox
Gui, Add, Tab2, x6 y10 w460 h190 vMyTabs, Keyboards|Mice|Other
Gui, Tab, 1
Gui, Add, ListView, x16 y40 w440 h150 vlvwKeyb gLV_Event AltSubmit, Name|Type|SubType|Keyboard Mode|Number of Function Keys|Number of Indicators|Number of Keys Total
Gui, Tab, 2
Gui, Add, ListView, x16 y40 w440 h150 vlvwMouse gLV_Event AltSubmit, Name|Mouse ID|Number of Buttons|Sample Rate
If (A_OSVersion = "WIN_VISTA") ;Only supported in Windows Vista and higher
    LV_InsertCol(5, "", "Has Horizontal Wheel")
Gui, Tab, 3
Gui, Add, ListView, x16 y40 w440 h150 vlvwOther gLV_Event, Name|Vendor ID|Product ID|Version Number|Usage Page|Usage

;Get count
iCount := HID_GetDevCount()

;Retrieve info for each device
Loop %iCount% {
    
    HID0 += 1
    
    ;Get device handle, type and name
    HID%HID0%_Handle := HID_GetDevHandle(HID0)
    HID%HID0%_Type   := HID_GetDevType(HID0)
    HID%HID0%_Name   := HID_GetDevName(HID0)
    
    ;Get device info
    If (HID%HID0%_Type = RIM_TYPEMOUSE) {
        HID%HID0%_ID            := HID_GetDevInfo(HID0, DI_MSE_ID)
        HID%HID0%_Buttons       := HID_GetDevInfo(HID0, DI_MSE_NUMBEROFBUTTONS)
        HID%HID0%_SampleRate    := HID_GetDevInfo(HID0, DI_MSE_SAMPLERATE)
        If (A_OSVersion = "WIN_VISTA") ;Only supported in Windows Vista and higher
            HID%HID0%_HWheel    := HID_GetDevInfo(HID0, DI_MSE_HASHORIZONTALWHEEL)
    } Else If (HID%HID0%_Type = RIM_TYPEKEYBOARD) {
        HID%HID0%_KBType        := HID_GetDevInfo(HID0, DI_KBD_TYPE)
        HID%HID0%_KBSubType     := HID_GetDevInfo(HID0, DI_KBD_SUBTYPE)
        HID%HID0%_KeyboardMode  := HID_GetDevInfo(HID0, DI_KBD_KEYBOARDMODE)
        HID%HID0%_FunctionKeys  := HID_GetDevInfo(HID0, DI_KBD_NUMBEROFFUNCTIONKEYS)
        HID%HID0%_Indicators    := HID_GetDevInfo(HID0, DI_KBD_NUMBEROFINDICATORS)
        HID%HID0%_KeysTotal     := HID_GetDevInfo(HID0, DI_KBD_NUMBEROFKEYSTOTAL)
    } Else If (HID%HID0%_Type = RIM_TYPEHID) {
        HID%HID0%_VendorID      := HID_GetDevInfo(HID0, DI_HID_VENDORID)
        HID%HID0%_ProductID     := HID_GetDevInfo(HID0, DI_HID_PRODUCTID)
        HID%HID0%_VersionNumber := HID_GetDevInfo(HID0, DI_HID_VERSIONNUMBER)
        HID%HID0%_UsagePage     := HID_GetDevInfo(HID0, DI_HID_USAGEPAGE)
        HID%HID0%_Usage         := HID_GetDevInfo(HID0, DI_HID_USAGE)
    }
}

;Add to listviews according to type
Loop %HID0% {
    If (HID%A_Index%_Type = RIM_TYPEMOUSE) {
        Gui, ListView, lvwMouse
        If (A_OSVersion = "WIN_VISTA") ;Only supported in Windows Vista and higher
            LV_Add("",HID%A_Index%_Name, HID%A_Index%_ID, HID%A_Index%_Buttons, HID%A_Index%_SampleRate, HID%A_Index%_HWheel)
        Else LV_Add("",HID%A_Index%_Name, HID%A_Index%_ID, HID%A_Index%_Buttons, HID%A_Index%_SampleRate)
    } Else If (HID%A_Index%_Type = RIM_TYPEKEYBOARD) {
        Gui, ListView, lvwKeyb
        LV_Add("", HID%A_Index%_Name, HID%A_Index%_KBType, HID%A_Index%_KBSubType, HID%A_Index%_KeyboardMode
        , HID%A_Index%_FunctionKeys, HID%A_Index%_Indicators, HID%A_Index%_KeysTotal)
    } Else If (HID%A_Index%_Type = RIM_TYPEHID) {
        Gui, ListView, lvwOther
        LV_Add("", HID%A_Index%_Name, HID%A_Index%_VendorID, HID%A_Index%_ProductID, HID%A_Index%_VersionNumber
        , HID%A_Index%_UsagePage, HID%A_Index%_Usage)
    }
}

;Adjust column width
Gui, ListView, lvwMouse
Loop 5
    LV_ModifyCol(A_Index, "AutoHdr")
Gui, ListView, lvwKeyb
Loop 7
    LV_ModifyCol(A_Index, "AutoHdr")
Gui, ListView, lvwOther
Loop 6
    LV_ModifyCol(A_Index, "AutoHdr")
Gui, Show
Return

GuiSize:
    Anchor("MyTabs", "wh")
    Anchor("lvwKeyb", "wh")
    Anchor("lvwMouse", "wh")
    Anchor("lvwOther", "wh")
Return

GuiEscape:
GuiClose:
ExitApp

;Catch Ctrl+c presses to copy selected device name to clipboard
LV_Event:
    If (A_GuiEvent = "K") {
        If GetKeyState("c", "P") And GetKeyState("Ctrl", "P") {
            Gui, ListView, %A_GuiControl%
            LV_GetText(s, LV_GetNext())
            ClipBoard := s
        }
    }
Return

;Anchor by Titan
;http://www.autohotkey.com/forum/viewtopic.php?t=4348
Anchor(i, a = "", r = false) {

    static c, cs = 12, cx = 255, cl = 0, g, gs = 8, z = 0, k = 0xffff, gx = 1
    If z = 0
        VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), z := true
    If a =
    {
        StringLeft, gn, i, 2
        If gn contains :
        {
            StringTrimRight, gn, gn, 1
            t = 2
        }
        StringTrimLeft, i, i, t ? t : 3
        If gn is not digit
            gn := gx
    }
    Else gn := A_Gui
    If i is not xdigit
    {
        GuiControlGet, t, Hwnd, %i%
        If ErrorLevel = 0
            i := t
        Else ControlGet, i, Hwnd, , %i%
    }
    gb := (gn - 1) * gs
    Loop, %cx%
        If (NumGet(c, cb := cs * (A_Index - 1)) == i) {
            If a =
            {
                cf = 1
                Break
            }
            Else gx := A_Gui
            d := NumGet(g, gb), gw := A_GuiWidth - (d >> 16 & k), gh := A_GuiHeight - (d & k), as := 1
                , dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
                , dw := NumGet(c, cb + 8, "Short"), dh := NumGet(c, cb + 10, "Short")
            Loop, Parse, a, xywh
                If A_Index > 1
                    av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
                        , d%av% += (InStr("yh", av) ? gh : gw) * (A_LoopField + 0 ? A_LoopField : 1)
            DllCall("SetWindowPos", "UInt", i, "Int", 0, "Int", dx, "Int", dy, "Int", dw, "Int", dh, "Int", 4)
            If r != 0
                DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
            Return
        }
    If cf != 1
        cb := cl, cl += cs
    If (!NumGet(g, gb)) {
        Gui, %gn%:+LastFound
        WinGetPos, , , , gh
        VarSetCapacity(pwi, 68, 0), DllCall("GetWindowInfo", "UInt", WinExist(), "UInt", &pwi)
            , NumPut(((bx := NumGet(pwi, 48)) << 16 | by := gh - A_GuiHeight - NumGet(pwi, 52)), g, gb + 4)
            , NumPut(A_GuiWidth << 16 | A_GuiHeight, g, gb)
    }
    Else d := NumGet(g, gb + 4), bx := d >> 16, by := d & k
    ControlGetPos, dx, dy, dw, dh, , ahk_id %i%
    If cf = 1
    {
        Gui, %gn%:+LastFound
        WinGetPos, , , gw, gh
        d := NumGet(g, gb), dw -= gw - bx * 2 - (d >> 16), dh -= gh - by - bx - (d & k)
    }
    NumPut(i, c, cb), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
        , NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
    Return, true
}
