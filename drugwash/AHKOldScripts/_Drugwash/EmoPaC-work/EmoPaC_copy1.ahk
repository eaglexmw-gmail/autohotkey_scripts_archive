; Generated by SmartGUI Creator
; Created by Drugwash
; April 2008
;version 0.1 pre-alpha

;---------------------------- MAIN ROUTINE ------------------------
debug := 1
inipath := "emopac.ini"
FileRead, init, %inipath%
if ErrorLevel
	{
	MsgBox, 48, Error !, Could not open %inipath%
	init :=
	ExitApp
	}
Gui, Font, S11 CDefault Bold, Verdana
Gui, Add, Text, x15 y0 w286 h17, Miranda IM Emoticon Pack Creator
Gui, Font, S8 CDefault Bold, Verdana
Gui, Add, Text, x53 y18 w215 h13, for Pescuma's Emoticons plug-in
Gui, Add, Pic, x326 y1 w32 h32, EmoPaC.ico
Gui, Font,
Gui, Add, Text, x384 y12 w102 h15, by Drugwash �2008
Gui, Add, GroupBox, x7 y32 w303 h80, Pack data
Gui, Add, Text, x16 y47 w80 h16 Right, Name :
Gui, Add, Text, x16 y68 w80 h16 Right, Author :
Gui, Add, Text, x16 y89 w80 h16 Right, Updater URL :
Gui, Add, Edit, x98 y46 w203 h17 vpname gvalid
Gui, Add, Edit, x98 y67 w203 h17 vpauthor gvalid
Gui, Add, Edit, x98 y88 w203 h17 vpupdater gvalid
Gui, Add, GroupBox, x316 y32 w169 h80, Actions
Gui, Add, Button, x324 y46 w75 h39, &Load
Gui, Add, Button, x403 y46 w75 h39, &Save
Gui, Add, Button, x403 y86 w75 h20, &Clear
Gui, Add, GroupBox, x7 y113 w303 h84, Codes
Gui, Add, Text, x16 y128 w80 h16 Right, Standard :
Gui, Add, Edit, x98 y127 w203 h17 ReadOnly vcodes
Gui, Add, Text, x16 y149 w80 h16 Right, Custom codes :
Gui, Add, Edit, x98 y148 w203 h17 vcustom gvalid
Gui, Add, Button, x98 y169 w66 h20, &Default
Gui, Add, Button, x167 y169 w66 h20, &Undo
Gui, Add, Button, x236 y169 w66 h20, &Merge
Gui, Add, Button, x315 y215 w70 h39 Default, &Folder
Gui, Add, Button, x315 y255 w70 h20, Add &image
Gui, Add, Button, x315 y276 w70 h20, &Rem. image
Gui, Add, Button, x315 y297 w35 h20, � �
Gui, Add, Button, x350 y297 w35 h20, � �
Gui, Add, Button, x315 y360 w70 h39, &Assign >>
Gui, Add, GroupBox, x316 y113 w169 h84, Protocols
Gui, Add, Radio, x324 y130 w60 h16 gdoAll, all
;Gui, Add, Radio, x324 y150 w60 h16 gdoNone, none
Gui, Add, Radio, x324 y150 w60 h16 Checked vselP gdoSel, select
Gui, Add, Checkbox, vmakeF, Folders
Gui, Add, TreeView, x387 y123 w92 h70 Checked Sort -HScroll -Lines AltSubmit vProto gdoProto
gosub iniP
Gui, Add, GroupBox, x7 y200 w586 h350, Emoticon images
Gui, Add, ListView, x15 y215 w297 h330 -Multi NoSortHdr -ReadOnly AltSubmit Icon Grid vsrcL gsrcSel, Name|Size(bytes)|Last modified
Loop, % countP + 1
	{
	temp := A_Index - 1
	Gui, Add, ListView, x387 y215 w200 h330 -Multi NoSortHdr ReadOnly AltSubmit Icon Sort Hidden vdestL%temp% gdestSel, Protocol|Common|Codes
	}
