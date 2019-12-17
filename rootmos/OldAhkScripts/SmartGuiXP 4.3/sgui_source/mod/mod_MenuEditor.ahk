oldSCS := A_StringCaseSense
StringCaseSense, Off
if w9x
	Hotkey9x("LD", "Off")
if !EditMenuGUI
	{
	oldWMsetcursor := OnMessage(0x20, "cursor")		; WM_SETCURSOR
	oldWMNotify := OnMessage(0x4E, "TVX_msg")		; WM_NOTIFY
	oldWMmouse := OnMessage(0x200, "TVX_drag")		; WM_MOUSEMOVE
	oldWMlbup := OnMessage(0x202, "TVX_drop")		; WM_LBUTTONUP
	oldWMsizing := OnMessage(0x214, "TVX_resize")		; WM_SIZING
	isMenuEditor := "parseMenu"
	mouseinmenu := "mim"
;========== TreeView/Menu stuff ===========
VarSetCapacity(TVHITTESTINFO, 16, 0)	; TVHITTESTINFO struct: POINT pt|UInt flags|UInt hItem
sstr = <------------------>		; separator string
menutemp = SGUIMenu.ini		; Menu temporary file
res = 23|24|21|25				; TreeView icons order
hTVIL := IL_Create(4, 1, 0)		; TreeView imagelist small icons
LogFile("TreeView small ImageList handle: " hTVIL, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Create TreeView small ImageList (hTVIL)", debugout)
hTVILL := IL_Create(4, 1, 1)		; TreeView imagelist large icons
LogFile("TreeView large ImageList handle: " hTVILL, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Create TreeView large ImageList (hTVILL)", debugout)
TVILtoggle=0					; switch for small icons -> large icons, in Menu editor
TVitemIdx = 1					; initialize TreeView item count
resizeMargin = 4				; resize margin
customSize = 1				; use custom resize margin
Loop, Parse, res, |
	{
	IL_Add(hTVIL, icons, A_LoopField)
	IL_Add(hTVILL, icons, A_LoopField)
	}
hCursZ := DllCall("LoadCursor", "UInt", NULL, "Int", 32644, "UInt")		; IDC_SIZEWE
hCursV := DllCall("LoadCursor", "UInt", NULL, "Int", 32645, "UInt")		; IDC_SIZENS
hCursTL := DllCall("LoadCursor", "UInt", NULL, "Int", 32642, "UInt")		; IDC_SIZENWSE
hCursTR := DllCall("LoadCursor", "UInt", NULL, "Int", 32643, "UInt")		; IDC_SIZENESW
hCursA := DllCall("LoadCursor", "UInt", NULL, "Int", 32512, "UInt")		; IDC_ARROW
DllCall("comctl32\ImageList_AddIcon", "UInt", hTVIL, "UInt", hCursA)
DllCall("comctl32\ImageList_AddIcon", "UInt", hTVIL, "UInt", hCursN)
DllCall("comctl32\ImageList_AddIcon", "UInt", hTVIL, "UInt", hCursH)
DllCall("comctl32\ImageList_AddIcon", "UInt", hTVILL, "UInt", hCursA)
DllCall("comctl32\ImageList_AddIcon", "UInt", hTVILL, "UInt", hCursN)
DllCall("comctl32\ImageList_AddIcon", "UInt", hTVILL, "UInt", hCursH)
DllCall("DestroyCursor", "UInt", hCursA)
;DllCall("DestroyCursor", "UInt", hCursN)
;DllCall("DestroyCursor", "UInt", hCursH)
hCurs10 := hCurs11 := hCursZ
hCurs12 := hCurs15 := hCursV
hCurs13 := hCurs17 := hCursTL
hCurs14 := hCurs16 := hCursTR

	Gui, 10:+ToolWindow -Caption +Border
;	if !w9x
;		Gui, 10:+Resize
	Gui, 10:+MinSize232x332 +MaxSize650x700
	Gui, 10:Margin, 0, 0
	Gui, 10:Font, s8 cDefault Norm, Tahoma
	Gui, 10:Color, White, White
	Gui, 10:Add, Edit, x86 y5 w140 h20 BackgroundTrans vmenuname gkilltip, %CtrlText%
	Gui, 10:Add, ListView, x86 y27 w40 h20 -E0x200 +Border -hdr +ReadOnly Report Background%MenuCol% Hidden AltSubmit hwndhLVMC vMenuCol gsetColors, M
; TVS_EX_AUTOHSCROLL TVS_EX_DOUBLEBUFFER TVS_EX_RICHTOOLTIP TVS_INFOTIP TVS_NONEVENHEIGHT
	Gui, 10:Add, TreeView, x6 y48 w220 h203 ImageList%hTVIL% AltSubmit -Buttons -Lines -ReadOnly +0x4820 +E0x14  gTVaction vmenuTV,
	Gui, 10:Add, Button, x15 y265 w100 h20, Add item
	Gui, 10:Add, Button, x15 y289 w100 h20, Add subitem
	Gui, 10:Add, Button, x117 y265 w100 h20, Add separator
	Gui, 10:Add, Button, x117 y289 w100 h20, Delete
	Gui, 10:Add, ComboBox, x89 y314 w130 h21 r5 Sort vTVlabel gTVlabelEdit, testlabel|| |
	Gui, 10:Add, Hotkey, x89 y338 w130 h20 vTVXhk gTVX_hk,
	Gui, 10:Add, Button, x15 y363 w100 h24, OK
	Gui, 10:Add, Button, x117 y363 w100 h24, Cancel
	Gui, 10:Add, Picture, x0 y0 w232 h400 0x400000E hwndhPic10 vsk10 gmoveit,
	hBSkin10 := ILC_FitBmp(hPic10, skin, cSkin)
	LogFile("GUI10 skin handle: " hBSkin10, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Create GUI10 skin (hBSkin10)", debugout)
	Gui, 10:Add, GroupBox, x6 y252 w220 h142 BackgroundTrans +0x8000,
	Gui, 10:Add, Text, x6 y7 w77 h16 +0x200 +Right BackgroundTrans, Menu name :
	Gui, 10:Font, s16 c0xFF0000 w400, Wingdings
	Gui, 10:Add, Text, x6 y27 w18 h22 +0x200 +BackgroundTrans vMO1 gToggleMC, û
	Gui, 10:Add, Text, x208 y27 w18 h22 +0x200 +BackgroundTrans Hidden vMO2 gToggleMC, û
	Gui, 10:Font, s8 cDefault Norm, Tahoma
	Gui, 10:Add, Text, x24 y27 w59 h22 +0x200 +Right BackgroundTrans, Menu color :
	Gui, 10:Add, Text, x129 y27 w77 h22 +0x200 +Right BackgroundTrans Hidden, same as GUI
	Gui, 10:Add, Text, x15 y316 w72 h16 +Right +0x200 BackgroundTrans, goto Label :
	Gui, 10:Add, Text, x15 y340 w72 h16 +Right +0x200 BackgroundTrans, Hotkey :
	WinGetPos,,, i,, ahk_id %wpID%
	Gui, 10:Show, % "x" i-238 " y2 w232 h" 402+WinDiffH-WinDiffW " Hide", Menu add/edit
	Gui, 10:+LastFound
	WinGet, hGui10, ID, Menu add/edit
	LogFile("GUI10 handle: " hGui10, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Get GUI10 handle (hGui10)", debugout)
	DllCall("SetParent", "UInt", hGui10, "UInt", wpID)
	hGuis .= "," hGui10
	EditMenuGUI = 1
	ControlGet, hTVmenu, Hwnd,, SysTreeView321, ahk_id %hGui10%
	LogFile("TreeView handle: " hTVmenu, A_LineNumber, A_LineFile, A_ThisLabel, A_ThisFunc, "Get TreeView handle (hTVmenu)", debugout)
	TVX_resize("", "", "", hGui10)
	}
if !uglyHack
	Gui, 10:Show
Gui, 10:Default
ControlGetPos, TVcx, TVcy, TVcw, TVch,, ahk_id %hTVmenu%
If !TV_GetCount()
	sID := TV_Add("Item" TVitemIdx, 0, "Vis Expand Icon3")
TV_Modify(sID, "Select")
TVchkvalid(sID)
TVrefresh()
uglyHack=
return
;**********************************************
10GuiContextMenu:
if (A_GuiControl <> "menuTV")
	return
TVILtoggle := TVILtoggle = 2 ? 0 : ++TVILtoggle
DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x1109, "UInt", 0, "UInt", (TVILtoggle & 0x1) ? 0 : (TVILtoggle & 0x2 ? hTVILL : hTVIL))
DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x1107, "UInt", 16, "UInt", 0)	; TVM_SETINDENT
GuiControl, % "10:" (TVILtoggle & 0x1 ? "+Lines +Buttons" : "-Lines -Buttons"), menuTV
return
;**********************************************
10GuiEscape:
dragged=
TVX_Cleanup(hTVmenu, hTVdragIL)
return
;**********************************************
10ButtonAdditem:
TVitemIdx++
TVX_Add("Item" TVitemIdx, "0", "Select")
return

10ButtonAddsubitem:
TVitemIdx++
TVX_Add("Item" TVitemIdx, "1", "Select")
return

10ButtonAddseparator:
TVitemIdx++
TVX_Add(sstr, "2", "Select")
return

10ButtonDelete:
TVX_Delete()
return
;**********************************************
10ButtonOK:
Gui, 10:Submit, NoHide
ToolTip,,,, 4
TVrefresh()
if debug
	{
	all := TV_GetCount()
	FileDelete, %menutemp%
	FileDelete, params.txt
	IniWrite, %menuname%, %menutemp%, Data, Name
	IniWrite, %TVsl%, %menutemp%, Data, Separators
	IniWrite, (%all%) -> %TVnl%, %menutemp%, Data, Items
	IniWrite, (%idx%) -> %stg%, %menutemp%, Data, Last moved items
	Run, %menutemp%
	}
xID=0
Loop
	{
	xID := TV_GetNext(xID, "Full")
	if !xID
		break
	if (!TV_GetChild(xID) && !L%xID% && !InStr(TVsl, xID Chr(160)))
		{
		TV_Modify(xID, "Select VisFirst Bold")
		; find selected item position and pass it to ToolTip
		VarSetCapacity(RECT, 16, 0)
		NumPut(xID, RECT, 0, "UInt")
		DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x1104, "UInt", 0x1, "UInt", &RECT)	; TVM_GETITEMRECT
		x := NumGet(RECT, 0, "Int")
		y := NumGet(RECT, 4, "Int")
		ControlGetPos, TVx, TVy,,,, ahk_id %hTVmenu%
		x += TVx+25
		y += TVy-5
		Tooltip, «« Selected item has no label assigned !, %x%, %y%, 4
		return
		}
	}
MenuGenerated = 1
Ctrl2Add = Menu
CtrlName = Menu
CtrlCount = 1
CtrlText = %menuname%
if !menuname
	{
	ControlGetPos, x, y,,, Edit1, ahk_id %hGui10%
	x += 25
	y -= 14
	Tooltip,  `n«« Please assign a name to this Menu !`n , %x%, %y%, 4
	return
	}
TV_Delete()
TV_AddBranch(TVnl, "0")
TV_Modify(new, "Select")
TVrefresh()
; we need to write Menu color too
i := MO1 ? (MO2 ? defGC : MenuCol) : ""
gosub write2ini
if debug
	run, %iniWork%
;****************************
if menuStrOld
	{
	if debug
		{
		Menu, %oldmenuname%_test, UseErrorLevel, Off
		}
	else
		Menu, %oldmenuname%_test, UseErrorLevel, On
	Gui, 1:Menu
	StringReplace, menuStrOld, menuStrOld, `,%A_Space%, `, , A
	Loop, Parse, menuStrOld, `n
		{
		StringSplit, par, A_LoopField, `,
		if InStr(par5, ":") = 1
			{
			StringTrimLeft, par5, par5, 1
			Menu, %par5%_test, DeleteAll
			Menu, %par5%_test, Delete
			par5 =
			}
		}
	Menu, %oldmenuname%_test, DeleteAll
	Menu, %oldmenuname%_test, Delete
	}
