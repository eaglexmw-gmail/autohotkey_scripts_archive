; 0 Unknown, 1 Path invalid, 2 Removable, 3 Fixed, 4 Remote (network), 5 CD-ROM, 6 RAM Disk
t0 = Unknown
t1 = Invalid path
t2 = Removable
t3 = Fixed
t4 = Remote (network)
t5 = CD-ROM
t6 = RAM Disk
Gui, Add, Button,, GetLogicalDriveStrings
Gui, Add, Button,, GetDriveType
Gui, Show
return
; ***********************************
ButtonGetLogicalDriveStrings:
strg =
Loop, %nmb%
	strg%A_Index% =
VarSetCapacity(Buffer, 100, 0)
string := DllCall("GetLogicalDriveStrings", UInt, 100, UInt, &Buffer)
if ErrorLevel
	MsgBox, Error %ErrorLevel%
nmb = 1
Loop, %string%
	{
	ch := NumGet(Buffer, A_Index - 1, "UChar")
	if ch = 0
		{
		StringUpper, strg%nmb%, strg%nmb%
		nmb++
		continue
		}
	strg%nmb% := strg%nmb% . Chr(ch)
	}
nmb--
Loop, %nmb%
	strg := strg . "`n" . strg%A_Index%
MsgBox, Detected drives: %strg%
return
; ***********************************
ButtonGetDriveType:
typ =
if ! strg1
	return
Loop, %nmb%
	{
	drv := strg%A_Index%
	tp := typ%A_Index% := DllCall("GetDriveType", Str, drv, UInt)
	typ := typ . "`n" . t%tp%
	if ErrorLevel
		MsgBox, Error %ErrorLevel%
	}
MsgBox, Types: %typ%
return
; kernel32.dll
; ***********************************

GuiClose:
ExitApp
