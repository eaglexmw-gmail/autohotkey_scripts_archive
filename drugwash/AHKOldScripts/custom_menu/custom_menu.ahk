#singleinstance ignore
SetWorkingDir %A_ScriptDir%

IfExist, %A_WorkingDir%\custom_menu.ico
{
Menu, TRAY, Icon, %A_WorkingDir%\custom_menu.ico,,1
}

GoSub, INI
GoSub, TRAYMENU
return

INI:
RowNumber = 1
Loop
{
IniRead, LineText, Menu.ini, Settings, %RowNumber%
If (LineText="Error" or RowNumber>20)
{
break
}
else
{
Location = ""
Name = ""
StringSplit,Col,LineText,`,
Name:=Col1
Location:=Col2
if(Location <> "" and Name <> "")
{
Name%RowNumber%:=Name
Location%RowNumber%:=Location
}
RowNumber ++ 1
}
}
return

TRAYMENU:
Menu, tray, NoStandard
Menu, tray, add, About, ABOUT
Menu, tray, add,
Menu, tray, add, Configure Menu, SETTINGS
Menu, tray, add, Exit, EXIT
Menu, tray, default, About
Menu, tray, Tip,Custom Menu ~ by David Barnes
return

;^MButton::
^]::
Menu, custom_menu, add, Hello, Item1 ;create a dummy menu item
Menu, custom_menu, DeleteAll
If(Name1 = "Divider" and Location1 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name1 <> "" and Location1 <> "")
{
Menu, custom_menu, add, %Name1%, Item1
}

If(Name2 = "Divider" and Location2 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name2 <> "" and Location2 <> "")
{
Menu, custom_menu, add, %Name2%, Item2
}

If(Name3 = "Divider" and Location3 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name3 <> "" and Location3 <> "")
{
Menu, custom_menu, add, %Name3%, Item3
}

If(Name4 = "Divider" and Location4 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name4 <> "" and Location4 <> "")
{
Menu, custom_menu, add, %Name4%, Item4
}

If(Name5 = "Divider" and Location5 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name5 <> "" and Location5 <> "")
{
Menu, custom_menu, add, %Name5%, Item5
}

If(Name6 = "Divider" and Location6 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name6 <> "" and Location6 <> "") 
{
Menu, custom_menu, add, %Name6%, Item6
}

If(Name7 = "Divider" and Location7 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name7 <> "" and Location7 <> "") 
{
Menu, custom_menu, add, %Name7%, Item7
}

If(Name8 = "Divider" and Location8 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name8 <> "" and Location8 <> "") 
{
Menu, custom_menu, add, %Name8%, Item8
}

If(Name9 = "Divider" and Location9 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name9 <> "" and Location9 <> "") 
{
Menu, custom_menu, add, %Name9%, Item9
}

If(Name10 = "Divider" and Location10 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name10 <> "" and Location10 <> "") 
{
Menu, custom_menu, add, %Name10%, Item10
}

If(Name11 = "Divider" and Location11 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name11 <> "" and Location11 <> "") 
{
Menu, custom_menu, add, %Name11%, Item11
}

If(Name12 = "Divider" and Location12 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name12 <> "" and Location12 <> "") 
{
Menu, custom_menu, add, %Name12%, Item12
}

If(Name13 = "Divider" and Location13 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name13 <> "" and Location13 <> "") 
{
Menu, custom_menu, add, %Name13%, Item13
}

If(Name14 = "Divider" and Location14 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name14 <> "" and Location14 <> "") 
{
Menu, custom_menu, add, %Name14%, Item14
}

If(Name15 = "Divider" and Location15 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name15 <> "" and Location15 <> "") 
{
Menu, custom_menu, add, %Name15%, Item15
}

If(Name16 = "Divider" and Location16 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name16 <> "" and Location16 <> "") 
{
Menu, custom_menu, add, %Name16%, Item16
}

If(Name17 = "Divider" and Location17 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name17 <> "" and Location17 <> "") 
{
Menu, custom_menu, add, %Name17%, Item17
}

If(Name18 = "Divider" and Location18 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name18 <> "" and Location18 <> "") 
{
Menu, custom_menu, add, %Name18%, Item18
}

If(Name19 = "Divider" and Location19 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name19 <> "" and Location19 <> "") 
{
Menu, custom_menu, add, %Name19%, Item19
}

If(Name20 = "Divider" and Location20 = "Divider")
{
Menu, custom_menu, add,
}
else
If(Name20 <> "" and Location20 <> "") 
{
Menu, custom_menu, add, %Name20%, Item20
}

If(Name1 = "" and Name2 = "" and Name3 = "" and Name4 = "" and Name5 = "" and Name6 = "" and Name7 = "" and Name8 = "" and Name9 = "" and Name10 = "" and Name11 = "" and Name12 = "" and Name13 = "" and Name14 = "" and Name15 = "" and Name16 = "" and Name17 = "" and Name18 = "" and Name19 = "" and Name20 = "")
{
Msgbox,,Custom Menu, Select Settings in the tray menu to create your custom menu.
}
else
{
Menu, custom_menu, add,
Menu, custom_menu, add, Cancel, Cancel
Menu, custom_menu, show
}
return

ITEM1:
Run, %Location1%
return

ITEM2: 
Run, %Location2%
return

ITEM3: 
Run, %Location3%
return

ITEM4: 
Run, %Location4%
return

ITEM5: 
Run, %Location5%
return

ITEM6: 
Run, %Location6%
return

ITEM7: 
Run, %Location7%
return

ITEM8: 
Run, %Location8%
return

ITEM9: 
Run, %Location9%
return

ITEM10: 
Run, %Location10%
return

ITEM11: 
Run, %Location11%
return

ITEM12: 
Run, %Location12%
return

ITEM13: 
Run, %Location13%
return

ITEM14: 
Run, %Location14%
return

ITEM15: 
Run, %Location15%
return

ITEM16: 
Run, %Location16%
return

ITEM17: 
Run, %Location17%
return

ITEM18: 
Run, %Location18%
return

ITEM19: 
Run, %Location19%
return

ITEM20: 
Run, %Location20%
return

CANCEL:
Menu, custom_menu, DeleteAll
return

SETTINGS:
GoSub, INI
Gui, 1: Destroy
Gui, 1: Font, s12 bold italic, Arial
Gui, 1: Add, Text,,Enter Divider for Name and Location to create a division in the menu ...
Gui, 1: Font, s12 norm, Arial
Gui, 1: Add, ListView,AltSubmit -Multi h100 w530 vListView gEDITSETTINGS,Name|Location

RowNumber = 1
Loop
{
IniRead, LineText, Menu.ini, Settings, %RowNumber%
If LineText=Error
{
break
}
else
{
StringSplit,Col,LineText,`,
Name:=Col1
Location:=Col2
LV_Add("",Name,Location)
RowNumber ++ 1
}
}
LV_ModifyCol(1, "AutoHdr")
LV_ModifyCol(2, 375)
LV_Modify(1, "Select Focus")

