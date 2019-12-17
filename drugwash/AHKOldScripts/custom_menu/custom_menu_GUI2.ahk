
Gui, 1:Add, Text, x7 y7 w100 h14, File path:
Gui, 1:Add, Edit, x7 y23 w340 h24 vLocation gEDITED
Gui, 1:Add, Text, x7 y48 w100 h14, Menu item name:
Gui, 1:Add, Edit, x6 y64 w190 h24 vName gEDITED
;Gui, 1:Add, ListView, x205 y64 w210 h215
Gui, 1: Add, ListView,AltSubmit -Multi x205 y64 w210 h215 vListView gEDITSETTINGS,Name|Location
Gui, 1:Add, Button, x347 y23 w70 h24, Browse
Gui, 1:Add, Button, x96 y96 w100 h30 gNEWSHORTCUT, Insert
Gui, 1:Add, Button, x96 y136 w100 h30 gDELETESHORTCUT, Remove
Gui, 1:Add, Button, x96 y176 w100 h30 gDIVIDER, Insert separator
Gui, 1:Add, Pic, x7 y96 w85 h85, %A_ScriptDir%\custom_menu.ico
Gui, 1:Add, Button, x96 y216 w100 h30 gSAVESETTINGS, OK
Gui, 1:Add, Button, x96 y250 w100 h30 gCANCELSETTINGS, Cancel
Gui, 1:Add, Text, cBlue x7 y223 w86 h16 Center, AutoHotkey
Gui, 1:Add, Text, cBlue x7 y257 w88 h16 Center, About...
Gui, 1:Show, x335 y300 h286 w424, Custom Menu Settings
Return

GuiClose:
ExitApp