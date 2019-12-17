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
   ACLineStatus := NumGet(sps, 0, "char")
   BatteryFlag := NumGet(sps, 1, "char")
   BatteryLifePercent := NumGet(sps, 2, "char")
   BatteryLifeTime := NumGet(sps, 4, "int")
   BatteryFullLifeTime := NumGet(sps, 8, "int")
   SetTimer, ShowMsgBox, -10
}

ShowMsgBox:
powersource := ACLineStatus ? "AC power" : "battery power"
batterystate := BatteryFlag & 8 ? "charging" : (ACLineStatus ? "fully charged" : "draining")
msgbox,
( ltrim
   The computer is currently powered by %powersource%.
   The Battery is now at %BatteryLifePercent%`% and is %batterystate%.
)
return
