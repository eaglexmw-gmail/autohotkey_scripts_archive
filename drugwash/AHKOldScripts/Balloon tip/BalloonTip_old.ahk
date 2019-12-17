;sTitle and sText are ASCII or UTF8 strings
BalloonTip(sTitle = "", sText = "", Timeout = 10000, RefreshRate = 100)
{
   Static hwnd, ActiveWinID, CaretX, CaretY
   If (!sTitle && !sText)
      Goto _DestroyBalloonTip
   coordmode, caret, screen
   If !hwnd
   {
      hwnd := DllCall("CreateWindowEx", "Uint", 0x80028, "str", "tooltips_class32", "str", "", "Uint", 0x42, "int", 0, "int", 0, "int", 0, "int", 0, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0)
      VarSetCapacity(ti, 40, 0)
      ti := Chr(40)
;      DllCall("ntdll\RtlFillMemoryUlong", "Uint", &ti + 4, "Uint", 4, "Uint", 0x20)   ; TTF_TRACK
      NumPut(0x20, ti, 4, "Uint")   ; TTF_TRACK
   }
   ActiveWinID := WinExist("A")
   CaretX := A_CaretX
   CaretY := A_CaretY
   ;65001 is UTF-8. ASCII is also correctly converted, though.
   ;Retrieve size of the title in unicode
   nSize := DllCall("MultiByteToWideChar", "Uint", 65001, "Uint", 0, "Uint", &sTitle, "int",  -1, "Uint", 0, "int",  0)
   VarSetCapacity(sU16, nSize * 2)
   DllCall("MultiByteToWideChar", "Uint", 65001, "Uint", 0, "Uint", &sTitle, "int",  -1, "Uint", &sU16, "int",  nSize)
   ;Cut the string at the proper size by writing an end char in memory.
   If (nSize>100) ;100=string+end char
      NumPut(0x2026, &sU16+196, "UInt") ;2026 is "…" .UInt is 32bits. The remaining bits will be filled with 0, creating the end char.
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1057, "Uint", 3, "Uint", &sU16)   ; TTM_SETTITLEW   ; 0: None, 1:Info, 2: Warning, 3: Error. n > 3: assumed to be an hIcon.
;   PostMessage, 1057, 3, % &sU16, , Ahk_ID %hwnd%
   ;Retrieve size of the text in unicode
   nSize := DllCall("MultiByteToWideChar", "Uint", 65001, "Uint", 0, "Uint", &sText, "int",  -1, "Uint", 0, "int",  0)
   VarSetCapacity(sU16, nSize * 2)
   DllCall("MultiByteToWideChar", "Uint", 65001, "Uint", 0, "Uint", &sText, "int",  -1, "Uint", &sU16, "int",  nSize)
;   DllCall("ntdll\RtlFillMemoryUlong", "Uint", &ti +36, "Uint", 4, "Uint", &sU16)
   NumPut(&sU16, ti, 36, "Uint")
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1028, "Uint", 0, "Uint", &ti)   ; TTM_ADDTOOL
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1041, "Uint", 1, "Uint", &ti)   ; TTM_TRACKACTIVATE
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1042, "Uint", 0, "Uint", (A_CaretX+4 & 0xFFFF)|(A_CaretY+11 & 0xFFFF)<<16)   ; TTM_TRACKPOSITION
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1081, "Uint", 0, "Uint", &ti)   ; TTM_UPDATETIPTEXTW
   SetTimer, _UpdateBalloonTip, %RefreshRate%
   SetTimer, _DestroyBalloonTip, -%Timeout%
   Return
   _UpdateBalloonTip:
   F := WinExist("A")
   If (F = ActiveWinID)
   {
      coordmode, caret, screen
      If ((A_CaretX = CaretX) && (A_CaretY = CaretY))
      {
         ;TTM_UPDATETIPTEXTW can be called here if needed
         Return
      }   
   }
   _DestroyBalloonTip:
   SetWinDelay, -1
   SetTimer, _UpdateBalloonTip, Off
   WinHide, Ahk_ID %hwnd%
   Return
}
