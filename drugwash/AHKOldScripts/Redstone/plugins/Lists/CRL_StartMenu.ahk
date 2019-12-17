startmenu_Initialize() {
	CommandRegister("StartMenu SetFolder", "startmenu_SetFolder")
	CommandRegister("StartMenu ProcessList", "startmenu_OnProcessList")
}

startmenu_SetFolder(A_Command, A_Args) {
	directory := getValue(A_Args, "directory")
	filter := syslist_Get("Filters", "/single:Yes /filter:name=Start Menu")
	addValues(filter, "/directory:" . directory)
	COMMAND("Lister SetFilter", filter)
}

startmenu_OnProcessList(A_Command, filter) {

	syslist_Set("StartMenu", "")

	directory := getValue(filter, "directory", "Programs")

	if (directory <> "Programs") {
		SplitPath, directory,,FDir
		entry := "/type:startmenu /weight:1 /name:Up /directory:" . FDir
		syslist_Add("StartMenu", entry)
	}

	startmenu_RefreshFolders(A_StartMenu, directory)
	startmenu_RefreshFolders(A_StartMenuCommon, directory)

	startmenu_RefreshFiles(A_StartMenu, directory)
	startmenu_RefreshFiles(A_StartMenuCommon, directory)
	
	list := syslist_Get("StartMenu")

	COMMAND("Lister SetText", "/focus:Yes /clear:Yes")

	ShowResults(filter, list)
}

startmenu_RefreshFiles(folder, subFolder) {
	CurrPath := folder
	if (subFolder <> "") {
		CurrPath := CurrPath . "\" . subFolder
	}
	subFolder := subFolder . "\"

	Loop,%CurrPath%\*.*,0
	{
		if A_LoopFileAttrib contains H,R
			continue
		SplitPath, A_LoopFileFullPath, , , , FNameNoExt

		entry := "/type:file /weight:3"
			. " /name:" . Enc_XML(FNameNoExt)
			. " /command:" . Enc_XML(A_LoopFileLongPath)
		syslist_Add("StartMenu", entry)
	}
}

startmenu_RefreshFolders(folder, subFolder) {

	CurrPath := folder
	if (subFolder <> "") {
		CurrPath := CurrPath . "\" . subFolder
	}
	subFolder := subFolder . "\"

	Loop,%CurrPath%\*.*,2
	{
		if A_LoopFileAttrib contains H
			continue

		entry := "/type:startmenu /weight:2"
			. " /name:" . Enc_XML(A_LoopFileName) 
			. " /directory:" . Enc_XML(subFolder . A_LoopFileName)

		syslist_Add("StartMenu", entry)
	}
}
