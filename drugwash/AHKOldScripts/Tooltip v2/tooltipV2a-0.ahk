/*
	tooltipV2a.ahk (Alternate)
	Version: 1.0
	By: Micahs
	
	CallWith: (You can use Hwnd, var, text, classnn)
		setTip("Ok", "Why would you ever need a tooltip that looks like this?", "", "", "C:\WINDOWS\system32\shell32.dll", "Icon24")	;using imgPath&imgoptions
		setTip("Retry", "Maybe do something again.", "", "", "", "Icon147")	;use imgOptions to set a different icon
		setTip("Cancel", "Cancel whatever is happening.", "", "", "", "Icon132")	;use imgOptions to set a different icon
		setTip("Click to enable", "Click to do something.", "", "", " ")	;use blank imgPath to show no icon if default already set
		setTip(MYEdit, "The infamous edit control", "", "", " ")   ;use blank imgPath to show no icon if default already set
		setTip(DDL, "Dropdownlist: for to drop down lists")   ;icon not given, using default
	
	setTip Parameters:
	1) tipControl - This is the control (Specify Hwnd, var, text, classnn)
	2) tipText - This is the caption to dispay. Specify "" to disable this tip. Specify " " to enable image only tip.
	3) guiNum - Gui number of where the control is (default is 1)
	4) tipGuiOpts - Options for the tooltip gui. Specify any or none of the following:
				A. Width, Height (default is autosize)		EG: "w100" or "w" . varcontainingwidth
				B. TextColor (RGB, defaults to standard tooltip color)		EG: "C0xFFFFFF" or "C" . varcontainingcolor
				C. BackgroundColor (RGB, defaults to standard tooltip color)		EG: "BGC0xFFFFFF" or "BGC" . varcontainingcolor
				D: Font (defaults to whatever guis default to)		EG: "Font10" or "Font" . varcontainingfont
				E: Font Size (defaults to whatever guis default to)		EG: "s10" or "s" . varcontainingfontsize
				Not Implemented	F. Transparency (0-255)		EG: "Transparency100" or "Transparency" . varcontainingtrans
				Not Implemented	G. TransColor (RGB)		EG: "TransColor0xFFFFFF" or "TransColor" . varcontainingtranscolor
				H. Border (1 or 0)		EG: "Border1" or "Border" . varcontainingbordervalue
				-  To use several options together, you must leave a space between them.		EG: "FontArial s10 C0xFFFFFF"
	5) tipImgPath - Location of the image to use
	6) tipImgOpts - Options for the image. Specify any or none of the following:
				A. Icon Group		EG: "Icon25" or "Icon" . varcontainingicongroup
				B. x,y
				C. W,H
				D. Altsubmit
				E. BackgroundTrans
				-  To use several options together, you must leave a space between them.		EG: "Icon25 x5 y5 Altsubmit"
	
	setTip_Defaults Parameters (See above for details):
	1) guiNum - Gui number of where the control is (default is 1)
	2) tipGuiOpts - Options for the tooltip gui. Specify any or none of the following:
	3) tipImgPath - Location of the image to use
	4) tipImgOpts - Options for the image. Specify any or none of the following:
	
*/

