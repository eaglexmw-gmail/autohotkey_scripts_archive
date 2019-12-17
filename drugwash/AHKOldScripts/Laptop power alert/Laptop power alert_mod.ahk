; by [VxE] http://www.autohotkey.com/forum/viewtopic.php?p=271781#271781
#Persistent
DetectHiddenWindows, on
MainID := WinExist("Ahk_PID " . DllCall("GetCurrentProcessId"))
OnMessage(0x218, "WM_POWERBROADCAST")
return
WM_POWERBROADCAST(wparam, lparam, msg, hwnd)
{
   Local sps
   If (hwnd != MainID)
      return
   VarSetCapacity(sps, 12, 0)
   DllCall("GetSystemPowerStatus", "UInt", &sps)
;   ACLineStatus := NumGet(sps, 0, "char")
;   if !ACLineStatus
   if!NumGet(sps, 0, "char")
     SetTimer, ShowMsgBox, -10
}

ShowMsgBox:
msgbox, 0x1030, Warning!, The power cable has been unplugged!
return
