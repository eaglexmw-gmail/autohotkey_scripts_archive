DetectHiddenWindows, On

;set drives here
Drives = CDEF

Gui, +ToolWindow -Border

;transparency
Gui, Color, FF33FF

;keep updating PosY after every item added
PosY = 7

Loop, Parse, Drives
{
	BarPos := PosY + 2
	Gui, Add, Text, x6 y%PosY% w20 h20, %A_LOOPFIELD%:
	Gui, Add, Progress, x26 y%BarPos% w60 h10 vBar%A_Index%,
	PosY += 20
}
PosY += 20

FormatTime, CurrTime, , h:mm tt 
Gui, Add, Text, x6 y%PosY% w80 h40 vTime, %CurrTime%`n%A_DD% %A_MMM%`, %A_DDDD%
PosY += 40
 
Gui, Show, x684 y250 h%PosY% w95, DeskBar

WinSet, TransColor, FF33FF, DeskBar

WinGet, Prnt, ID, Program Manager
WinGet, Chld, ID, DeskBar
DllCall("SetParent", Int, Chld, Int, Prnt)




Gosub, CheckFree
SetTimer, CheckFree, 30000
SetTimer, TimeShow, 1000
Return

GuiClose:
ExitApp


CheckFree:
	Loop, Parse, Drives
	{
		DriveGet, %A_LOOPFIELD%_Cap, Capacity, %A_LOOPFIELD%:
		DriveSpaceFree, %A_LOOPFIELD%_Free, %A_LOOPFIELD%:
		%A_LOOPFIELD%_Bar := ( %A_LOOPFIELD%_Cap - %A_LOOPFIELD%_Free ) / %A_LOOPFIELD%_Cap * 100
		GuiControl,, Bar%A_Index%, % %A_LOOPFIELD%_Bar
	}
Return

TimeShow:
	FormatTime, CurrTime,, h:mm tt 
	GuiControl,, Time, %CurrTime%`n%A_DD% %A_MMM%`, %A_DDDD%
Return
