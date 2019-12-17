filter_Initialize() {

	CommandRegister("Filters Show", "filter_Show", "/name:List Filters")
	CommandRegister("Filter Apply", "filter_Apply")
	CommandRegister("Filter Click", "filter_OnClick")
	CommandRegister("Filter RightClick", "filter_OnRightClick")

	NotifyRegister("UI Create", "filter_OnUiCreate")
}

filter_OnUiCreate(A_Command, A_Args) {

	COMMAND("UI AddControl", "/name:Categories"
		. " /type:button"
		. " /x:23 /y:62 /w:16 /h:16"
		. " /style:-theme +0x8000"
		. " /tooltip:Categories"
		. " /image:res\Filters.bmp"
		. " /rightClickCallback:Filter RightClick"
		. " /callback:Filter Click")
}

filter_OnClick(A_Command, A_Args) {
	COMMAND("Filter Apply", "/name:Categories")
}

filter_OnRightClick(A_Command, A_Args) {
	COMMAND("Filter Apply", "/name:Filters")
Return
	COMMAND("Menu Clear", "/menu:uiMenu")

	filters := syslist_Get("Categories", "/sort:name")
	loop
	{
		entry := list_Iterate(filters, iter)
		if (entry = "") {
			break
		}
		filterName := getValue(entry, "name")

		menuAdd("/menu:uiMenu", "/item:" . filterName, entry)
	}
	
	COMMAND("Menu Show", "/menu:uiMenu")
}

filter_Show(A_Command, A_Args) {
	COMMAND("Filter Apply", "/name:Filters")
}

filter_Apply(A_Command, A_Args) {

	name := getValue(A_Args, "name")
	filter := syslist_Get("Filters", "/single:Yes /filter:name=" . name)

	if (filter = "") {
		listName := getValue(A_Args, "list")
		if (listName <> "") {
			filter := "/type:filter /name:" . listName . " /list:" . listName
		}
	}
	COMMAND("Lister SetFilter", filter)
;	COMMAND("Lister SetText", "/clear:Yes /focus:Yes")
}

