contextMenu_Initialize() {
}

GuiContextMenu:
	MouseGetPos, , , , control
	OnContextMenu(control)
Return

OnContextMenu(control) {
	entry := syslist_Get("Controls", "/single:Yes /filter:control=" . control)
	if (entry <> "") {
		callback := getValue(entry, "rightClickCallback")
		if (callback <> "") {
			COMMAND(callback, entry)
		}
	}
}
