toolbar_Initialize() {
	CommandRegister("Toolbar Create", "toolbar_Create")
	CommandRegister("Toolbar ClickText", "toolbar_OnClickText")
	CommandRegister("Toolbar RightClickText", "toolbar_OnRightClickText")
	CommandRegister("Toolbar Click", "toolbar_OnClick")
	CommandRegister("Toolbar RightClick", "toolbar_OnRightClick")
	CommandRegister("Toolbar ShowTooltip", "toolbar_OnShowTooltip")

	NotifyRegister("UI Create", "toolbar_CreateUI")
	NotifyRegister("List Update", "toolbar_OnListUpdate")
	NotifyRegister("UI BuildMenu", "toolbar_OnBuildMenu")
}

toolbar_CreateUI(A_Command, A_Args) {

	list := syslist_Get("toolbars", "/sort:name")
	loop
	{
		entry := list_Iterate(list, iter)
		if (entry = "") {
			break
		}
		addValues(entry, "/index:" . A_Index)
		COMMAND("Toolbar Create", entry)
	}
}

toolbar_Create(A_Command, A_Args) {

;	Global CTRLToolbar1, CTRLToolbar2
	Global CTRLToolbarText_1, CTRLToolbarText_2

	index := getValue(A_Args, "index")
	filter := getValue(A_Args, "filter")
	filterMeta := syslist_Get("Filters", "/single:Yes /filter:name=" . filter)
	list := getValue(filterMeta, "list")

	yText := 5
	yBack := 18
	xText := (index-1) * 257 + 5
	xBack := (index-1) * 257 + 5

	COMMAND("UI AddControl", "/name:CTRLToolbarText_" . index
		. " /type:text"
		. " /toolbar:CTRLToolbar" . index
		. " /x:" . xText . " /y:" . yText . " /w:245"
		. " /options:R1 Center vCTRLToolbarText_" . index
		. " /style:+BackgroundTrans"
		. " /text:" . filter
		. " /rightClickCallback:Toolbar RightClickText"
		. " /callback:Toolbar ClickText")

	COMMAND("UI AddControl", "/name:CTRLToolbar" . index
		. " /type:toolbar"
		. " /x:" . xBack . " /y:" . yBack . " /w:245 /h:23"
		. " /style:FLAT"
		. " /tooltipCallback:Toolbar ShowTooltip"
		. " /rightClickCallback:Toolbar RightClick"
		. " /callback:Toolbar Click")

	toolbar_OnListUpdate("", "/listName:" . list)
}

toolbar_OnClickText(A_Command, A_Args) {
	text := getValue(A_Args, "text")
	filterMeta := syslist_Get("Filters", "/single:Yes /filter:name=" . text)
	COMMAND("Lister SetFilter", filterMeta)
}

toolbar_OnRightClickText(A_Command, A_Args) {

	toolbarName := getValue(A_Args, "toolbar")
	toolbarMeta := syslist_Get("Toolbars", "/single:Yes /filter:name=" . toolbarName)
	COMMAND("Menu Create", toolbarMeta)
}

toolbar_OnBuildMenu(A_Command, A_Args) {
	toolbarMeta := getNestedNode(A_Args, "Entry")
	type := getValue(toolbarMeta, "type")

	if (type = "toolbar") {

		COMMAND("Menu Clear", "/menu:ReplaceList")

		filters := syslist_Get("Filters", "/filter:user=Yes /sort:name")
		loop
		{
			filter := list_Iterate(filters, iter)
			if (filter = "") {
				break
			}
			filterName := getValue(filter, "name")
			replaceValue(toolbarMeta, "filter", filterName)

			command := commandCreate("List Add", "/listName:Toolbars")
			addNamedArgument(command, "Entry", toolbarMeta)
			menuAdd("/menu:ReplaceList", "/item:" . filterName, command)
		}
		menuAdd(A_Args, "/item:Replace with /submenu:ReplaceList")
	}
}

toolbar_GetListForToolbar(toolbar) {

	toolbarMeta := syslist_Get("Toolbars", "/single:Yes /filter:name=" . toolbar)

	filter := getValue(toolbarMeta, "filter")
	filterMeta := syslist_Get("Filters", "/single:Yes /filter:name=" . filter)
	return getValue(filterMeta, "list")
}

toolbar_OnRightClick(A_Command, A_Args) {

	control := getValue(A_Args, "name")
	id := getValue(A_Args, "id")
	
	listName := toolbar_GetListForToolbar(control)

	list := syslist_Get(listName)
	entry := list_Get(list, id)

	COMMAND("Menu Create", entry)
}

toolbar_OnClick(A_Command, A_Args) {

	control := getValue(A_Args, "name")
	id := getValue(A_Args, "id")
	
	listName := toolbar_GetListForToolbar(control)

	list := syslist_Get(listName)
	entry := list_Get(list, id)
	COMMAND("Command Run", entry)
}

toolbar_OnShowTooltip(A_Command, A_Args) {

	control := getValue(A_Args, "name")
	id := getValue(A_Args, "id")
; TODO-1: thread issue
id := STATE_GET("Toolbar tooltipId")

	listName := toolbar_GetListForToolbar(control)

	list := syslist_Get(listName)
	entry := list_Get(list, id)
	name := getValue(entry, "name")

	COMMAND("UI Tooltip", name)
}

toolbar_OnListUpdate(A_Command, A_Args) {

	updatedListName := getValue(A_Args, "listName")

	list := syslist_Get("toolbars", "/sort:name")
	loop
	{
		toolbar := list_Iterate(list, iter)
		if (toolbar = "") {
			break
		}
		filter := getValue(toolbar, "filter")
		filterMeta := syslist_Get("Filters", "/single:Yes /filter:name=" . filter)
		listName := getValue(filterMeta, "list")

		if (updatedListName = listName) {

			imageList := IL_Create(10, 10)

			tlist := syslist_Get(listName)
			loop
			{
				entry := list_Iterate(tlist, iter2)
				if (entry = "") {
					break
				}
				lister_AddIconToImageList(entry, imageList)
				if (A_Index >= 10)
					break
			}
			COMMAND("Toolbar32 SetImageList", "/control:CTRLToolbar" . A_Index . " /imageList:" . imageList)
		}
	}
	
	if (updatedListName = "Toolbars") {
		Loop {
			entry := list_Iterate(list, iter)
			if (entry = "") {
				break
			}

			name := getValue(entry, "filter")
			GuiControl,,CTRLToolbarText_%A_index%,%name%

			listName := toolbar_GetListForToolbar("CTRLToolbar" . A_Index)
			toolbar_OnListUpdate("", "/listName:" . listName)
		}
	}
}
