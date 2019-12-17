#NoEnv
#Include, _CreateImageButton_ 2.0.ahk
FS := 12
Gui, Margin, 20, 20
Gui, Color, A0A0A0
Gui, Font, s%FS%, Tahoma
; Normal -----------------------------------------------------------------------
Gui, Add, Button, Section, I'm a regular Button!`nWith two,`nno three Lines!
Gui, Add, CheckBox, Center,Check me!`nLine 2
; Nicht normal! ----------------------------------------------------------------
Gui, Add, Button, ys hwndBTID, I'm a regular Button?`nWith two,`nno three Lines?
_CreateImageButton_(BTID, "C0C0C0", "800080", 2, "606060")
Gui, Add, CheckBox, Center hwndCBID, Check me!`nLine 2
_CreateImageButton_(CBID, "FFFF00", "606000", 2, "808000")
FS := 10
Gui, Font, s%FS%
Y := (2 * FS) + 4
H := (7 * FS) + Y
Gui, Add, GroupBox, xs wp+20 h%H% hwndGBID, Choose color
_CreateImageButton_("Set", "GC", "D0D0D0")
Gui, Add, Radio, Left xp+10 yp+%Y% w100  hwndRBID, Red
_CreateImageButton_(RBID, "FF0000", "FFFF00", 1)
Gui, Add, Radio, Right y+5 hp wp hwndRBID, Green
_CreateImageButton_(RBID, "00FF00", "008000", 1)
Gui, Add, Radio, Center y+5 hp wp hwndRBID, Blue
_CreateImageButton_(RBID, "0000FF", "C0C0C0", 1)
; ------------------------------------------------------------------------------
Gui, Show, , "Colored Buttons"
Return

GuiClose:
GuiEscape:
ExitApp
