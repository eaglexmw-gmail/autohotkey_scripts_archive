; http://www.autohotkey.com/forum/viewtopic.php?p=126864#126864
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ThrowWindows by Matthäus Drobiec (foom)
; Based on EasyGlide by Paul Pliska (ManaUser) Enhancements by Laszlo
; Based on Easy Window Dragging by Chris?
;
;      AutoHotkey Version: 1.0.46+
;                Platform: XP/2k/NT
;                  Author: Matthäus Drobiec (foom)
;                 Version: 0.1
;
; Script Function:
; Throw any window by dragging it with the middle mousebutton and releaseing it.
; The window will float around the monitor bouncing of the screen edges.
; Gravity can be applied to a window in 5 different modes.
; Note that performance starts to suffer when there are 3 or more windows
; moving at the same time or when windows have large pictures displayed in them.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;CONFIG
;;
    INERTIA = 0.97 ; 1 means Move forever, 0 means not at all.
 BOUNCYNESS = 0.5  ; 1 means no speed is lost, 0 means don't bounce.
SENSITIVITY = 0.33 ; Higher is more responsive, lower smooths out glitchs more.
                   ; Must be greater than 0 and no higher than 1.


GRAVITY     = 1  ; 0 means turn gravity off. Negative values are possible too. Best results are in range from -2 to 2.
GRAVITYMODE = 4  ; 1 means the bottom edge has gravity only
                 ; 2 means the first edge the window hits will be its source of gravity.
                 ; 3 means the last edge the window hits will be its source of gravity.
                 ; 4 same as 2 but starts of with bottom gravity rather then moving in a straight line.
                 ; 5 same as 3 but starts of with bottom gravity rather then moving in a straight line.

SCALEWIN   = 0   ; (performance hog) 0=off, 1=on. Scale windows to get the effect of throwing windows to the background.
SCALEFACTOR= 0.99 ; 0.90 - 0.99 The factor the window should be scaled down by when thrown.

MINWIDTH = 200   ; Minimum width a window should be scaled too.
MINHEIGHT = 100  ; Minimum height a window should be scaled too.
                 ; If one of those two minimums is reached scaling stops.
SpeedA := 1 - SENSITIVITY
;;
;;CONFIG END. DON'T EDIT BELOW.

SpeedX := SpeedY := 0 ; init or else it might not work.

#SingleInstance Force
#NoEnv
SetBatchLines -1        ; Run faster
SetWinDelay -1          ; Makes the window moves faster/smoother.
CoordMode Mouse, Screen ; Switch to screen/absolute coordinates.

OnMessage(0x1A , "WM_SETTINGCHANGE") ; In case the workarea changes.
WM_SETTINGCHANGE(w){
    global
;    if w = 47 ;SPI_SETWORKAREA
;        SysGet WorkArea, MonitorWorkArea
    if w = 47 ;SPI_SETWORKAREA 
    { 
        ; MSDN: The virtual screen is the bounding rectangle of all display monitors. 
        SysGet, WorkAreaLeft, 76    ; SM_XVIRTUALSCREEN 
        SysGet, WorkAreaTop, 77     ; SM_YVIRTUALSCREEN 
        SysGet, WorkAreaRight, 78   ; SM_CXVIRTUALSCREEN 
        SysGet, WorkAreaBottom, 79  ; SM_CYVIRTUALSCREEN 
        ; convert width,height to right,bottom 
        WorkAreaRight += WorkAreaLeft 
        WorkAreaBottom += WorkAreaTop 
    }
}
WM_SETTINGCHANGE(47)

~^!d::ListVars          ; debug
~*LButton::             ; Clicking a mouse button stops movement.
~*RButton::
    loop, parse, WindowQueue, `n, `n
        RemoveWin(A_LoopField)
Return

