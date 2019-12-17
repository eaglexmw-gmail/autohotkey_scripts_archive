IE_Initialize() {

	CommandRegister("IE Scan", "IE_Scan")
}

IE_Scan(A_Command, A_Args) {

	directory := GetCommonPath("FAVORITES")
	Loop, %directory%\*.url, 0, 1
	{
		IniRead, url, %A_LoopFileFullPath%, InternetShortcut, URL

		if (url <> "") AND (url <> "ERROR") {
			COMMAND("Website DownloadIcon", "/url:" . url)

			SplitPath, A_LoopFileFullPath, , , , FNameNoExt
			entry := "/name:" . FNameNoExt . " /listName:Default /type:bookmark /command:" . url
			syslist_Add("Default", entry)
		}
	}
}
