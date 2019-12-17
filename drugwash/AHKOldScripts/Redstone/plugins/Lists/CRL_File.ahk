filelist_Initialize() {

	CommandRegister("Files ProcessText", "files_OnProcessText")
	CommandRegister("Files ProcessList", "files_OnProcessList")
}

files_OnProcessText(A_Command, A_Args) {

	currText := getValue(A_Args, "searchPhrase")

	colon := SubStr(CurrText, 2, 1)
	ifNotEqual,colon,:
	{
		filter := syslist_Get("Filters", "/single:Yes /filter:name=Matches")
		addValues(filter, "/searchPhrase:" . CurrText)
		COMMAND("Lister SetFilter", filter)
		Return
	}

	filter := STATE_GET("Lister CurrentFilter")

	currPath := getValue(filter, "directory", "c:")

	Loop,
	{
		StringRight,rightChar,currText,1
		if (rightChar <> "\")
			break
		StringTrimRight, currText, currText, 1
	}

	if (CurrText <> currPath)
	{
		IfExist,%CurrText%
		{
			currPath := currText
			FileGetAttrib, fileType , %currText%
			
			IfInString, fileType, D
			{
logA("setting folder with:" . currText)
				COMMAND("Command UserRun", "/type:folder /command:" . currText)
				Return
			}
		}
	}

	len := StrLen(currPath)+2
	text := SubStr(CurrText, len)
	
	lister_selectMatchSimple(text)
}

files_OnProcessList(A_Command, filter) {

	StartTime := A_TickCount

	COMMAND("Status Display", "/status:Building File List")
	currPath := getValue(filter, "directory", "c:")
logA("processingList:" . currPath)

	Loop,
	{
		StringRight,isColon,currPath,1
		if (isColon <> "\")
			break
		StringTrimRight, currPath, currPath, 1
	}

	StringRight,isColon,currPath,1
	
	if isColon = :
	{
		list := list_Create()
	}
	else
	{
		SplitPath, currPath, FName, FDir, FExt, FNameNoExt
		StringRight,isColon,FDir,1
	
		if isColon = :
			FDir := FDir . "\"
		list := list_Create()
		list_Add(list, "/name:Up /type:folder /command:" . FDir)
	}

	Loop,%CurrPath%\*.*,2
	{
		if A_LoopFileAttrib contains H
			continue
		list_Add(list, "/name:" . Enc_XML(A_LoopFileName) . " /type:folder /command:" . Enc_XML(A_LoopFileLongPath))
	}
	Loop,%CurrPath%\*.*,0
	{
;		if A_LoopFileAttrib contains H,R
;			continue
		; 2400
		FormatTime, fdate, %A_LoopFileTimeModified%, MM/dd/yyyy HH:mm
		fileName := Enc_XML(A_LoopFileName)
		filePath := Enc_XML(A_LoopFileLongPath)
		entry = /type:file /name:%fileName% /command:%filePath% /size:%A_LoopFileSizeKB% KB /date:%fdate%
		list_Add(list, entry)
	}
;	syslist_Set("Files", list)

	COMMAND("Status Display")
	log("Files elapsed:" . A_TickCount - StartTime)

	; TODO: Fix this...
;	ControlGetFocus, control
;	ControlGet,control,HWND,,%control%
;	GuiControlGet,scontrol,Hwnd,SearchControl
;	if (control != scontrol) {
		COMMAND("Lister SetText", "/focus:Yes /text:" . currPath)
;	}

	ShowResults(filter, list)
}
