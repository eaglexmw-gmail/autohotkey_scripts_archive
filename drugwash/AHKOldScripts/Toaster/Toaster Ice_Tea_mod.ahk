; Animation options:
;AW_HOR_POSITIVE	0x00000001
;AW_HOR_NEGATIVE	0x00000002
;AW_VER_POSITIVE	0x00000004
;AW_VER_NEGATIVE	0x00000008
;AW_CENTER			0x00000010
;AW_HIDE			0x00010000
;AW_ACTIVATE		0x00020000
;AW_SLIDE			0x00040000
;AW_BLEND			0x00080000
; 123456789
; RLDUCHASB
; Background, Actions, Freeze on hover

Title = This Title is Bold and optional
Message = This is normal text. You can display a bunch of information here.`nLet's see if it does linebreaks.
Lifespan = 7000 ;ms
FontSize = 8
FontColor := 0xffffff
BGColor := 0xE3F2FE
FontFace=Arial
Pic:="avatar.jpg"
Back:="back.png"
Effect=5756
;Effect=847836
;Effect=827836

tempvar := Toast(Title, Message, Effect, Lifespan, Back, Pic, 56, "Test", 5, 9, 8, FontColor)
Toast_Wait()
GuiClose:
ExitApp

Test:
SetTimer, Toast_Fade, OFF
;	MsgBox, , TP Callback Test, Event received:  %TP_GuiEvent%      `
return

;Use: Toast([ Title, Message, Effects, Lifespan, BackgroundPath, PicPath, PicSize, CallbackLabel, EffectSpeed, TitleSize, FontSize, FontColor, BGColor, FontFace ])   
Toast(TP_Title="", TP_Message="", eff="827816", TP_Lifespan=0, BPath="", Path="", pw="48", TP_CallBack="", TP_Speed="10", TP_TitleSize="9", TP_FontSize="8", TP_FontColor="0x00437e", TP_BGColor="0xE3F2FE",  TP_FontFace="")
	{
	Global TP_GuiEvent
	Static TP_CallBackTarget, TP_GUI_ID, Speed, bkg, dirI, dirO, INeff:=0x0, OUTeff:=0x0, p1:=0x1, p2:=0x2, p3:=0x4, p4:=0x8, p5:=0x10, p6:=0x10000, p7:=0x20000, p8:=0x40000, p9:=0x80000
	str=0x0 + 0
	Loop, parse, eff
		{
		tt := p%A_LoopField%
		str += %tt%
		if A_LoopField in 6
			{
			OUTeff:=str
			str=
			}
		else if A_LoopField in 7
			{
			INeff:=str
			str=
			}
		}
	TP_CallBackTarget := TP_CallBack
	Speed:= TP_Speed
	pz:=pw+6
	DetectHiddenWindows, On
	SysGet, Workspace, MonitorWorkArea
	Gui, 89:Destroy
	Gui, 89:-Caption +ToolWindow +LastFound +AlwaysOnTop +Border
	Gui, 89:Add, Picture, x0 y0 vbkg, %BPath%
	Gui, 89:Color, %TP_BGColor%
	If (TP_Title)
		{
		TP_TitleSize := TP_FontSize + 1
		Gui, 89:Font, s%TP_TitleSize% c%TP_FontColor% w700, %TP_FontFace%
		Gui, 89:Add, Text, BackgroundTrans r1 gToast_Fade x%pz% y3, %TP_Title%
		Gui, 89:Margin, 0, 0
		}
	Gui, 89:Font, s%TP_FontSize% c%TP_FontColor% w400, %TP_FontFace%
	Gui, 89:Add, Text, BackgroundTrans gToast_Fade x%pz% y+5, %TP_Message%
	if Path
		Gui, 89:Add, Picture, w%pw% h-1 x3 y3, %Path%
	IfNotEqual, TP_Title,, Gui, 89:Margin, 5, 5
	Gui, 89:Show, Hide, TP_Gui
	TP_GUI_ID := WinExist("TP_Gui")
	WinGetPos, , , GUIWidth, GUIHeight, ahk_id %TP_GUI_ID%
	if (INeff & 1 OR INeff & 2)
		dirI:=GUIHeight
	else
	if (INeff & 4 OR INeff & 8 OR INeff & 16)
		dirI:=GUIWidth
	if (OUTeff & 1 OR OUTeff & 2)
		dirO:=GUIHeight
	else
	if (OUTeff & 4 OR OUTeff & 8 OR OUTeff & 16)
		dirO:=GUIWidth
	NewX := WorkSpaceRight-GUIWidth-5
	NewY := WorkspaceBottom-GUIHeight-5
	Gui, 89:Show, Hide x%NewX% y%NewY%
	GuiControl, 89:Move, Static1, % "w" . GuiWidth-pz-3
	GuiControl, 89:Move, Static2, % "w" . GuiWidth-pz-3
	GuiControl, 89:Move, bkg, % "w" . GuiWidth "h" . GuiHeight
	DllCall("AnimateWindow","UInt", TP_GUI_ID,"Int", dirI*Speed,"UInt", INeff)
	If (TP_Lifespan)
		SetTimer, Toast_Fade, -%TP_Lifespan%
	Return TP_GUI_ID

89GuiContextMenu:
Toast_Fade:
	TP_GuiEvent := A_GuiEvent
	If (TP_GuiEvent and TP_CallBackTarget)
		{
		If IsLabel(TP_CallBackTarget)
			Gosub, %TP_CallBackTarget%
		else
			{
			If InStr(TP_CallBackTarget, "(")
				Msgbox Cannot yet callback a function
			else
				Msgbox, not a valid CallBack
			}
		}
	DllCall("AnimateWindow","UInt", TP_GUI_ID,"Int", dirO*Speed,"UInt", OUTeff)
	Gui, 89:Destroy
	Return
	}

Toast_Wait(TP_GUI_ID="")
	{
	If not (TP_GUI_ID)
		TP_GUI_ID := WinExist("TP_Gui")
	WinWaitClose, ahk_id %TP_GUI_ID%
	}
