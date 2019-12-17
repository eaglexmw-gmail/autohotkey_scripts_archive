skype_Initialize() {

	RegRead, recentUser, HKCU, SOFTWARE\Skype\PluginManager, RecentUsr
	configFile := A_AppData . "\Skype\" . recentUser . "\" . "config.xml"

	IfNotExist,%configFile%
		configFile := STATE_GET("Skype Config")
	IfNotExist,%configFile%
	{
;		syslist_Add("Errors", "/type:error /error:Unable to locate Skype configuration file")
		Return
	}
	RegRead, exeFile, HKCU, SOFTWARE\Skype\Phone, SkypePath

	ifNotExist,%exeFile%
		exeFile := STATE_GET("Skype Executable")
	IfNotExist,%exeFile%
	{
;		log("Unable to locate Skype executable")
		Return
	}

	STATE_SET("Skype Config", configFile)
	STATE_SET("Skype EXE", exeFile)

	CommandRegister("Skype ImportContacts", "skype_ImportContacts")
}

skype_ImportContacts(A_Command, A_Args) {

	configFile := STATE_GET("Skype Config")
	IfNotExist,%configFile%
	{
		Return
	}
	exeFile := STATE_GET("Skype EXE")

	xpath_load(xml, configFile)

;	list := xpath(xml, iterzz, "/config/Lib/CentralStorage/SyncSet/u")
;	StringReplace,list,list,_.2B,+,All
;	xpath_load(list)
;logA("LOOPING")
;	Loop {
;		entry := list_Iterate(list, iter)
;		if (entry = "") {
;			break
;		}
;logA("entry:" . entry)
;		contact := getRoot(entry)
;		StringReplace,name,name,.2E,%A_Space%,All
;
;		entry := "/name:Skype: " . name . " /listName:Default /type:skype /command:" . exeFile . " /parameters:/callto:" . name
;logA("entry:" . entry)
;		list_Add(slist, entry)
;	}

	list := xpath(xml, iter, "/config/Lib/CentralStorage/SyncSet/u/*/name()")
	slist := list_Create()
	Loop, Parse, list, `,
	{
		contact := A_LoopField
		StringReplace,contact,contact,<,,All

		pos := InStr(contact, ">")
		contact := SubStr(contact, 1, pos-1)
		StringReplace,name,contact,_.2B,+,All
		StringReplace,name,name,.2E,%A_Space%,All

		entry := "/name:Skype: " . name . " /listName:Default /type:skype /command:" . exeFile . " /parameters:/callto:" . name
		list_Add(slist, entry)
	}
	syslist_Merge("default", slist)
}

