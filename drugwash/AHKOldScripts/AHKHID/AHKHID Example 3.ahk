/* TheGood
    AHKHID - An AHK implementation of the HID functions.
    AHKHID Example 3
    
    Monitors the mouse movements and button state changes.
    This is a good example showing how to use the RI_MOUSE flags of the member II_MSE_BUTTONFLAGS.
    ___________________________________________________________
    1. Check RIDEV_INPUTSINK (or Alt+k) if you'd like to capture events even when in the background.
    2. Press the Register button (or Alt+r) to start monitoring the mouse.
    3. Any mouse button state changes will be displayed in the left listbox. Mouse movements will show up in the right one.
    4. Doubleclick any of the listboxes to clear.
    5. Press Unregister (or Alt+u) to stop monitoring the mouse.
*/

;You have to put the #Include line in the auto-execute section if you want to use the constants
#Include %A_ScriptDir%\AHKHID.ahk

;To make x,y movements look nice
SetFormat, Float, 3.0

Gui, +Resize -MaximizeBox -MinimizeBox +LastFound
Gui, Add, Button, w80 gRegister, &Register
Gui, Add, Button, w80 yp x+10 gUnregister, &Unregister
Gui, Add, CheckBox, ym+5 x+10 vInputSink, RIDEV_INPUTSIN&K
Gui, Font, s8, Courier New
Gui, Add, Listbox,    R10 xm y+15 w390 vlbxInput hwndhlbxInput gClear
Gui, Add, Listbox,    R9 x+10 yp w100 vlbxMove hwndhlbxMove gClear
Gui, Add, Text, xp+4 y+1 w100 vlblXY, % " dX" A_Tab " dY"    ;%

;Keep handle
GuiHandle := WinExist()

;Intercept WM_INPUT
OnMessage(0x00FF, "InputMsg")

Gui, Show
Return

GuiEscape:
GuiClose:
ExitApp

GuiSize:
    Anchor("lbxInput", "wh")
    Anchor("lbxMove", "xh")
    Anchor("lblXY", "xy")
Return

Register:
    Gui, Submit, NoHide    ;Put the checkbox in associated var
    HID_Register(1,2,GuiHandle,InputSink ? RIDEV_INPUTSINK : 0)
Return

Unregister:
    HID_Register(1,2,0,RIDEV_REMOVE)    ;Although MSDN requires the handle to be 0, you can send GuiHandle if you want.
Return                                    ;AHKHID will automatically put 0 for RIDEV_REMOVE.

Clear:
    If A_GuiEvent = DoubleClick
        GuiControl,, %A_GuiControl%,|
Return

InputMsg(wParam, lParam) {
    Local flags, s, x, y
    Critical
    
    ;Get movement and add to listbox
    x := HID_GetInputInfo(lParam, II_MSE_LASTX) + 0.0
    y := HID_GetInputInfo(lParam, II_MSE_LASTY) + 0.0
    GuiControl,, lbxMove, % x A_Tab y    ;%
    
    ;Auto-scroll
    SendMessage, 0x018B, 0, 0,, ahk_id %hlbxMove%
    SendMessage, 0x0186, ErrorLevel - 1, 0,, ahk_id %hlbxMove%

    ;Get flags and add to listbox
    flags := HID_GetInputInfo(lParam, II_MSE_BUTTONFLAGS)
    If (flags & RI_MOUSE_LEFT_BUTTON_DOWN)
        s := "You pressed the left button "
    If (flags & RI_MOUSE_LEFT_BUTTON_UP)
        s .= (s <> "" ? "and" : "You") " released the left button "
    If (flags & RI_MOUSE_RIGHT_BUTTON_DOWN)
        s .= (s <> "" ? "and" : "You") " pressed the right button "
    If (flags & RI_MOUSE_RIGHT_BUTTON_UP)
        s .= (s <> "" ? "and" : "You") " released the right button "
    If (flags & RI_MOUSE_MIDDLE_BUTTON_DOWN)
        s .= (s <> "" ? "and" : "You") " pressed the middle button "
    If (flags & RI_MOUSE_MIDDLE_BUTTON_UP)
        s .= (s <> "" ? "and" : "You") " released the middle button "
    If (flags & RI_MOUSE_BUTTON_4_DOWN)
        s .= (s <> "" ? "and" : "You") " pressed XButton1 "
    If (flags & RI_MOUSE_BUTTON_4_UP)
        s .= (s <> "" ? "and" : "You") " released XButton1 "
    If (flags & RI_MOUSE_BUTTON_5_DOWN)
        s .= (s <> "" ? "and" : "You") " pressed XButton2 "
    If (flags & RI_MOUSE_BUTTON_5_UP)
        s .= (s <> "" ? "and" : "You") " released XButton2 "
    If (flags & RI_MOUSE_WHEEL)
        s .= (s <> "" ? "and" : "You") " turned the wheel by " Round(HID_GetInputInfo(lParam, II_MSE_BUTTONDATA) / 120) " notches "
    
    ;Add background/foreground info
    s .= (InputSink And s <> "") ? (wParam ? "in the background" : "in the foreground") : ""
    GuiControl,, lbxInput,%s%
    
    ;Auto-scroll
    SendMessage, 0x018B, 0, 0,, ahk_id %hlbxInput%
    SendMessage, 0x0186, ErrorLevel - 1, 0,, ahk_id %hlbxInput%
}

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