alttab_Initialize() {
	CommandRegister("AltTab Tab", "alttab_OnTab")
}

alttab_OnTab(A_Command, A_Args) {

	hwnd := STATE_GET("Redstone WID")
	WinGet, style, Style, ahk_id %hwnd%
	visible := (style & 0x10000000)   ; WS_VISIBLE

	filter := STATE_GET("Lister CurrentFilter")
	name := getValue(filter, "name")
	if (name <> "Active Tasks") {
		COMMAND("Filter Apply", "/name:Active Tasks")
		visible := ""
	}

	if (visible = "") {
		COMMAND("UI Show")
	}

		rowNum := LV_GetNext()
		GetKeyState, state, shift
		if (state = "D") {
			rowNum--
		} else {
			rowNum++
		}
		if (rowNum > LV_GetCount())
			rowNum = 1
		if (rowNum = 0)
			rowNum = LV_GetCount()
		LV_Modify(rowNum, "Focus Select Vis")

	SetTimer, Check_Alt_Hotkey2_Up, 250
	
	Return
	
	Check_Alt_Hotkey2_Up:
		GetKeyState, state, Alt
  		If (state <> "D") {
			SetTimer, Check_Alt_Hotkey2_Up, Off
			entry := lister_GetCurrentCommandMeta()
			COMMAND("Command Run", entry)
		}
	Return
}

