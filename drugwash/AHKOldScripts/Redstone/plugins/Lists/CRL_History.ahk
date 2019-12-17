history_Initialize() {
	CommandRegister("Command HistoryAdd", "command_HistoryAdd")

	NotifyRegister("UI BuildMenu", "historybar_BuildMenu")
	NotifyRegister("UI BuildMenu", "additem_BuildMenu")
}

additem_BuildMenu(A_Command, A_Args) {
	entry := getNestedNode(A_Args, "Entry")
	listName := getValue(entry, "listName")
	listMeta := syslist_Get("Lists", "/single:Yes /filter:list=" . listName)
	addable := getValue(listMeta, "addable")
	if (addable = "Yes") {
		defaultType := getValue(listMeta, "defaultType")
		if (defaultType <> "") {
		 	command := commandCreate("Editor2 Create", "/type:" . defaultType . " /listName:" . listName)
			menuAdd(A_Args, "/item:New", command)
		}
	}
}

historybar_BuildMenu(A_Command, A_Args) {

	entry := getNestedNode(A_Args, "Entry")
	type := getValue(entry, "type")

	if (type <> "") {

		typeEntry := getTypeMeta(type)
		typeType := getValue(typeEntry, "typeType")
		run := getValue(typeEntry, "run")
		listName := getValue(entry, "listName")
		category := getValue(entry, "category")
		editable := getValue(entry, "editable")
		movable := getValue(entry, "movable")
		
		if (editable <> "No") {
			editable := getValue(typeEntry, "editable", "Yes")
		}
		if (movable <> "No") {
			movable := getValue(typeEntry, "movable", "Yes")
		}

		if (editable <> "No")
		{
; find by keys to use entry from history
			if (listName = "History") {
				replace := "Yes"
			} else {
				replace := "No"
			}
		 	command := commandCreate("Editor2 Create", "/replace:" . replace)
			replaceValue(entry, "listName", "History")
		 	addNamedArgument(command, "Entry", entry)
			menuAdd(A_Args, "/item:Edit", command)

;		 	command := commandCreate("Editor2 Create", "/replace:No")
;		 	addNamedArgument(command, "Entry", entry)
;			menuAdd(A_Args, "/item:Duplicate", command)
		}

		if (movable <> "No") {
	
			filters := syslist_Get("filters", "/filter:addable=Yes /sort:name")

			COMMAND("Menu Clear", "/menu:AddToList")
			Loop {
				filter := list_Iterate(filters, iter)
				if (filter = "") {
					break
				}
				
				name := getValue(filter, "name")

				if (name <> category) {
					command := commandCreate("List Add", "/listName:History")
					replaceValue(entry, "category", name)
					addNamedArgument(command, "Entry", entry)
	
					menuAdd("/menu:AddToList", "/item:" . name, command)
				}
			}

		 	command := commandCreate("Filter New")
		 	addNamedArgument(command, "Entry", entry)
			menuAdd("/menu:AddToList")
			menuAdd("/menu:AddToList", "/item:New category...", command)

			if (category = "") {
				menuAdd(A_Args, "/item:Add to /submenu:AddToList")
			} else {
				menuAdd(A_Args, "/item:Move to /submenu:AddToList")
			}
		}

		if (category <> "") AND (movable <> "No") {

			command := commandCreate("List Add", "/listName:History")
			removeValue(entry, "category")
			addNamedArgument(command, "Entry", entry)
			menuAdd(A_Args, "/item:Remove from " . category, command)
		}

		if (listName = "History") {
			command := commandCreate("List Remove", "/listName:History")
			addNamedArgument(command, "Entry", entry)
			menuAdd(A_Args, "/item:Remove completely", command)
		}
	}
}

command_HistoryAdd(A_Command, A_Args) {

	FormatTime, TimeString, , yyyy/MM/dd HH:mm:ss
	replaceValue(A_Args, "executed", TimeString)

	listName := getValue(A_Args, "listName")
	if (listName <> "History") {
		list := syslist_Get("History")
		oldEntry := syslist_FindByKeys(list, A_Args)
	}

	keyword := getValue(A_Args, "searchPhrase")
	if (keyword = "") AND (oldEntry <> "") {
		list := syslist_Get("History")
		keyword := getValue(oldEntry, "searchPhrase")
		if (keyword <> "") {
			addValues(A_Args, "/searchPhrase:" . keyword)
		}
	}

	count := getValue(A_Args, "executedCount", 0)
	count++
	replaceValue(A_Args, "executedCount", count)

	syslist_Add("History", A_Args)
}
