skin_Initialize() {

	CommandRegister("Skin Save", "skin_OnSave")
	CommandRegister("Skin Change", "skin_Change")
}

skin_OnSave(A_Command, A_Args) {
	list := syslist_Get("Controls")
	nlist := list_Create()
	
	Loop {
		entry := list_Iterate(list, iter)
		if (entry = "") {
			break
		}

		control := getValue(entry, "control")
		GuiControlGet, MyEdit, Pos, %control% 

		replaceValue(entry, "x", MyEditX)
		replaceValue(entry, "y", MyEditY)
		replaceValue(entry, "w", MyEditW)
		replaceValue(entry, "h", MyEditH)
		
		removeValue(entry, "hwnd")
		removeValue(entry, "listName")
		removeValue(entry, "control")
		removeValue(entry, "tooltipCallback")
		removeValue(entry, "rightClickCallback")
		removeValue(entry, "callback")
		removeValue(entry, "tooltipCallback")
		
		list_Add(nlist, entry)
	}
	
	list_Write(nlist, "ui.xml")
	list_Write(list, "ui-orig.xml")
}

skin_Change(A_Command, A_Args) {
	name := getValue(A_Args, "name")
	STATE_SET("UI Skin", name)
	STATE_WRITE("UI Skin")
	COMMAND("AHK Reload")
}
