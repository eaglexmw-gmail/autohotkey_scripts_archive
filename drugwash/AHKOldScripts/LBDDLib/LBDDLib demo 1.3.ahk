#SingleInstance, Force

Gui, Add, Text, x12 y2 w220 h15 Section, Drag source:
Gui, add, ListBox, xs y+15 w220 h200 HwndLBHwnD, 00|01|02|03|04|05|06|abcdef
Gui, Add, Text, xs y+25 w220 h15, Drop target with changing Delimiter:
Gui, Add, Edit, xs y+3 w220 HwndEditHwnd vedit1,
Gui, Add, CheckBox, xs y+8 vCheckB3 gCheckB3G, Clear editbox with every drop onto it
Gui, Add, CheckBox, xs y+8 vCheckB4 gCheckB4G, Remove items from listboxes after drop
Gui, Add, Text, xs y+30 w220 h15, Custom drop target:
Gui, Add, Button, xp+100 yp-4 w220 HwndButtonHwnd gbtest, Test
Gui, Add, Text, xs+240 y2  w220 h15 Section, Drop target, without deleting original:
Gui, add, ListBox, xs y+15 w220 h200 HwndLBHwnD2, 01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40
Gui, Add, DropDownList, xs y+43 w180 h20 Choose1 R3 gDDL_Select2 vDDL_value2 AltSubmit, Indicate drop with Arrow|Indicate drop with Line|Indicate drop with both
Gui, Add, CheckBox, xs y+8 vCheckB6 gCheckB6G, Use thick line for drop indicator
Gui, Add, Text, xs y+9, RGB-Hex value: #
Gui, Add, Edit, xp+90 yp-2 vedit2, 000000
Gui, Add, Button, xp+60 yp-1 gsetcolor, set
Gui, Add, Text, xs+240 y2 w220 h15 Section, Listbox with changeable Options:
Gui, Add, ListBox, xs y+15 w220 h200 HwndLBHwnD3, AA|BB|CC|DD|EE|FF|GG|HH|II|JJ|KK|LL|MM|NN|OO|PP|QQ|RR|SS|TT|UU|VV|WW|XX|YY|ZZ
Gui, Add, CheckBox, xs y+25 vCheckB5, Disable drop for above ListBox!
Gui, Add, CheckBox, xs y+8 vCheckB1 Checked, Allow Drag for the above ListBox!
Gui, Add, DropDownList, xs y+8 w180 h20 Choose1 R3 gDDL_Select vDDL_value AltSubmit, Listbox works only with itself|Listbox accepts "drops"|Normal Drag&Drop listbox
Gui, Add, CheckBox, xs y+8 vCheckB2 gCheckB2G Checked, Remove items from other listbox if`ndropped onto above listbox
Gui, 2:+owner1 +ToolWindow -SysMenu
Gui, 2:Add, ListBox, w220 h150 HwndLBHwnd4, Test with second|Gui-Window and longer|text inside the listbox.|Settings for this listbox are:|-No removing of original item.|-Showing a yellow line instead of|an arrow for the insertion mark.|-Only accepts drops, from itself and others,| but dragging to others is not possible.
Gui, 2:Add, ListBox, x+30 w220 h100 HwndLBHwnd5, If you find any bugs|or have suggestions,|please post in the forums!|It might be a time till I respond, though!
Gui, 2:Add, Text, y+8 HwndTextHwnd, This is a custom Drop-Target!`n--

LBDDLib_Init("gttip vttip httip UseEventNames")
LBDDLib_Add(LBHwnD)
LBDDLib_Add(LBHwnD2, "LB", "noremove")
LBDDLib_Add(EditHwnd, "edit", "gMyTest d%A_Space%|%A_Space% add noremove")
LBDDLib_Add(ButtonHwnd, "custom", "gMyTestButton")
LBDDLib_Add(LBHwnD3, "ddlb", "OnlySelf vvertest hvertest")
LBDDLib_Add(LBHwnD4, "DDLB", "Drop noremove InsLine #yellow")
LBDDLib_Add(LBHwnD5)
LBDDLib_Add(TextHwnd, "custom", "gMyTestText")
MyCount := 0
MyButtonBool := True

Gui, Show, y50, DragListBox demo
Gui, 2:Show, y500 NoActivate
return

ttip(){
  Global LBHwnD, LBHwnD2, LBHwnD3, EditHwnd, ButtonHwnd
  event := LBDDLib_UserVar("event")
  hWnd := LBDDLib_UserVar("ThWnd")
  ShWnd := LBDDLib_UserVar("ShWnd")
  drag := LBDDLib_UserVar("ItemToMove")
  curr := LBDDLib_UserVar("NewPosition")
  MouseGetPos, mx, my

;  ToolTip, %A_TickCount%, 0,0,2
; WARNING: Uncomment above line, and script will hang sometimes, because it
; no longer detects the mouse-button release (the drop) properly.
; This behaviour occurs if more than 1 tooltip is used!

  if (hWnd == LBHwnD+0)
    hWnd := "T: ListBox1"
  else if (hWnd == LBHwnD2+0)
    hWnd := "T: ListBox2"
  else if (hWnd == LBHwnD3+0)
    hWnd := "T: ListBox3"
  else if (hWnd == EditHwnd+0)
    hWnd := "T: EditBox"
  else if (hWnd == ButtonHwnd+0)
    hWnd := "T: Button"

  if (ShWnd == LBHwnD+0)
    ShWnd := "S: ListBox1"
  else if (ShWnd == LBHwnD2+0)
    ShWnd := "S: ListBox2"
  else if (ShWnd == LBHwnD3+0)
    ShWnd := "S: ListBox3"
  else if (ShWnd == EditHwnd+0)
    ShWnd := "S: EditBox"
  else if (ShWnd == ButtonHwnd+0)
    ShWnd := "S: Button"

  if (event = "verify")
    ToolTip, %ShWnd%`n%hWnd%`n%drag%`n%curr%, mx+20, my+20
  else if (event = "Hover")
    ToolTip, %ShWnd%`n%hWnd%`n%drag%`n%curr%, mx+20, my+20
  else if (event = "OutOfBounds")
    ToolTip,
  else if (event = "Drop")
    ToolTip,
  else if (event = "DropOutOfBounds")
    ToolTip,
  else if (event = "DragCancel")
    ToolTip,
}

