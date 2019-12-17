scanlist_Initialize() {

	NotifyRegister("List Update", "scan_OnListUpdate")
	NotifyRegister("UI BuildMenu", "scan_BuildMenu")
	NotifyRegister("Scan Refreshed", "scan_OnScanRefreshed")
}

scan_OnListUpdate(A_Command, A_Args) {
	listName := getValue(A_Args, "listName")
	if (listName = "Scan") {
		COMMAND("Scan Refresh")
	}
}

scan_OnScanRefreshed(A_Command, A_Args) {
	syslist_Read("Default")
	NOTIFY("List Update", "/listName:Default")
}

scan_BuildMenu(A_Command, A_Args) {

	entry := getNestedNode(A_Args, "Entry")
	type := getValue(entry, "type")
	listName := getValue(entry, "listName")

	if (listName <> "Scan") AND (type = "Folder")
	{
	 	command := commandCreate("Editor2 Create", "/type:scan /listName:Scan")
	 	directory := getValue(entry, "command")
	 	name := getValue(entry, "name")
	 	entry := createNode("/name:" . name . " /directory:" . directory . " /recurse:No /includeDirs:No", "Scan")
	 	addValues(entry, "/includeTypes:" . Enc_XML("exe,lnk"))
	 	addNamedArgument(command, "Entry", entry)

		menuAdd(A_Args, "/item:Index this folder", command)
	}
}
