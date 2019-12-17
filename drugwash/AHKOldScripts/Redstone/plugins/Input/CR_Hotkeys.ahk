; TODO-1: reload hotkeys if list updated

hotkeys_Initialize() {
	CommandRegister("Hotkeys Enable", "hotkeys_OnEnable")

	NotifyRegister("UI Created", "hotkeys_OnUICreated")
	NotifyRegister("UI BuildMenu", "hotkeys_BuildMenu")
}

hotkeys_BuildMenu(A_Command, A_Args) {

	entry := getNestedNode(A_Args, "Entry")
	type := getValue(entry, "type")
	typeEntry := getTypeMeta(type)
	run := getValue(typeEntry, "run")
	editable := getValue(typeEntry, "editable", "Yes")

	if (run <> "") AND (editable <> "No") {
	 	; Set the command
	 	command := commandCreate("Editor2 Create", "/type:hotkey /listName:Hotkeys")
	 	addNamedArgument(command, "Entry", entry)
	
		menuAdd(A_Args, "/item:Set Hotkey", command)
	}
}

hotkeys_OnUICreated(A_Command, A_Args) {

	hotkeys := syslist_Get("Hotkeys")

	Loop
	{
		entry := list_Iterate(hotkeys, iter)
		if (entry = "") {
			break
		}

		onlyWhenActive := getValue(entry, "onlyWhenActive")
		key := getValue(entry, "hotkey")
		if (onlyWhenActive <> "Active") {
			Hotkey, IfWinNotActive, RedStone
			Hotkey, %key%, onInactiveHotKey
		}
		if (onlyWhenActive <> "Inactive") {
			Hotkey, IfWinActive, RedStone
			Hotkey, %key%, onActiveHotKey
		}
	}
	Return
	
	onInactiveHotKey:
		hotkeys_Run(A_ThisHotKey, "Active")
	Return

	onActiveHotKey:
		hotkeys_Run(A_ThisHotKey, "Inactive")
	Return
}

hotkeys_OnEnable(A_Command, A_Args) {

	state := getValue(A_Args, "state")

	hotkeys := syslist_Get("Hotkeys")
	Loop
	{
		entry := list_Iterate(hotkeys, iter)
		if (entry = "") {
			break
		}
		key := getValue(entry, "hotkey")
		
		Hotkey, %key%, %state%
	}
}

hotkeys_Run(keyPressed, state) {

	hotkeys := syslist_Get("Hotkeys")
	iter := ""

; TODO: This should be a search, not iterating
	Loop {
		entry := list_Iterate(hotkeys, iter)
		if (entry = "") {
			break
		}
		key := getValue(entry, "hotkey")
		onlyWhenActive := getValue(entry, "onlyWhenActive")
		if (key = keyPressed) AND (onlyWhenActive <> state) {
			command := getNode(entry, "command")
			COMMAND("Command Run", command)
			break
		}
	}
}
