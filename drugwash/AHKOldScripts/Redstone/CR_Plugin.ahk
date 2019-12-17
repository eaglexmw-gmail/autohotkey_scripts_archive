plugin_Initialize() {

	CommandRegister("Plugin Ready", "plugin_Ready")
	CommandRegister("Syslist Get", "plugin_SyslistGet")
	CommandRegister("State Set", "plugin_StateSet")
	CommandRegister("State Get", "plugin_StateGet")
	CommandRegister("Plugin Notify", "plugin_Notify")
	CommandRegister("Plugin Install", "plugin_Install")
	CommandRegister("Plugin Heartbeat", "plugin_Heartbeat")

;	plugins_CheckNew()

	OnMessage(0x4a, "pluginHost_ReceiveMessage", 16)  ; 0x4a is WM_COPYDATA

	pid := STATE_GET("Redstone Pid")
	wid := STATE_GET("Redstone Wid")

	log("STARTUP+++++++++++++++++++++++++++++++++++")
	
	plugins := syslist_Get("plugins")

	iter := ""
	loop
	{
		entry := list_Iterate(plugins, iter)
		if (entry = "") {
			break
		}
		enabled := getValue(entry, "enabled")
		name := getValue(entry, "name")
		if (enabled = "Yes") {
;log("STARTING PLUGIN:" . name)
			source := getValue(entry, "source")
			if (source <> "") {
				; TODO-1: use workingdir
				STATE_SET("Plugin Ready", "")
				Run, %source% /pid:%pid% /wid:%wid%,, UseErrorLevel, cpid
				log("clientPid:" . cpid)
				if ErrorLevel = ERROR
				{
					syslist_Add("Errors", "/type:error /error:Plugin failed to load:" . name)
					logA("PLUGIN run failed:" . source, 6)
					continue
				}
				Loop,100
				{
					cpid := STATE_GET("Plugin Ready")
					if (cpid <> "")
						break
					Sleep,50
				}
				init := getValue(entry, "initialize")

				if (init <> "") {
					message := createNode("/clientCallback:pluginClient_Initialize")
					setNode(message, "Args", "/initialize:" . init)
					if (pluginHost_SendMessage(message, cpid) = "FAIL") {
						log("failed to load plugin:" . source, 6)
						syslist_Add("Errors", "/type:error /error:Plugin failed to load:" . name)
					}
				}
				
			} else {
				init := getValue(entry, "initialize")
				if (init = "") {
					log("Invalid init routine:" . name, 0)
				} else {
					%init%()
				}
			}
		}
	}
}

ClientNotifyRegister(command, callback) {

	command := createNode("/type:command /clientCallback:" . callback 
		. " /command:" . command
		. " /pid:" . STATE_GET("Application PID")
		. " /callback:plugin_Callback")

	CLIENT_COMMAND("Notify Register", command)
}

ClientCommandRegister(command, callback, args="") {
	global pid

	command := createNode("/type:command /clientCallback:" . callback 
		. " /command:" . command
		. " /pid:" . STATE_GET("Application PID")
		. " /callback:plugin_Callback")

	CLIENT_COMMAND("Command Register", command)
}

CLIENT_NOTIFY(command, args="") {

	message := createNode("/type:command /command:Command Notify")
	messageArgs := createNode("/notification:" . command)
	if (args <> "") {
		setNode(messageArgs, "Args", args)
	}
	setNode(message, "Args", messageArgs)

	pluginClient_SendMessage(message, STATE_GET("Host WID"))
}

CLIENT_COMMAND(command, args="") {

	message := createNode("/type:command /command:" . command)
	if (args <> "") {
		setNode(message, "Args", args)
	}
	return pluginClient_SendMessage(message, STATE_GET("Host WID"))
}

plugin_Heartbeat(A_Command, A_Args) {
}