MButton::
   ;SetTimer Move, Off
   MouseGetPos LastMouseX, LastMouseY, MWin
   WinGet WinState, MinMax, ahk_id %MWin%
   IfNotEqual WinState, 0 ; If the window is maximized, just do normal Middle Click.
   {
       Click Middle
       Return
   }
   RemoveWin(MWin) ; Necessary else GRAVITYMODE = 4 will fail sometimes.
   WinGetPos WinX, WinY, WinWidth, WinHeight, ahk_id %MWin%
   SetTimer WatchMouse, 10,        ; Track the mouse as the user drags it
Return

WatchMouse:
   If !GetKeyState("MButton","P") {
      SetTimer WatchMouse, Off   ; Button has been released, so drag is complete.
      AddWin(MWin)
      SetTimer Move, 10          ; Start moveing
      Return
   }
                                 ; Drag: Button is still pressed
   MouseGetPos MouseX, MouseY
   WinX += MouseX - LastMouseX
   WinY += MouseY - LastMouseY

   ;Enforce Boundaries
   WinX := WinX < WorkAreaLeft ? WorkAreaLeft : WinX+WinWidth > WorkAreaRight ? WorkAreaRight-WinWidth : WinX
   WinY := WinY < WorkAreaTop ? WorkAreaTop : WinY+WinHeight > WorkAreaBottom ? WorkAreaBottom-WinHeight : WinY

   WinMove ahk_id %MWin%,, WinX, WinY
   SpeedX := SpeedX*SpeedA + (MouseX-LastMouseX)*SENSITIVITY ;
   SpeedY := SpeedY*SpeedA + (MouseY-LastMouseY)*SENSITIVITY ;
   LastMouseX := MouseX,     LastMouseY := MouseY
Return
AddWin(MWin)
{
    global

    WindowQueue:=List(WindowQueue,MWin)

    %MWin%WinX := WinX, %MWin%WinY := WinY, %MWin%WinWidth := WinWidth, %MWin%WinHeight := WinHeight
    %MWin%SpeedX := SpeedX, %MWin%SpeedY := SpeedY
    %MWin%gravity := GRAVITYMODE = 1 OR GRAVITYMODE = 4 OR GRAVITYMODE = 5 ? "b" : ""
}
RemoveWin(MWin)
{
    global

    WindowQueue:=List(WindowQueue,MWin,"d")
    ;No need to remove these as they are from persistent memory (1-64 bytes).
    ;%MWin%WinX := %MWin%WinY := %MWin%WinWidth := %MWin%WinHeight := %MWin%SpeedX := %MWin%SpeedY := ""
    %MWin%gravity := %MWin%touch := %MWin%touchedonce := ""
}

Move:
    If !WindowQueue
        SetTimer Move, Off

    Loop, Parse, WindowQueue , `n, `n
        Move(A_LoopField)
Return

boo(t){ ;debug
tooltip, %t%
return t
}

