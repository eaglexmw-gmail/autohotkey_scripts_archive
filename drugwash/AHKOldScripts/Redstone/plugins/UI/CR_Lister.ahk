lister_Initialize() {
	CommandRegister("Lister RunCommand", "lister_RunCommand")
	CommandRegister("Lister SetFilter", "lister_SetFilter")
	CommandRegister("Lister SetText", "lister_SetText")
	CommandRegister("Lister DefaultListProcessor", "lister_DefaultListProcessor")
	CommandRegister("Lister DefaultTextProcessor", "lister_DefaultTextProcessor")

	NotifyRegister("UI Create", "lister_CreateUI")
	NotifyRegister("UI Activate", "lister_OnActivate")
	NotifyRegister("UI Show", "lister_OnActivate")
	NotifyRegister("List Update", "lister_ListUpdated")
}

lister_CreateUI(A_Command, A_Args) {
	global SearchControl, CTRLListView, ImageListID1

	COMMAND("UI AddControl", "/name:SearchControl"
		. " /type:edit"
		. " /x:175 /y:325 /w:334"
		. " /anchor:yw /redraw:Yes"
		. " /options:R1 -0x200000 gGetText +Multi -Wrap -WantReturn vSearchControl")

;	COMMAND("UI AddControl", "/name:OpenButton"
;		. " /type:button"
;		. " /callback:Lister RunCommand"
;		. " /text:&Open"
;		. " /style:0x8000 -Wrap Default gOpenButton Hidden")
	Gui, 1:Add, Button, xp+160 y325 w75 0x8000 -Wrap Default gOpenButton Hidden, &Open

	Hotkey, IfWinActive, RedStone
	Hotkey, Up, onKey
	Hotkey, PgUp, onKey
	Hotkey, Down, onKey
	Hotkey, PgDn, onKey
	Return

	GetText:
		; TODO-1: control-enter does something funny
		GuiControlGet, CurrText,, SearchControl
		LastText = %CurrText%

		StartTime := A_TickCount
		lister_ProcessText(CurrText)
		log("GetText elapsed:" . A_TickCount - StartTime, 4)
		
		; Check if while the list was being displayed, the user entered more text
		GuiControlGet, CurrText,, SearchControl
		IfNotEqual, CurrText, %LastText%
		{
			gosub GetText
		}
	Return
	OpenButton:
		COMMAND("Lister RunCommand")
	Return
	onKey:
		ControlGetFocus, gblCurrCtrl, RedStone
		IfEqual, gblCurrCtrl, Edit1
		{
			ControlGet,visible,VISIBLE,,SysListView322
			if visible
				ControlSend, SysListView322, {%A_ThisHotKey%}, RedStone
			else
				ControlSend, SysListView321, {%A_ThisHotKey%}, RedStone
		}
		else
			ControlSend, %gblCurrCtrl%, {%A_ThisHotKey%}, RedStone
	Return
}

lister_SetText(A_Command, A_Args) {

	focus := getValue(A_Args, "focus")
	clear := getValue(A_Args, "clear")
	text := getValue(A_Args, "text")

	if (focus = "Yes") {
		wid := STATE_GET("Application WID")
		IfWinActive, ahk_id %wid%
			GuiControl, Focus, SearchControl
	}

	if (clear = "Yes")
		GuiControl,, SearchControl,

	if (text <> "") {
		GuiControl,, SearchControl,%text%
		
		select := getValue(A_Args, "select")
		if (select = "Yes")
			ControlSend, Edit1, {HOME}+{End}, RedStone
		else
			ControlSend, Edit1, {End}, RedStone
	}
}

lister_OnActivate(A_Command, A_Args) {

	control := getControl("SearchControl")
	wid := STATE_GET("Application Wid")

	GuiControl, Focus, %control%
	ControlSend, %control%, {HOME}+{End}, ahk_id %wid% 
}