; TODO-2: Version check
plugins_CheckNew() {
	Loop, plugins/*.*, 2
	{
		entries := list_Read("plugins/" . A_LoopFileName . "/plugins.lst")
		Loop,Parse,entries,`n
		{
			name := getValue(A_LoopField, "name")
			if (name <> "") {
				if (syslist_Get("Plugins", "/single:Yes /filter:name=" . name) = "") {
					COMMAND("Plugin Install", "/pluginName:" . A_LoopFileName)
				}
			}
		}
	}
}

plugin_Install(A_Command, A_Args) {

	name := getValue(A_Args, "pluginName")
	log("Installing Plugin:" . name)
	Loop, plugins/%name%/*.lst, 0, 0
	{
		fileName := "plugins/" . name . "/" . A_LoopFileName
		SplitPath, A_LoopFileFullPath, , , , FNameNoExt

		list := list_Read(fileName)
		loop,Parse,list,`n
		{
			syslist_Add(FNameNoExt, A_LoopField)
		}
	}
}

plugin_Notify(A_Command, A_Args) {
	command := getValue(A_Args, "notification")
	args := getNode(A_Args, "Args")
	NOTIFY(command, args)
}

plugin_StateSet(A_Command, A_Args) {

	name := removeValue(A_Args, "StateName")

	STATE_SET(name, A_Args)
}

plugin_StateGet(A_Command, A_Args) {
	name := removeValue(A_Args, "StateName")
	clientpid := removeValue(A_Args, "pid")

	value := STATE_GET(name)

	message := "/callback:pluginclient_ReceiveData /pluginCommand:Syslist Data /value:" . value
	pluginHost_SendMessage(message, clientpid)
}

plugin_SyslistGet(A_Command, A_Args) {
	listName := getValue(A_Args, "listName")
	clientpid := getValue(A_Args, "pid")
	args := getNode(A_Args, "Args")

	list := syslist_Get(listName, args)

	message := createNode("/clientCallback:pluginclient_ReceiveData")
	if (list <> "") {
		setNode(message, "Args", list)
	}
	
	pluginHost_SendMessage(message, clientpid)
}

plugin_Ready(A_Command, A_Args) {
	pid := getValue(A_Args, "pid")
	STATE_SET("Plugin Ready", pid)
}

plugin_Callback(commandMeta, args) {
logA("callback:" . xpath_save(args))
logA("pluginCallback:" . xpath_save(commandMeta), 6)
logA("pluginCallback:" . callback, 6)
logA("pluginCallback:" . command, 6)
logA("pluginCallback:" . args, 6)

	pid := getValue(commandMeta, "pid")
	if (pid <> "") {
		if (args <> "") {
			message := message . " " . args
		}
		pluginHost_SendMessage(commandMeta, pid)
	}
}

pluginHost_ReceiveMessage(wParam, lParam)
{
	StringAddress := NumGet(lParam + 8)  ; lParam+8 is the address of CopyDataStruct's lpData member.
	StringLength := DllCall("lstrlen", UInt, StringAddress)
	if StringLength <= 0
		logA("Received invalid length:" . StringLength)
	else
	{
		VarSetCapacity(message, StringLength)
		DllCall("lstrcpy", "str", message, "uint", StringAddress)  ; Copy the string out of the structure.
		logA("HostReceive:" . xpath_save(message), 6)
		COMMAND("Command Process", message)
	}
	return true  ; Returning 1 (true) is the traditional way to acknowledge this message.
}

pluginClient_SendMessage(message, hostWid)  {

	if (hostWid = "") {
		logA("PluginClient->Invalid WID: " . message, 6)
	}
    VarSetCapacity(CopyDataStruct, 12, 0)  ; Set up the structure's memory area.
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    NumPut(StrLen(message) + 1, CopyDataStruct, 4)  ; OS requires that this be done.
    NumPut(&message, CopyDataStruct, 8)  ; Set lpData to point to the string itself.

if (isXML(message)) {
	logA("ClientSend->Pid:" . hostWid . " " . xpath_save(message), 6)
} else {
	logA("ClientSend->Pid:" . hostWid . " " . message, 6)
}
	; 0x4a is WM_COPYDATA. Must use Send not Post.
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    DetectHiddenWindows On
	SendMessage, 0x4a, 0, &CopyDataStruct,, ahk_id %hostWid%
	DetectHiddenWindows %Prev_DetectHiddenWindows%

	retVal := ErrorLevel
	if (retVal = "FAIL") {
		log("ClientSend->Return:" . retVal, 6)
	}
	return retVal  ; Return SendMessage's reply back to our caller.
}

pluginHost_SendMessage(message, clientPid) {

	if (clientPid = "") {
		logA("PluginHost->Invalid PID: " . message, 6)
	}

    VarSetCapacity(CopyDataStruct, 12, 0)  ; Set up the structure's memory area.
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    NumPut(StrLen(message) + 1, CopyDataStruct, 4)  ; OS requires that this be done.
    NumPut(&message, CopyDataStruct, 8)  ; Set lpData to point to the string itself.

if (isXML(message)) {
	logA("HostSend->Pid:" . clientPid . " [" . xpath_save(message) . "]", 6)
} else {
	logA("HostSend->Pid:" . clientPid . " [" . message . "]", 6)
}

    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    DetectHiddenWindows On
	; 0x4a is WM_COPYDATA. Must use Send not Post.
	SendMessage, 0x4a, 0, &CopyDataStruct,, ahk_pid %clientPid%  
	DetectHiddenWindows %Prev_DetectHiddenWindows%

	retVal := ErrorLevel
	if (retVal = "FAIL") {
		log("HostSend->Return:" . retVal, 6)
	}
	return retVal  ; Return SendMessage's reply back to our caller.
}
