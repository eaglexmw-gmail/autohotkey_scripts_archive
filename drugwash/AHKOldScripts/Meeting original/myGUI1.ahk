Gui, 90:Add, GroupBox, x8 y1 w378 h260 , Settings
Gui, 90:Add, Text, x16 y15 w300 h20 +0x200, Select your preferred text editor:
Gui, 90:Add, Edit, x16 y37 w300 h20 +0x200,
Gui, 90:Add, Button, x318 y37 w60 h20 , Browse
Gui, 90:Add, Text, x16 y59 w180 h20 +0x200, Hotkey for editor's 'Refresh' function:
Gui, 90:Add, Hotkey, x199 y59 w65 h20 , 
Gui, 90:Add, Hotkey, x266 y59 w50 h20 , 
Gui, 90:Add, Hotkey, x318 y59 w60 h20 , 
Gui, 90:Add, Text, x16 y81 w300 h20 +0x200, Select seriatim file for this event (leave blank to create new):
Gui, 90:Add, Edit, x16 y103 w300 h20 , 
Gui, 90:Add, Button, x318 y103 w60 h20 , Browse
Gui, 90:Add, Text, x16 y125 w300 h20 +0x200, Select storage path for seriatim file:
Gui, 90:Add, Edit, x16 y147 w300 h20 , 
Gui, 90:Add, Button, x318 y147 w60 h20 , Browse
Gui, 90:Add, Text, x16 y169 w300 h20 +0x200, Select speaker list for this event:
Gui, 90:Add, Edit, x16 y191 w300 h20 , 
Gui, 90:Add, Button, x318 y191 w60 h20 , Browse
Gui, 90:Add, Text, x16 y213 w300 h20 +0x200, Select storage path for speaker list:
Gui, 90:Add, Edit, x16 y235 w300 h20 , 
Gui, 90:Add, Button, x318 y235 w60 h20 , Browse
; Generated using SmartGUI Creator 4.1b (fixed)
Gui, 90:Show, x348 y167 h349 w441, New GUI Window
Return

90GuiClose:
ExitApp