IconView := true
IconViewL := true
gosub iniD
wP := 1
GuiControl, Show, destL1
Gui, Add, StatusBar
SB_SetParts(62, 70, 315)
Gui, Add, Progress, X15 Y553 W297 H11 vloader
GuiControl, Hide, loader
;Control, Disable,, SysTreeView321
Control, Disable,, SysListView321
Gui, Show, x420 y85 h585 w600, EmoPaC
Return
;-------------------------- END MAIN ROUTINE ---------------------

;------------------------- ERROR MANAGEMENT -------------------
errMgm:
if critical
	{
	MsgBox, 48, Error !, There was a critical error:`n`n%errMsg%`n`n`tProgram will now exit.
	Loop, sourceCount
		{
		path%A_Index% :=
		size%A_Index% :=
		}
	Gui, ListView, destL
	Loop % LV_GetCount()
		label%A_Index% :=
	colInd :=
	count :=
	countF :=
	countL :=		; number of labels (standard emoticons)
	countP :=	; number of protocols
	critical :=		; switch enabling critical error handling
	custom :=
	debug :=		; switch enabling debugging messages
	debugPath :=
	dragged :=	; full path to the dragged file
	dselItemID :=	; selected item number in the labels list (destination)
	errMsg :=
	expert :=		; switch enabling the use of expert items
	fdpath :=		; current folder path
	fdpathN :=	; newly added folder path
	filepath :=
	fold :=		; protocol subfolder added to pack if makeF enabled
	fpath :=
	gifT :=		; GIF transparency
	IconView :=	; switch toggling icon/report view mode
	indB :=
	inipath :=		; full path to program's ini file (critical!)
	init :=
	labelCount :=
	last :=		; last enabled protocol
	lastP :=		; last selected protocol (stupid TreeView!)
	makeF :=		; switch enabling creation of protocol subfolders
	mT :=
	newIndex :=
	newPos :=
	pathA :=		; full path for multiple selected files
	pathHead :=	; partial path to multiple selected files
	pauthor :=	; pack author's name
	pname :=		; pack name
	pro :=
	Proto :=		; Protocol list variable (unused)
	pStep :=		; progressbar advance step
	pupdater :=	; pack Updater URL
	selItemID :=	; selected item number in the images list (source)
	sourceCount := ; total number of images in the source list
	sT :=
	temp :=
	tForm :=		; formatted string with 'last modified' time
	tRaw :=		; raw string with 'last modified' time
	wP :=		; currently active protocol (0 of all)
	ExitApp
	}
MsgBox, 48, Error !, %errMsg%
return
;------------------------- ERROR MANAGEMENT -------------------

;------------ DEBUG -------------
deb:
	Gui, Add, Text, x315 y438 w70 h16, Images: %sourceCount%
return
;--------- END DEBUG ----------

;--------------------------- RADIO BUTTONS -----------------------
doAll:
Loop % TV_GetCount()
	{
	GuiControl, Hide, destL%A_Index%
	TV_Modify(Pr%A_Index%, "Check")
	}
GuiControl, Show, destL0
TV_Modify(Pr1, "VisFirst")
Control, Disable,, SysTreeView321
wP := 0
return

doNone:
Loop % TV_GetCount()
	TV_Modify(Pr%A_Index%, "-Check")
TV_Modify(Pr1, "VisFirst")
;Control, Disable,, SysTreeView321
return

doSel:
GuiControl, Hide, destL0
GuiControl, Show, destL%wP%
Control, Enable,, SysTreeView321
Loop, % TV_GetCount()
	TV_Modify(Pr%A_Index%, "-Check")
TV_Modify(Pr%last%)
sleep, 1
TV_Modify(Pr%last%, "Check VisFirst")
wP := last
return

doProto:
if A_GuiEvent not in Normal,S
	return
;Control, Check,, Button18
;ControlFocus, SysTreeView321
TV_Modify(Pr%last%, "-Check")
Loop, % TV_GetCount()
	{
	if TV_Get(Pr%A_Index%, "Check")
		{
		last := A_Index
		break
		}
;	if debug
;		MsgBox, % "LastP = " . lastP . "`n" . "Pr" . A_Index . "=" . Pr%A_Index% . "`n" . "Last=" . last . "`nPr" . A_Index . "has been unchecked"
	}