setTip_Defaults(guiNum=1, tipGuiOpts="", tipImgPath="", tipImgOpts="")	;set the tooltip defaults so we don't have to mess with it in the setTip call - optional
{	
	global
	tipGui_SetFirstAsDefault = 0	;turn this off 'cause we're doing it here
	tipGuiOpts := " " . tipGuiOpts . " "	;add a space to the beginning and end so we can have consistent regexmatches
	StringReplace, tipGuiOpts, tipGuiOpts, 0x,, All	;get rid of the "0x" in colors to avoid gui confusion
	RegExMatch(tipGuiOpts, " (Border)0 ", tipGui_Border), tipGui_Border := tipGui_Border1 ? "-" . tipGui_Border1 ;pull out some stuff from the guiOpts (Border, trans, transcolor, ...) (All of the stuff that we extract will also be left in bacuase they will be ignored by the gui command!)
	RegExMatch(tipGuiOpts, " Transparency([\d]+) ", tipGui_Transparency), tipGui_Transparency := tipGui_Transparency1
	RegExMatch(tipGuiOpts, " TransColor([\d]+) ", tipGui_TransColor), tipGui_TransColor := tipGui_TransColor1
	RegExMatch(tipGuiOpts, " Font(.*?) ", tipGui_Font), tipGui_Font := tipGui_Font1
	RegExMatch(tipGuiOpts, " (s.*?) ", tipGui_FontSize), tipGui_FontSize := tipGui_FontSize1
	RegExMatch(tipGuiOpts, " (C.*?) ", tipGui_FontColor), tipGui_FontColor := tipGui_FontColor1
	RegExMatch(tipGuiOpts, " BGC(.*?) ", tipGui_BackgroundColor), tipGui_BackgroundColor := tipGui_BackgroundColor1
	If(!tipGui_Init)	;only need to do this once
	{	tipGui_BG := GetSysColor(COLOR_INFOBK := 24)	;get Background color for tooltips
		tipGui_FG := GetSysColor(COLOR_INFOTEXT  := 23)	;get text color for tooltips
	}
	tipGui_Default_tipGuiOpts := tipGui_Default_tipGuiOpts ? tipGui_Default_tipGuiOpts : tipGuiOpts	;set the default stuff (only set on the first use of each item)
	tipGui_Default_tipImgPath := tipGui_Default_tipImgPath ? tipGui_Default_tipImgPath : tipImgPath
	tipGui_Default_tipImgOpts := tipGui_Default_tipImgOpts ? tipGui_Default_tipImgOpts : tipImgOpts
	tipGui_Default_Border := tipGui_Default_Border ? tipGui_Default_Border : tipGui_Border
	tipGui_Default_Border := !tipGui_Default_Border ? "+Border" : tipGui_Default_Border	;if no default border, make it turned on
	tipGui_Default_Transparency := tipGui_Default_Transparency ? tipGui_Default_Transparency : tipGui_Transparency
	tipGui_Default_TransColor := tipGui_Default_TransColor ? tipGui_Default_TransColor : tipGui_TransColor
	tipGui_Default_Font :=tipGui_Default_Font ? tipGui_Default_Font : tipGui_Font
	tipGui_Default_FontColor := tipGui_Default_FontColor ? tipGui_Default_FontColor : tipGui_FontColor
	tipGui_Default_FontColor := !tipGui_Default_FontColor ? tipGui_FG : tipGui_Default_FontColor	;if none given, use the default color for tooltips
	tipGui_Default_BackgroundColor := tipGui_Default_BackgroundColor ? tipGui_Default_BackgroundColor : tipGui_BackgroundColor
	tipGui_Default_BackgroundColor := !tipGui_Default_BackgroundColor ? tipGui_BG : tipGui_Default_BackgroundColor	;if none given, use the default bgcolor for tooltips
	tipGui_Default_FontSize := tipGui_Default_FontSize ? tipGui_Default_FontSize : tipGui_FontSize
	If(!tipGui_Init)	;enable tooltips when the first one is set, but only if TipsState has not been called (either to enable or disable)
	{	TipsState(1)
	}
}

