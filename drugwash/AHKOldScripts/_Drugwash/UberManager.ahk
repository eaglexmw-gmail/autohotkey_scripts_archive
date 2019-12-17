; (c) Drugwash Oct2008
; an idea of centralizing information


DriveGet, AllDrv, List,	; all drives listed
; Retrieve total number of drives with StrLen or something, in drvno
Loop, drvno
	{
	DriveGet, type%A_Index%, List, AllDrv%A_Index%	; drive type
	DriveGet, cap%A_Index%, Cap, AllDrv%A_Index%	; get capacity for each drive
	DriveGet, FS%A_Index%, FS, AllDrv%A_Index%	; get file system for each drive
	if ErrorLevel
		MsgBox, Unformatted or unknown file system.
	DriveGet, lab%A_Index%, Label, AllDrv%A_Index%	; get labels
	DriveGet, ser%A_Index%, Serial, AllDrv%A_Index%	; get serials (useful for ejectable media)
	DriveGet, stat%A_Index%, Status, AllDrv%A_Index%	; get status
; optional
	DriveGet, statCD%A_Index%, StatusCD, AllDrv%A_Index%	; get CD status
	}
return

GuiClose:
ExitApp
