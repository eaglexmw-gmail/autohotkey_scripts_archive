Gui, 90:Add, GroupBox, x6 y1 w381 h162 , Settings
Gui, 90:Add, Edit, x16 y37 w300 h20 , Preferred editor
Gui, 90:Add, Button, x318 y37 w60 h20 , Browse
Gui, 90:Add, Text, x16 y15 w300 h20 +0x200, Select your preferred text editor:
Gui, 90:Add, Text, x16 y59 w180 h20 +0x200, Hotkey for editor's 'Refresh' function:
Gui, 90:Add, Hotkey, x199 y59 w65 h20 , 
Gui, 90:Add, Hotkey, x266 y59 w50 h20 , 
Gui, 90:Add, Hotkey, x319 y59 w60 h20 , 
; Generated using SmartGUI Creator 4.1b (fixed)
Gui, 90:Show, x348 y167 h349 w441, New GUI Window
Return

90GuiClose:
ExitApp