#include CR_Util.ahk
#include CR_Debug.ahk
#include CR_SysList.ahk
#include CR_List.ahk
#include CR_Args.ahk
#include CR_XML.ahk
#include CR_Log.ahk
#include CR_Command.ahk
#include CR_Plugin.ahk
#Include XPath.ahk
#include CR_AHK.ahk

CR_Initialize(AppName) {

	Process, Exist
	pid := errorlevel
	STATE_SET(AppName . " PID", pid)
	STATE_SET("Application PID", pid)

	Gui, 1:+ToolWindow -Caption +Border +Resize
	Gui, 1:+LastFound
	STATE_SET(AppName . " WID", WinExist())
	STATE_SET("Application WID", WinExist())
	STATE_SET("Application Name", AppName)

	state_Initialize(AppName)
	log_Initialize(AppName)
StartTimeX := A_TickCount
	list_Initialize()
log("List Startup in:" . A_TickCount - StartTimeX)
	command_Initialize()
StartTimeX := A_TickCount
	plugin_Initialize()
log("Plugin Startup in:" . A_TickCount - StartTimeX)

	NOTIFY("System Initialized")
}

BACKGROUND_COMMAND(command, args="") {

	entry := createNode("/bgcommand:" . command, "Command")
	setNode(entry, "args", args)

	syslist_Add("BackgroundCommands", entry)
	SetTimer, BackgroundCommandTimer, 10
	
	Return

	BackgroundCommandTimer:
		SetTimer, BackgroundCommandTimer, Off
;		Thread, priority, -1000000

		Loop {
			blist := syslist_Get("BackgroundCommands")
			entry := list_Get(blist, 1)
			if (entry = "") {
				break
			}
			list_Remove(blist, entry)

			syslist_Set("BackgroundCommands", blist)

			bgCommand := getValue(entry, "bgcommand")
			args := getNode(entry, "args")

			COMMAND(bgCommand, args)
		}
	Return
}

STATE_SET(name, value) {
	global

	StringReplace, name, name, %A_Space%, _
	states%name% := value

	log("SET    : " . name . " [" . value . "]", 5)
}

STATE_GET(name, default="") {

	local value=

	StringReplace, name, name, %A_Space%, _
	value := states%name%
	
	if (value = "") {
		log("GET    : " . name . " [" . value . "]", 0)
		return default
	} 
	log("GET    : " . name . " [" . value . "]", 5)
	return value
}


state_Initialize(AppName) {
	xpath_load(list, A_ScriptDir . "/" . AppName . ".xml")

	Loop {
		entry := list_Iterate(list, iter)
		if (entry = "") {
			break
		}
		entries := xpath(entry, iter2, "/*/*/nodes()")
        StringReplace, entries, entries, </, , All
        StringReplace, entries, entries, >, , All
        root := getRoot(entry)
		Loop,Parse,entries,`,
		{
			value := getValue(entry, A_LoopField)
			STATE_SET(root . " " . A_LoopField, value)
		}
	}
	STATE_SET("System State", list)
}

STATE_WRITE(name) {

; TODO: Broke
Critical,On

	list := STATE_GET("System State")
	if (list = "") {
		list := list_Create()
	}
	value := STATE_GET(name)

	StringSplit,narray,name,%A_SPACE%

	entry := getNode(list, narray1)
	if (entry = "") {
		entry := createNode("")
	}
	replaceValue(entry, narray2, value)
	
	setNode(list, narray1, entry)
	
	STATE_SET("System State", list)

	appName := STATE_GET("Application Name")
	xpath_save(list, A_ScriptDir . "/" . appName . ".xml")
	Critical,Off
}

CommandRegister(command, callBack, args="") {

	list := syslist_Get("Redstone")
	
	if (args = "") {
		args := list_Create("command")
	} else {
		args := createNode(args)
	}

	addValues(args, "/type:command /command:" . command . " /callback:" . callback) 	

	list_Add(list, args)
	syslist_Set("Redstone", list)
}

COMMAND(command, args="") {

	entry := syslist_Get("Redstone", "/single:Yes /filter:command=" . command)
	if (entry <> "") {
		callback := getValue(entry, "callback")
		if (callback <> "") {

			if (isXML(args)) {
				logA("COMMAND: " . callback . "->" . command . xpath_save(args), 1)
			} else {
				logA("COMMAND: " . callback . "->" . command . " [" . args . "]", 1)
			}
			Return %callback%(entry, args)
		}
	}

	logA("COMMAND: " . command . " [" . args . "]", 0)
	ErrorLevel = ERROR
}

NOTIFY(command, args="") {
	if (isXML(args)) {
		logA("NOTIFY : " . command . " [" . xpath_save(args) . "] *******************************", 1)
	} else {
		logA("NOTIFY : " . command . " [" . args . "] *******************************", 1)
	}

	StringReplace, command, command, %A_Space%, _

	list := syslist_Get("Notifications")
	node := getNode(list, command)
	Loop {
	
		entry := list_Iterate(node, iter)
		if (entry = "") {
			break
		}

		callback := getValue(entry, "callback")
		if (callback <> "") {

			if (isXML(args)) {
				logA("CALBACK: " . callback . "->" . command . xpath_save(args), 1)
			} else {
				logA("CALBACK: " . callback . "->" . command . " [" . args . "]", 1)
			}
			%callback%(entry, args)
		}
	}
}

NotifyRegister(command, callBack, args="") {

	list := syslist_Get("Notifications")

	if (!isXML(args)) {
		args := createNode(args)
	}
	addValues(args, "/type:command /command:" . command . " /callback:" . callback) 	

	StringReplace, command, command, %A_Space%, _
	node := getNode(list, command)
	if (node = "") {
		node := createNode("", command)
	}

	list_Add(node, args)
	setNode(list, command, node)
	syslist_Set("Notifications", list)
}
