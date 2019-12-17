;sTitle and sText are ASCII strings
BalloonTip(sTitle = "", sText = "", Timeout = 10000, MinTimeDisp = 200, RefreshRate = 100)
{
   Static hwnd, ActiveWinID, ActiveCtrl, CtrlContent, CaretX, CaretY, MinTime
   If (!sTitle && !sText)
      Goto _DestroyBalloonTip
   SetTimer, _DestroyBalloonTip, Off
   Gosub _DestroyBalloonTip
   ActiveWinID := WinExist("A")
   ControlGetFocus, ActiveCtrl, Ahk_ID %ActiveWinID%
   If !ActiveCtrl
      Return
   MinTime = 1
   ControlGetText, CtrlContent, %ActiveCtrl%, Ahk_ID %ActiveWinID%
   coordmode, caret, screen
   CaretX := A_CaretX
   CaretY := A_CaretY
; style was 0x80028 below. 0x20 is 'clickthrough' and clips balloon if used.
;hwnd := DllCall("CreateWindowEx", "Uint", 0x80008, "str", "tooltips_class32", "str", "", "Uint", 0x42, "int", 0, "int", 0, "int", 0, "int", 0, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0)
hwnd := DllCall("CreateWindowEx", "Uint", 0x80088, "str", "tooltips_class32", "str", "", "Uint", 0xC3, "int", 0, "int", 0, "int", 0, "int", 0, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0)
   VarSetCapacity(ti, 40, 0)
   ti := Chr(40)
;   DllCall("ntdll\RtlFillMemoryUlong", "Uint", &ti + 4, "Uint", 4, "Uint", 0x20)   ; TTF_TRACK
NumPut(0x20, ti, 4, "UInt")
   If (StrLen(sTitle)>99)
      sTitle := SubStr(sTitle, 1, 98) "…"
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1056, "Uint", 3, "Uint", &sTitle)   ; TTM_SETTITLE   ; 0: None, 1:Info, 2: Warning, 3: Error. n > 3: assumed to be an hIcon.
;   DllCall("ntdll\RtlFillMemoryUlong", "Uint", &ti +36, "Uint", 4, "Uint", &sText)
NumPut(&sText, ti, 36, "UInt")
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1028, "Uint", 0, "Uint", &ti)   ; TTM_ADDTOOL
      ;sleep 1000
   WinGetPos, WinX, WinY, , , Ahk_ID %ActiveWinID%
   ControlGetPos, CtrlX, CtrlY, CtrlW, CtrlH, %ActiveCtrl%, Ahk_ID %ActiveWinID%
   ; TTM_TRACKPOSITION
   If ((CaretY < CtrlY+WinY) || (CaretY > CtrlY+CtrlH-11+WinY) || (CaretX < CtrlX+WinX) || (CaretX > CtrlX+CtrlW-4+WinX))
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1042, "Uint", 0, "Uint", (CtrlX+4+WinX & 0xFFFF)|(CtrlY+CtrlH-9+WinY & 0xFFFF)<<16)
   Else
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1042, "Uint", 0, "Uint", (CaretX+4 & 0xFFFF)|(CaretY+11 & 0xFFFF)<<16)
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1036, "Uint", 0, "Uint", &ti)   ; TTM_UPDATETIPTEXT
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1041, "Uint", 1, "Uint", &ti)   ; TTM_TRACKACTIVATE
   WinShow, Ahk_ID %hwnd%
   SetTimer, _UpdateBalloonTip, %RefreshRate%
   If MinTimeDisp
      SetTimer, _MinTimeDisp, -%MinTimeDisp%
   If Timeout
      SetTimer, _DestroyBalloonTip, -%Timeout%
   Return
   _MinTimeDisp:
   MinTime =
   Return
   _UpdateBalloonTip:
   F := WinExist("A")
   If (F = ActiveWinID)
   {
      ControlGetFocus, F, Ahk_ID %ActiveWinID%
      If (F = ActiveCtrl)
      {
         coordmode, caret, screen
         ControlGetText, F, %F%, Ahk_ID %ActiveWinID%
         If ((A_CaretX = CaretX) && (A_CaretY = CaretY) && (CtrlContent = F))
            Return
         Else If MinTime
         {
            CaretX := A_CaretX
            CaretY := A_CaretY
            CtrlContent := F
            WinGetPos, WinX, WinY, , , Ahk_ID %ActiveWinID%
            ControlGetPos, CtrlX, CtrlY, CtrlW, CtrlH, %ActiveCtrl%, Ahk_ID %ActiveWinID%
            If ((CaretY < CtrlY+WinY) || (CaretY > CtrlY+CtrlH-11+WinY) || (CaretX < CtrlX+WinX) || (CaretX > CtrlX+CtrlW-4+WinX))
               DllCall("SendMessage", "Uint", hWnd, "Uint", 1042, "Uint", 0, "Uint", (CtrlX+4+WinX & 0xFFFF)|(CtrlY+CtrlH-9+WinY & 0xFFFF)<<16)
            Else
               DllCall("SendMessage", "Uint", hWnd, "Uint", 1042, "Uint", 0, "Uint", (CaretX+4 & 0xFFFF)|(CaretY+11 & 0xFFFF)<<16)
            Return
         }
      }
   }
   _DestroyBalloonTip:
   SetTimer, _UpdateBalloonTip, Off
   SetTimer, _MinTimeDisp, Off
   SetWinDelay, -1
   WinClose, Ahk_ID %hwnd%
   hwnd =
   Return
}
