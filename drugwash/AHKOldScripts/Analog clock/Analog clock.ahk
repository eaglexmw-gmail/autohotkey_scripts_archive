#NoEnv
SetBatchLines -1

CoordMode Mouse, Screen
OnExit Exit

Run rundll32.exe shell32.dll`,Control_RunDLL timedate.cpl`,`,0,,,PID
GroupAdd Group1, ahk_pid %PID%         ; Work around forbidden variables in #IfWinActive
WinWait ahk_pid %PID%
WinSet AlwaysOnTop, ON, ahk_pid %PID%
WinGetPos wX0, wY0,,, ahk_pid %PID%    ; Default position of Date/Time settings
ControlGetPos cX,cY,cW,cH, ClockWndMain1, ahk_pid %PID%
oX := cX + cW//2                       ; Origin = center of clock
oY := cY + cH//2 - 1                   ; -1/-2 <-- Windows Theme
dX := 0.75 * 150                       ; Zoom factor * Diameter in x direction
dY := dx*A_ScreenHeight/A_ScreenWidth*4/3 ; Handle clock distortion, y-diameter
XY := Round(oX-dX/2) "-" Round(oY-dY/2)   ; Position of clock within control
wX := A_ScreenWidth//2 - oX
wY := -Round(oY-dY/2)                  ; Initial clock position
Full := Pos(0)                         ; Show cut-off clock
SetTimer IsClosed, 999                 ; Exit script if clock is closed

#IfWinActive ahk_group Group1          ; Group1 = Date/Time settings, in any language
~LButton::                             ; Double click toggles clock - full Date/Time window
   If (A_PriorHotKey = "~LButton Up" and A_TimeSincePriorHotkey < 500)
      Full := Pos(!Full)
   Else If !Full {                     ; Start left-drag
      MouseGetPos mX0, mY0             ; Mouse position at start of drag
      SetTimer Drag, 100
   }
Return                                 ; OK-Cancel: close clock! Click on Apply for changes

~LButton Up::SetTimer Drag, OFF

Drag:                                  ; Left-drag
   MouseGetPos mX, mY
   wX += mX-mX0                        ; change window position
   wY += mY-mY0
   WinMove ahk_pid %PID%,, %wX%, %wY%
   mX0 = %mX%                          ; remember new mouse position
   mY0 = %mY%
Return

Pos(Full) {                            ; Full Date/Time window, or cut-off Clock
   Global PID, wX, wY, wX0, wY0, XY, dX, dY
   If Full {                           ; Full window at default position
      WinSet Region,,ahk_pid %PID%
      WinSet Transparent, Off, ahk_pid %PID%
      WinMove ahk_pid %PID%,, %wX0%, %wY0%
   } Else {                            ; Clock at last position
      WinSet Region, %XY% w%dX% h%dY% E, ahk_pid %PID%
      WinSet Transparent, 200, ahk_pid %PID%
      WinMove ahk_pid %PID%,, %wX%, %wY%
   }
   Return Full
}

IsClosed:                              ; Check if Clock is closed
   IfWinExist ahk_pid %PID%
      Return
Exit:                                  ; Close clock at Exit script
   WinClose ahk_pid %PID%
ExitApp