lister_SetFilter(A_Command, filter) {

	if (filter <> "") {
	
		STATE_SET("Lister CurrentFilter", filter)
		NOTIFY("Lister SetFilter", filter)

		listProcessor := getValue(filter, "listProcessor", "Lister DefaultListProcessor")
		COMMAND(listProcessor, filter)
	}
}

lister_DefaultListProcessor(A_Command, filter) {

	listName := getValue(filter, "list", "Default")
	list := syslist_Get(listName)
	text := getValue(filter, "searchPhrase")
;	if (text <> "")
;		COMMAND("Lister SetText", "/focus:Yes /select:Yes /text:" . text)
;	else
		COMMAND("Lister SetText", "/focus:Yes /clear:Yes")

	ShowResults(filter, list)
}

lister_UpdateFilter(filter) {

	STATE_SET("Lister CurrentFilter", filter)

	list := getValue(filter, "list", "Default")
	text := getValue(filter, "searchPhrase")
	listEntry := syslist_Get("Lists", "/single:Yes /filter:list=" . list)
;	command := getValue(listEntry, "refreshCommand")
;	if (command <> "") {
;		COMMAND(command, filter)
;	}

;	SearchList := FilterList(filter, text)
;	ShowResults(filter, SearchList)
}

lister_ListUpdated(A_Command, A_Args) {

	listName := getValue(A_Args, "listName")
	filter := STATE_GET("Lister CurrentFilter")
	list := getValue(filter, "list", "Default")

	if (list = listName) {

		entry := getNestedNode(A_Args, "Entry")
		if (entry = "") {
			listProcessor := getValue(filter, "listProcessor", "Lister DefaultListProcessor")
			COMMAND(listProcessor, filter)
;			lister_UpdateFilter(filter)
		}
;		GuiControl, Focus, SearchControl
	}
}

lister_ProcessText(CurrText) {

	filter := STATE_GET("Lister CurrentFilter")
	name := getValue(filter, "name")
logA("lister_ProcessText:" . CurrText, 7)
	
	; TODO: regex this
	Loop
	{
		StringRight,rightChar,CurrText,1
		if (rightChar <> A_Space)
			break
		StringTrimRight, CurrText, CurrText, 1
	}

	; TODO: regex match to filter value
	slash := SubStr(CurrText, 1, 1)
	colon := SubStr(CurrText, 2, 1)

	ifEqual,slash,/
	{
		if (name <> "Quick Searches") {
			filter := syslist_Get("Filters", "/single:Yes /filter:name=Quick Searches")
			COMMAND("Lister SetFilter", filter)
		}
	}
	else ifEqual,colon,:
	{
		if (name <> "Files") {
			filter := syslist_Get("Filters", "/single:Yes /filter:name=Files")
			COMMAND("Lister SetFilter", filter)
		}
	} 

	textProcessor := getValue(filter, "textProcessor", "Lister DefaultTextProcessor")
	COMMAND(textProcessor, "/searchPhrase:" . CurrText)
}

lister_DefaultTextProcessor(A_Command, A_Args) {

	currText := getValue(A_Args, "searchPhrase")

	if (!lister_selectMatchSimple(currText)) {

		filter := syslist_Get("Filters", "/single:Yes /filter:name=Matches")
		addValues(filter, "/searchPhrase:" . CurrText)
		COMMAND("Lister SetFilter", filter)
	}
}

lister_selectMatchSimple(currText) {

	StringLen, Len, currText

	Loop % LV_GetCount()
	{
		LV_GetText(name, A_Index, 3)
		StringLeft, name, name, %Len%
		If (name = CurrText) {
			LV_Modify(A_Index, "Focus Select Vis")
			Return 1
		}
	}

	Loop % LV_GetCount()
	{
		LV_GetText(Name, A_Index, 3)
		if (InStr(Name, CurrText)) {
			LV_Modify(A_Index, "Focus Select Vis")
			Return 1
		}
	}

	return 0
}