Move(MWin)
{
    global
    local T, G
   
    G:=%MWin%gravity  ;dereferencing is slow.

    If (GRAVITY ? Abs(%MWin%SpeedX) < 1 AND Abs(%MWin%SpeedY) < 1 AND %MWin%Touch : Abs(%MWin%SpeedX) < 1 AND Abs(%MWin%SpeedY) < 1){
            RemoveWin(MWin)
            return
    }
    if GRAVITY
    {
        %MWin%SpeedX += G = "r" ? GRAVITY : G = "l" ? -GRAVITY : 0
        %MWin%SpeedY += G = "b" ? GRAVITY : G = "t" ? -GRAVITY : 0
       
        ;update wincoords before touch check. If touch() reports collision bouncyness kicks in.
        %MWin%WinX += %MWin%SpeedX,   %MWin%WinY += %MWin%SpeedY

        if (T:=Touch(MWin))
        {
            if GRAVITYMODE = 2
                %MWin%gravity := G ? G : T
            else if (GRAVITYMODE = 3 OR GRAVITYMODE = 5)
                %MWin%gravity := T
            else if GRAVITYMODE = 4
                %MWin%gravity :=   %MWin%touchedonce ? G : ((%MWin%touchedonce := 1) ? T : "c")
            ;tooltip, % "Touchedonce: " %MWin%touchedonce "`n`nG: " G " T: " T "`n`n EXP: " (tmp:= %MWin%touchedonce ? G : ((%MWin%touchedonce := 1) ? T : "c"))

            %MWin%touch:=T  ;Used to check if window should stop moving when in gravity mode.
            %MWin%SpeedY := (T = "b" || T = "t") ? %MWin%SpeedY * -BOUNCYNESS : %MWin%SpeedY * BOUNCYNESS
            %MWin%SpeedX := (T = "l" || T = "r") ? %MWin%SpeedX * -BOUNCYNESS : %MWin%SpeedX * BOUNCYNESS
        }
        else
            %MWin%touch=

    }
    else
    {
        %MWin%SpeedX *= INERTIA,  %MWin%SpeedY *= INERTIA
        %MWin%WinX += %MWin%SpeedX,   %MWin%WinY += %MWin%SpeedY
        if (T:=Touch(MWin))
        {
            %MWin%SpeedY *= (T = "b" || T = "t") ? -BOUNCYNESS : 1
            %MWin%SpeedX *= (T = "l" || T = "r") ? -BOUNCYNESS : 1
        }

    }

    ;Out of bounds checks.
    %MWin%WinX := %MWin%WinX < WorkAreaLeft ? WorkAreaLeft: %MWin%WinX + %MWin%WinWidth > WorkAreaRight ? WorkAreaRight - %MWin%WinWidth : %MWin%WinX
    %MWin%WinY := %MWin%WinY < WorkAreaTop ? WorkAreaTop : %MWin%WinY + %MWin%WinHeight > WorkAreaBottom ? WorkAreaBottom - %MWin%WinHeight : %MWin%WinY


    if SCALEWIN
    {
        Scale(MWin)
        WinMove ahk_id %MWin%,, %MWin%WinX, %MWin%WinY , %MWin%WinWidth, %MWin%WinHeight
        return
    }
   
    WinMove ahk_id %MWin%,, %MWin%WinX, %MWin%WinY
   
}
Scale(MWin)
{
    global
    local w, h

    w:=%MWin%WinWidth * SCALEFACTOR,  h:=%MWin%WinHeight * SCALEFACTOR

    if (w > MINWIDTH AND h > MINHEIGHT)
         %MWin%WinX+=(%MWin%WinWidth-w)/2, %MWin%WinWidth := w,%MWin%WinY+=(%MWin%WinHeight-h)/2 , %MWin%WinHeight := h
}

Touch(MWin)
{
    global
    if (%MWin%WinY + %MWin%WinHeight >= WorkAreaBottom)
        return "b"
    else if (%MWin%WinY <= WorkAreaTop)
        return "t"
    else if (%MWin%WinX <= WorkAreaLeft)
        return "l"
    else if (%MWin%WinX + %MWin%WinWidth >= WorkAreaRight)
        return "r"

}


List(list,Item,Action="",Delim="`n")
{
;Adds Item to a %Delim% Delimited list, removes it, or selects it by putting 2 Delims behind it.
;Action can be s for select, d for delete, a for add. If ommited it defaults to add.
    if !Item
        return list
    if !list
        if Action = d
            return
        else if Action = s
            return Item . Delim . Delim
        else
            return Item

    if Action = d
        list:=RegExReplace(list,"i)\Q" . Item . "\E(\Q" . Delim . "\E)*","")    ;delete Item if allready in list
    list:=RegExReplace(list,"i)(\Q" . Delim . "\E){2,}",Delim)                  ;replace succesive Delims
    list:=RegExReplace(list,"i)^(\Q" . Delim . "\E)|(\Q" . Delim . "\E)$","")   ;delete Delims from start and end of list

    if Action = s
        list:=RegExReplace(list,"i)(\Q" . Item . "\E)(?:\Q" . Delim . "\E)*","$1" . Delim . Delim)

    if (Action = "s" || Action = "d" || RegExMatch(list, "i)(?:\Q" . Item . "\E)(?:\Q" . Delim . "\E)*"))  ;the regexmatch assures we don't add an item twice
        return list
    return Item . Delim . list    ;prepend new items rather than append makes it easier to debug lists
}
