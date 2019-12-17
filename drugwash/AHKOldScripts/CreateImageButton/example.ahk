#NoEnv
#Include _CreateImageButton_.ahk
FS := 14
BMIX := 0

Gui, Margin, 20, 20
Gui, Color, 608080
Gui, Font, s%FS%
; Normal -----------------------------------------------------------------------
Gui, Add, Button, Section, Regular button!
Gui, Add, CheckBox, Right, Kill me softly!
; Nicht normal! ----------------------------------------------------------------
Gui, Add, Button, ys hwndBTID, Not really regular!
BMIX++, hBM%BMIX% := _CreateImageButton_(BTID, "000000", "00FF00", 2, "E0E0E0")
Gui, Add, CheckBox, Right hwndCBID, Kill me softly!
BMIX++, hBM%BMIX% := _CreateImageButton_(CBID, "FF0000", "008000", 2, "FFFF00")
Y := (2 * FS) + 4
H := (7 * FS) + Y
Gui, Add, GroupBox, xs wp+20 h%H%, Choose color
_CreateImageButton_("Set", "GC", "F0F0F0")
Gui, Add, Radio, xp+10 yp+%Y% hwndRBID, Color
BMIX++, hBM%BMIX% := _CreateImageButton_(RBID, "FF0000", "FF0000", 1)
Gui, Add, Radio, y+5 hwndRBID, Color
BMIX++, hBM%BMIX% := _CreateImageButton_(RBID, "00FF00", "00FF00", 1)
Gui, Add, Radio, y+5 hwndRBID, Color
BMIX++, hBM%BMIX% := _CreateImageButton_(RBID, "0000FF", "0000FF", 1)
; ------------------------------------------------------------------------------
Gui, Show, , "Colored Buttons"
Return

GuiClose:
GuiEscape:
Loop, %BMIX% {
   DllCall("DeleteObject", "UInt", hBM%A_Index%)
}
ExitApp