;****************************
StringReplace, menuStr, menuStr, `,%A_Space%, `, , A
StringTrimRight, menuStrTemp, menuStr, 1
if debug
	{
	msgbox, %menuStrTemp%`n•END MENU•
	Menu, %menuname%_test, UseErrorLevel, Off
	}
else
	Menu, %menuname%_test, UseErrorLevel, On
Loop, Parse, menuStrTemp, `n
	{
	StringSplit, par, A_LoopField, `,
; we use the 'testlabel' trick to avoid 'nonexistant label' errors
if (SubStr(par5, 1, 1) = ":")
	Menu, %par2%_test, Add, %par4%, %par5%_test
else
	Menu, %par2%_test, Add, %par4%, testlabel
	par4 =
	par5 =
	}
Gui, 1:Menu, %menuname%_test
;i := MO1 ? (MO2 ? defGC : MenuCol) : ""
Menu, %menuname%_test, Color, %i%
Menu, ControlMenu2, Enable, Main menu
menuStrTemp=
menuStrOld=%menuStr%
oldmenuname=%menuname%
MenuVis=1
;****************************
10ButtonCancel:
CtrlText=
Ctrl2Add=
CtrlName=
StringCaseSense, %oldSCS%
if w9x
	Hotkey9x("LD", "On")
Gui, 1:Default
Gui, 10:Submit
killtip:
ToolTip,,,, 4
return
;**********************************************
testlabel:
MsgBox, Menu test label was launched from %A_ThisMenu% > %A_ThisMenuItem%.
return
;**********************************************
parseMenu:
		StringTrimRight, mStr, mStr, 1
		Loop, Parse, mStr, |
			str := TVtl%A_LoopField% str
		TVtl := TVml str
		StringTrimRight, TVtl, TVtl, 1
; need to remove from TVtl the items that do not belong to the unique loaded Menu
		str := CtrlText
		Loop, Parse, TVtl, |
			{
			StringSplit, i, A_LoopField, % Chr(160)
				if i3 in %str%
					if InStr(i7, ":") = 1
						str .= "," SubStr(i7, 2)
			}
		Loop, Parse, TVtl, |
			{
			StringSplit, i, A_LoopField, % Chr(160)
				if i3 not in %str%
					{
					StringReplace, TVtl, TVtl, %A_LoopField%
;					outsideMenu .= A_LoopField "`n"
					StringReplace, TVtl, TVtl, ||, |, All
					}
			}
		if InStr(TVtl, "|") = 1
			StringTrimLeft, TVtl, TVtl, 1
		if SubStr(TVtl, 0) = "|"
			StringTrimRight, TVtl, TVtl, 1
		if debug
			{
			FileDelete, allMenu.txt
			FileAppend, %CtrlText%`n`n%TVtl%, allMenu.txt
			run, allMenu.txt
			}
		SetEnv, CtrlName, Menu
		CtrlCount := ++%CtrlName%Count
		uglyHack=1
		MenuCol := Menu_%CtrlText%_color
		gosub EditMenu
		ClickedCtrl=Static3
		gosub ToggleMC
		TV_Delete()
		TVX_Populate(TVtl)
		gosub 10ButtonOK