If LV_GetCount() = 0
{
LV_Add("","","")
}


Gui, 1: Font, s12 bold, Arial
Gui, 1: Add, Text,x18 y150,Name:
Gui, 1: Font, s12 norm, Arial
Gui, 1: Add, Edit, w150 vName gEDITED
Gui, 1: Font, s12 bold, Arial
Gui, 1: Add, Text,x188 y150,Location:
Gui, 1: Font, s12 norm, Arial
Gui, 1: Add, Edit, w150 vLocation gEDITED
Gui, 1: Font, s12 norm, Arial
Gui, 1: Add, Button, w80 x375 y176 h28 gNEWSHORTCUT, Insert
Gui, 1: Add, Button, w80 x465 y176 h28 gDELETESHORTCUT, Delete
Gui, 1: Add, Button, w150 x18 y220 h28 gSAVESETTINGS, OK
Gui, 1: Add, Button, w150 x188 y220 h28 gCANCELSETTINGS, Cancel
Gui, 1: Show,, Settings

RowNumber := LV_GetNext(0, S)
If RowNumber <> 0
{
LV_GetText(Name,RowNumber,1)
LV_GetText(Location,RowNumber,2)
GuiControl,,Name, %Name%
GuiControl,,Location, %Location%
}
return

EDITSETTINGS:
if (A_GuiEvent = "Normal" or A_GuiEvent = "K")
{
RowNumber := LV_GetNext(0, S)
if (RowNumber <> 0)
{
LV_GetText(Name,RowNumber,1)
LV_GetText(Location,RowNumber,2)
GuiControl,,Name, %Name%
GuiControl,,Location, %Location%
}
}
return

EDITED:
Gui, 1: Submit, NoHide
LV_Modify(RowNumber, "", Name, Location)
return

NEWSHORTCUT:
RowNumber := LV_GetNext(0) + 1
TotalRows := LV_GetCount()
If TotalRows <20
{
LV_Insert(RowNumber,"Select","","")
LV_Modify(RowNumber, "Vis Select Focus")
GuiControl,,Name,
GuiControl,,Location,
GuiControl, Focus, Name
}
else
{
Msgbox,,Keyboard Menu,You can add a maximum of 20 items to your Custom Menu.
LV_Modify(RowNumber-1, "Select Focus")
GuiControl, Focus, ListView
If RowNumber<>1
{
Send,{Up}{Down}
}
else
{
Send,{Down}{Up}
}
GuiControl, Focus, Name
}
return

DELETESHORTCUT:
RowNumber := LV_GetNext(0)
LV_Delete(RowNumber)
If RowNumber<>1
{
RowNumber -- 1
}
LV_Modify(RowNumber, "Select Focus")
GuiControl, Focus, ListView
If RowNumber<>1
{
Send,{Up}{Down}
}
else
{
Send,{Down}{Up}
}
GuiControl, Focus, Name
return

SAVESETTINGS:
RowNumber = 1
Loop % LV_GetCount()
{
LV_GetText(Name, RowNumber, 1)
LV_GetText(Location, RowNumber, 2)
IniWrite,%Name%`,%Location%,Menu.ini,Settings,%RowNumber%
RowNumber ++ 1
}
Loop
{
if RowNumber>20
{
break
}
else
{
IniDelete,Menu.ini,Settings,%RowNumber%
RowNumber ++ 1
}
}
Gui, 1: Destroy
GoSub, INI
return

CANCELSETTINGS:
Gui, 1: Destroy
return

EXIT:
ExitApp

ABOUT:
Gui, 3: Destroy
Gui, 3: Font, s13 bold, Arial
Gui, 3: Add,text,, Keyboard Menu
Gui, 3: Font, s11 bold, Arial
Gui, 3: Add,text,xm ym+20,by David Barnes
Gui, 3: Font, s10 norm, Arial
Gui, 3: Add,text,xm ym+50, Add up to 20 items to your Custom `nMenu, to launch your favourite folders, `nprograms and webpages.
Gui, 3: Add,text,xm ym+120, Menu customisable via the tray menu
Gui, 3: Add,text,xm ym+150, For more great software, be sure to visit:
Gui, 3: Font, cBlue bold underline
Gui, 3: Add,text,xm ym+170 GSOFTWAREGUIDER, www.softwareguider.110mb.com
Gui, 3: Color, White
Gui, 3: Show,, Keyboard Menu
return

SOFTWAREGUIDER:
run, www.softwareguider.110mb.com
return