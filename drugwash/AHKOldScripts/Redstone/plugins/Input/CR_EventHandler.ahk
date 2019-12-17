eventHandler_Initialize() {

	list := syslist_Get("EventHandlers")
	
	Loop {
		entry := list_Iterate(list, iter)
		if (entry = "") {
			break
		}
		event := getValue(entry, "event")
		if (event <> "") {
			NotifyRegister(event, "eventHandler_OnNotify")
		}  
	}
}

eventHandler_OnNotify(A_Command, A_Args) {
	
	command := getValue(A_Command, "command")
	list := syslist_Get("EventHandlers", "/single:Yes /filter:event=" . command)
	command := getNode(list, "command")
	COMMAND("Command Run", command)
}
