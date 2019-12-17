; http://www.autohotkey.com/forum/viewtopic.php?p=262863#262863

;*************gui1*********************
Gui, Add, Button,,Click to do nothing
Gui, Add, DropDownList,vDDL,red|blue|green||
Gui, Add, Checkbox,, Click to enable
Gui, Add, Edit, HwndMYEdit,This is an edit box
Gui, Add, Button,, Ok
Gui, Add, Button, x+ yp, Cancel
Gui, Add, Button, x+ yp, Retry
Gui, Show,x200
;set tooltips for each button - supply text, variable, classnn, or hwnd
setTip("Button1", "This button does absolutely nothing.")   ;using the classnn
setTip("Ok", "Begin the Process")   ;using the caption
setTip("Cancel", "Cancel Whatever is Happening!")
setTip("Retry", "Do Over")
setTip("Click to enable", "Checkbox")
setTip(DDL, "Dropdownlist")   ;using the variable
setTip(MYEdit, "The infamous edit control")   ;using the hwnd

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
setTip("Button1", "This button does absolutely nothing. gui2", 2)   ;using the classnn
setTip("Ok", "Begin the Process gui2", 2)   ;using the caption
setTip("Cancel", "Cancel Whatever is Happening! gui2", 2)
setTip("Retry", "Do Over gui2", 2)
setTip("Click to enable", "Checkbox gui2", 2)
setTip(DDL2, "Dropdownlist part two: This time it's personal", 2)   ;using the variable
setTip(MYEdit2, "The infamous edit control redeux", 2)   ;using the hwnd

;TipsState(0)   ;disable tooltips
Return
#Include tooltipV2.ahk

2guiClose:
guiClose:
   ExitApp
Return
