; c = Colour
; s = Size
; w = Weight (max 1000)
; b = Bold
; i = Italic
; d = Delete/Strikeout
; u = Underline
; f = Font

#SingleInstance Force
SetBatchLines -1

Text =
(
<ce5460f>Colour: </c><c7d1cba>This can be specified</c><c456745> using the c tag.</c>
<s14>Size: </s><s6>Different</s>sizes can be specified <s16>easily</s> using the s tag.
<w1000>Weight:</w><w100>Different</w>weights can be specified <w800>easily</w>using the w tag.
<b>Bold: </b>The b tag can be used for <b>bold</b>text.
<i>Italic: </i>The i tag can be used for <i>italic</i>text.
<d>Delete:</d> The d tag can be used for <d>deleted</d>text.
<u>Underline:</u> The u tag can be used for <u>underlined</u>text.
<fComic Sans MS>Font:</f>Different <fGaramond>fonts</f> can be specified with the f tag.
)

HTMLText("x10 y40 w400", Text, 2)
Gui, 2: Show, AutoSize
Return

;###########################################################################

HTMLText(Options, Text, Gui=1)
{   
   RestoreDHW := A_DetectHiddenWindows
   DetectHiddenWindows, On
   Gui, %Gui%: +LastFound
   hwnd := WinExist()
   Gui, %Gui%: Default
   
   RegExMatch(Options, "x([0-9]+)", x)
   RegExMatch(Options, "y([0-9]+)", y)
   RegExMatch(Options, "w([0-9]+)", w)
   x := x1, y := y1, w := w1
   
   StringReplace, Text, Text, `n,, All
   
   Loop
   {
      ControlGetPos, XPos, YPos, Width, Height, Static%A_Index%, ahk_id %hwnd%
      If !(Width || Height)
      {
         CN := A_Index-1
         Break
      }
   }   
   AllText := Text
   Tags := "<c[0-9a-fA-F]+?>,<s[0-9]+?>,<w[0-9]+?>,<b>,<i>,<d>,<u>,<f.+?>"
   StringSplit, Tag, Tags, `,
   
   Loop
   {     
      Loop
      {     
         FirstPos := ""
         Loop, %Tag0%
         {
            Pos := RegExMatch(Text, Tag%A_Index%, Test)
            If ((Pos) && (Pos < FirstPos)) || (!FirstPos)
            FirstPos := Pos
         }
         Pos := FirstPos               
         
         If (Pos) && (Pos != 1)
         {     
            IntText := SubStr(Text, 1, Pos-1)
            StringSplit, IntText, IntText, % " "   ;%           
            GoSub, AddText
            If !Length
            EndTrim += Pos-1
            StringTrimLeft, Text, Text, % Pos-1      ;%           
            Started := 1
         }
         Else If (Pos) && (Pos = 1)
         {     
            ETag := SubStr(Text, 2, 1)
            Pos := RegExMatch(Text, "<" ETag ".+?</" ETag ">", Text, 1)
            If !Length
            EndTrim += StrLen(Text)
         Length := 1
           
            If ETag in b,i,d,u
            {
               StringReplace, Text, Text, <%ETag%>,, All
               StringReplace, Text, Text, </%ETag%>,, All
               If (Etag = "b")
               Gui, %Gui%: Font, Bold
               If (Etag = "i")
               Gui, %Gui%: Font, Italic
               If (Etag = "d")
               Gui, %Gui%: Font, Strike
               If (Etag = "u")
               Gui, %Gui%: Font, Underline
            }
           
            If ETag in c,w,f,s
            {
               Pos := RegExMatch(Text, "<" ETag "(.+?)>(.+?)</" ETag ">", Text, 1)
               If (Etag = "c")
               Gui, %Gui%: Font, c%Text1%
               If (Etag = "w")
               Gui, %Gui%: Font, w%Text1%
               If (Etag = "f")
               Gui, %Gui%: Font,, %Text1%
               If (Etag = "s")
               Gui, %Gui%: Font, s%Text1%

               Text := Text2
            }                     
         }
         Else
         {     
            StringSplit, IntText, Text, % " "   ;%         
            If !Length
            EndTrim += StrLen(Text)
            GoSub, AddText         
            Started := 1
            Break
         }
      }
      Gui, %Gui%: Font
     
      StringTrimLeft, AllText, AllText, %EndTrim%
      Text := AllText
     Length := EndTrim := ""
      If !Text
      Break
   }
   DetectHiddenWindows, %RestoreDHW%
   Return, 0
   
   ;###########################################################################
   
   AddText:
   Loop, %IntText0%
   {
      CN++
     Gui, %Gui%: Add, Text, % ((A_Index = 1) && (!Started)) ? "x" x " y" y : "x+0 yp+0", % (A_Index != IntText0) ? IntText%A_Index% " " : IntText%A_Index%
      GuiControlGet, Pos, Pos, Static%CN%

      If (PosH != OldPosH) && (OldPosH)
      {
         NewY := OldPosY+OldPosH > PosY+PosH ? PosY+(OldPosH-PosH) : PosY-(PosH-OldPosH)

         GuiControl, Move, Static%CN%, % "y" NewY   ;%
         Gui, %Gui%: Add, Text, % "x" PosX+PosW " y" NewY " w" 0 " h" PosH   ;%
         CN++
      }
     
      OldPosX := PosX, OldPosY := PosY, OldPosW := PosW, OldPosH := PosH

      If (PosW+PosX > x+w) || (IntText%A_Index% = "<l>")
      {
         y += 40
         GuiControl, Move, Static%CN%, x%x% y%y%
         Gui, %Gui%: Add, Text, % "x" x+PosW " y" y " w" 0   ;%
         CN++
      }
   }
   Return
}

Esc::ExitApp