Loop, % TV_GetCount()
	{
	TV_Modify(Pr%A_Index%, "-Check")
	GuiControl, Hide, destL%A_Index%
	}
TV_Modify(Pr%last%, "Check Select")
wP := last
Gui, Submit, NoHide
GuiControl, Show, destL%wP%
count := countL%wP%
	if debug
		Gui, Add, Text, x315 y420 w70 h16, Labels:  %count%
return
;--------------------------- RADIO BUTTONS -----------------------

;--------------------------- VALIDATE INPUT -----------------------
valid:
Gui, Submit, NoHide
return
;------------------------ END VALIDATE INPUT ---------------------

;------------------- INITIALIZE PROTOCOLS LIST ---------------
iniP:
;----- parsing loop------------
Loop, 99	; assumingly there will never be more than 99 supported protocols :-)
	{
	IniRead, protoL, %inipath%, Protocols, %A_Index%, %A_Space%
	if protoL =
		break
	countP := A_Index
	if protoL = Default
		{
		Pr%countP% := TV_Add(protoL, 0, "Check")
		last := 1
		}
	else
		Pr%countP% := TV_Add(protoL)
	}
if debug
	Gui, Add, Text, x315 y402 w70 h16, Protos: %countP%
return
;---------------- END INITIALIZE PROTOCOLS LIST -------------

;------------------- INITIALIZE DESTINATION LISTS ---------------
iniD:
gosub initF
Loop, %countP%
	{
	temp := A_Index
	Gui, ListView, destL%temp%
	GuiControl, -Redraw, destL%temp%
;----- parsing loop------------
	Loop, 999	; assumingly there will never be more than 999 supported definitions :-)
		{
		IniRead, action, %inipath%, Def%temp%, %A_Index%, %A_Space%
		if action =
			break
		countL%temp% := A_Index
		StringReplace, action1, action, "`,%A_Space%", �, 1
		Loop, parse, action1, �
			act%A_Index% := A_LoopField
		LV_Add(Icon1, act2, act1, act3)
		}
	GuiControl, +Redraw, destL%temp%
	}
Gui, ListView, destL0
Loop, 20
	LV_Add(Icon1, "common", "N/A", "N/A")
return
;---------------- END INITIALIZE DESTINATION LISTS -------------

;------------------- INITIALIZE FIRST ICON ---------------------
initF:
;srcID := IL_Create(1, 5, 0)
srcIDL := IL_Create(1, 5, 1)
Gui, ListView, srcL
LV_SetImageList(srcIDL, 1)
LV_SetImageList(srcIDL, 0)
Loop, % countP + 1
	{
	Proto := A_Index -1
	Gui, ListView, destL%Proto%
	LV_SetImageList(srcIDL, 1)
	LV_SetImageList(srcIDL, 0)
	}
;IL_Add(srcIDL, "noimg.ico", 0xFFFFFF, 1)
IL_Add(srcIDL, "noimg1.ico", 0xFFFFFF, 1)
return
;------------------- INITIALIZE FIRST ICON ---------------------

