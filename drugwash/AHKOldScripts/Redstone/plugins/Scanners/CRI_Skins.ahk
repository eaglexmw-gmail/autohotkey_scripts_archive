skin_Initialize() {

	CommandRegister("Skin Scan", "skin_Scan")
}

skin_Scan(A_Command, filter) {

	list := list_Create()

	skinPath := A_ScriptDir . "/config/skins"
	Loop,%skinPath%\*.*,2
	{
		if A_LoopFileAttrib contains H
			continue
	 	command := commandCreate("Skin Change", "/name:" . A_LoopFileName)
	 	addValues(command, "/icon:" . Enc_XML("shell32.dll,141") 
	 		. " /category:Skins"
	 		. " /editable:No"
	 		. " /movable:No"
	 		. " /name:" . A_LoopFileName . " Skin")

		list_Add(list, command)
	}
	syslist_Merge("default", list)
}
