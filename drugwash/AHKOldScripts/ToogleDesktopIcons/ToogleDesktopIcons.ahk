~LButton::
; If ( A_PriorHotKey = A_ThisHotKey && A_TimeSincePriorHotkey < 400 )
^1::
{
   WinGetClass, Class, A
   If Class in Progman,WorkerW
     SetTimer, ToggleDesktopIcons, -50
 }
Return

ToggleDesktopIcons:

var := (flag=1)? "Hide" : "Show"

flag := !flag
Run, ping,, min
msgbox, flag=%flag%`nvar=%var%
WinExist("ahk_class Progman")
Control,%var%,, SysListView321

Return
