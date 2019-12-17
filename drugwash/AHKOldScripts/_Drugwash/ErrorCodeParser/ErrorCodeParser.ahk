; © Drugwash oct2008
; Error Code Parser
; parses known WinAPI error codes found in WINERROR.H
; version 1.1

debug := 0
service := 0
Gui, Add, Edit, x10 y4 w195 h14 r1 vsearch gdig, %srch%
Gui, Add, Text, x14 y7 vhint BackgroundTrans C808080, Search by error code
Gui, Add, Text, x210 y7 w295 r1 AltSubmit vbrf, %briefex%
Gui, Add, Text, x10 y28 w530 r1 AltSubmit vdisp, %display%
Gui, Add, ListView, x10 y45 w530 h265 -Multi NoSortHdr ReadOnly AltSubmit Sort Hidden vErrlist gDetails, Error code|Brief explanation|Details
if FileExist("ECPpath.ini")
	{
	Loop, Read, ECPpath.ini
	loadhdr := A_LoopReadLine
	goto readme
	}
selfile:
FileSelectFolder, loadpath,, 3, Please select the folder containing the error code header:
if ErrorLevel
	goto selfile
Loop, %loadpath% . \winerror.h
	file := A_LoopFileName
loadhdr := loadpath . "\" . file
if debug
	MsgBox, Folder name is %loadpath%`nHeader path is %loadhdr%
ifnotexist %loadhdr%
	{
	MsgBox, 48, Error !, The chosen path does not contain the header file!
	goto selfile
	}
FileAppend, %loadhdr%, ECPpath.ini
readme:
if service
	goto skip
VarSetCapacity(line1, 255, 0)
VarSetCapacity(line2, 255, 0)
entries := 1
Loop, Read, %loadhdr%
	{
	line1 := A_LoopReadLine
	line0 := A_Index
	StringLeft, type1, line1, 2	; comment
	StringLeft, type2, line1, 7	; #define
	StringLeft, type3, line1, 16	; #define FACILITY
	StringLeft, type4, line1, 13	; MessageId
	if (type3 = "#define FACILITY" || not line1)
		continue
	if (type4 = "// MessageID:")
		{
		count := 6
		continue
		}
	if (type1 = "//" && count = 3)
		{
		StringTrimLeft, message, line1, 4
		count--
		continue
		}
	if (type2 = "#define" && count = 1)
		{
		line3 := RegExReplace(line1, " * ", "•", "", -1, 1)
		StringSplit, bulk, line3, •, %A_Space% %A_Tab% `/
		brief := bulk2
		bulk3 := RegExReplace(bulk3, "(?<=[0-9])L|L(?=\))", "", "", -1, 1)
		code := bulk3
		LV_Add("Icon99999", code, brief, message)
		if debug
			MsgBox, Line %line0% in main file`nEntry %entries% in list`n`nline1=%line1%`nline2=%line2%`ntype1=%type1%`ntype2=%type2%`ntype3=%type3%`ntype4=%type4%`ncount=%count%`ncode=%code%`nbrief=%brief%`nmessage=%message%`n`nTotal: %bulk0%. %bulk4%, %bulk5%, %bulk6%, %bulk7%, %bulk8%, %bulk9%
		entries++
		}
	if count
		count--
	}
skip:
GuiControl, Show, Errlist
If A_OSVer in WIN_XP,WIN_VISTA
	LV_ModifyCol(0, "AutoHdr Logical")
else
	{
	LV_ModifyCol(1, "AutoHdr CaseLocale")
	LV_ModifyCol(2, "AutoHdr CaseLocale")
	LV_ModifyCol(3, "AutoHdr CaseLocale")
	}
Gui, Show, w550 h350 AltSubmit, ErrorCodeParser
Gui, +Resize -MaximizeBox +MinSize250x350 +MaxSize1000x720
Gui, Submit, NoHide
return

GuiSize:
GuiControl, -Redraw, Errlist
listh := A_GuiHeight - 55
listw := A_GuiWidth - 20
dispw := A_GuiWidth - 20
GuiControl, Move, Errlist, % "h" listh "w" listw
GuiControl, Move, disp, % "w" dispw
Gui, Submit, NoHide
GuiControl, +Redraw, Errlist
If A_OSVer in WIN_XP,WIN_VISTA
	LV_ModifyCol(0, "AutoHdr Logical")
else
	{
	LV_ModifyCol(1, "AutoHdr CaseLocale")
	LV_ModifyCol(2, "AutoHdr CaseLocale")
	LV_ModifyCol(3, "AutoHdr CaseLocale")
	}
return

dig:
If search
	GuiControl, Hide, hint
Gui, Submit, NoHide
;MsgBox, this is supposed to search incrementally in realtime
return

Details:
If ! search
	GuiControl, Show, hint
if A_GuiEvent not in Normal,RightClick
	return
LV_GetText(display, A_EventInfo, 3)
LV_GetText(briefex, A_EventInfo, 2)
LV_GetText(srch, A_EventInfo, 1)
GuiControl,, disp, %display%
GuiControl,, brf, %briefex%
GuiControl,, search, %srch%
if A_GuiEvent = RightClick
	clipboard := display
Gui, Submit, NoHide
;MsgBox, this is not ready yet
return

GuiClose:
ExitApp

GetError(code)
{
MsgBox, should get data from a listview
return
}
