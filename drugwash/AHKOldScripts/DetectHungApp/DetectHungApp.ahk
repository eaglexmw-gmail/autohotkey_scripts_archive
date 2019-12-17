; http://www.autohotkey.com/forum/viewtopic.php?p=83784#83784
; by SKAN

#Persistent
Menu, Tray, Icon, User32.dll, 2
SMTO_NOTIMEOUTIFNOTHUNG := 8     
Delay = 200                   
SetTimer, CheckAllWindows, 10
Return

CheckAllWindows:
  SetTimer, CheckAllWindows, Off
  WinGet, hWnd, List

  Loop, %hWnd%           {

        ID := hwnd%A_Index%

        DllCall("SendMessageTimeout", UInt,ID, UInt, 0, Int,0, Int,0
                , UInt, SMTO_NOTIMEOUTIFNOTHUNG, Int,3, "UInt *", Result )

        WinGetTitle, Title, ahk_id %ID%
        IfNotEqual,Result,0, GoSub,Alert

        Sleep %Delay%
                         }
  SetTimer, CheckAllWindows, %Delay%
Return

Alert: ; This routine can be used to repeat testing & offer a WinKill.
MsgBox,64,Alert: Window probably hung?!, Window Title: %Title%, 3
Return