vertest(){
  Global CheckB1, CheckB5, LBHwnD3
  if (LBDDLib_UserVar("event") == 0){
    Gui, Submit, NoHide
    return CheckB1
  } else if (LBDDLib_UserVar("event") == 1){
    return not CheckB5
  }
}

MyTestText(){
  Texthandle := LBDDLib_UserVar("thwnd")
  lbhandle := LBDDLib_UserVar("sHWnD")
  item := LBDDLib_UserVar("ITemtomoVE")
  MyText := LBDDLib_LBGetItemText(lbhandle, item)
  MyText := "This is a custom Drop-Target!`n" . MyText
  ControlSetText,, %MyText%, ahk_id %Texthandle%
}

MyTestButton(){
  buttonhandle := LBDDLib_UserVar("thwnd")
  lbhandle := LBDDLib_UserVar("sHWnD")
  item := LBDDLib_UserVar("ITemtomoVE")
  MyText := LBDDLib_LBGetItemText(lbhandle, item)
  ControlSetText,, %MyText%, ahk_id %buttonhandle%
  LBDDLib_LBDelItem(lbhandle, item)
}

MyTest(){
  Global ButtonHwnd, EditHwnd, MyCount
  p1 := LBDDLib_UserVar(1)
  p2 := LBDDLib_UserVar(2)
  p3 := LBDDLib_UserVar(3)
  if (MyCount == 0)
    LBDDLib_Modify(EditHwnd, "d%A_Space%|%A_Space%")
  else if (MyCount == 1)
    LBDDLib_Modify(EditHwnd, "d|||")
  else if (MyCount == 2)
    LBDDLib_Modify(EditHwnd, "d%A_Space%")
  else if (MyCount == 3)
    LBDDLib_Modify(EditHwnd, "d§^(2)^(3)$")
  else if (MyCount == 4)
    LBDDLib_Modify(EditHwnd, "d&""&")
  else if (MyCount == 5)
    LBDDLib_Modify(EditHwnd, "d%")
  else if (MyCount == 6)
    LBDDLib_Modify(EditHwnd, "d%A_Space%%A_Space%g")
  else if (MyCount == 7)
    LBDDLib_Modify(EditHwnd, "d---")
  MyCount ++
  if MyCount > 7
    MyCount := 0
  ControlSetText,, Dropped: %p3%, ahk_id %ButtonHwnd%
  LBDDLib_CallBack()
}

setcolor:
  Gui, Submit, NoHide
  LBDDLib_Modify(LBHwnD2, "#" . edit2)
return

btest:
  MyButtonBool := not MyButtonBool
  if not MyButtonBool {
    LBDDLib_Modify(ButtonHwnd, "g")
    ControlSetText,, Disabled drop function, ahk_id %ButtonHwnd%
  } else {
    LBDDLib_Modify(ButtonHwnd, "gMyTestButton")
    ControlSetText,, Enabled, ahk_id %ButtonHwnd%
  }
return

DDL_Select:
  Gui, Submit, NoHide
  if (DDL_value == 1)
    LBDDLib_Modify(LBHwnD3, "onlyself")
  else if (DDL_value == 2)
    LBDDLib_Modify(LBHwnD3, "drop")
  else if (DDL_value == 3)
    LBDDLib_Modify(LBHwnD3, "global")
return

DDL_Select2:
  Gui, Submit, NoHide
  if (DDL_value2 == 1)
    LBDDLib_Modify(LBHwnD2, "InsArrow")
  else if (DDL_value2 == 2)
    LBDDLib_Modify(LBHwnD2, "InsLine")
  else if (DDL_value2 == 3)
    LBDDLib_Modify(LBHwnD2, "InsArrowLine")
return

CheckB2G:
  Gui, Submit, NoHide
  if CheckB2
    LBDDLib_Modify(LBHwnD3, "remove")
  else
    LBDDLib_Modify(LBHwnD3, "noremove")
return

CheckB3G:
  Gui, Submit, NoHide
  if CheckB3
    LBDDLib_Modify(EditHwnd, "del")
  else
    LBDDLib_Modify(EditHwnd, "add")
return

CheckB4G:
  Gui, Submit, NoHide
  if CheckB4
    LBDDLib_Modify(EditHwnd, "remove")
  else
    LBDDLib_Modify(EditHwnd, "noremove")
return

CheckB6G:
  Gui, Submit, NoHide
  if CheckB6
    LBDDLib_Modify(LBHwnD2, "thickline")
  else
    LBDDLib_Modify(LBHwnD2, "nothickline")
return

~ESC::
  if LBDDLib_UserVar("isDrag")
    return
GuiClose:
ExitApp

#include LBDDLib 1.3.ahk
