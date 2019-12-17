buttons_Initialize() {
	CommandRegister("Buttons Click", "buttons_OnClick")
	CommandRegister("Buttons RightClick", "buttons_OnRightClick")
	CommandRegister("Buttons ShowTooltip", "buttons_OnShowTooltip")

	NotifyRegister("UI Create", "buttons_CreateUI")
	NotifyRegister("UI BuildMenu", "buttons_OnBuildMenu")
	NotifyRegister("List Update", "buttons_OnListUpdate")
}

buttons_CreateUI(A_Command, A_Args) {

	buttonMetaList := syslist_Get("Buttons", "/sort:name")

	loop
	{
		entry := list_Iterate(buttonMetaList, iter)
		if (entry = "") {
			break
		}
		buttonName := getValue(entry, "name")
		buttonIcon := getValue(entry, "icon")
		
		BX := (A_Index -1) * 28 + 5

		COMMAND("UI AddControl", "/name:" . ButtonName
			. " /type:button"
			. " /x:" . BX . " /y:323 /w:25 /h:25"
			. " /tooltipCallback:Buttons ShowTooltip"
			. " /anchor:y /redraw:Yes"
			. " /image:" . Enc_XML(buttonIcon)
			. " /rightClickCallback:Buttons RightClick"
			. " /callback:Buttons Click")
	}
}

buttons_OnClick(A_Command, A_Args) {
	name := getValue(A_Args, "name")
	buttonMeta := syslist_Get("Buttons", "/single:Yes /filter:name=" . name)
	command := getNode(buttonMeta, "command")
	BACKGROUND_COMMAND("Command Run", command)
}

buttons_OnListUpdate(A_Command, A_Args) {

	listName := getValue(A_Args, "listName")
	if (listName = "Buttons") {
		buttonMetaList := syslist_Get("Buttons")
		loop
		{
			entry := list_Iterate(buttonMetaList, iter)
			if (entry = "") {
				break
			}
			buttonName := getValue(entry, "name")
			buttonIcon := getValue(entry, "icon")
			COMMAND("Button SetImage", "/name:" . buttonName . " /image:" . buttonIcon)
		}
	}
}

buttons_OnShowTooltip(A_Command, A_Args) {

	buttonName := getValue(A_Args, "name")
	buttonMeta := syslist_Get("Buttons", "/single:Yes /filter:name=" . buttonName)
	filterName := xpath(buttonMeta, iter, "/Button/command/Args/name/text()")
	COMMAND("UI Tooltip", filterName)
}

buttons_OnRightClick(A_Command, A_Args) {

	buttonName := getValue(A_Args, "name")
	buttonMeta := syslist_Get("Buttons", "/single:Yes /filter:name=" . buttonName)
	
	COMMAND("Menu Create", buttonMeta)
}

buttons_OnBuildMenu(A_Command, A_Args) {

	buttonMeta := getNestedNode(A_Args, "Entry")
	type := getValue(buttonMeta, "type")

	if (type = "Button") {

		COMMAND("Menu Clear", "/menu:ReplaceList")

		filters := syslist_Get("Search", "/filter:category=Categories /sort:name")

		loop
		{
			filter := list_Iterate(filters, iter)
			if (filter = "") {
				break
			}

			filterIcon := getValue(filter, "icon")
			if (filterIcon = "")
				filterIcon := "res\Ico281C.ico"
			replaceValue(buttonMeta, "icon", Enc_XML(filterIcon))

			filterName := getValue(filter, "name")
			buttonCommand := commandCreate("Filter Apply", "/name:" . filterName)
			setNode(buttonMeta, "command", buttonCommand)

			command := commandCreate("List Add", "/listName:Buttons")
			addNamedArgument(command, "Entry", buttonMeta)

			menuAdd(A_Args, "/item:" . filterName, command)
		}
	}
}