;		GuiScript := MenuScript GuiScript	; add Menu commands before any GUI command
return
;**********************************************
ToggleMC:
StringReplace, i, ClickedCtrl, Static,
i-=(2+2*(i>4))
MO%i% := !MO%i%
Gui, 10:Font, % "s16 " (MO%i% ? "c0x0000FF" : "c0xFF0000") " w400", Wingdings
GuiControl, 10:Font, % "Static" i+2
GuiControl, 10:, % ("Static" i+2), % (MO%i% ? "ü" : "û")
Gui, 10:Font
GuiControl, % "10:" (MO1 && !MO2 ? "Show" : "Hide"), SysListView321
GuiControl, % "10:" (MO1 ? "Show" : "Hide"), Static4
GuiControl, % "10:" (MO1 ? "Show" : "Hide"), Static6
return
;**********************************************
TVaction:
ifEqual, A_GuiEvent, E
	if InStr(TVsl, A_EventInfo Chr(160))
		DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x1116, "UInt", 0, "UInt", 0)	; TVM_ENDEDITLABELNOW block separator label editing
IfEqual, A_GuiEvent, +
	TV_Modify(A_EventInfo, "Icon2")
 IfEqual, A_GuiEvent, -
	TV_Modify(A_EventInfo, "Icon1")
return
;**********************************************
TVlabelEdit:
Gui, Submit, NoHide
sID := TV_GetSelection()
; needs cleanup, maybe RegExReplace for non-alphanumeric chars
if !InStr(TVsl, sID Chr(160))	; for safety- separator selection disables the Label control anyway
	L%sID% = %TVlabel%
lastLabel = %TVlabel%
return
;**********************************************
TVlabelCheck:
ControlGet, i, FindString, %lastLabel%, ComboBox1, ahk_id %hGui10%
if !i
	GuiControl, 10:, ComboBox1, %lastLabel%

if (lastLabel != TVlabel && SubStr(TVlabel,1,1) != Chr(58))
	{
	ControlGet, i, FindString, %TVLabel%, ComboBox1, ahk_id %hGui10%
	if !i
		GuiControl, 10:, ComboBox1, %TVLabel%
; check if the label exists, first ; if it doesn't, mark it to be created by the script
; To be done in TVX_AddBranch()
	}
return
;**********************************************
TVupdateKL:
sID = %hTVsource%
TVchkvalid(sID)
If !InStr(TVsl, sID Chr(160))
	if !TV_GetChild(sID)
		{
		GuiControl, 10:, msctls_hotkey321, % K%sID%
		if !L%sID%
			{
			GuiControl, 10:ChooseString, ComboBox1, testlabel
			L%sID% = testlabel
			}
		else
			{
			gosub TVlabelCheck
			GuiControl, 10:ChooseString, ComboBox1, % "||" L%sID%
			}
		}
	else
		{
		GuiControl, 10:, msctls_hotkey321,
		GuiControl, 10:ChooseString, ComboBox1, ||%A_Space%
		}
return
;**********************************************
TVX_hk:
Gui, 10:Submit, NoHide
sID := TV_GetSelection()
if !InStr(TVsl, sID Chr(160))	; for safety- separator selection disables the Hotkey control anyway
	K%sID% = %TVXhk%
return
;**********************************************
InitMenu(p="")	; to be completed with something meaningful
{
if !p
	{
	OnMessage(0x20, "oldWMsetcursor")	; WM_SETCURSOR
	OnMessage(0x4E, "oldWMNotify")	; WM_NOTIFY
	OnMessage(0x200, "oldWMmouse")	; WM_MOUSEMOVE
	OnMessage(0x202, "oldWMlbup")	; WM_LBUTTONUP
	OnMessage(0x214, "oldWMsizing")	; WM_SIZING
	DllCall("DestroyCursor", "UInt", hCursZ)
	DllCall("DestroyCursor", "UInt", hCursV)
	DllCall("DestroyCursor", "UInt", hCursTL)
	DllCall("DestroyCursor", "UInt", hCursTR)
	}
}
;**********************************************
TVX_msg(wP, lP, msg, hwnd)
{
Global
Critical
Local info, mXdrag, mYdrag, ms
Static last=0, clk
if (oldWMNotify != A_ThisFunc)
	%oldWMNotify%(wP, lP, msg, hwnd)
ofi := A_FormatInteger
SetFormat, IntegerFast, H
hwnd+=0
if (hwnd != hGui10)
	{
	ToolTip,,,, 3
	SetFormat, Integer, %ofi%
	return
	}
oscs := A_StringCaseSense
StringCaseSense, Off
nc := NumGet(lP+8) & 0x00000000FFFFFFFF	; NMHDR code (beginning of structure)
ms := nc & 0x0000FFFF
SetFormat, IntegerFast, D
if !dragged
	{
	if (ms = 0xFFEF)	; NM_SETCURSOR
		clk := NumGet(lP+12)
	if (ms = 0xFFF4 && clk)	; NM_CUSTOMDRAW
		{
		hTVsource := clk
		clk=
		DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x07, "UInt", 0x9, "UInt", hTVsource)	; set focus to TreeView control
		DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x110B, "UInt", 0x9, "UInt", hTVsource)	; select item
		gosub TVupdateKL
		SetFormat, Integer, %ofi%
		StringCaseSense, %oscs%
		return
		}
	if (ms = 0xFE6E or ms = 0xFE3D)	; TVN_SELCHANGED A/W
		{
		oldH := hTVsource
		hTVsource := DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x110A, "UInt", 0x9, "UInt", 0)	; get selected item
		gosub TVupdateKL
		}
	}
