Gui, Add, Edit, x22 y150 w720 h330 , 
Gui, Add, GroupBox, x12 y130 w740 h360 , Code
Gui, Add, GroupBox, x12 y30 w200 h90 , Settings
Gui, Add, Radio, x22 y50 w180 h20 , Use normal injection
Gui, Add, Radio, x22 y70 w180 h20 , Use dynamic injection
Gui, Add, Radio, x22 y90 w180 h20 , Use obfuscated injection
Gui, Add, Text, x232 y50 w30 h20 , PID:
Gui, Add, Text, x232 y80 w30 h20 , DLL:
Gui, Add, GroupBox, x222 y30 w260 h90 , 
Gui, Add, DropDownList, x262 y80 w210 h20 , DropDownList
Gui, Add, DropDownList, x262 y50 w210 h20 , DropDownList
; Generated using SmartGUI Creator 4.0
Gui, Show, x168 y138 h575 w770, New GUI Window
Return

GuiClose:
ExitApp