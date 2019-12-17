menu_Initialize() {
	CommandRegister("Menu Create", "menu_OnCreate")
	CommandRegister("Menu Show", "menu_OnShow")
	CommandRegister("Menu Add", "menu_OnAdd")
	CommandRegister("Menu Action", "menu_OnAction")
	CommandRegister("Menu Clear", "menu_OnClear")
}

menu_OnClear(A_Command, A_Args) {
	menu := getValue(A_Args, "menu")
	COMMAND("List Clear", "/listName:Menu_" . menu)
	Menu, %menu%, UseErrorLevel,On
	Menu, %menu%, Delete
}

menu_OnAdd(A_Command, A_Args) {
	menu := getValue(A_Args, "menu")
	item := getValue(A_Args, "item")
	submenu := getValue(A_Args, "submenu")
	RSMenu(menu, item, A_Args, submenu)
}

menu_OnAction(A_Command, A_Args) {
	Name := getValue(A_Args, "menu")
	action := getValue(A_Args, "action")
	item := getValue(A_Args, "item")

	if (action = "Check") {
		Menu, %Name%, Check, %item%
	} else if (action = "ToggleCheck") {
		Menu, %Name%, ToggleCheck, %item%
	}
}

RSMenu(Name, Text="", command="", submenu="") {
	if (submenu <> "") {
		Menu, %Name%, Add, %Text%, :%submenu%
	} else {
		Menu, %Name%, Add, %Text%, MenuCommand
		if (Text <> "")
			MenuRegister(Name, Text, command)
	}
}

MenuRegister(menu, name, command) {

	StringReplace, OutputVar, name, &
	StringReplace, OutputVar, OutputVar, %A_SPACE%,,All
	entry := "/menuItem:" . name . " " . command

	menuList := syslist_Get("Menu_" . menu)
	list_Add(menuList, command)
	syslist_Set("Menu_" . menu, menuList)
}

MenuCommand:
	MenuCommandRun(A_ThisMenu, A_ThisMenuItem)
Return

MenuCommandRun(thisMenu, thisMenuItem) {

	entry := syslist_Get("Menu_" . thisMenu, "/single:Yes /filter:item=" . thisMenuItem)
	command := getNode(entry, "command")

	if (command <> "") {
		COMMAND("Command UserRun", command)
	} else {
;		syslist_Add("Errors", "/type:error /error:Invalid Menu Command: " . thisMenuItem)
	}
}

menu_OnCreate(A_Command, entry) {

	CoordMode, Mouse, Relative
	MouseGetPos, xpos, ypos

	COMMAND("Menu Clear", "/menu:uiMenu")

	menuArgs := createNode("/menu:uiMenu", "MenuEntry")
	addNestedNode(menuArgs, "Entry", entry)

	NOTIFY("UI BuildMenu", menuArgs)
	
	COMMAND("Menu Show", "/menu:uiMenu /x:" . xpos . " /y:" . ypos)
	COMMAND("Command CheckErrors")
}

menu_OnShow(A_Command, A_Args) {
	menu := getValue(A_Args, "menu")
	x := getValue(A_Args, "x")
	y := getValue(A_Args, "y")
	Menu, %menu%, Show, %x%, %y%
	Menu, %menu%, UseErrorLevel, Off
}

menuAdd(menuNode, menuArgs="", commandNode="") {

	menu := getValue(menuNode, "menu")
	
	menuNode := createNode("/menu:" . menu, "MenuEntry")
	if (menuArgs <> "") {
		addValues(menuNode, menuArgs)
	}

	if (commandNode <> "") {
		setNode(menuNode, "command", commandNode)
	}
	
;	COMMAND("Menu Add", menuNode)
	menu_OnAdd(0, menuNode)
}