if (ms = 0xFE69 or ms = 0xFE38)	; TVN_BEGINDRAG A/W
	{
	hCursA := DllCall("LoadCursor", "UInt", NULL, "Int", 32512, "UInt")	; Load the ARROW cursor
	hCursN := DllCall("LoadCursor", "UInt", NULL, "Int", 32648, "UInt")	; Load the NO cursor
	hCursH := DllCall("LoadCursor", "UInt", NULL, "Int", 32649, "UInt")	; Load the HAND cursor
	DllCall("ImageList_ReplaceIcon", "UInt", hTVIL, "Int", 4, "UInt", hCursA)
	DllCall("ImageList_ReplaceIcon", "UInt", hTVIL, "Int", 5, "UInt", hCursN)
	DllCall("ImageList_ReplaceIcon", "UInt", hTVIL, "Int", 6, "UInt", hCursH)
	DllCall("ImageList_ReplaceIcon", "UInt", hTVILL, "Int", 4, "UInt", hCursA)
	DllCall("ImageList_ReplaceIcon", "UInt", hTVILL, "Int", 5, "UInt", hCursN)
	DllCall("ImageList_ReplaceIcon", "UInt", hTVILL, "Int", 6, "UInt", hCursH)
	If TVILtoggle != 1
		DllCall("ShowCursor", "UInt", 0)	; hide cursor
	if !hTVdragIL := DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x1112, "UInt", 0, "UInt", hTVsource)	; TVM_CREATEDRAGIMAGE
		{
		VarSetCapacity(RC, 16, 0)
		NumPut(hTVsource, RC, 0, "UInt")
		if !DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x1104, "UInt", (TVILtoggle = "1" ? "1" : "0"), "UInt", &RC)	; TVM_GETITEMRECT (0=full row, 1=text only)
			DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x1104, "UInt", 0, "UInt", &RC)
		x1 := NumGet(RC, 0, "Int"), y1 := NumGet(RC, 4, "Int")
		x2 := NumGet(RC, 8, "Int"), y2 := NumGet(RC, 12, "Int")
		TViW := x2-x1
		TViH := y2-y1
		ControlGetPos, TVx, TVy, TVw, TVh,, ahk_id %hTVmenu%
		x := TVx+x1
		y := TVy+y1
		hDC := DllCall("GetDC", UInt, hTVmenu)
		hDCB := DllCall("CreateCompatibleDC", "UInt", hDC)
		hBM := DllCall("CreateCompatibleBitmap" , "UInt", hDC, "UInt", TViW, "UInt", TViH)
		hobm := DllCall("SelectObject", "UInt", hDCB, "UInt", hBM)
		DllCall("SetStretchBltMode", "UInt", hDCB, "Int", 3)
		DllCall("BitBlt", "UInt", hDCB, "Int", 0, "Int", 0, "Int", TViW, "Int", TViH, "UInt", hDC,  "Int", x1, "Int", y1, "UInt", 0x00CC0020)
		DllCall("SelectObject", "UInt", hDCB, "UInt", hobm)
		hTVdragIL := DllCall("ImageList_Create", "Int", TViW, "Int", TViH, "UInt", 0x19, "Int", 1, "Int", 1) ; initial 1 img, grow 1 ILC_MASK ILC_COLOR24
		indx := DllCall("ImageList_Add", "UInt", hTVdragIL, "UInt", hBM, "UInt", 0, "Int")
		DllCall("DeleteObject", "UInt", hBM)
		DllCall("DeleteDC", "UInt", hDCB)
		DllCall("ReleaseDC", "UInt", hTVmenu, "UInt", hDC)
		}
	If TVILtoggle != 1
		DllCall("ImageList_SetDragCursorImage", "UInt", hTVILL, "Int", 6, "Int", 0, "Int", 0)
	DllCall("ImageList_BeginDrag", "UInt", hTVdragIL, "Int", 0, "Short", 0, "Short", 0)
	MouseGetPos, mXdrag, mYdrag
	DllCall("ImageList_DragEnter", "UInt", hTVmenu, "Int", mXdrag-TVcx, "Int", mYdrag-TVcy)
	DllCall("SetCapture", "UInt", hwnd)
	If TVILtoggle = 1
		{
		DllCall("SetCursor", "UInt", hCursH)
;		DllCall("ShowCursor", "UInt", 1)	; show cursor
		}
	DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x1125, "UInt", 0, "UInt", 0xFF8830)	; set insertmark color
	dragged = 1
	SetFormat, Integer, %ofi%
	StringCaseSense, %oscs%
	return 1
	}
if (ms = 0xFE66 or ms = 0xFE35)	; TVN_BEGINLABELEDIT A/W
	{
	hEdit := DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x110F, "UInt", 0, "UInt", 0)
	DllCall("SendMessage", "UInt", hEdit, "UInt", 0xC5, "UInt", 15, "UInt", 0)	; limit item titles to 15 chars
	}
