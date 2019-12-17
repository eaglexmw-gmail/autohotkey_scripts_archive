startmenu_Initialize() {
	CommandRegister("StartMenu Scan", "startmenu_OnScan")
}

startmenu_OnScan(A_Command, A_Args) {

	startmenu_RefreshFolders(A_StartMenu, "Programs")
	startmenu_RefreshFolders(A_StartMenuCommon, "Programs")
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

		entry := "/type:file"
			. " /name:" . Enc_XML(FNameNoExt)
			. " /command:" . Enc_XML(A_LoopFileLongPath)
		syslist_Add("Default", entry)
	}
}

startmenu_RefreshFolders(folder, subFolder) {

	startmenu_RefreshFiles(folder, subFolder)

	CurrPath := folder
	if (subFolder <> "") {
		CurrPath := CurrPath . "\" . subFolder
	}

	Loop,%CurrPath%\*.*,2
	{
		if A_LoopFileAttrib contains H
			continue

		entry := "/type:startmenu"
			. " /name:" . Enc_XML(A_LoopFileName) 
			. " /directory:" . Enc_XML(subFolder . "\" . A_LoopFileName)
		syslist_Add("Default", entry)
		
		startmenu_RefreshFolders(folder, subFolder . "\" .  A_LoopFileName)
	}
}
