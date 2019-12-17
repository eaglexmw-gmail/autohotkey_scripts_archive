;CoordMode,Mouse,Screen
Gui,Add,Text
Gui,Show,w800 h600,GUI
Gui,+LastFound
hwnd:=WinExist()
; tthwnd:=ToolTip(1,"Hallo","test","I1 X400 Y400")
tthwnd:=ToolTip(2,"Hallo","test","I1")
DllCall("SetParent", "uint", tthwnd, "uint", hwnd)
OnMessage(0x200,"Show")
Return
2GuiClose:
GuiClose:
ToolTip()
ExitApp

Show(wParam,lParam){
   ToolTip(2,"Parameters passed`nwParam: " wParam "`nlParam: " lParam,"Test","I1 BFF00FF FFFFFFF D0.001 O1 C1 M1")
}

#include Tooltip advanced.ahk
