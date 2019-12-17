clipboard_Initialize() {

	CommandRegister("Clipboard Retrieve", "clipboard_Retrieve")
}

clipboard_Retrieve(A_Command, A_Args) {

	clipData := Clipboard
log("clipData:[" . clipData . "]")
	StringSplit, clipData, clipData, `n
;	StringSplit, clipData, clipData1, `t
	StringSplit, clipData, clipData1, `r
	clipData := clipData1
	if (clipData <> "") {
		command := lister_EvalCommand(clipData)
		if (command <> "") {
logA("Command:" . command)
			COMMAND("Editor Edit", command)
;			COMMAND("Command HistoryAdd", command)
		}
	}
	clipData =
}