/*
	tooltipV2.ahk
	Version: 1.2
	By: Micahs
	
	CallWith: (You can use Hwnd, var, text, classnn)
	setTip("Button1", "This button does absolutely nothing.")   ;using the classnn
	setTip("Ok", "Begin the Process")   ;using the caption
	setTip("Cancel", "Cancel Whatever is Happening!")
	setTip(DDL, "Dropdownlist")   ;using the variable
	setTip(MYEdit, "The infamous edit control")   ;using the hwnd
*/

setTip(tipControl, tipText, guiNum=1)   ;tipControl - text,variable,hwnd,classnn ;   tipText - text to display ;   gui number, default is 1
{
	global
	local List_ClassNN
	Gui,%guiNum%:Submit,NoHide
	Gui,%guiNum%:+LastFound
	WinGet, tipGui_guiID, ID
	WinGet, List_ClassNN, ControlList
	StringReplace, List_ClassNN, List_ClassNN, `n, `,, All
	IfInString, tipControl, %List_ClassNN%	;it is a classnn
	{	tipGui_ClassNN := tipControl   ;use it as is
	}
	Else	;must be text/var or ID
	{	tipGui_ClassNN := tipGui_getClassNN(tipControl, guiNum)   ;get the classnn
	}
	tipGui_%guiNum%_%tipGui_ClassNN% := tipText   ;set the tip   
	If(!tipGui_Init)	;enable tooltips when the first one is set, but only if TipsState has not been called (either to enable or disable)
	{	TipsState(1)
	}
}

TipsState(ShowToolTips)
{
	global tipGui_Init
	tipGui_Init = 1	;iniialize this latch
	If(ShowToolTips)
	{	OnMessage(0x200, "WM_MOUSEMOVE")   ;enable tips
	}
	Else
	{	OnMessage(0x200, "")   ;disable tips
	}
}

WM_MOUSEMOVE()
{
	global
	Critical
	IfEqual, A_Gui,, Return
	MouseGetPos,,,tipGui_outW,tipGui_outC
	If(tipGui_outC != tipGui_OLDoutC)
	{	tipGui_OLDoutC := tipGui_outC
		Gui, %A_Gui%:+LastFound
		ToolTip,,,, 20
		tipGui_ID := WinExist()
		SetTimer, tipGui_killTip, 1000
		counter := A_TickCount + 500
		Loop
		{	 MouseGetPos,,,, tipGui_newC
			IfNotEqual, tipGui_outC, %tipGui_newC%, Return
			looper := A_TickCount
			IfGreater, looper, %counter%, Break
			sleep,50
		}

		tooltip, % tipGui_%A_Gui%_%tipGui_outC%,,, 20
	}
	Return
	tipGui_killTip:
	MouseGetPos,,, tipGui_outWm
	If(tipGui_outWm != tipGui_ID) or (A_TimeIdle >= 4000)
	{	SetTimer, tipGui_killTip, Off
		ToolTip,,,, 20
	}
	Return
}

tipGui_getClassNN(tipControl, g=1)   ;tipControl = text/var,Hwnd	;g = gui number, default=1
{
	Gui,%g%:+LastFound
	guiID := WinExist()   ;get the id for the gui
	WinGet, List_controls, ControlList
	StringReplace, List_controls, List_controls, `n, `,, All
	;if id supplied do nothing special
	IfNotInString, tipControl, %List_controls%	;must be the text/var - get the ID
	{	mm := A_TitleMatchMode
		SetTitleMatchMode, 3   ;exact match only
		ControlGet, o, hWnd,, %tipControl%	;get the id
		SetTitleMatchMode, %mm%   ;restore previous setting
		If(o)   ;found match
		{	tipControl := o   ;set sought-after id
		}
	}
	Loop, Parse, List_controls, CSV
	{	ControlGet, o, hWnd,, %A_LoopField%   ;get the id of current classnn
		If(o = tipControl)   ;if it is the one we want
		{	Return A_Loopfield   ;return the classnn
		}
	}
}