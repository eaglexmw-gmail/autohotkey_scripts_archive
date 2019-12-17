; http://www.autohotkey.com/forum/viewtopic.php?p=262667#262667

#SingleInstance force
#NoEnv
SetBatchLines, -1

Start = 0xffffff
Stop  = 0x000000

Gui, Add, Text,,Start Color
Gui, Add, Edit, w70 vStart, %Start%
Gui, Add, Button, x+10 gCopy, <<<Copy
Gui, Add, Text, ym x+0, Step Color
Gui, Add, Edit, w70 vNow ReadOnly, %Start%
Gui, Add, Button, x+0 gCopy, Copy>>>
Gui, Add, Text, ym, Stop Color
Gui, Add, Edit, w70 vStop, %Stop%
Gui, Add, Text, ym,% A_Space "R+" A_Tab A_Space "G+" A_Tab A_Space "B+"
Gui, Add, Edit, w40
Gui, Add, UpDown, vR Range-85-85, -1
Gui, Add, Edit, w40 x+0
Gui, Add, UpDown, vG Range-85-85, -1
Gui, Add, Edit, w40 x+0
Gui, Add, UpDown, vB Range-85-85, -1
Gui, Add, Text, ym, Sleep
Gui, Add, Edit, w70
Gui, Add, UpDown, vSleep Range50-1000, 100
Gui, Add, Button, w70 x+10 Default, Start
Gui, Add, Button, w70 x+10, Stop
Gui, Add, Button, w40 x+50 vStep, Step
Gui, Color, %Start%
Gui, Show, h600, Rainbow RGB Player
return
GuiClose:
ExitApp

ButtonStep:
step = 1
ButtonStart:
GuiControl, Disable, Step
Gui, Submit, NoHide
msg := H2D(Start)="invalid" ? "Invalid start value"
      :H2D(Stop)="invalid" ? "Invalid stop value":""
If (msg) {
 Gui, +OwnDialogs
 MsgBox,48,,%msg%
 GuiControl, Enable, Step
 return
}
RGB := step ? Now:Start
prev =
quit = 0
Loop {
 RGB := Add(RGB,R,G,B)
 If (Start<Stop AND RGB>Stop) OR (Start>Stop AND RGB<Stop) OR (RGB = prev)
 {
  If (A_Index = 1) {
   Gui, +OwnDialogs
   MsgBox,48,,Resulting color is beyond Stop color.
  }
  break
 }
 prev := RGB
 GuiControl,,Now, %RGB%
 Gui, Color, %RGB%
 Sleep, %Sleep%
 If (quit) OR (step) OR (RGB = Stop)
  break
}
GuiControl, Focus, Now
PostMessage, 0xB1, 0, -1, Edit2, A
step = 0
GuiControl, Enable, Step
return

ButtonStop:
quit = 1
return

Copy:
Gui, Submit, NoHide
GuiControl,,% InStr(A_GuiControl,"<") ? "Start":"Stop", %Now%
return

Add(RGB,R,G,B)
{
 global Start, Stop
 RGB := H2D(RGB)
 If RGB = invalid
  Return, "invalid"
 StringSplit, RGB, RGB, `,
 RGB1 += R
 RGB2 += G
 RGB3 += B
 Loop,3 {
  If (RGB%A_Index% < 0)
   RGB%A_Index% = 0
  Else If (RGB%A_Index% > 255)
   RGB%A_Index% = 255
 }
 RGB := RGB1 "," RGB2 "," RGB3
 Return, D2H(RGB)
}

H2D(RGB)
{
 If RGB is not xdigit
  Return, "invalid"
 If (SubStr(RGB,1,2) = "0x")
  StringTrimLeft, RGB, RGB, 2
 len := StrLen(RGB)
 If (len > 6)
  StringTrimRight, RGB, RGB,% len - 6
 Else If (len < 6)
  Loop,% 6 - len
   RGB .= 0
 Loop, Parse, RGB
 {
  RGB%A_Index% := "0x" A_LoopField
  RGB%A_Index% += 0
 }
 R := (RGB1*16)+RGB2
 G := (RGB3*16)+RGB4
 B := (RGB5*16)+RGB6
 Return, R "," G "," B
}

D2H(RGB)
{
 StringSplit, RGB, RGB, `,
 RGB=
 Loop,3 {
  num1 := RGB%A_Index%//16
  num2 := Mod(RGB%A_Index%,16)
  SetFormat, Integer, Hex
  RGB .= num1+0 num2+0
  SetFormat, Integer, D
 }
 StringReplace, RGB, RGB, 0x,,All
 Return, "0x" RGB
}