;------------------------ ADD FOLDER ----------------------------
ButtonFolder:
FileSelectFolder, fdpathN,, 2, Please select images folder
if fdpathN =
	{
	if fdpath =
		MsgBox, 64, Information, No folder has been selected.`nPlease select a folder containing emoticon images.
	return
	}
else
	{
	fdpath := fdpathN
	Gui, ListView, srcL
	Loop, %fdpath%\*.*
		countF += 1	; keeps score of current folder contents
	GuiControl, -Redraw, srcL
	GuiControl, Show, loader
	Loop, %fdpath%\*.*
		{
		if A_LoopFileExt NOT IN bmp,emf,exif,gif,ico,jpg,jpeg,png,tif,tga,wmf
			continue
		sourceCount += 1
		sT := A_LoopFileExt
		gosub selTrans
		path%sourceCount% := A_LoopFileFullPath
		name%sourceCount% := A_LoopFileName
		size%sourceCount% := A_LoopFileSize
;		IL_Add(srcID, A_LoopFileFullPath, mT, 1)
		IL_Add(srcIDL, A_LoopFileFullPath, mT, 1)
		gosub formTime
		newIndex := sourceCount + 1
		LV_Add("Icon" . newIndex, A_LoopFileName, A_LoopFileSize, tForm)
		pStep := (A_Index * 100) // countF
		GuiControl,, loader, %pStep%
		}
	GuiControl, +Redraw, srcL
	GuiControl, Hide, loader
	Control, Enable,, SysListView321
	;LV_ModifyCol(1, "AutoHdr CaseLocale")
	LV_ModifyCol(1, "AutoHdr Logical")
	LV_ModifyCol(2, "AutoHdr Integer")
	LV_ModifyCol(3, "AutoHdr")
	Gui, Show
	GuiControl, +default, Save
	Gui, Add, Text, x15 y551 w295 h14 cBlue gopenPath, %fdpath%
	Gui, Add, Text, x310 y551 w165 h14 cBlue Right gopenIni, %inipath%
	}
if debug
	goto deb
return
;------------------------- END ADD FOLDER ----------------------

;---------------------- SELECT TRANSPARENCY ----------------
selTrans:
SetFormat, integer, H
if (sT = "bmp")
	mT := 0xFF00FF
else if (sT = "gif")
	{
	debugPath := A_LoopFileFullPath
	gosub calcMask
	}
else if (sT = "ico" OR sT = "jpg" OR sT = "jpeg" OR sT = "png" OR sT = "tif")
	mT := 0x000000
SetFormat, integer, D
return

calcMask:
FileRead, gifT, *m0x30D %debugPath%
colInd := *(&gifT + 0x0B)
indB :=  colInd * 3 + 0x0D
mT := *(&gifT + indB) * 0x010000 + *(&gifT + indB +1) * 0x100 + *(&gifT + indB + 2)
gifT :=
return
;---------------------- SELECT TRANSPARENCY ----------------

;-------------- FORMAT TIME MODIFIED -----------------
formTime:
tRaw := A_LoopFileTimeModified
formT1:
tForm := Substr(tRaw, 7,2) . "." . Substr(tRaw, 5,2) . "." . Substr(tRaw, 1,4) . ", " . Substr(tRaw, 9,2) . ":" . Substr(tRaw, 11,2)
return
;---------- END FORMAT TIME MODIFIED -----------------

;---------------------------- ADD IMAGE ----------------------------
ButtonAddimage:
Gui, ListView, srcL
FileSelectFile, fpath, M27,, Select image files to add to the pack, Images (*.ico; *.bmp; *.gif; *.jpg; *.png; *.tiff) 
if ErrorLevel
	{
	errMsg := "No file(s) selected"
	goto errMgm
	}
Loop, parse, fpath, `n
	{
	if A_Index = 1
		pathHead := A_LoopField
	else
		{
		sourceCount += 1
		path%sourceCount% := pathHead . "\" . A_LoopField
		gosub extract
		}
	}
if debug
	goto deb
return

extract:
		pathA := path%sourceCount%
		if debug
			MsgBox, LoopField = %A_LoopField%`nPath = %pathA%
		Loop, %pathA%
			{
			sT := A_LoopFileExt
			gosub selTrans
;			IL_Add(srcID, A_LoopFileFullPath, mT, 1)
			IL_Add(srcIDL, A_LoopFileFullPath, mT, 1)
			size%sourceCount% := A_LoopFileSize
			name%sourceCount% := A_LoopFileName
			gosub formTime
			newIndex := sourceCount + 1
			LV_Add("Icon" . newIndex, A_LoopFileName, A_LoopFileSize, tForm)
			if debug
				MsgBox, File #%sourceCount%: %A_LoopFileFullPath%`nsize: %A_LoopFileSize% bytes`ntime: %tRaw%
			}
return
;--------------------------- END ADD IMAGE --------------------------

;--------------------------- SOURCE SELECTED -------------------------
srcSel:
if A_GuiControl <> srcL
	return
if A_GuiEvent NOT IN Normal,D,d
	return
Gui, ListView, srcL
selItemID := A_EventInfo
dragSel:
if selItemID = 0
	{
	selItemID :=
	return
	}
LV_GetText(selItem, selItemID)
SB_SetText("Image #"selItemID, 1)
SB_SetText(size%selItemID% . " bytes", 2)
SB_SetText(path%selItemID%, 3)
;SB_SetText(dselItemID, 4)
debugPath := path%selItemID%
SetFormat, integer, H
gosub calcMask
gifT :=
SetFormat, integer, D
if debug
	{
	Gui, Add, Text, x315 y496 w70 h14 cRed, Index: %colInd%
	Gui, Add, Text, x315 y510 w70 h14 cRed, Addr: %indB%
	Gui, Add, Text, x315 y526 w70 h14 cRed, Mask: %mT%
	}
if (A_GuiEvent <> D and A_GuiEvent <> d)
	return
LV_GetText(dragged, selItemID, 1)
return
;------------------------- END SOURCE SELECTED ----------------------

;------------------------ DESTINATION SELECTED ----------------------
destsel:
Gui, ListView, destL%wP%
if A_GuiEvent <> Normal
	return
dselItemID := A_EventInfo
if dselItemID = 0
	{
	dselItemID :=
	return
	}
SB_SetText(dselItemID, 4)
return
;----------------------END DESTINATION SELECTED -------------------

;----------------------------- CLEAR ALL DATA -----------------------
ButtonClear:
if (not pname and not pauthor and not pupdater and not custom and not fdpath)
	{
	MsgBox, 64, Hmmm..., There is nothing to delete`; the session is clear., 15
	return
	}
