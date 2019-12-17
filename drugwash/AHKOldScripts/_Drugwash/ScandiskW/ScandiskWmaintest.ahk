Gui, Add, Pic, x16 y8 w32 h-1 , %iconlocal%
Gui, Font, s16, 
Gui, Add, Text, x67 y15 w180 h20 , ScanDisk 32-bit GUI
Gui, Font, s8, 
Gui, Add, Text, x17 y49 w229 h16 , Select the dri&ve(s) you want to check for errors:
Gui, Add, ListBox, x17 y67 w230 h134 , 
Gui, Add, GroupBox, x254 y48 w193 h153 , Type of test
Gui, Add, Radio, x261 y67 w75 h21 vst Checked gstandard, Stan&dard
Gui, Add, Radio, x261 y108 w76 h18 vth gthorough, &Thorough
Gui, Add, Text, x277 y88 w164 h16 , (checks files && folders for errors)
Gui, Add, Text, x277 y128 w166 h17 , (Standard test + disk surface scan)
Gui, Add, Button, x306 y158 w92 h30 vBopt Disabled, &Options...
Gui, Add, Checkbox, x257 y208 w140 h19 vaf Checked, Automatically &fix errors
Gui, Add, Checkbox, x17 y207 w210 h20 vss Checked, Su&ppress screensaver while scanning
Gui, Add, GroupBox, x16 y230 w430 h78 , Progress
Gui, Add, Button, x16 y318 w100 h30 , &Start
Gui, Add, Button, x16 y318 w100 hidden , St&op
Gui, Add, Button, x126 y318 w100 h30 , &Close
Gui, Add, Button, x346 y318 w100 h30 , &Advanced
Gui, Add, Button, x346 y8 w100 h30 , A&bout
Gui, Add, Progress, x66 y247 w370 h30 , 25
Gui, Add, Progress, x66 y278 w370 h24 , 25
; Generated using SmartGUI Creator 4.0
Gui, Show, x169 y142 h355 w464, New GUI Window
Return

GuiClose:
ExitApp