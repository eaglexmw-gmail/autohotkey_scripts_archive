; Custom Menu by SoftwareGuider
; modified by Drugwash
; Provides a user-customized menu
; at the mouse cursor position
;*****************************************
appname = Custom Menu		; application name
version = 1.0.1				; version number
release = February 18, 2009		; release date
type = internal				; release type (internal / public)
iconlocal = %A_ScriptDir%\custom_menu.ico	; external icon for uncompiled script
debug = 0					; debug switch (1 = active)
; *****************************************

ahklink = http://www.autohotkey.com
winname = Custom Menu Settings

#singleinstance ignore
SetWorkingDir %A_ScriptDir%
IfExist, %iconlocal%
	Menu, TRAY, Icon, %iconlocal%,,1

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
^]::	; personal preference since I got middle-click as double-click for my Logitech mouse
Menu, custom_menu, add, Hello, Item1 ;create a dummy menu item
Menu, custom_menu, DeleteAll
Loop, %RowNumber%
	{
	If(Name%A_Index% = "Divider" and Location%A_Index% = "Divider")
		Menu, custom_menu, add,
	else
		If(Name%A_Index% <> "" and Location%A_Index% <> "")
			{
			NameX := Name%A_Index%
			Menu, custom_menu, add, %NameX%, Item%A_Index%
			}
	}
items =
Loop, %RowNumber%
	{
	items := items . Name%A_Index%
	}
if debug
	MsgBox, items=%items%
If !items
	Msgbox,,Custom Menu, Select Settings in the tray menu to create your custom menu.
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
Gui, 1:Add, Text, x7 y7 w130 h14, File/folder path or URL:
Gui, 1:Add, Edit, x7 y23 w340 h24 vLocation gEDITED
Gui, 1:Add, Text, x7 y48 w100 h14, Menu item name:
Gui, 1:Add, Edit, x6 y64 w190 h24 vName gEDITED
Gui, 1: Add, ListView, AltSubmit -Multi -LV0x10 NoSortHdr x205 y64 w210 h215 vListView gEDITSETTINGS, Name|Location

RowNumber = 1
Loop
{
IniRead, LineText, Menu.ini, Settings, %RowNumber%
If LineText=Error
	break
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
LV_ModifyCol()
Gui, 1:Add, Button, x347 y23 w70 h24, Browse
Gui, 1:Add, Button, x96 y96 w100 h30 gNEWSHORTCUT, Insert
Gui, 1:Add, Button, x96 y136 w100 h30 gDELETESHORTCUT, Remove
Gui, 1:Add, Button, x96 y176 w100 h30 gDIVIDER, Insert separator
if ! A_IsCompiled
	Gui, 1:Add, Picture, x7 y96 w85 h85, %iconlocal%
else
	Gui, 1:Add, Picture, x7 y96 w85 h85 Icon1, %A_ScriptName%
;Gui, 1:Add, Pic, x7 y96 w85 h85, %iconlocal%
Gui, 1:Add, Button, x96 y216 w100 h30 gSAVESETTINGS, OK
Gui, 1:Add, Button, x96 y250 w100 h30 gCANCELSETTINGS, Cancel
Gui, 1:Add, Text, cBlue x7 y223 w86 h16 Center gGOAHK, AutoHotkey
Gui, 1:Add, Text, cBlue x7 y257 w88 h16 Center gABOUT, About...
Gui, 1:Show, x335 y300 h286 w424, %winname%

RowNumber := LV_GetNext(0, S)
If RowNumber <> 0
{
LV_GetText(Name,RowNumber,1)
LV_GetText(Location,RowNumber,2)
GuiControl,,Name, %Name%
GuiControl,,Location, %Location%
}

if ! hCurs
	{
	hCurs := DllCall("LoadCursor", "UInt", NULL, "Int", 32649, "UInt") ;IDC_HAND
	OnMessage(0x200, "WM_MOUSEMOVE")
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

ButtonBrowse:
FileSelectFile, myfile, 3,, Please select a file for the current menu item:
if !myfile
	MsgBox, Please select a file for the current menu item!
else
	GuiControl,, Location, %myfile%
return

DIVIDER:
gosub NEWSHORTCUT
GuiControl,,Name, Divider
GuiControl,,Location, Divider

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
gosub CANCELSETTINGS
GoSub, INI
return

CANCELSETTINGS:
Gui, 1: Destroy
IfWinNotExist, %winname%
	{
	OnMessage(0x200,"")
	DllCall("DestroyCursor", "Uint", hCurs)
	}
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

GOAHK:
Run, %ahklink%,, UseErrorLevel
return

SOFTWAREGUIDER:
run, www.softwareguider.110mb.com
return

WM_MOUSEMOVE(wParam, lParam)
{
Global hCurs, winname
WinGetTitle, wind
MouseGetPos,,, winid, ctrl
; change StaticX below to suit the actual window(s)
if wind in %winname%
	if ctrl in Static4,Static5
		DllCall("SetCursor", "UInt", hCurs)
return
}
