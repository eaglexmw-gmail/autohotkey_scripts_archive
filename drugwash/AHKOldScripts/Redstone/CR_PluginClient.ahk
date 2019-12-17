#Persistent
#NoEnv
#SingleInstance FORCE
#NoTrayIcon

Process, Exist
pid := errorlevel

	log_level_PASS := 1
	log_level_FAIL := 1
	log_level_DEBUG := 1
	log_level_PERF := 1
	log_level_LIST := 1
	log_level_STATE := 1
	log_level_PLUGIN := 1

;log_Initialize()
logA("INITIALIZE ****************************************", 6)
params = %1%
redstonePid := getValue(params, "pid")
params = %2%
redstoneWid := getValue(params, "wid")

OnMessage(0x4a, "pluginClient_ReceiveMessage", 16)

log("PluginClient pid:" . pid, 6)
log("RedStone pid:" . redstonePid, 6)
log("RedStone wid:" . redstoneWid, 6)

NotifyRegister("AHK Reload", "plugin_Exit")
NotifyRegister("AHK Exit", "plugin_Exit")

COMMAND("Plugin Ready", "/pid:" . pid)

Return

#include CR_Util.ahk
#include CR_List.ahk
#include CR_Args.ahk
#include CR_XML.ahk
#include CR_Log.ahk
#Include XPath.ahk

CommandRegister(command, callback, args="") {
	global pid

	command := createNode("/type:command /clientCallback:" . callback 
		. " /command:" . command
		. " /pid:" . pid
		. " /callback:plugin_Callback")

	COMMAND("Command Register", command)
}

NotifyRegister(command, callback) {

	global pid

	args := "/pid:" . pid . " /userCommand:" . command . " /callback:" . callback
	COMMAND("Notify Register", args)
}

NOTIFY(command, args="") {

	global pid

	if (args <> "") {
		args := args . " "
	}
	args := args . "/command:" . command
	COMMAND("Plugin Notify", args)
}

STATE_SET(name, value) {

	COMMAND("State Set", "/StateName:" . name . " " . value)
}

STATE_GET(name) {
	global pid, plugin_Data

	COMMAND("State Get", "/pid:" . pid . " /StateName:" . name)

	value := getValue(plugin_Data, "value")
	return value
}

STATE_READ(name) {
	return STATE_GET(name)
}

syslist_Add(listName, entry) {
	COMMAND("List Add", "/listName:" . listName . " " . entry)
}

syslist_Remove(listName, entry) {
	COMMAND("List Remove", "/listName:" . listName . " " . entry)
}

syslist_Get(listName, args="") {
	global pid, plugin_Data

	cmdArgs := createNode("/listName:" . listName . " /pid:" . pid)
	if (args <> "") {
		setNode(cmdArgs, "Args", args)
	}

	COMMAND("Syslist Get", cmdArgs)
	return plugin_Data
}

COMMAND(command, args="") {

	message := createNode("/type:command /command:" . command)
	if (args <> "") {
		setNode(message, "Args", args)
	}
	pluginClient_SendMessage(message)
}

pluginClient_ReceiveData(A_Command, A_Args) {
	global 
	plugin_Data := A_Args
}

pluginClient_Initialize(A_Command, A_Args) {

	initialize := getValue(A_Args, "initialize")
	if (initialize <> "") {
		logA("pluginClient->Initialize: " . initialize, 6)
		%initialize%()
	} else {
		logA("pluginClient->Initialize Error: " . A_Args, 6)
	}
}

pluginClient_ProcessMessage(message) {
	logA("ClientReceive:" . xpath_save(message), 6)
	callback := getValue(message, "clientCallback")
	if (callback <> "") {
		args := getNode(message, "Args")
		logA("COMMAND: " . callback . "->" . command . " [" . message . "]", 6)
		%callback%(message, args)
	} else {
		logA("pluginClient->ProcessMessage Error: " . message, 6)
	}
}

pluginClient_ReceiveMessage(wParam, lParam) {

	StringAddress := NumGet(lParam + 8)  ; lParam+8 is the address of CopyDataStruct's lpData member.
	StringLength := DllCall("lstrlen", UInt, StringAddress)
	if StringLength <= 0
		logA("Received invalid length:" . StringLength, 6)
	else
	{
		VarSetCapacity(message, StringLength)
		DllCall("lstrcpy", "str", message, "uint", StringAddress)  ; Copy the string out of the structure.
		pluginClient_ProcessMessage(message)
	}
	return true  ; Returning 1 (true) is the traditional way to acknowledge this message.
}

pluginClient_SendMessage(message)  {

	global redstoneWid
	
	if (redstoneWid = "") {
		logA("PluginClient->Invalid WID: " . message, 6)
	}
    VarSetCapacity(CopyDataStruct, 12, 0)  ; Set up the structure's memory area.
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    NumPut(StrLen(message) + 1, CopyDataStruct, 4)  ; OS requires that this be done.
    NumPut(&message, CopyDataStruct, 8)  ; Set lpData to point to the string itself.

if (isXML(message)) {
	logA("ClientSend->Pid:" . redstoneWid . " " . xpath_save(message), 6)
} else {
	logA("ClientSend->Pid:" . redstoneWid . " " . message, 6)
}
	; 0x4a is WM_COPYDATA. Must use Send not Post.
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    DetectHiddenWindows On
	SendMessage, 0x4a, 0, &CopyDataStruct,, ahk_id %redstoneWid%
	DetectHiddenWindows %Prev_DetectHiddenWindows%

	retVal := ErrorLevel
	if (retVal = "FAIL") {
		log("ClientSend->Return:" . retVal, 6)
	}
	return retVal  ; Return SendMessage's reply back to our caller.
}

plugin_Exit(A_Command, A_Args) {
	ExitApp
}

BACKGROUND_COMMAND(command, args="") {

	global blist

	entry := "/bgcommand:" . command
	if (args <> "") {
		entry := entry . " " . args
	}
	list_Add(blist, entry)
	SetTimer, BackgroundCommandTimer, 10
	
	Return

	BackgroundCommandTimer:
		SetTimer, BackgroundCommandTimer, Off

		Loop
		{
			entry := list_Get(blist, 1)
			list_Remove(blist, entry)

			bgCommand := removeValue(entry, "bgcommand")

			COMMAND(bgCommand, entry)
			if (blist = "")
				break
		}
	Return
}