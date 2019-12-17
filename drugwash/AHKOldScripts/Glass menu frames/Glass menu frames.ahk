; by Lexicos http://www.autohotkey.com/forum/viewtopic.php?t=48215

DetectHiddenWindows, On
SysGet, bx, 32
SysGet, by, 33
bx := (bx-3)*2
by := (by-3)*2

; Create temporary hidden window to access window class information.
if !(hwnd := DllCall("CreateWindowEx", "uint", 0, "str", "#32768", "str", "", "uint", 0, "int", 0, "int", 0, "int", 0, "int", 0, "uint", 0, "uint", 0, "uint", 0, "uint", 0))
; Get current window procedure.
    || !(menu_wndproc := DllCall("GetClassLong", "uint", hwnd, "int", -24)) ; GCL_WNDPROC
; Create "subclass" window procedure.
    || !(menu_subclass := RegisterCallback("MenuWindowProc", "", 4, menu_wndproc))
{
    ListVars
    MsgBox FAIL
    ExitApp
}
; Replace window procedure for windows of this class.
DllCall("SetClassLong", "uint", hwnd, "int", -24, "uint", menu_subclass)
; Remove CS_DROPSHADOW class style.
DllCall("SetClassLong", "uint", hwnd, "int", -26, "int", ~0x20000
        & DllCall("GetClassLong", "uint", hwnd, "int", -26))
; Destroy temporary window.
DllCall("DestroyWindow", "uint", hwnd)

Menu, M, Add, Nuthin 1, Nuthin
Menu, M, Add, Nuthin 2, Nuthin
Menu, M, Add, Nuthin 3, Nuthin
MI_SetMenuItemIcon("M", 1, "user32.dll", 2, 16)
MI_SetMenuItemIcon("M", 2, "user32.dll", 3, 16)
MI_SetMenuItemIcon("M", 3, "user32.dll", 4, 16)
MI_ShowMenu("M")

Nuthin:
return

MenuWindowProc(hwnd, msg, wParam, lParam)
{
    global bx, by
    Critical 100
    if msg = 1 ; WM_CREATE
    {
        ; Add WS_THICKFRAME style.
        DllCall("SetWindowLong", "uint", hwnd, "int", -16, "int", 0x40000
                | DllCall("GetWindowLong", "uint", hwnd, "int", -16))
    }
    else if msg = 0x0046 ; WM_WINDOWPOSCHANGING
    {
        ; Adjust window size.
        NumPut(NumGet(lParam+16)+bx, lParam+16)
        NumPut(NumGet(lParam+20)+by, lParam+20)
        ; Remove our subclass from this specific window, since we don't need to process any more messages.
        DllCall("SetWindowLong", "uint", hwnd, "int", -4, "uint", A_EventInfo)
    }
    ; Call original window procedure.
    return DllCall("CallWindowProc", "uint", A_EventInfo, "uint", hwnd, "uint", msg, "uint", wParam, "uint", lParam)
}
