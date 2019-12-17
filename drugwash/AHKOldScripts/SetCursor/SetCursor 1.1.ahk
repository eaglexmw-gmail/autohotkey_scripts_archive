;Title:      SetCursor 
;---------------------------------------------------------------------------------------------------------------------------------- 
; Function:  SetCursor 
;            Set cursor shape for control or window 
; 
; Parameters: 
;            pShape  - Name of the system cursor to set, or cursor handle, or full cursor path (must have .ani or .cur extension)
;            pCtrl   - Class of the control. If omited, cursor will be set for the window 
; 
; System Cursors: 
;      APPSTARTING  - Standard arrow and small hourglass 
;      ARROW        - Standard arrow 
;      CROSS        - Crosshair 
;      HAND         - Windows 98/Me, Windows 2000/XP: Hand 
;      HELP         - Arrow and question mark 
;      IBEAM        - I-beam 
;      ICON         - Obsolete for applications marked version 4.0 or later. 
;      NO           - Slashed circle 
;      SIZE         - Obsolete for applications marked version 4.0 or later. Use IDC_SIZEALL. 
;      SIZEALL      - Four-pointed arrow pointing north, south, east, and west 
;      SIZENESW     - Double-pointed arrow pointing northeast and southwest 
;      SIZENS       - Double-pointed arrow pointing north and south 
;      SIZENWSE     - Double-pointed arrow pointing northwest and southeast 
;      SIZEWE       - Double-pointed arrow pointing west and east 
;      UPARROW      - Vertical arrow 
;      WAIT         - Hourglass 
;      SIZEWE_BIG   - Big double-pointed arrow pointing west and east 
;      SIZEALL_BIG  - Big four-pointed arrow pointing north, south, east, and west 
;      SIZEN_BIG    - Big arrow pointing north 
;      SIZES_BIG    - Big arrow pointing south 
;      SIZEW_BIG    - Big arrow pointing west 
;      SIZEE_BIG    - Big arrow pointing east 
;      SIZENW_BIG   - Big double-pointed arrow pointing north and west 
;      SIZENE_BIG   - Big double-pointed arrow pointing north and east 
;      SIZESW_BIG   - Big double-pointed arrow pointing south and west 
;      SIZESE_BIG   - Big double-pointed arrow pointing south and east 
; 
SetCursor(pShape, pCtrl="") { 
   return SetCursor_(pShape, pCtrl, 0, 0) 
} 

SetCursor_(wparam, lparam, msg, hwnd) { 
   static WM_SETCURSOR := 0x20, WM_MOUSEMOVE := 0x200 
   static APPSTARTING := 32650,HAND := 32649 ,ARROW := 32512,CROSS := 32515 ,IBEAM := 32513 ,NO := 32648 ,SIZE := 32640 ,SIZEALL := 32646 ,SIZENESW := 32643 ,SIZENS := 32645 ,SIZENWSE := 32642 ,SIZEWE := 32644 ,UPARROW := 32516 ,WAIT := 32514 
   static SIZEWE_BIG := 32653, SIZEALL_BIG := 32654, SIZEN_BIG := 32655, SIZES_BIG := 32656, SIZEW_BIG := 32657, SIZEE_BIG := 32658, SIZENW_BIG := 32659, SIZENE_BIG := 32660, SIZESW_BIG := 32661, SIZESE_BIG := 32662
   static hover, curOld=32512, cursor, ctrls="`n", init 

   if !init
      init := 1, OnMessage(WM_SETCURSOR, "SetCursor_"),  OnMessage(WM_MOUSEMOVE, "SetCursor_") 

   if A_Gui = 
   { 
      if wparam is not Integer 
            If InStr( wparam, ".cur" ) || InStr( wparam, ".ani" ) {   ;LoadCursorFromFile 
                 IfNotExist, % WPARAM  ; verify existance 
                    return 
                 cursor := DllCall("LoadCursorFromFile", "Str", WPARAM) 
            } 
            Else cursor := DllCall("LoadCursor", "Uint", 0, "Int", %WPARAM%, "Uint") 

      if lparam = 
            curOld := cursor 
      else  ctrls .= lparam "=" cursor "`n" 
   } 

   If (msg = WM_SETCURSOR) 
      ifEqual, hover, 1,   return 1 

   if (msg = WM_MOUSEMOVE) 
   { 
      MouseGetPos, ,,,c 
      If j := InStr(ctrls, "`n" c "=") 
      { 
         hover := true, 
         j += 2+StrLen(c) 
         j := SubStr(ctrls, j, InStr(ctrls, "`n", 0, j)-j+1) 
         DllCall("SetCursor", "uint",j) 
      } 
      else DllCall("SetCursor", "uint", curOld), hover := "" 
   } 
    
} 
;--------------------------------------------------------------------------------------------------------------------- 
; Group: Example 
;>   Gui,  Add, Text, , I am <-> 
;>   Gui,  Add, Text, , I am hand 
;>   Gui,  Add, Text, , I am cross 
;>   Gui,  Add, Text, , I am size 
;>   Gui,  Add, Text, , I am no-no 
;>   Gui,  Add, Text, , I am size all 
;>   Gui,  Add, Text, , I am a waiting 
;>   Gui,  Add, Text, , I am a custom .cur file 
;>   Gui,  Add, Text, , I am a custom .ani file 
;> 
;>   SetCursor("APPSTARTING")       
;>   SetCursor("SIZEWE", "Static1") 
;>   SetCursor("HAND",   "Static2") 
;>   SetCursor("CROSS",   "Static3") 
;>   SetCursor("SIZENWSE","Static4") 
;>   SetCursor("NO",      "Static5") 
;>   SetCursor("SIZEALL","Static6") 
;>   SetCursor("WAIT",   "Static7") 
;>   SetCursor(A_WinDir . "\cursors\hnesw.cur",   "Static8") 
;>   SetCursor(A_WinDir . "\cursors\drum.ani",   "Static9") 
;> 
;>   gui, show, h300 w300 
;>return 

;--------------------------------------------------------------------------------------------------------------------- 
; Group: About 
;      o Ver 1.1 by majkinetor. See http://www.autohotkey.com/forum/topic19400.html 
;      o Thank you's : freakkk
;      o Licenced under Creative Commons Attribution-Noncommercial <http://creativecommons.org/licenses/by-nc/3.0/>.