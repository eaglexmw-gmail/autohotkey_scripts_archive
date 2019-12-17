/*    
Kyokusen.
cockClock
*/


#SingleInstance force
#NoEnv 
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
SendMode Input

imgDir:= A_ScriptDir "\img\"

Gui, +ToolWindow +AlwaysOnTop
Gui, Color, 000000
Gui, Font, s6 Bold cf0f0f0, FFF Galaxy
Gui, Add, Picture, AltSubmit BackgroundTrans vBg x3 y3, %imgDir%bg.png

GuiAddClock("h")
GuiAddClock("r")
GuiAddClock("g")

Gui, Add, Text, CFFE000 BackgroundTrans Center Section x58 y0 vDate, 88
Gui, Show, NoActivate w100 h84 x20 y20, kyokusen
;~ WinSet, TransColor,050505, kyokusen
Gosub, CheckTime

Return


GuiAddClock(unit){
	global 	
	
	cnt := ((unit == "g") ? (4) : (((unit == "h") ? (12) : (11))))
	i = 0

	Loop, %cnt%
	{
		i++
		name:= unit i
		Gui, Add, Picture, AltSubmit BackgroundTrans Hidden v%name% x3 y3,% imgDir name ".png"
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