setTip(tipControl, tipText, guiNum=1, tipGuiOpts="", tipImgPath="", tipImgOpts="")   ;tipControl - text,variable,hwnd,classnn ;   tipText - text to display ;   gui number (default is 1); tipGuiOptions = actual gui setup; tipImgPath; tipImgOpts
{
	global
	local List_ClassNN
	tipGui_SetFirstAsDefault = 1	;only make default vals if enabled (not doing this means that every tip that needs an icon has to be explicitly set)
	tipGui_GuiNum=99	;this is the gui for the custom tooltips
	guiNum := !guiNum ? 1 : guiNum
	Gui,%guiNum%:Submit, NoHide
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
	If(!tipGui_Init)	;only need to do this once
	{	tipGui_BG := GetSysColor(COLOR_INFOBK := 24)	;get Background color for tooltips
		tipGui_FG := GetSysColor(COLOR_INFOTEXT  := 23)	;get text color for tooltips
	}
	
	tipGuiOpts := " " . tipGuiOpts . " "	;add a space to the beginning and end so we can have consistent regexmatches
	StringReplace, tipGuiOpts, tipGuiOpts, 0x,, All	;get rid of the "0x" in colors to avoid gui confusion
	RegExMatch(tipGuiOpts, " (Border)0 ", tipGui_Border), tipGui_Border := tipGui_Border1 ? "-" . tipGui_Border1 ;pull out some stuff from the guiOpts (Border, trans, transcolor, ...) (All of the stuff that we extract will also be left in because they will be ignored by the gui command!)
	RegExMatch(tipGuiOpts, " Transparency([\d]+) ", tipGui_Transparency), tipGui_Transparency := tipGui_Transparency1
	RegExMatch(tipGuiOpts, " TransColor([\d]+) ", tipGui_TransColor), tipGui_TransColor := tipGui_TransColor1
	RegExMatch(tipGuiOpts, " Font(.*?) ", tipGui_Font), tipGui_Font := tipGui_Font1
	RegExMatch(tipGuiOpts, " (s.*?) ", tipGui_FontSize), tipGui_FontSize := tipGui_FontSize1
	RegExMatch(tipGuiOpts, " (C.*?) ", tipGui_FontColor), tipGui_FontColor := tipGui_FontColor1
	RegExMatch(tipGuiOpts, " BGC(.*?) ", tipGui_BackgroundColor), tipGui_BackgroundColor := tipGui_BackgroundColor1

	tipGui_%guiNum%_%tipGui_ClassNN%_tipText := tipText   ;set the tip text and other per-tip stuff
	tipGui_%guiNum%_%tipGui_ClassNN%_GuiOpts := tipGuiOpts
	tipGui_%guiNum%_%tipGui_ClassNN%_ImgPath := tipImgPath
	tipGui_%guiNum%_%tipGui_ClassNN%_ImgOpts := tipImgOpts
	tipGui_%guiNum%_%tipGui_ClassNN%_Border := tipGui_Border
	tipGui_%guiNum%_%tipGui_ClassNN%_Transparency := tipGui_Transparency
	tipGui_%guiNum%_%tipGui_ClassNN%_TransColor := tipGui_TransColor
	tipGui_%guiNum%_%tipGui_ClassNN%_Font := tipGui_Font
	tipGui_%guiNum%_%tipGui_ClassNN%_FontSize := tipGui_FontSize
	tipGui_%guiNum%_%tipGui_ClassNN%_FontColor := tipGui_FontColor
	tipGui_%guiNum%_%tipGui_ClassNN%_BackgroundColor := tipGui_BackgroundColor

	If(tipGui_SetFirstAsDefault)	;only make default vals if enabled (not doing this means that every tip that needs an icon has to be explicitly set, also text size, gui color...)
	{	tipGui_Default_tipGuiOpts := tipGui_Default_tipGuiOpts ? tipGui_Default_tipGuiOpts : tipGuiOpts	;set the default stuff (only set on the first use of each item)
		tipGui_Default_tipImgPath := tipGui_Default_tipImgPath ? tipGui_Default_tipImgPath : tipImgPath
		tipGui_Default_tipImgOpts := tipGui_Default_tipImgOpts ? tipGui_Default_tipImgOpts : tipImgOpts
		tipGui_Default_Border := tipGui_Default_Border ? tipGui_Default_Border : tipGui_Border
		tipGui_Default_Border := !tipGui_Default_Border ? "+Border" : tipGui_Default_Border	;if no default border, make it turned on
		tipGui_Default_Transparency := tipGui_Default_Transparency ? tipGui_Default_Transparency : tipGui_Transparency
		tipGui_Default_TransColor := tipGui_Default_TransColor ? tipGui_Default_TransColor : tipGui_TransColor
		tipGui_Default_Font :=tipGui_Default_Font ? tipGui_Default_Font : tipGui_Font
		tipGui_Default_FontColor := tipGui_Default_FontColor ? tipGui_Default_FontColor : tipGui_FontColor
		tipGui_Default_FontColor := !tipGui_Default_FontColor ? tipGui_FG : tipGui_Default_FontColor	;if none given, use the default color for tooltips
		tipGui_Default_BackgroundColor := tipGui_Default_BackgroundColor ? tipGui_Default_BackgroundColor : tipGui_BackgroundColor
		tipGui_Default_BackgroundColor := !tipGui_Default_BackgroundColor ? tipGui_BG : tipGui_Default_BackgroundColor	;if none given, use the default bgcolor for tooltips
		tipGui_Default_FontSize := tipGui_Default_FontSize ? tipGui_Default_FontSize : tipGui_FontSize
	}

	If(!tipGui_Init)	;enable tooltips when the first one is set, but only if TipsState has not been called (either to enable or disable)
	{	TipsState(1)
	}
}

