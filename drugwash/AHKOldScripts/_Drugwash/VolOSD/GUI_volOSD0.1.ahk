; Generated by SmartGUI Creater

Gui, Add, GroupBox, x10 y30 w460 h169, Multi-monitor options
Gui, Add, Radio, x16 y47 w171 h21, Always follow active window
Gui, Add, Radio, x16 y68 w171 h19, Always on primary monitor
Gui, Add, Radio, x16 y88 w171 h20, Use the monitor selected below
Gui, Add, Radio, x36 y108 w151 h19, Monitor #1
Gui, Add, Radio, x36 y127 w151 h20, Monitor #2
Gui, Add, Radio, x36 y147 w151 h20, Monitor #3
Gui, Add, Radio, x36 y167 w151 h20, Monitor #4
Gui, Add, Text, x196 y48 w101 h19, Detected monitors:
Gui, Add, Text, x196 y67 w11 h16, 1.
Gui, Add, Text, x207 y67 w251 h16, Monitor #1
Gui, Add, Text, x197 y83 w11 h16, 2.
Gui, Add, Text, x207 y83 w251 h16, Monitor #2
Gui, Add, Text, x197 y99 w11 h16, 3.
Gui, Add, Text, x208 y99 w250 h16, Monitor #3
Gui, Add, Text, x197 y115 w11 h16, 4.
Gui, Add, Text, x208 y115 w250 h16, Monitor #4
Gui, Add, Text, x196 y137 w261 h56, Due to OS limitations, Windows 95 and NT will always report a single monitor even when multiple monitors exist. For this reason, the aforementioned OS versions will always display the OSD on the primary monitor.
Gui, Add, GroupBox, x10 y203 w180 h165, Display options
Gui, Add, Text, x16 y218 w101 h16, Progress bar width:
Gui, Add, Button, x117 y217 w62 h21, Default
Gui, Add, Text, x16 y268 w101 h16, Progress bar height:
Gui, Add, Button, x116 y266 w61 h22, Default
Gui, Add, Text, x17 y317 w39 h14, Master:
Gui, Add, Text, x16 y331 w40 h14, Wave
Gui, Add, Button, x115 y316 w62 h22, Default
Gui, Add, Text, x16 y344 w40 h14, Backgr:
Gui, Add, GroupBox, x192 y203 w275 h165, Hotkeys
Gui, Add, Text, x198 y218 w67 h19, Master up:
Gui, Add, Edit, x268 y218 w109 h19, CTRL+Up
Gui, Add, Text, x198 y240 w67 h16, Master down:
Gui, Add, Edit, x268 y240 w108 h18, CTRL+Down
Gui, Add, Text, x198 y259 w67 h17, Wave up:
Gui, Add, Edit, x268 y259 w108 h18, RALT+Up
Gui, Add, Text, x198 y279 w67 h17, Wave down:
Gui, Add, Edit, x268 y279 w108 h18, RALT+Down
Gui, Add, Text, x197 y298 w67 h17, Master dim:
Gui, Add, Edit, x268 y297 w108 h18, CTRL+SHIFT+Up
Gui, Add, Text, x198 y317 w66 h18, Mute:
Gui, Add, Edit, x268 y316 w108 h19, CTRL+SHIFT+Down
Gui, Add, Text, x197 y337 w67 h18, Options
Gui, Add, Edit, x268 y337 w108 h18, CTRL+SHIFT+O
Gui, Add, Checkbox, x379 y216 w84 h21, No icon
Gui, Add, Checkbox, x379 y237 w84 h23, Autostart
Gui, Show, x229 y18 h375 w475, Generated using SmartGUI 2.5
Return

GuiClose:
ExitApp