slash_Initialize() {
	CommandRegister("Slash ProcessText", "slash_ProcessText")
	CommandRegister("Slash ProcessList", "slash_ProcessList")
	CommandRegister("Slash Run", "slash_Run")
}

slash_Run(A_Command, A_Args) {

	text := getValue(A_Args, "searchPhrase")
	description := getValue(A_Args, "description", A_Args)
	
	spacePos := InStr(text, A_Space)
	if (spacePos > 0)
		text := SubStr(text, spacePos+1)
	else
		text := ""

	command := getNode(A_Args, "command")
	AddValues(command, "/name:" . description . ": " . text)
	AddValues(command, "/term:" . text)

	COMMAND("Command Run", command)
}

slash_ProcessList(A_Command, filter) {

	list := syslist_Get("Search")

	ShowResults(filter, list)
}

slash_ProcessText(A_Command, A_Args) {

	text := getValue(A_Args, "searchPhrase")

	slash := SubStr(text, 1, 1)
	ifNotEqual,slash,/
	{
		filter := syslist_Get("Filters", "/single:Yes /filter:name=Matches")
		addValues(filter, "/searchPhrase:" . text)
		COMMAND("Lister SetFilter", filter)
		Return
	}

	lister_selectMatchSimple(text)
}
