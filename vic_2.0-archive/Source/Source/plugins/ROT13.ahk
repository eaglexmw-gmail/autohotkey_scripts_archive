;-------------------------------------------------
; Like this one, your plugin script must begin
; by the two following lines of code :
;-------------------------------------------------

SetTitleMatchMode, 2
WinActivate, - Vic

;-------------------------------------------------
; The rest is at your convinience.
; This code is from DerRaphael.
;-------------------------------------------------

Sleep,100
Send ^C
Clipboard:=rotX(clipboard)
Sleep,100
Send ^V

rotX(txt,rot=13)
{
 If (rot==5)
  StartLetter:="0",Replacement:="$1$2$2$1",Offset:=rot
 Else if (rot==13)
  StartLetter:="A",Replacement:="$U1$U2$L1$L2$U2$U1$L2$L1",Offset:=rot*4
 Else if (rot==47)
  StartLetter:="!",Replacement:="$1$2$2$1",Offset:=rot
 Else
  Return
 Loop,% rot*2
  src.=chr(asc(StartLetter)-1+A_Index)
  src:=RegExReplace(src,"(.{" rot "})(.{" rot "})",Replacement)
 Loop,Parse,txt
  o.=RegExMatch(src,"\Q" A_LoopField "\E")
  ? SubStr(src,RegExMatch(src,"\Q" A_LoopField "\E")+Offset,1) : A_LoopField
 Return o
}
