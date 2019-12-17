; sources: http://www.cpu-world.com , http://www.sandpile.org , http://en.wikipedia.org/wiki/CPUID , http://www.paradicesoftware.com

Gui, Add, Text, x6 y6 h14, CPU Identification Utility
Gui, Add, Text, x+200 yp h14, by Drugwash
Gui, Add, GroupBox, x3 y20 w464 h54, Generic CPU
Gui, Add, Text, x6 y33 w120 h14, Manufacturer
Gui, Add, ComboBox, xp y+2 w136 r10 vmanufacturer AltSubmit Limit, AMD|AMD K5|Centaur|Cyrix|Intel|National Semiconductor|NexGen|Rise|SiS|Transmeta|UMC
Gui, Add, Text, x+2 y33 w35 h14, Family
Gui, Add, ComboBox, xp y+2 w35 r10 vfamily AltSubmit Limit, 0|4|5|6|7|F
Gui, Add, Text, x+2 y33 w52 h14, Ext. family
Gui, Add, ComboBox, xp y+2 w52 r10 vextfamily AltSubmit Limit, 00|01|02
Gui, Add, Text, x+2 y33 w35 h14, Model
Gui, Add, ComboBox, xp y+2 w50 r10 vmodel AltSubmit Limit, 0|1|2|3|4|5|6|7|8|9|A|B|D|E|F|10|11|12|1314|15|16|17|1C|xx00b|xx01b|xx10b|xx11b|00xxb|01xxb|10xxb|11xxb
Gui, Add, Text, x+2 y33 w55 h14, Ext. model
Gui, Add, ComboBox, xp y+2 w55 r10 vextmodel AltSubmit Limit, 0|1|2|4|5|6|7
Gui, Add, Text, x+2 y33 w50 h14, Stepping
Gui, Add, ComboBox, xp y+2 w50 r10 vstepping AltSubmit Limit, 1|2|3|4|5|6|7|8|9|A|B|C|D|E|F
Gui, Add, Button, x+5 yp w65 h21, Identify
Gui, Add, GroupBox, x3 y+10 w464 h54, AMD CPU
Gui, Add, Text, x6 yp+14 h14, Code row 1
Gui, Add, Edit, xp y+2 w128 h20 vcpucode1a Uppercase
Gui, Add, Text, xp+4 yp+2 w123 h14 BackgroundTrans Disabled, type code here
Gui, Add, Text, x+4 yp-18 h14, Code row 2
Gui, Add, Edit, xp y+2 w128 h20 vcpucode2a Uppercase
Gui, Add, Text, xp+4 yp+2 h14 w123 BackgroundTrans Disabled, type code here
Gui, Add, Text, x+4 yp-18 h14, Code row 3 (optional)
Gui, Add, Edit, xp y+2 w128 h20 vcpucode3a Uppercase
Gui, Add, Text, xp+4 yp+2 h14 w123 BackgroundTrans Disabled, type code here
Gui, Add, Button, x+5 yp-2 w65 h21, Identify
Gui, Add, GroupBox, x3 y+10 w464 h54, Intel CPU
Gui, Add, Text, x6 yp+14 h14, Code string 1
Gui, Add, Edit, xp y+2 w128 h20 vcpucode1i Uppercase
Gui, Add, Text, xp+4 yp+2 w123 h14 BackgroundTrans Disabled, type code here
Gui, Add, Text, x+4 yp-18 h14, Code string 2
Gui, Add, Edit, xp y+2 w128 h20 vcpucode2i Uppercase
Gui, Add, Text, xp+4 yp+2 h14 w123 BackgroundTrans Disabled, type code here
Gui, Add, Text, x+4 yp-18 h14, Code string 3 (optional)
Gui, Add, Edit, xp y+2 w128 h20 vcpucode3i Uppercase
Gui, Add, Text, xp+4 yp+2 h14 w123 BackgroundTrans Disabled, type code here
Gui, Add, Button, x+5 yp-2 w65 h21, Identify
Gui, Show, h300 w470, CPUmagic
return

Lman1 := "AMD"
Lman2 := "AMD"
Lman3 := "Centaur"
Lman4 := "Cyrix"
Lman5 := "Intel"
Lman6 := "National Semiconductor"
Lman7 := "NexGen"
Lman8 := "Rise"
Lman9 := "SiS"
Lman11 := "Transmeta"
Lman12 := "UMC"

;1x2x

 GuiClose:
ExitApp