TipsState(ShowToolTips)
{
	global
	If(!tipGui_Init)	;only need to do this once
	{	tipGui_Init = 1	;iniialize this latch
		SysGet, SM_CYCURSOR, 14	;estimate size of cursor (find better way)
	}
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
		Gui, %tipGui_GuiNum%:Destroy
		Gui, %A_Gui%:+LastFound
		tipGui_ID := WinExist()
		SetTimer, tipGui_killTip, 1000
		counter := A_TickCount + 500
		Loop
		{	 MouseGetPos,,,, tipGui_newC
			IfNotEqual, tipGui_outC, %tipGui_newC%, Return
			looper := A_TickCount
			IfGreater, looper, %counter%, Break
			sleep, 50
		}
		
		tipGui_tipText := tipGui_%A_Gui%_%tipGui_newC%_tipText	;set the vals for the current tip (use the default vals if per-tip vals not given)
		tipGui_guiOpts := tipGui_%A_Gui%_%tipGui_newC%_GuiOpts ? tipGui_%A_Gui%_%tipGui_newC%_GuiOpts : tipGui_Default_tipGuiOpts
		tipGui_tipImgPath := tipGui_%A_Gui%_%tipGui_newC%_ImgPath ? tipGui_%A_Gui%_%tipGui_newC%_ImgPath : tipGui_Default_tipImgPath
		tipGui_tipImgOpts := tipGui_%A_Gui%_%tipGui_newC%_ImgOpts ? tipGui_%A_Gui%_%tipGui_newC%_ImgOpts : tipGui_Default_tipImgOpts
		tipGui_Font := tipGui_%A_Gui%_%tipGui_newC%_Font ? tipGui_%A_Gui%_%tipGui_newC%_Font : tipGui_Default_Font
		tipGui_FontColor := tipGui_%A_Gui%_%tipGui_newC%_FontColor ? tipGui_%A_Gui%_%tipGui_newC%_FontColor : tipGui_Default_FontColor
		tipGui_BackgroundColor := tipGui_%A_Gui%_%tipGui_newC%_BackgroundColor ? tipGui_%A_Gui%_%tipGui_newC%_BackgroundColor : tipGui_Default_BackgroundColor
		tipGui_FontSize := tipGui_%A_Gui%_%tipGui_newC%_FontSize ? tipGui_%A_Gui%_%tipGui_newC%_FontSize : tipGui_Default_FontSize
		tipGui_Border := tipGui_%A_Gui%_%tipGui_newC%_Border ? tipGui_%A_Gui%_%tipGui_newC%_Border : tipGui_Default_Border
		
		If(tipGui_tipText)
		{	Gui, %tipGui_GuiNum%:Default
			Gui, +ToolWindow -Caption +AlwaysOnTop +LastFound %tipGui_Border%
			Gui, Color, %tipGui_BackgroundColor%
			Gui, Font, %tipGui_FontColor% %tipGui_Font% %tipGui_FontSize%	;set the font color and size
			If(tipGui_tipImgPath) and (tipGui_tipImgPath != " ")	;if there is an image given
			{	Gui, Margin, 2, 5
				Gui, Add, Picture, vtipGui_Pic %tipGui_tipImgOpts%, %tipGui_tipImgPath%
				GuiControlGet, tipGui_Pic_, Pos, tipGui_Pic
				tipGui_Pic_Mid := tipGui_Pic_Y+tipGui_Pic_H/2
				tipGui_Text_X = x+2	;make it current x val plus 2
			}
			Else
			{	tipGui_Pic_Mid = 1
				tipGui_Text_X =
			}
			If(tipGui_tipText) and (tipGui_tipText != " ")
			{	Gui, Margin, 5, 3
				Gui, Add, Text, vtipGui_Text %tipGui_Text_X% +BackgroundTrans Section, %tipGui_tipText%
				If(tipGui_Pic_Mid != 1)
				{	GuiControlGet, tipGui_text_, Pos, tipGui_Text	;vert center it on the image
					tipGui_text_Y := tipGui_Pic_Mid-(tipGui_text_H/2)
					GuiControl, Move, tipGui_Text, y%tipGui_text_Y%
				}
			}
			CoordMode, Mouse, Screen
			CoordMode, Tooltip, Screen
			MouseGetPos, tipGui_X, tipGui_Y
			tipGui_Y += SM_CYCURSOR/2+5
			Gui, Show, x%tipGui_X% y%tipGui_Y% NA %tipGui_guiOpts%
		}
	}
	Return
	tipGui_killTip:
	MouseGetPos,,, tipGui_outWm
	If(tipGui_outWm != tipGui_ID) or (A_TimeIdle >= 4000)
	{	SetTimer, tipGui_killTip, Off
		Gui, %tipGui_GuiNum%:Destroy
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

GetSysColor(d_element)	;thanks SKAN
{ 
	A_FI:=A_FormatInteger 
	SetFormat, Integer, Hex 
	BGR:=DllCall("GetSysColor" , Int,d_element)+0x1000000 
	SetFormat,Integer,%A_FI% 
	StringMid,R,BGR,8,2 
	StringMid,G,BGR,6,2 
	StringMid,B,BGR,4,2 
	RGB := R G B 
	StringUpper,RGB,RGB 
	Return RGB 
}
