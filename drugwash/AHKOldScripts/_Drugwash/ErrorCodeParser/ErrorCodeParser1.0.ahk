; © Drugwash oct2008
; Error Code Parser
; parses known WinAPI error codes found in WINERROR.H

debug := 0
Gui, Add, ListView, x10 y30 w530 h300 -Multi NoSortHdr ReadOnly AltSubmit Sort Hidden vErrlist gDetails, Code|Brief|Details
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
	if (type3 = "#define FACILITY")
		continue
	if not line1
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
GuiControl, Show, Errlist
If A_OSVer in WIN_XP,WIN_VISTA
	LV_ModifyCol(0, "Auto Logical")
else
	{
	LV_ModifyCol(1, "Auto CaseLocale")
	LV_ModifyCol(2, "Auto CaseLocale")
	LV_ModifyCol(3, "Auto CaseLocale")
	}
Gui, Show, x420 y85 w250 h350 AltSubmit, ErrorCodeParser
Gui, +Resize -MaximizeBox +MinSize250x350 +MaxSize1000x720
Gui, Submit, NoHide
return

GuiSize:
GuiControl, -Redraw, Errlist
listh := A_GuiHeight - 40
listw := A_GuiWidth - 20
GuiControl, Move, Errlist, % "h" listh "w" listw
Gui, Submit, NoHide
GuiControl, +Redraw, Errlist
If A_OSVer in WIN_XP,WIN_VISTA
	LV_ModifyCol(0, "Auto Logical")
else
	{
	LV_ModifyCol(1, "Auto CaseLocale")
	LV_ModifyCol(2, "Auto CaseLocale")
	LV_ModifyCol(3, "Auto CaseLocale")
	}
return

Details:
;MsgBox, this is not ready yet
return

GuiClose:
ExitApp

GetError(code)
{
MsgBox, should get data from a listview
return
}