; Generated by SmartGUI Creater

Gui, Add, Text, x186 y77 w270 h42, Welcome to the Miranda IM Custom Installer!
Gui, Add, Button, x196 y328 w70 h30, &Back
Gui, Add, Button, x286 y328 w70 h30, &Next
Gui, Add, Button, x376 y328 w70 h30, &Exit
Gui, Add, Text, x185 y7 w270 h50, Miranda IM Custom Installer
Gui, Add, Pic, x6 y7 w171 h310, E:\Downloads\Other\Pictures\Dianne Patrice Bloom\l_2fdc0bd2bdd64741129c923f9c037252.jpg
Gui, Add, Text, x37 y340 w109 h20, � 2008 Drugwash
Gui, Add, Text, x186 y120 w270 h27, %detected_file%
Gui, Add, Text, x187 y149 w269 h28, Which Miranda archive do you want to install?
Gui, Add, Radio, x187 y178 w271 h19, The detected file mentioned above
Gui, Add, Radio, x187 y198 w269 h19, I will select the zip manually
Gui, Add, Edit, x186 y228 w241 h20,
Gui, Add, Button, x428 y227 w29 h21, ...
Gui, Show, x242 y192 h373 w472, Generated using SmartGUI 2.5
Return

GuiClose:
ExitApp