SetFormat, Integer, %ofi%
StringCaseSense, %oscs%
}
;**********************************************
TVchkvalid(sID)
{
Global TVsl
pID := TV_GetParent(sID)
nID := TV_GetNext(sID)
cID := TV_GetChild(sID)
If InStr(TVsl, sID Chr(160))
	{
	GuiControl, 10:Disable, Button2
	GuiControl, 10:Disable, Button3
	}
else if ((!pID && !cID) OR (nID && InStr(TVsl, nID Chr(160))))
	{
	GuiControl, 10:Enable, Button2
	GuiControl, 10:Disable, Button3
	}
else
	{
	GuiControl, 10:Enable, Button2
	GuiControl, 10:Enable, Button3
	}
GuiControl, % "10:" (pID && !cID && !InStr(TVsl, sID Chr(160)) ? "Enable" : "Disable"), msctls_hotkey321
GuiControl, % "10:" (pID && !cID && !InStr(TVsl, sID Chr(160)) ? "Enable" : "Disable"), ComboBox1
GuiControl, % "10:" (!pID && !nID && !TV_GetPrev(sID) ? "Disable" : "Enable"), Button4
}
;**********************************************
TVX_Add(name, t="0", opt="")	; 0=item, 1=subitem, 2=separator
{
Global
Local sID, pID, nID, sep
sID := TV_GetSelection()
pID := TV_GetParent(sID)
if t=0
	nID := TV_Add(name, pID, sID " Icon3 " opt)
else if t=1
	{
	if InStr(TVsl, sID Chr(160))
		return
	nID := TV_Add(name, sID, opt " Icon3")
	TV_Modify(sID, "Expand Icon2")
	}
else if t=2
	{
	if !pID
		TV_Modify(sID, "Expand Icon2")
	sep := TV_Add(name, (pID ? pID : sID), (pID ? sID : "") " Icon4 " opt)
	TVsl .= sep Chr(160) "|"
	}
if t < 2
	{
	GuiControl, 10:, msctls_hotkey321, % K%nID%
	TVlabel := "testlabel"
	L%nID% := "testlabel"
	gosub TVlabelCheck
	GuiControl, 10:ChooseString, ComboBox1, % "||" L%nID%
	}
TVrefresh()
GuiControl, 10:+Redraw, SysTreeView321
}
;**********************************************
TVX_Delete(sID="")
{
if !sID
	sID := TV_GetSelection()
pID := TV_GetParent(sID)
nID := TV_GetNext(sID, "Full")
vID := TV_GetPrev(sID)
if vID
	{
	xID := vID
	Loop
		{
		oID := xID
		xID := TV_GetNext(xID, "Full")
		if (xID = sID)
			break
		}
	vID := oID
	}
nID := nID ? nID : (vID ? vID : pID)
TVchkvalid(sID)
TV_Delete(sID)
;== NOT SURE ==
K%sID%=
L%sID%=
;============
TV_Modify(nID, "Select")
TV_Modify(pID, "Icon" (TV_GetChild(pID) ? "2" : "3" ))
TVrefresh()
GuiControl, 10:+Redraw, SysTreeView321
}
;**********************************************
TVrefresh()
{
Global
Local xID, iText, ip, pi, ii, allow
xID = 0
TVnl=
TVsl=
menuLabels=
Loop
	{
	xID := TV_GetNext(xID, "Full")
	if not xID
		break
	MenuName%xID%=
	TV_GetText(iText, xID)
	ip := TV_GetParent(xID)
	pi := TV_GetPrev(xID)
	ii := TV_GetItemInfo(hTVmenu, xID, "7")	; get icon index
;=== NOT SURE ===
	if TV_GetChild(xID)
		{
		K%xID%=
		L%xID%=
		}
	GuiControl, 10:ChooseString, ComboBox1, % "||" L%xID%
	GuiControl, 10:, msctls_hotkey321, % K%xID%
;=============
	if L%xID%
		IfNotInString, menuLabels, % L%xID% "|"
			menuLabels .= L%xID% "|"
	TVnl .= iText Chr(160) xID Chr(160) ip Chr(160) pi Chr(160) ii Chr(160) K%xID% Chr(160) L%xID% Chr(160) "|"
	if (iText = sstr)
		TVsl .= xID Chr(160) "|"
	}
StringTrimRight, TVnl, TVnl, 1
StringTrimRight, TVsl, TVsl, 1
allow=1
xID=0
Loop
	{
	xID := TV_GetNext(xID)
	if not xID
		break
	if !TV_GetChild(xID)
	allow=0
	}
GuiControl, % "10:" (allow ? "Enable" : "Disable"), Button5
}
;**********************************************
TV_GetItemInfo(hT, hI, fld="7")	; field 7=icon
{
Static strg
Global debug
VarSetCapacity(TVITEM, 40, 0)		; TVITEM struct
VarSetCapacity(strg, 256, 0)
mask := 0x40 | 0x2 | 0x20 | 0x8 | 0x1 | 0x4 ; TVIF_CHILDREN|TVIF_IMAGE|TVIF_SELECTEDIMAGE|TVIF_STATE|TVIF_TEXT|TVIF_PARAM
NumPut(mask, TVITEM, 0, "UInt")		; mask
NumPut(hI, TVITEM, 4, "UInt")		; handle
NumPut(&strg, TVITEM, 16, "UInt")	; string pointer
NumPut(255, TVITEM, 20, "Int")		; string max size
DllCall("SendMessage", "UInt", hT, "UInt", 0x110C, "UInt", 0, "UInt", &TVITEM)	; TVM_GETITEMA
VarSetCapacity(strg, -1)
if fld=5
	return strg
else if fld
	return NumGet(TVITEM, (fld-1)*4, "Int")
if debug
	{
	p := "UInt mask|UInt item|UInt state|UInt statemask|UInt txt|Int strlen|Int image|Int selimage|Int children|Int lParam"
	Loop, Parse, p, |
		st .= A_LoopField "=" NumGet(TVITEM, (A_Index-1)*4, "UInt") "`n"
	msgbox, %st%`nName: %strg%
	}
}
;**********************************************
TVX_drag(wP, lP, msg, hwnd)
{
Global
Critical
Static oldht=0, deny=0, mXdrag, mYdrag, prev
if (oldWMmouse != A_ThisFunc)
	%oldWMmouse%(wP, lP, msg, hwnd)
if getcurs("Static1", TVcursor, resizeMargin) && !dragged
	DllCall("SetCursor", "UInt", hCurs%TVcursor%)
if !dragged
	return
if GetKeyState("Esc", "P")
	 return, dragged := TVX_cleanup(hTVmenu, hTVdragIL)
MouseGetPos, mXdrag, mYdrag
mXdrag -= TVcx
mYdrag -= TVcy
NumPut(mXdrag, TVHITTESTINFO, 0, "Short")
NumPut(mYdrag, TVHITTESTINFO, 4, "Short")
hTVtarget := DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x1111, "UInt", 0, "UInt", &TVHITTESTINFO)	; hit test
DllCall("comctl32\ImageList_DragMove", "Int", mXdrag, "Int", mYdrag)
DllCall("comctl32\ImageList_DragShowNolock", "UInt", 0)
if ((mYdrag < 0) OR (mYdrag > TVch) OR (mXdrag < 0) OR (mXdrag > TVcw)) && !TVout
	{
	DllCall("SetCursor", "UInt", hCursN)
	if TVILtoggle != 1
		DllCall("ShowCursor", "UInt", 1)	; show cursor
	TVout=1
	}
else if mXdrag between 0 and %TVcw%
	if mYdrag between 0 and %TVch%
		if TVout
			{
			if TVILtoggle = 1
				DllCall("SetCursor", "UInt", hCursH)
			else
				{
				DllCall("SetCursor", "UInt", hCursA)
				DllCall("ShowCursor", "UInt", 0)	; hide cursor
				}
			TVout=
			}
if mYdrag <= 0
	DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x115, "UInt", 0, "UInt", 0) 	; scroll up
else if (mYdrag >= TVch)
	DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x115, "UInt", 1, "UInt", 0)	; scroll down
if mXdrag <= 0
	DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x114, "UInt", 0, "UInt", 0)	; scroll left
else if (mXdrag >= TVcw)
	DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x114, "UInt", 1, "UInt", 0)	; scroll right
if !TVout
	{
if (hTVtarget <> oldht)
	{
	if DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x1102, "UInt", 2, "UInt", hTVtarget)	; expand hovered item (2=expand, 1=collapse)
		TV_Modify(hTVtarget, "Icon2")
	DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x1114, "UInt", 1, "UInt", hTVtarget)	; ensure hovered item is visible
	DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x111A, "UInt", 0, "UInt", 0)	; remove insert mark
	DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x110B, "UInt", 0x8, "UInt", hTVtarget)	; hilight hovered item
	; ****** drop validity check here ******
		cond1 := (InStr(TVsl, hTVsource Chr(160)) && (InStr(TVsl, TV_GetNext(hTVtarget) Chr(160)) OR InStr(TVsl, hTVtarget Chr(160)) OR (!TV_GetParent(hTVtarget) && !TV_GetChild(hTVtarget))))

	if ((hTVsource = hTVtarget) OR cond1 OR !TVX_CopyBranch(hTVmenu, hTVsource, hTVtarget)) && !deny
		{
		deny=1
		If TVILtoggle != 1
			DllCall("ImageList_SetDragCursorImage", "UInt", hTVILL, "Int", 5, "Int", 0, "Int", 0)
		else
			DllCall("SetCursor", "UInt", hCursN)
		}
	else if ((hTVsource != hTVtarget) && !cond1 && TVX_CopyBranch(hTVmenu, hTVsource, hTVtarget)) && deny
		{
		deny=
		If TVILtoggle != 1
			DllCall("ImageList_SetDragCursorImage", "UInt", hTVILL, "Int", 6, "Int", 0, "Int", 0)
		else
			DllCall("SetCursor", "UInt", hCursH)
		}
	oldht := hTVtarget
	prev=
	}
	if GetKeyState("Shift", "P") && !prev
		{
		DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x111A, "UInt", 1, "UInt", hTVtarget)	; show insert mark (1=below, 0=above)
		DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x110B, "UInt", 0x8, "UInt", 0)	; remove hilighting from hovered item
		prev=1
		}
	if !GetKeyState("Shift", "P")
		{
		DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x111A, "UInt", 0, "UInt", 0)	; remove insert mark
		DllCall("SendMessage", "UInt", hTVmenu, "UInt", 0x110B, "UInt", 0x8, "UInt", hTVtarget)	; hilight hovered item
		prev=
		}
	}
DllCall("comctl32\ImageList_DragShowNolock", "UInt", 1)
}
;**********************************************
TVX_drop(wP, lP, msg, hwnd)
{
Global
Local mx, my, hwnd2
Critical
if (oldWMlbup != A_ThisFunc)
	%oldWMlbup%(wP, lP, msg, hwnd)
;MouseGetPos,,, hwnd2, ctrl, 2
;if (hwnd2=MainWndID && !ctrlOp)
;	if drawMS(ctrl, lP, 0x202, MainWndID)
;		return 0
if !dragged
	return
if !TVout
	TVX_dropMain(hTVsource, hTVtarget, hTVmenu, hTVIL)
dragged := TVX_cleanup(hTVmenu, hTVdragIL)
}
;**********************************************
TVX_dropMain(hItem, ht, hTV, hIL)
{
Global
Critical
Local cID, eID, iIdx, iName, ip, new, nID, pID, pp, ppID, sID, sib, sis,  stg, tcID, tpID, tsID, tis
;======================================
; abort if source = target or [Esc] pressed
if (!hItem OR hItem = ht OR GetKeyState("Esc", "P"))
	return
;======================================
tis := InStr(TVsl, ht Chr(160))		; check if target is separator
sis := InStr(TVsl, hItem Chr(160))		; check if source is separator
TV_GetText(iName, hItem)			; get dragged item's name
tpID := TV_GetParent(ht)			; get target parent's ID
pID := TV_GetParent(hItem)		; get source parent's ID
cID := TV_GetChild(hItem)			; source's first child
tcID := TV_GetChild(ht)			; target's first child
tsID := TV_GetNext(ht)			; target's first sibling below
;======================================
; abort if source is separator AND (target/target sibling is separator OR (target is level 0 node AND no child) )
if (InStr(TVsl, hItem Chr(160)) && (InStr(TVsl, tsID Chr(160)) OR tis OR (!tpID && !tcID)))
	return
;======================================
; move dropped item
;=== if moved item has no children, perform simple move ===
if !cID
	{
	if (tis OR GetKeyState("Shift", "P"))				; if target is separator or [SHIFT] pressed
		new := TV_Add(iName, tpID, ht " Select")	; move below as sibling.
	else if sis								; if source is separator
		{
		pp := tpID ? tpID : ht
		ip := tpID ? ht : (TV_GetChild(ht) ? TV_GetChild(ht) : "First")
		new := TV_Add(iName, pp, ip " Select")
		}
	else
;		new := TV_Add(iName, ht, "Select Expand")	; I'm torn whether I should add item at the bottom or at the top
		new := TV_Add(iName, ht, "First Select Expand")
	K%new% := K%hItem%	; update hotkey
	L%new% := L%hItem%	; update label
	if !GetKeyState("Ctrl", "P")	; Hold CTRL to create a copy of the dragged item
		{
		TV_Delete(hItem)
		K%hItem%=
		L%hItem%=
		if sis	; if we just moved a separator, build a fresh separator list
			StringReplace, TVsl, TVsl, % hItem Chr(160), % new Chr(160)
		}
	else if sis	; if we just copied a separator, add it to the separator list
		TVsl .= new Chr(160) "|"
	TV_Modify(new, "Select Icon" (sis ? "4" : "3" ))
	if debug
		sID := new
	goto clean
	}
;=== else build a copy of dragged item's tree ===
stg := TVX_CopyBranch(hTV, hItem, ht)
if !stg
	return
;****************
GuiControl, 10:-Redraw, SysTreeView321
if !GetKeyState("Ctrl", "P")	; Hold CTRL to create a copy of the dragged branch
	TV_Delete(hItem)
;=== move branch ===
sib := GetKeyState("Shift", "P") | tis	; insert first item as sibling if SHIFT pressed or target is separator
TV_AddBranch(stg, ht, sib)
clean:
GuiControl, 10:, msctls_hotkey321, % K%sID%
GuiControl, 10:ChooseString, ComboBox1, % "||" L%sID%
TV_Modify(new, "Select")
if !tis
	TV_Modify(ht, " Expand Icon" (TV_GetChild(ht) ? "2" : "3" ))
if pID
	TV_Modify(pID, "Icon" (TV_GetChild(pID) ? "2" : "3" ))
TVrefresh()
GuiControl, 10:+Redraw, SysTreeView321
}
;**********************************************
TVX_cleanup(TVhandle, ByRef ILhandle)
{
Global
DllCall("ImageList_DragLeave", "UInt", TVhandle)
DllCall("ImageList_EndDrag")
DllCall("ImageList_Destroy", "UInt", ILhandle)
ILhandle=
DllCall("SendMessage", "UInt", TVhandle, "UInt", 0x110B, "UInt", 0x8, "UInt", 0)	; remove hilighting from hovered item
DllCall("SendMessage", "UInt", TVhandle, "UInt", 0x111A, "UInt", 0, "UInt", 0)		; remove insert mark
DllCall("ReleaseCapture")
DllCall("SetCursor", "UInt", hCursA)
if TVILtoggle != 1
	DllCall("ShowCursor", "UInt", 1)
DllCall("DestroyCursor", "Uint", hCursA)
DllCall("DestroyCursor", "Uint", hCursN)
;DllCall("DestroyCursor", "Uint", hCursH)
return 0
}
;**********************************************
TVX_CopyBranch(hTV, hItem, ht)
{
Global
Local nID, eID, idx, iIdx, ppID
nID := hItem
Loop
	{
	eID := TV_GetNext(nID)	; end marker
	if eID
		break
	nID := TV_GetParent(nID)
	if !nID
		break
	}
idx=1
stg=
nID := hItem
Loop
	{
	iIdx := TV_GetItemInfo(hTV, nID, "7")
	TV_GetText(iName, nID)
	ppID := TV_GetParent(nID)
	; string: name handle parent previous icon hotkey label
	stg .= iName Chr(160) nID Chr(160) ppID Chr(160) TV_GetPrev(nID) Chr(160) iIdx Chr(160) K%nID% Chr(160) L%nID% Chr(160) "|"
	nID := TV_GetNext(nID, "Full")
	if (!nID OR nID = eID OR TV_GetParent(nID) = eID)
		break
	idx++
	}
StringTrimRight, stg, stg, 1		; remove trailing separator
;****************
if ht
	If InStr(stg, ht Chr(160)) > InStr(stg, "|")		; abort if target belongs to source branch
		stg=
return stg
}
;**********************************************
TV_AddBranch(Istring, target, pos="0")
{
Global
Local cnt, index, items0, items1, items2, items3, items4, items5, items6, items7, items8, isexp, p1, p2, pID, istg
if debug
	FileDelete, items.txt
index=1
menuStr=
Loop, Parse, Istring, |
	{
	StringSplit, items, A_LoopField, % Chr(160)
	items5++
	isexp := items5 = 1 ? "" : " Expand"
	if (SubStr(items7, 1, 1) = Chr(58))
		StringTrimLeft, item7, items7, 1
	if A_Index = 1
		{
		p1 := pos ? TV_GetParent(target) : target
		p2 := pos ? target : ""
		i%items2% := TV_Add(items1, p1, p2 " Icon" items5 isexp)
		i%items3% := TV_GetParent(i%items2%)
		i%items4% := TV_GetPrev(i%items2%)
		new := i%items2%
		pID := i%items3%
		MenuName%pID% = %CtrlText%
		}
	else
		{
		i%items2% := TV_Add(items1, i%items3%, i%items4% " Icon" items5 isexp)	; buggy icons, no full refresh
		pID := i%items3%
		if !MenuName%pID%
			{
			index++
			MenuName%pID% = MenuLevel%index%
;			MenuName%pID% := item7 ? item7 : "MenuLevel" index
			cnt := index
			}
		else
			cnt := SubStr(MenuName%pID%, 10)
		}
	sID := i%items2%
	if debug
		FileAppend, [index-%index%] [cnt-%cnt%] [i1-%items1%] [i2-%items2%] [i3-%items3%] [i4-%items4%] [i5-%items5%] [i6-%items6%] [i7-%items7%]`n, items.txt
	if (items7 && SubStr(items7, 1, 1) != Chr(58))
		{
		K%sID% = %items6%
		L%sID% = %items7%
		if debug
			msgbox, % "Pass 2 hotkey " items1 " (" sID "): " K%sID%
		StringReplace, items6, items6, `+, Shift`+
		StringReplace, items6, items6, !, Alt`+
		StringReplace, items6, items6, ^, Ctrl`+
		StringReplace, items6, items6, #, Win`+
		StringReplace, items7, items7, `&, ``&
		menuStr%cnt% .= "Menu, " MenuName%pID% ", Add" (items1 = sstr ? "" : ", " items1 (items6 ? "`t" items6 : "") ", " items7) "`n"
		}
	else
		{
		istg := "Menu, " MenuName%pID% ", Add" (items1 = sstr ? "" : ", " items1 ", :MenuLevel" index+1) "`n"
;		istg := "Menu, " MenuName%pID% ", Add" (items1 = sstr ? "" : ", " items1 ", " items7) "`n"
		K%sID% =
		L%sID% =
		if (MenuName%pID% = CtrlText)
			menuLvl1 .= istg
		else
			menuStr%cnt% .= istg
		}
	Loop, 8
		items%A_Index%=
	item7=
	}
Loop, %index%
	{
	pos := index+1-A_Index
	menuStr .= menuStr%pos%
	menuStr%pos%=
	}
menuStr .= menuLvl1
menuLvl1=
if debug
	{
	FileDelete, menuStr.txt
	FileAppend, %menuStr%, menuStr.txt
; we need this trick to have a complete set of instructions in the saved file
; since we actually attach the menu later on
; menuMain := "Gui, " GUICountA "Menu, " CtrlText "`n"
	FileAppend, % "Gui, " GUICountA "Menu, " CtrlText "`n", menuStr.txt
	run, menuStr.txt
	}
}
;**********************************************
TVX_Populate(Istring)
{
Global
Local index, items0, items1, items2, items3, items4, items5, items6, items7, item7, items8, isexp, pID, tmpV
index=1
Loop, Parse, Istring, |
	{
	StringSplit, items, A_LoopField, % Chr(160)
	items5++
	isexp := items5 = 1 ? "" : " Expand"
	if (SubStr(items7, 1, 1) = Chr(58))
		{
		StringTrimLeft, item7, items7, 1
		p%item7% := items2	; locate nods (parents)
		}
	if A_Index = 1
		{
		i%items2% := TV_Add(items1, 0, " Icon" items5 isexp)
		i%items3% := TV_GetParent(i%items2%)
		i%items4% := TV_GetPrev(i%items2%)
		new := i%items2%
		pID := p%items3% := i%items3%
		MenuName%pID% = %CtrlText%
		}
	else
		{
		pID := p%items3%
		i%items2% := TV_Add(items1, i%pID%, i%items4% " Icon" items5 isexp)
		if !MenuName%pID%
			{
			index++
			MenuName%pID% = MenuLevel%index%
;			MenuName%pID% = %items3%
			}
		}
	sID := i%items2%
	if (items7 && SubStr(items7, 1, 1) != Chr(58))
		{
		K%sID% = %items6%
		L%sID% = %items7%
		if debug
			msgbox, % "Pass 1 hotkey " items1 " (" sID "): " K%sID%
		GuiControl, 10:, msctls_hotkey321, % K%sID%
		StringReplace, items6, items6, `+, Shift`+
		StringReplace, items6, items6, !, Alt`+
		StringReplace, items6, items6, ^, Ctrl`+
		StringReplace, items6, items6, #, Win`+
		StringReplace, items7, items7, `&, ``&
		TVlabel = %items7%
		gosub TVlabelCheck
		GuiControl, 10:ChooseString, ComboBox1, % "||" L%sID%
		}
	else
		{
		K%sID% =
		L%sID% =
		}
	Loop, 8
		items%A_Index%=
	}
TV_Modify(sID, "Select")
}
;**********************************************
TVX_resize(wP, lP, msg, hwnd)
{
Global
Critical
Local ww, wh, nw, nh
if (oldWMsizing != A_ThisFunc)
	%oldWMsizing%(wP, lP, msg, hwnd)
if (hwnd != hGui10)
	return
WinGetPos,,, ww, wh, ahk_id %hwnd%
ControlGetPos, TVcx, TVcy, TVcw, TVch,, ahk_id %hTVmenu%
ControlMove, Button5,, wh-37,,, ahk_id %hwnd%
ControlMove, Button6,, wh-37,,, ahk_id %hwnd%
ControlMove, Static8,, wh-60,,, ahk_id %hwnd%
ControlMove, msctls_hotkey321,, wh-62,,, ahk_id %hwnd%
ControlMove, Static7,, wh-84,,, ahk_id %hwnd%
ControlMove, ComboBox1,, wh-86,,, ahk_id %hwnd%
ControlMove, Button3,, wh-135,,, ahk_id %hwnd%
ControlMove, Button4,, wh-111,,, ahk_id %hwnd%
ControlMove, Button1,, wh-135,,, ahk_id %hwnd%
ControlMove, Button2,, wh-111,,, ahk_id %hwnd%
ControlMove, Button7,, wh - 148,,, ahk_id %hwnd%
SysGet, sx, 32
SysGet, sy, 33
nw := ww-12- (!w9x ? 2*sx : 0)
nh := wh-48-148- (!w9x ? sy : 0)
GuiControl, 10:Move, SysTreeView321, x6, y48, w%nw%, h%nh%
GuiControl, 10:Move, Static1, x0, y0, w%ww%, h%wh%	; flickers but can't do without :-(
WinSet, Redraw,, ahk_id %hwnd%
}
;**********************************************
;**********************************************
cursor(wP, lP, msg, hwnd)
{
Global
Critical
if (oldWMsetcursor != A_ThisFunc)
	%oldWMsetcursor%(wP, lP, msg, hwnd)
if TVcursor
	{
	DllCall("SetCursor", "UInt", hCurs%TVcursor%)
	return 1	; this little SOB stops the default arrow flickering
	}
}
;**********************************************
getcurs(ctrl1, ByRef TVcursor, rm="")
{
Critical
Global resizeMargin, customSize, hGui10
if rm
	rmX := rmY := rm
else
	{
	SysGet, rmX, 32
	SysGet, rmY, 33
	}
TVcursor=
MouseGetPos, mX, mY, wid, ctrl
if (wid != hGui10)
	return TVcursor
if ctrl not in %ctrl1% 		; don't drag by other items
	return TVcursor
WinGetPos, wx, wy, ww, wh, ahk_id %wid%
hm := ww-rmX
vm := wh-rmY
if mX between 0 and %rmX%
	{
	if mY between 0 and %rmY%
		TVcursor = 13		; HTTOPLEFT
	else if mY between %vm% and %wh%
		TVcursor = 16		; HTBOTTOMLEFT
	else
		TVcursor = 10		; HTLEFT
	}
else if mX between %hm% and %ww%
	{
	if mY between 0 and %rmY%
		TVcursor = 14		; HTTOPRIGHT
	else if mY between %vm% and %wh%
		TVcursor = 17		; HTBOTTOMRIGHT
	else
		TVcursor = 11		; HTRIGHT
	}
else if mY between 0 and %rmY%
		TVcursor = 12		; HTTOP
else if mY between %vm% and %wh%
		TVcursor = 15		; HTBOTTOM
else return TVcursor
}
;**********************************************
mim(hwnd)
{
Global
if (hwnd = hGui10)
	{
	if (TVcursor != "")
		PostMessage, 0xA1, %TVcursor%,,, ahk_id %hGui10%	; WM_NCLBUTTONDOWN (only works in Win9x)
	else if ClickedCtrl in Static3,Static4,Static5,Static6
		{
		DllCall("SetCursor", "UInt", hCursH)
		SetTimer, ToggleMC, -1
		return 1
		}
	else
		{
		DllCall("SetCursor", "UInt", hCursM)
		PostMessage, 0xA1, 2,,, A	; WM_NCLBUTTONDOWN
		}
	ControlGetPos, TVcx, TVcy, TVcw, TVch,, ahk_id %hTVmenu%
	return 1
	}
}
