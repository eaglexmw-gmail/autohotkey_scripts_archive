;*************gui1*********************
Gui, Add, Button,,Click to do nothing
;Gui, Add, Picture, Icon133, c:\windows\system\shell32.dll
;Gui, Add, Picture, Icon106, c:\windows\moricons.dll
Gui, Add, DropDownList,vDDL,red|blue|green||
Gui, Add, Checkbox,, Click to enable
Gui, Add, Edit, HwndMYEdit,This is an edit box
Gui, Add, Button,, Ok
Gui, Add, Button, x+ yp, Cancel
Gui, Add, Button, x+ yp, Retry
Gui, Show,x200

;setTip_Defaults("", "FontArial s15 C0xAA0000 BGC0xFF9B9B", "shell32.dll", "Icon24")
setTip_Defaults("", "FontArial s15 C0xAA0000 BGC0xFF9B9B", "moricons.dll", "Icon24")

;set tooltips for each button - supply text, variable, classnn, or hwnd
setTip("Ok", "Why would you ever need a tooltip that looks like this?", "", "", "", "Icon24")   ;imgoptions are "x, y, icon, altsubmit, ..."   ;using the classnn
setTip("Retry", "Maybe do something again.", "", "", "", "Icon47")   ;use imgOptions to set a different icon
setTip("Cancel", " ", "", "", "", "Icon32")   ;use imgOptions to set a different icon
setTip("Click to enable", "Click to do something.", "", "", "", " ")   ;use blank imgPath to show no icon if default already set
setTip(MYEdit, "The infamous edit control", "", "", "", " ")   ;use blank imgPath to show no icon if default already set
setTip(DDL, "Dropdownlist: for to drop down lists")   ;icon not given, using default
setTip("Button1", "This button does absolutely nothing.", "", "", "", "Icon105")   ;Change to diff icon again

;*************gui2*********************
Gui, 2:Add, Button,,Click to do nothing
Gui, 2:Add, DropDownList,vDDL2,red|blue|green||
Gui, 2:Add, Checkbox,, Click to enable
Gui, 2:Add, Edit, HwndMYEdit2,This is edit box two
Gui, 2:Add, Button,, Ok
Gui, 2:Add, Button, x+ yp, Cancel
Gui, 2:Add, Button, x+ yp, Retry
Gui, 2:Show,x400
;set tooltips for each button - supply text, variable, classnn, or hwnd
setTip("Ok", "Why would you ever need a tooltip that looks like this?", "2")   ;on guis other than 1, have to give the gui number - Gui 2 uses all default settings
setTip("Retry", "Maybe do something again.", "2")
setTip("Cancel", "Cancel whatever is happening.", "2")

;~ TipsState(0)   ;disable tooltips
Return
#Include tooltipV2a.ahk

2guiClose:
guiClose:
   ExitApp
Return
