^1::PostMessage,0x111,28755,,,ahk_class Progman

~LButton::
; If ( A_PriorHotKey = A_ThisHotKey && A_TimeSincePriorHotkey < 400 )
 {
   WinGetClass, Class, A
   If Class in Progman,WorkerW
     SetTimer, ToggleDesktopIcons, -50
 }
Return

ToggleDesktopIcons:
 WinActivate, ahk_class Progman
 ControlGet, Selected, List, Selected, SysListView321, ahk_class Progman
 IfEqual,Selected,,PostMessage,0x111,28755,,,ahk_class Progman
Return
