; http://www.autohotkey.com/forum/viewtopic.php?p=33245#33245
;        Title:       Reveal Desktop
;           Coder:      Terrapin aka Bob Allred
;           Email:       rka1961@etinternet
;            Date:       22 Sept 2005
;  AutoHotKey Ver:        1.0.38.03
;        Script Ver:   0.9 (first release)
;Purpose/Function:   Mostly for fun & learning/practice.  Temporarily uncovers
;                  a window-cluttered desktop in a cool and useful manner. 
;                  Idea from the VDM goScreen at http://goScreen.info   
;         Usage:      Hold down the Right Mouse Button while clicking the Left
;                  Button to slide open, visible windows off either side of the
;                  screen until the next Left Click, which will bring them back. 
;                  A sliding/transition effect.  Allows you to click something on
;                  the desktop when the screen is cluttered.

SetWinDelay, -1         ; want to move pretty fast

+!g::               ; fire shift-alt-g - an ad for a great shareware utility
msgbox, 4164, Blatant Ad... , Take a look at Andrei's site -`nA GREAT Virtual Desktop Manager!
IfMsgBox, Yes
{
   Run, http://goscreen.info
}
Return

^!+q::         ; hotkey to close the script quick & easy
exitapp

         ; Finally, the Fun
+#r::               ; If you'd rather use a hotkey, comment out the moust triggers
RButton & LButton::      ; easy mouse trigger - click left button while holding down right
Slide:               ;   .... to show the desktop temporarily in a cool effect
{
Slid = true
GoSub, GetVDimensions   ; get vitrual screen in case multi-monitor, but not tested
GoSub, GetWinDimensions   ; get the upper left corner, width & height of each visible window
GoSub, WinInfo         ; ... and of windows & do some figuring

ScrnLeft := X0 + 40      ; don't move windows *quite* all the way off-screen
ScrnRight := X0 + VWidth - 40   
         
Loop, 40            ; kind of an arbitrary number of maximum slides (steps) educated guess                        
{
   i = %WinArray%      ; number of windows being slid
   Loop, %i%         ; cycle through list of visible windows
   {
      If WinTitle%A_Index% <>         ; if the window has no title, most likely leave it be
      { 
         If (x2%A_Index% > ScrnLeft)   ; we won't slid a window any more once
         {                     ; .... once it is at Left edge of screen
            If (x1%A_Index% < ScrnRight)   ; ditto - left side if moving left
            {
               
   hwnd := WinArray%A_Index%      ; easy to use this simple var each time around
   If Side%A_Index% = L         ; for each window, slide it off the side of
      step = -30               ; .... the screen it is on
   If Side%A_Index% = R         ; ... LEFT or RIGHT
      step = +30               ; by 30 pixels per step
      
   NumMoves%A_Index%++            ; count how many times we moved the window so
                           ; ... we can return it the same way later
   x1%A_Index% += %step%         ; these two lines set up to slide windows a step at   
   x2%A_Index% += %step%         ; .. a time of 30 pixels per step
   x1 := x1%A_Index%            ; move array element to a simpler var
   y1 := y1%A_Index%            ; just using left and right sides, so y doesn't change
   WinMove, ahk_id %hwnd% , , x1, y1   ; and slide the window, finally
   moved%A_Index% = true         ; save to remember to move this one back - just a
            }               ;    ... corresponding array of flags
         }
      }   
   }
}
Return
}      

~LButton::               ; if you comment out the trigger click above, do this one too
SlideBack:               ; this slides the windows back to their original positions
{
i = %WinArray%

Loop, 40
{
   Loop, %i%
   {
      If moved%A_Index%               ; check each windows flag so only sliding back
      {                           ;   ... the ones we moved in the first place
         hwnd := WinArray%A_Index%
         If Side%A_Index% = L         ;
            step = +30               ; reverse direction
         If Side%A_Index% = R         ;
            step = -30               ; by 30 pixels per step      
         If NumMoves%A_Index% > 0      ; remember, we counted the moves for each window
         {                        ; ... so we know how many times to slide it back
            NumMoves%A_Index%--         ; decrement the number of moves each time we slide
            x1%A_Index% += %step%      ; set up to move window back one "step" (30 pixels)
            x2%A_Index% += %step%            
            x1 := x1%A_Index%
            y1 := y1%A_Index%
            WinMove, ahk_id %hwnd%, , x1, y1   ; move it
         }
      }
   }
}
Return
}         
         

*RButton Up::            ; pass on through that Right "shift" button

{
If Not %Slid%            ; only pass along the right button click if it wasn't used by this app
{
   Slid := Not Slid   ; turn off flag
   Send, {RButton}      ; guess :)
}
return
}         
         
         
Decide(cx)                  ; pass this function the horizontal window center...
{
   If  (cx < ScrnXCenter())     ; it will compare it to the horiz screen center
      Side = L            ;   ... to decide which side of the screen the
   Else                  ; ... window is on, Left
      Side = R            ; .... or Right

Return, Side               ; when we slide, windows on the left side of the screen
}                        ;    .... will go left, and vice versa

GetWinDimensions:
{
DetectHiddenWindows, Off       ; only act on visible windows
WinGet, WinArray, List         ; get # of visible windows and each window handle into array
i = %WinArray%               ; use this variable for loops
   
Loop, %i%                  ; execute loop once per window
{
   hwnd := WinArray%A_Index%   ; var for ahk_id for each window as we loop
; below - get location and size of each window as we loop -- and window titles
   WinGetPos, WinArray%A_Index%_X, WinArray%A_Index%_Y, WinArray%A_Index%_W, WinArray%A_Index%_H, ahk_id %hwnd%
   WinGetTitle, WinTitle%A_Index%, ahk_id %hwnd%
}
DetectHiddenWindows, On         ; I normally keep it on, what the heck
Return
}

WinInfo:
{
i = %WinArray%                  ; number of found visible windows

Loop, %i%                     ; get various info for each window
{

   Title := WinTitle%A_Index%       ; obvious... I hope
   x1 := WinArray%A_Index%_X       ; Left....
   y1 := WinArray%A_Index%_Y      ;  .... Top corner of the current window
   width := WinArray%A_Index%_W   ; width and ...
   height := WinArray%A_Index%_H   ; .... height of the current window
   x2 := x1 + width            ; calculate right side of each window...
   y2 := height + y1            ; ....as well as the bottom side
   cx := width/2+x1            ; horizontal center of window - using virtual screen....
   cy := height/2+y1            ; .. in case dual monitors - this gets vertical center
   x1%A_Index% = %x1%            ; store left side locations in an array matching the hwnd array
   x2%A_Index% = %x2%            ; ditto for right sides
   cx%A_Index% = %cx%            ; ditto for horizontal centers
   side%A_Index% := Decide(cx)      ; this calls a function which determines which horizontal
                           ;   .. side of the screen each window is located
}
Return
}

GetVDimensions:         ; using virtual screen dimensions
{
SysGet,X0,76
SysGet,Y0,77
SysGet,VWidth,78
SysGet,VHeight,79
Return
}

; function names should make these clear
WinXCenter(WinID)
{
WinGetPos, , , width, , ahk_id %WinID%
Return, width/2
}

WinYCenter(WinID)
{
WinGetPos, , , , height, ahk_id %WinID%
Return, height/2
}

ScrnXCenter()
{
SysGet,x,76
SysGet,VWidth,78
Return, (VWidth/2)+x
}

ScrnYCenter()
{
SysGet,y,77
SysGet,VHeight,79
Return, (VHeight/2)+y
}