MsgBox, 36, Warning..., Are you sure you want to delete all data for the current session?`n`tThere is no 'Undo' for this operation...`n`n`t`tProceed?
IfMsgBox, No
	return
GuiControl,, pname
GuiControl,, pauthor
GuiControl,, pupdater
GuiControl,, custom
Loop, %countP%
	{
	temp := A_Index
	Gui, ListView, destL%A_Index%
	Loop % LV_GetCount()
		label%temp%x%A_Index% :=
	LV_Delete()
	}
Gui, ListView, srcL
LV_Delete()
IL_Destroy(srcID)
IL_Destroy(srcIDL)
gosub iniD
Gui, Submit, NoHide
return
;--------------------------- END CLEAR ALL DATA ------------------

;------------------------------ SWITCH VIEW ------------------------
;------ LEFT -------
Button��:
if NOT sourceCount
	return
Gui, ListView, srcL
if NOT IconView
    GuiControl, +Icon, srcL
else
    GuiControl, +Report, srcL
;LV_ModifyCol(1, "AutoHdr CaseLocale")
LV_ModifyCol(1, "AutoHdr Logical")
LV_ModifyCol(2, "AutoHdr Integer")
LV_ModifyCol(3, "AutoHdr")
IconView := not IconView
return
;----- RIGHT ------
Button��:
if NOT countL%wP%
	return
Gui, ListView, destL%wP%
if NOT IconViewL
    GuiControl, +Icon, destL%wP%
else
    GuiControl, +Report, destL%wP%
;LV_ModifyCol(1, "AutoHdr CaseLocale")
LV_ModifyCol(1, "AutoHdr Logical")
LV_ModifyCol(2, "AutoHdr Logical")
LV_ModifyCol(3, "AutoHdr Logical")
IconViewL := not IconViewL
return
;--------------------------- END SWITCH VIEW ------------------------

;------------------------------ ASSIGN FILE ------------------------------
ButtonAssign>>:
if not dselItemID
	{
	MsgBox, 48, Error !, You have not selected a destination label.
	return
	}
if not selItemID
	{
	MsgBox, 48, Error !, Please select an image in the left-hand list.
	return
	}
	fullP := path%selItemID%
if selP = 1
	{
	Loop, %countP%
		label%A_Index%x%dselItemID% := fullP
	}
else
	label%last%x%dselItemID% := fullP
