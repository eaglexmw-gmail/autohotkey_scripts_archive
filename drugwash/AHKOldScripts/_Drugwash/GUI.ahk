; Generated by SmartGUI Creater

Gui, Font,   S11 CDefault Bold,   Verdana
Gui, Add, Text, x15 y0 w286 h17, Miranda IM Emoticon Pack Creator
Gui, Font,   S8 CDefault Bold,   Verdana
Gui, Add, Text, x53 y18 w215 h13, for Pescuma's Emoticons plug-in
Gui, Add, Pic, x326 y1 w32 h32, EmoPaC.ico
Gui, Font,
Gui, Add, Text, x384 y12 w102 h15, by Drugwash �2008
Gui, Add, GroupBox, x7 y32 w308 h80, Pack data
Gui, Add, Text, x16 y47 w80 h16 Right, Name :
Gui, Add, Text, x16 y68 w80 h16 Right, Author :
Gui, Add, Text, x16 y89 w80 h16 Right, Updater URL :
Gui, Add, Edit, x98 y46 w203 h17 vpname ,
Gui, Add, Edit, x98 y67 w203 h17 vpauthor ,
Gui, Add, Edit, x98 y88 w203 h17 vpupdater ,
Gui, Add, GroupBox, x322 y32 w87 h166, Actions
Gui, Add, Button, x329 y46 w75 h39, &Load
Gui, Add, Button, x329 y87 w75 h39, &Save
Gui, Add, Button, x329 y170 w75 h20, &Clear
Gui, Add, GroupBox, x7 y113 w308 h84, Codes
Gui, Add, Text, x16 y128 w80 h16 Right, Standard :
Gui, Add, Edit, x98 y127 w203 h17 ReadOnly vcodes,
Gui, Add, Text, x16 y149 w80 h16 Right, Custom codes :
Gui, Add, Edit, x98 y148 w203 h17 vcustom ,
Gui, Add, Button, x98 y169 w66 h20, &Default
Gui, Add, Button, x167 y169 w66 h20, &Undo
Gui, Add, Button, x236 y169 w66 h20, &Merge
Gui, Add, Button, x329 y215 w75 h39, &Folder
Gui, Add, Button, x329 y255 w75 h20, Add &image
Gui, Add, Button, x329 y276 w75 h20, &Rem. image
Gui, Add, Button, x329 y297 w38 h20, � �
Gui, Add, Button, x367 y297 w37 h20, � �
Gui, Add, Button, x329 y347 w75 h39, &Assign >>
Gui, Add, GroupBox, x417 y32 w167 h166, Protocols
Gui, Add, Radio, x422 y152 w60 h16, all
Gui, Add, Radio, x421 y173 w60 h16, select
Gui, Add, Checkbox, x422 y48 w63 h32, Folders
Gui, Show, x162 y122 h453 w592, Generated using SmartGUI 2.5
Return

GuiClose:
ExitApp