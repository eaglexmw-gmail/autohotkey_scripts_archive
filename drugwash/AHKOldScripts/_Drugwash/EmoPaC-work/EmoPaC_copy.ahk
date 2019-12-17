; Generated by SmartGUI Creater

debug := 1
inipath := "itemlist.txt"
Gui, Font,  S11 CDefault Bold,  Verdana
Gui, Add, Text, x15 y0 w286 h17, Miranda IM Emoticon Pack Creator
Gui, Font,  S8 CDefault Bold,  Verdana
Gui, Add, Text, x53 y18 w215 h13, for Pescuma's Emoticons plug-in
Gui, Add, Pic, x326 y1 w32 h32, EmoPaC.ico
Gui, Font,
Gui, Add, Text, x384 y12 w102 h15, by Drugwash �2008
Gui, Add, GroupBox, x7 y32 w299 h80, Pack data
Gui, Add, Text, x16 y49 w80 h16, Name:
Gui, Add, Text, x16 y69 w80 h16, Author:
Gui, Add, Text, x16 y89 w80 h16, Updater URL:
Gui, Add, Edit, x98 y48 w200 h16 vpname gvalid
Gui, Add, Edit, x98 y68 w200 h17 vpauthor gvalid
Gui, Add, Edit, x98 y88 w200 h17 vpupdater gvalid
Gui, Add, GroupBox, x316 y32 w169 h80, Actions
Gui, Add, Button, x327 y48 w70 h19 Default, Folder
Gui, Add, Button, x327 y68 w70 h19, Add image
Gui, Add, Button, x401 y88 w75 h19, Clear
Gui, Add, Button, x401 y48 w75 h39, Save
Gui, Add, Button, x326 y88 w72 h19, Rem. image
Gui, Add, GroupBox, x7 y113 w300 h84, Codes
Gui, Add, Text, x16 y129 w80 h16, Standard:
Gui, Add, Edit, x97 y128 w201 h16 ReadOnly vcodes
Gui, Add, Text, x16 y149 w80 h16, Custom codes:
Gui, Add, Edit, x97 y148 w201 h16 vcustom gvalid
Gui, Add, Button, x16 y169 w80 h20, Alt. view
Gui, Add, Button, x112 y169 w80 h20, Merge
Gui, Add, Button, x218 y169 w80 h20, Assign
Gui, Add, GroupBox, x316 y113 w169 h84, Protocols
Gui, Add, Radio, x326 y130 w60 h16 Checked, all
Gui, Add, Radio, x326 y150 w60 h16, none
Gui, Add, Radio, x326 y170 w60 h16, choose
Gui, Add, TreeView, x387 y123 w90 h70 Checked -HScroll -Lines,
Pr1 := TV_Add("Default")
Pr2 := TV_Add("AIM")
Pr3 := TV_Add("C6")
Pr4 := TV_Add("Gadu-Gadu")
Pr5 := TV_Add("GoogleTalk")
Pr6 := TV_Add("ICQ")
Pr7 := TV_Add("IRC")
Pr8 := TV_Add("Jabber")
Pr9 := TV_Add("MSN")
Pr10 := TV_Add("MySpace")
Pr11 := TV_Add("Sametime")
Pr12 := TV_Add("Skype")
Pr13 := TV_Add("Yahoo")
Gui, Add, GroupBox, x7 y200 w479 h350, Emoticon images
Gui, Add, ListView, x15 y215 w294 h330 -Multi NoSortHdr -ReadOnly AltSubmit Icon Grid gsrcSel vsrcL, Name|Size(bytes)|Last modified
IconView := true
Loop, Read, %inipath%
	{
	if A_Index <> 0
	labelCount += 1
	}
; former coords: x317 y215 w161 h330
Gui, Add, ListView, x387 y215 w91 h330 -Multi NoSortHdr ReadOnly AltSubmit Icon Sort gdestSel vdestL, Label|Protocols
gosub iniD
Gui, Add, StatusBar
SB_SetParts(62, 70, 315)
Gui, Show, x257 y113 h585 w492, EmoPaC
Return
;------------------------- END MAIN ROUTINE ---------------------

