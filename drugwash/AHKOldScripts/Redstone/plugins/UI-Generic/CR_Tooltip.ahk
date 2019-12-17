tooltip_Initialize() {
	global showingTT = 0
	global PrevControl = 0

	CommandRegister("UI Tooltip", "ui_Tooltip")

	NotifyRegister("UI Deactivate", "tooltip_Deactivate")
	NotifyRegister("UI Activate", "tooltip_Activate")
}

tooltip_Activate(A_Command, A_Args) {
	OnMessage(0x200, "WM_MOUSEOVER")
}

tooltip_Deactivate(A_Command, A_Args) {
	SetTimer, HoveredToolTip,off
	OnMessage(0x200, "")
;	OnMessage(0x205, "")

	Tooltip
}

WM_MOUSEOVER(wParam, lParam) {
	MouseGetPos, , , , control
	toolbar_MouseOver(control)
}

toolbar_MouseOver(GuiControl) {
   global
   CurrControl := GuiControl
   If (CurrControl <> PrevControl) {  
		if showingTT = 1
			gosub ui_RemoveToolTip

		SetTimer, HoveredToolTip, off
		if CurrControl
			SetTimer, HoveredToolTip, 750
		PrevControl := CurrControl
	}
}

tooltip_Process(control) {
	entry := syslist_Get("Controls", "/single:Yes /filter:control=" . control)

	if (entry <> "") {
		callback := getValue(entry, "tooltipCallback")
		if (callback <> "") {
			COMMAND(callback, entry)
		} else {
			tooltipText := getValue(entry, "tooltip")
			if (tooltipText <> "") {
				COMMAND("UI Tooltip", tooltipText)
			}
		}
	}
}

HoveredToolTip:
	SetTimer, HoveredToolTip,off

	if PrevControl
		tooltip_Process(PrevControl)
Return

ui_Tooltip(A_Command, A_Args) {
	global showingTT = 1
	Tooltip, %A_Args%
	SetTimer,ui_RemoveToolTip,3000
}

ui_RemoveToolTip:
	SetTimer, ui_RemoveToolTip, off
	showingTT = 0
	ToolTip
return
