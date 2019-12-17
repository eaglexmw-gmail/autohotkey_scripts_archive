; Generated by SmartGUI Creater

Gui, Add, GroupBox, x6 y27 w183 h171, Multi-monitor options
Gui, Add, Radio, x16 y47 w171 h21, Always follow active window
Gui, Add, Radio, x16 y68 w171 h19, Always on primary monitor
Gui, Add, Radio, x16 y88 w171 h20, Use the monitor selected below
Gui, Add, Radio, x36 y108 w151 h19, Monitor #1
Gui, Add, Radio, x36 y127 w151 h20, Monitor #2
Gui, Add, Radio, x36 y147 w151 h20, Monitor #3
Gui, Add, Radio, x36 y167 w151 h20, Monitor #4
Gui, Add, Text, x327 y40 w91 h15, Monitors:
Gui, Add, Text, x326 y55 w10 h13, 1.
Gui, Add, Text, x338 y55 w127 h12, Monitor #1
Gui, Add, Text, x326 y67 w9 h13, 2.
Gui, Add, Text, x338 y66 w127 h14, Monitor #2
Gui, Add, Text, x327 y80 w10 h12, 3.
Gui, Add, Text, x338 y80 w127 h13, Monitor #3
Gui, Add, Text, x327 y92 w10 h12, 4.
Gui, Add, Text, x338 y93 w127 h13, Monitor #4
Gui, Add, Text, x198 y125 w124 h76, Note:`nDue to OS limitations Windows 95 && NT will always display OSD on primary monitor.
Gui, Add, GroupBox, x6 y204 w181 h164, Display options
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
Gui, Add, Checkbox, x387 y336 w77 h19, No icon
Gui, Add, Checkbox, x328 y184 w137 h18, Start with Windows
Gui, Add, GroupBox, x324 y27 w143 h149, Detected devices
Gui, Add, GroupBox, x193 y27 w127 h88, Soundcard
Gui, Add, Radio, x196 y47 w122 h22, Soundcard #1
Gui, Add, Radio, x197 y69 w121 h18, Soundcard #2
Gui, Add, Radio, x197 y87 w121 h19, Soundcard #3
Gui, Add, Text, x328 y117 w89 h15, Soundcards:
Gui, Add, Text, x327 y132 w11 h13, 1.
Gui, Add, Text, x338 y131 w127 h14, Soundcard #1
Gui, Add, Text, x327 y145 w9 h14, 2.
Gui, Add, Text, x338 y145 w127 h14, Soundcard #2
Gui, Add, Text, x328 y159 w10 h14, 3.
Gui, Add, Text, x338 y159 w127 h14, Soundcard #3
Gui, Show, x328 y9 h375 w475, Generated using SmartGUI 2.5
Return

GuiClose:
ExitApp