newPos := selItemID + 1
Gui, ListView, destL%wP%
LV_Modify(dselItemID, "Icon" . newPos)
Gui, Submit, NoHide
if debug
	{
	temp := label%last%x%dselItemID%
	MsgBox, 0, Debug, Image #%selItemID% has been assigned to %dselItemID%`nlabel%last%x%dselItemID% = %fullP%`n%temp%
	}
return
;---------------------------- END ASSIGN FILE --------------------------

;------------------------------ DRAG'N'DROP ---------------------------
GuiDropFiles:
if A_GuiControl <> destL%wP%
	return
if NOT dragged
	dragged := A_GuiEvent
if dselItemID =
	{
	MsgBox, 48, Error !, You have not selected a destination label.
	return
	}
if debug
	MsgBox, 0, Debug, A_GuiControl is %A_GuiControl%`ndselItemID is %dselItemID%
if ErrorLevel > 1
	{
	MsgBox, 48, Error !, You cannot assign more than one image to an emoticon label!
	return
	}
Gui, ListView, srcL
fpath := dragged
sourceCount += 1
path%sourceCount% := fpath
gosub extract
selItemID := sourceCount
gosub dragSel
LV_Modify(sourceCount, "Select")
goto ButtonAssign>>
return
;---------------------------- END DRAG'N'DROP ---------------------------


;------------------------------- OPEN PATH ---------------------------------
openPath:
Run Explorer.exe %fdpath%
return
;----------------------------- END OPEN PATH ----------------------------

;--------------------------- OPEN INIFILE PATH --------------------------
openIni:
Run Explorer.exe %inipath%
return
;------------------------- END OPEN INIFILE PATH ----------------------

;---------------------------- LOAD & PARSE PACK -----------------------
ButtonLoad:
MsgBox, Not yet implemented.
return
;---------------------------- LOAD & PARSE PACK -----------------------

;-------------------------------- SAVE PACK -------------------------------
ButtonSave:
if NOT pname
	{
	MsgBox, 48, Error !, You have not given a name to the emoticon pack!
	return
	}
if NOT pauthor
	{
	MsgBox, 68, Warning..., There is no author name for the pack.`nDo you want to remain anonymous? `;-)
	ifMsgBox, No
		return
	}
filepath := pname . "\" . pname . ".mep"
IfExist, %filepath%
	{
	MsgBox, 8257, Attention !, Files already exist. Do you want to overwrite them?
	IfMsgBox, Cancel
		return
	FileDelete, %filepath%
	If ErrorLevel
		{
		MsgBox, 64, Error !, There was an error deleting the file %filepath%
		return
		}
	}
IfNotExist %pname%
	FileCreateDir, %pname%
If ErrorLevel
	{
	MsgBox, 64, Error !, Could not create folder %pname%
	return
	}
FileAppend, Name: %pname%`n, %filepath%
FileAppend, Creator: %pauthor%`n, %filepath%
FileAppend, Updater URL: %pupdater%`n, %filepath%
if ErrorLevel
	{
	MsgBox, 64, Error !, There was an error writing to`n%filepath%
	return
	}
;------------------------ END SAVE SIGNATURE FILE -------------------
Loop, %countP%
	{
	writeP := A_Index
	Gui, ListView, destL%writeP%
	TV_GetText(pro, Pr%writeP%)
	if expert
		{
		filepath1 := pname . "\" . pro . ".emo"
		FileDelete, %filepath1%
		FileAppend, # %pname% by %pauthor%`n, %filepath1%
		}
	FileAppend, `n# %pro% emoticons`n`n, %filepath%
	if makeF
		fold := pro . "\"
	count := countL%wP%
	Loop, %count%
		{
		tempL := label%writeP%x%A_Index%
;		MsgBox, Protocol %writeP%`nLabel %A_Index%`ntempL=%tempL%
		if NOT tempL
			continue
		name := name%A_Index%
		LV_GetText(tempS, A_Index, 1)
		temp := """" . pro . "\" . tempS . """ = " . """" . fold . name . """"
		FileCopy, %tempL%, %pname%
		FileAppend, %temp%`n, %filepath%
		}
	}
;IniWrite, local%countP%-%countL%, pro . ".emo", 
return
;-------------------------------- SAVE PACK -------------------------------

GuiClose:
ExitApp