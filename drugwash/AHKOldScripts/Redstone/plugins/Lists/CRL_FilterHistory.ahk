filterHistory_Initialize() {
	CommandRegister("Lister PreviousFilter", "filterHistory_OnPreviousFilter")

	NotifyRegister("Lister SetFilter", "filterHistory_OnSetFilter")
}

filterHistory_OnPreviousFilter(A_Command, A_Args) {
	history := syslist_Get("FilterHistory")
	filter := list_Get(history, 2)

	if (filter <> "") {
		currFilter := list_Get(history, 1)
		list_Remove(history, currFilter)
		list_Remove(history, filter)
		syslist_Set("FilterHistory", history)
		COMMAND("Lister SetFilter", filter)
		
;		text := getValue(filter, "searchPhrase")
;		if (text <> "")
;			COMMAND("Lister SetText", "/select:Yes /text:" . text)
;		else
;			COMMAND("Lister SetText", "/clear:Yes")
	}
}

filterHistory_OnSetFilter(A_Command, filter) {
	syslist_Add("FilterHistory", filter)
dumpHistory()
}

dumpHistory() {
	list := syslist_Get("FilterHistory")
	
	logA("Filter History")
	logA("**************")
	Loop {
		entry := list_Iterate(list, iter)
		if (entry = "") {
			break
		}
		logA(getValue(entry, "name") . " " . getValue(entry, "searchedFor"))
	}
	logA("**************")
}
