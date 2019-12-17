/*    
Kyokusen.
cockClock
*/


#SingleInstance force
#NoEnv 
SetBatchLines, -1
SetControlDelay, -1
SetWinDelay, -1
ListLines, Off
SetWorkingDir, %A_ScriptDir%
SendMode Input

Menu, Tray, NoStandard
Menu, Tray, Add, Hide clock, GuiContextMenu
Menu, Tray, Default, Hide clock
Menu, Tray, Add
Menu, Tray, Add, Reload, reload
Menu, Tray, Add, Exit, GuiClose

imgDir:= A_ScriptDir "\img\"
inifile := A_ScriptDir "\kyokusen.ini"
IniRead, pos, %inifile%, Preferences, pos, %A_Space%
Gui, +ToolWindow +AlwaysOnTop -Caption
Gui, Color, 000000
Gui, Font, s6 Bold cf0f0f0, FFF Galaxy
Gui, Add, Picture, AltSubmit BackgroundTrans 0x4000000 vBg x3 y3 gmoveit, %imgDir%bg.png

GuiAddClock("h")
GuiAddClock("r")
GuiAddClock("g")

Gui, Add, Text, cFFE000 BackgroundTrans Center Section x58 y0 vDate, 88
Gui, Show, % "NoActivate w100 h84 " (pos ? pos : "x20 y20"), kyokusen
WinSet, Region, 0-0 R10-10 w100 h84, kyokusen
;~ WinSet, TransColor,050505, kyokusen
Gosub, CheckTime
hCursM := DllCall("LoadCursor", "UInt", 0, "Int", 32646, "UInt")	; IDC_SIZEALL
Return

reload:
WinGetPos, x, y,,, kyokusen
IniWrite, x%x% y%y%, %inifile%, Preferences, pos
reload
GuiClose:
WinGetPos, x, y,,, kyokusen
IniWrite, x%x% y%y%, %inifile%, Preferences, pos
ExitApp

GuiContextMenu:
vis := !vis
Menu, Tray, Rename, % (vis ? "Hide" : "Show") " clock", % (vis ? "Show" : "Hide") " clock"
Gui, % vis ? "Hide" : "Show"
return

moveit:
DllCall("SetCursor", "UInt", hCursM)
PostMessage, 0xA1, 2,,, A
return

GuiAddClock(unit){
	global 	
	
	cnt := ((unit == "g") ? (4) : (((unit == "h") ? (12) : (11))))
	i = 0

	Loop, %cnt%
	{
		i++
		name:= unit i
		Gui, Add, Picture, AltSubmit BackgroundTrans Hidden v%name% x3 y3 gmoveit,% imgDir name ".png"
	}	
}

GuiHideClock(unit,cnt){
	global 	imgDir
	
	i:=cnt
	Loop, %cnt%
		{
			GuiControl, Hide,% unit i
			i--
		}	
}


ShowClock(unit, cnt){
	global imgDir
	
	i=0
	Loop, %cnt% {
		i++
		GuiControl,Show,% unit i
		Sleep, % ((unit=="g") ? (150) : (80))
	}

}


CheckTime:
SetTimer, CheckTime, Off
FormatTime, newMin,, mm
IfNotEqual, newMin, %curMin%
 UpdateTime(newMin)
curMin := newMin
SetTimer, CheckTime, 500
return


UpdateTime(min){
	global curH,curR,curG,curMin
	
	
	chkR := UpdateG(min)
	chkH := curH

	IfNotEqual, chkR, %curR%
	 chkH := UpdateR(chkR)
	curR := chkR
	
	If (chkH!=curH) {
	 UpdateH(chkH)
	 FormatTime, newDate,, dd
	 GuiControl,,Date,%newDate%
 WinSet, Region, 0-0 R10-10 w100 h84, kyokusen
}
 
	curH := chkH
}



UpdateG(newMin){
	global curG
	
	newR := newMin // 5
	newG := newMin-(newR*5)
	
	GuiHideClock("g",curG)
	
	curG := newG
	IfNotEqual, newG, 0
	 ShowClock("g", newG) 
	Return % newR
}

UpdateR(newR){
	global curR
	
	GuiHideClock("r",curR)
	IfNotEqual, newR, 0
	 ShowClock("r", newR)
	FormatTime, newH,, hh
	Return % newH

	
}


UpdateH(newH){
	global curH
	
	GuiHideClock("h",curH)
	IfNotEqual, newH, 0
	 ShowClock("h", newH)
}