;--------------------------- VALIDATE INPUT -----------------------
valid:
Gui, Submit, NoHide
return
;------------------------ END VALIDATE INPUT ---------------------

;------------------- INITIALIZE DESTINATION LIST ---------------
iniD:
count := labelCount
Gui, ListView, destL
gosub initF
GuiControl, -Redraw, destL
Loop, Read, %inipath%
	LV_Add(Icon1, A_LoopReadLine, "N/A")
GuiControl, +Redraw, destL
return
;---------------- END INITIALIZE DESTINATION LIST -------------


;------------------- INITIALIZE FIRST ICON ---------------------
initF:
if debug
MsgBox, 0, Debug, count is %count%, 5
;srcID := IL_Create(count, 5, 0)
srcIDL := IL_Create(count, 5, 1)
;LV_SetImageList(srcID)
LV_SetImageList(srcIDL)
;IL_Add(srcID, "noimg.ico")
IL_Add(srcIDL, "noimg.ico", 0xFFFFFF, 1)
return
;------------------- INITIALIZE FIRST ICON ---------------------

;------------------------ ADD FOLDER ----------------------------
ButtonFolder:
FileSelectFolder, fdpathN,, 2, Please select images folder
if fdpathN =
	{
	if fdpath =
		MsgBox, No folder has been selected.`nPlease select a folder containing emoticon images.
	return
	}
else
	{
	fdpath := fdpathN
	Gui, ListView, srcL
	if srcID =
		goto firsttime
	IL_Destroy(srcID)
	IL_Destroy(srcIDL)
	LV_Delete()
firsttime:
	Loop, %fdpath%\*.*
		{
		if A_Index <> 0
			sourceCount += 1
		}
	count := sourceCount
	gosub initF
	pWdth = 350
	GuiControl, -Redraw, srcL
	Progress,B2 ZH5 FM12 CTFF00FF CW0 Y200 W%pWdth%,,Please wait until images are loaded...,,Tahoma
	Loop, %fdpath%\*.*
		{
		if A_LoopFileExt NOT IN bmp,emf,exif,gif,ico,jpg,jpeg,png,tif,tga,wmf
			continue
		sT := A_LoopFileExt
		gosub selTrans
		path%A_Index% := A_LoopFileFullPath
		size%A_Index% := A_LoopFileSize
;if debug
;MsgBox, File is %A_LoopFileExt%, indB is %indB%, mT is %mT%
;		IL_Add(srcID, A_LoopFileFullPath, mT, 1)
;		if (A_LoopFileExt = "ico")
;			IL_Add(srcIDL, A_LoopFileFullPath)
;		else
			IL_Add(srcIDL, A_LoopFileFullPath, mT, 1)
		gosub formTime
		newIndex := A_Index + 1
		LV_Add("Icon" . newIndex, A_LoopFileName, A_LoopFileSize, tForm)
		pStep := (A_Index * 100) // count
		Progress, %pStep%
		}
	GuiControl, +Redraw, srcL
	Progress, Off
	;LV_ModifyCol(1, "AutoHdr CaseLocale")
	LV_ModifyCol(1, "AutoHdr Logical")
	LV_ModifyCol(2, "AutoHdr Integer")
	LV_ModifyCol(3, "AutoHdr")
	Gui, Show
	GuiControl, +default, Save
	Gui, Add, Text, x15 y551 w295 h14 cBlue gopenPath, %fdpath%
	Gui, Add, Text, x310 y551 w165 h14 cBlue Right gopenIni, %inipath%
	}
return
;------------------------- END ADD FOLDER ----------------------

;---------------------- SELECT TRANSPARENCY ----------------
selTrans:
SetFormat, integer, H
if (sT = "bmp")
mT := 0xFF00FF
if (sT = "gif")
{
debugPath := A_LoopFileFullPath
gosub calcMask
}
if (sT = "ico" OR sT = "jpg" OR sT = "jpeg" OR sT = "png" OR sT = "tif")
mT := 0x000000
SetFormat, integer, D
return
;---------------------- SELECT TRANSPARENCY ----------------

calcMask:
FileRead, gifT, *m0x30D %debugPath%
colInd := *(&gifT + 0x0B)
indB :=  colInd * 3 + 0x0D
mT := *(&gifT + indB) * 0x010000 + *(&gifT + indB +1) * 0x100 + *(&gifT + indB + 2)
gifT :=
return

;-------------- FORMAT TIME MODIFIED -----------------
formTime:
tRaw := A_LoopFileTimeModified
tForm := Substr(tRaw, 7,2) . "." . Substr(tRaw, 5,2) . "." . Substr(tRaw, 1,4) . ", " . Substr(tRaw, 9,2) . ":" . Substr(tRaw, 11,2)
return
;---------- END FORMAT TIME MODIFIED -----------------

;---------------------------- ADD IMAGE ----------------------------
ButtonAddimage:
Gui, ListView, srcL
FileSelectFile, fpath, M27,, Select image files to add to the pack, Images (*.bmp; *.gif; *.jpg; *.png; *.tiff) 
if fpath =
MsgBox, No file(s) selected
else
MsgBox, Selected file(s): %fpath%
Return
;--------------------------- END ADD IMAGE --------------------------

;--------------------------- SOURCE SELECTED -------------------------
srcSel:
if A_GuiControl <> srcL
	return
if A_GuiEvent NOT IN Normal,D,d
	return
Gui, ListView, srcL
selItemID := A_EventInfo
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
Gui, Add, Text, x310 y496 w70 h14 cRed, Index: %colInd%
Gui, Add, Text, x310 y510 w70 h14 cRed, Addr: %indB%
Gui, Add, Text, x310 y526 w70 h14 cRed, Mask: %mT%
if (A_GuiEvent <> D and A_GuiEvent <> d)
	return
LV_GetText(dragged, selItemID, 1)
return
;------------------------- END SOURCE SELECTED ----------------------

;----------------------------- CLEAR ALL DATA -----------------------
ButtonClear:
Gui, ListView, destL
Loop % LV_GetCount()
label%A_Index% :=
LV_Delete()
Gui, ListView, srcL
LV_Delete()
gosub iniD
return
;--------------------------- END CLEAR ALL DATA ------------------

;------------------------------ SWITCH VIEW ------------------------
ButtonAlt.view:
if NOT fdpath
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
;--------------------------- END SWITCH VIEW ------------------------

;------------------------ DESTINATION SELECTED ----------------------
destsel:
Gui, ListView, destL
if A_GuiEvent <> Normal
	return
dselItemID := A_EventInfo
SB_SetText(dselItemID, 4)
return
;----------------------END DESTINATION SELECTED -------------------

;------------------------------ ASSIGN FILE ------------------------------
ButtonAssign:
if dselItemID =
	{
	MsgBox, Error!, You have not selected a destination label.
	return
	}
label%dselItemID% := debugPath
newPos := selItemID + 1
Gui, ListView, destL
LV_Modify(dselItemID, "Icon" . newPos)
Gui, Show
if debug
{
temp := label%dselItemID%
MsgBox, Debug message:`nImage #%selItemID% has been assigned to %dselItemID%`nlabel%dselItemID% = %debugPath%`n%temp%
}
return
;---------------------------- END ASSIGN FILE --------------------------

;------------------------------ DRAG'N'DROP ---------------------------
GuiDropFiles:
if A_GuiControl <> destL
	return
if dselItemID =
	return
if debug
	MsgBox, Debug message:`nA_GuiControl is %A_GuiControl%`ndselItemID is %dselItemID%
if ErrorLevel > 1
	{
	MsgBox, 48, Error!, You cannot assign more than one image to an emoticon label!
	return
	}
if NOT dragged
dragged := A_GuiEvent
label%dselItemID% := dragged
if debug
	MsgBox, %dragged% has been assigned to %dselItemID%
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
	MsgBox, 8257, Attention !, File already exists. Do you want to overwrite it?
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
	MsgBox, 64, Error !, There was an error writing to`n%filepath%
return
;-------------------------------- SAVE PACK -------------------------------

GuiClose:
ExitApp