lister_RunCommand(A_Control, A_Args) {

	SelItem := LV_GetNext()

;	logA("Lister Run Command:" . A_Args)
	StartTime := A_TickCount
	; TODO-1: filter out invalid chars
	
	if (SelItem = 0) {

		GuiControlGet, Command,, SearchControl
		StringReplace, Command, Command, !,, All

		RunItem := lister_EvalCommand(command)

	} else {

		RunItem := lister_GetCurrentCommandMeta()
		removeValue(RunItem, "weight")

		GuiControlGet, text,, SearchControl
		if (text <> "") {
			replaceValue(RunItem, "searchPhrase", Enc_XML(text))
		}
	}

	COMMAND("Lister SetText", "/clear:Yes")
	GetKeyState, CtKey, Control

	IfEqual, CtKey, D
		COMMAND("Command UserAltRun", RunItem)
	else
		COMMAND("Command UserRun", RunItem)

	count := LV_GetCount()
	COMMAND("Lister SetText", "/focus:Yes")

	log("Command Run elapsed:" . A_TickCount - StartTime, 4)
}

lister_EvalCommand(command) {
	gosub isURL
	gosub isFile
	gosub isFolder

	StringLeft,lchar,command,1
	IfEqual, lchar, *
	{
		command := SubStr(command,2)
		RegExMatch(command, "(\w+\s.+?)\s(.+)$", a)
		if (a1 <> "") {
			command := a1
			args := a2
		}
		runItem := commandCreate(command, args)

	} else if (is_a_file = 1) {

		SplitPath, Command, FName, FDir, FExt, FNameNoExt
		runItem := "/name:" . FNameNoExt . " /type:file /command:" . command

	} else if (is_a_folder = 1) {
		
		; TODO-1: if this is a unc style path, switch to file mode
		SplitPath, command, FName, FDir, FExt, FNameNoExt
		runItem := "/name:" . FNameNoExt . " /type:folder /command:" . command

	} else if (is_a_url = 1) {
		StringGetPos, pos, command, ://
		if (pos < 1)
			command := "http://" . command
		StringGetPos, pos, Command, ://
		pos := pos + 4
		OutputVar := SubStr(command, pos)
		StringSplit, llrArray, OutputVar , /
		runItem :=  "/name:" . Enc_XML(llrArray1) . " /type:website /command:" . Enc_XML(command)
	}
	else {
		runItem := "/name:" . Enc_XML(command) . " /type:webSearch /term:" . Enc_XML(command)
	}

	Return runItem
	
	isURL:
		is_a_url = 0

		if (InStr(command, "://")) {
			url := command
		} else {
			url := "http://" . command
		}

		; TODO-1: allow spaces in parameters
		if (RegExMatch(url, "^(((https?:|ftp:|gopher:)//))[-[:alnum:]?%,./&##!@:=+~_]+[A-Za-z0-9/]$") = 1) {
			if ((InStr(command, ".") > 0) OR (InStr(command, ":") > 0))
				is_a_url = 1
		}
	Return

	isFolder:
	
		ifExist, %command%
		{
			FileGetAttrib, attrib, %command%
			IfInString, attrib, D
				is_a_folder = 1
		}
	Return

	isFile:

		is_a_file = 0
		
		SplitPath, command, FName, FDir, FExt, FNameNoExt
		
		if FExt =
		{
			fileName := command . ".exe"
			FExt = exe
		}
		else
			fileName := command

		ifExist, %fileName%
			is_a_file = 1
		else if ((FExt = "exe") AND (FDir = "")) {

			EnvGet, DosPath, Path
			log("path is " . DosPath)
			Loop, Parse, DosPath, `;
			{
				IfEqual, A_LoopField,, 
					Continue
				Path := A_LoopField . "\" . fileName
				IfExist, %Path%
				{
					Command := Path
					is_a_file = 1
					break
				}
			}
		}
	Return
}
