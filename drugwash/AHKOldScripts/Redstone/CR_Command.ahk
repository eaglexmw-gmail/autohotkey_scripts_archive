command_Initialize()
{
	CommandRegister("Command Run", "command_Run")
	CommandRegister("Command Process", "command_Process")
	CommandRegister("Command UserRun", "command_UserRun")
	CommandRegister("Command UserRunBegin", "command_UserRunBegin")
	CommandRegister("Command UserRunEnd", "command_UserRunEnd")
	CommandRegister("Command UserAltRun", "command_UserRun")
	CommandRegister("Command CheckErrors", "command_CheckErrors")
	CommandRegister("Command Register", "command_Register")
	CommandRegister("Notify Register", "command_NotifyRegister")
	CommandRegister("Command ProcessList", "command_OnProcessList")
	CommandRegister("Command Notify", "command_OnNotify")

	STATE_SET("Command ErrorCount", 0)
}

command_Register(A_Command, A_Args) {
	syslist_Add("Redstone", A_Args)
}

command_OnNotify(A_Command, A_Args) {
	notification := getValue(A_Args, "notification")
	args := getNode(A_Args, "Args")
	NOTIFY(notification, args)
}

command_NotifyRegister(A_Command, A_Args) {
	list := syslist_Get("Notifications")

	command := getValue(A_Args, "command")
	StringReplace, command, command, %A_Space%, _
	node := getNode(list, command)
	if (node = "") {
		node := createNode("", command)
	}

	list_Add(node, A_Args)
	setNode(list, command, node)
	syslist_Set("Notifications", list)
}

command_Process(A_Command, A_Args) {

	command := getValue(A_Args, "command")
	args := getNode(A_Args, "Args")

	COMMAND(command, args)
	if (ErrorLevel = "ERROR") {
		syslist_Add("Errors", "/type:error /error:Invalid command [" . command . "]")
	}
}

command_UserRunBegin(A_Command, A_Args) {
	COMMAND("Animation Start")
}

command_UserRun(A_Command, A_Args) {

	COMMAND("Command UserRunBegin")
	command_Run(A_Command, A_Args)
	COMMAND("Command UserRunEnd")
}

command_UserRunEnd(A_Command, A_Args) {
	COMMAND("Animation Stop")
	COMMAND("Status Display", "")
	COMMAND("Command CheckErrors")
}

command_CheckErrors(A_Command, A_Args) {
	
	errorList := syslist_Get("Errors")
	count := list_GetCount(errorList)

	prevCount := STATE_GET("Command ErrorCount")
	if (prevCount != count) {
		COMMAND("Filter Apply", "/name:Errors")
	}
	STATE_SET("Command ErrorCount", count)
}

command_Run(A_Command, A_Args) {

	type := getValue(A_Args, "type")

	handler := getTypeMeta(type)

	if (handler <> "") {
		A_Command := getValue(A_Command, "command")
		if (A_Command = "Command UserAltRun")
			runCommand := getValue(handler, "altRun")
		else
			runCommand := getValue(handler, "run")

		COMMAND(runCommand, A_Args)
	}
}

command_OnProcessList(A_Command, A_Args) {
	commands := getNode(A_Args, "commands")
	Loop {
		entry := list_Iterate(commands, iter)
		if (entry = "") {
			break
		}
		COMMAND("Command Run", entry)
	}
}
