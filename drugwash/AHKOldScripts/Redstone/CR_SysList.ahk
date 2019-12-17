list_Initialize() {

	lists := syslist_Read("Lists")
	Loop
	{
		entry := list_Iterate(lists, iter)
		if (entry = "") {
			break
		}
		listName := getValue(entry, "list")
		persistent := getValue(entry, "persistent")
		if (listName <> "Lists") AND (persistent = "Yes") OR (listName = "Default") {
			syslist_Read(listName)
;			if (list <> "") {
;				iter2 :=
;				nlist := list_Create()
;				Loop {
;					entry := list_Iterate(list, iter2)
;					if (entry = "")
;						break
;					entryListName := getValue(entry, "listName")
;					if (entryListName = "")
;						addValues(entry, "/listName:" . listName)
;					list_Add(nlist, entry)
;				}
;				syslist_Set(listName, nlist)
;				list_Write(nlist, listName . ".xml")
;			}
		}
	}
	
	type_Cache()

	CommandRegister("List Add", "clist_Add")
;	CommandRegister("List Merge", "list_Merge")
	CommandRegister("List Remove", "clist_Remove")
	CommandRegister("List Clear", "clist_Clear")
}

type_Cache() {
	handlers := syslist_Get("Handler")
	
	loop
	{
		handler := list_Iterate(handlers, iter)
		if (handler = "") {
			break
		}
		handleType := getValue(handler, "handleType")
		type := getValue(handler, "typeType")
		typeType := syslist_Get("Types", "/single:Yes /filter:typeType=" . type)
		addValues(typeType, "/handleType:" . handleType)
		syslist_Add("typeMeta", typeType)
	}
}

syslist_ConvertToXML(list) {

	log("Converting to XML")

	xml := list_Create()

	loop,Parse,list,`n
	{
		fieldIndex := 1
		fields := A_LoopField
		type := getValue(fields, "type")

		removeValue(fields, "listName")
		loop
		{
			StringGetPos, epos, fields, :
			if epos = -1
				break
			name := SubStr(fields, 2, epos-1)
			xvalue := removeValue(fields, name)
			if (fieldIndex = 1) {
				xpath(xml, iter, "/Redstone/" . type . "[+1]/" . name . "[+1]/text()", xvalue)
			} else {
				xpath(xml, iter, "/Redstone/" . type . "[last()]/" . name . "[+1]/text()", xvalue)
			}
			
			fieldIndex ++
		}
	}

	return xml
}

clist_Clear(A_Command, A_Args) {
	listName := getValue(A_Args, "listName")
	if (listName <> "") {
		syslist_Set(listName, list_Create())
	}
}

clist_Remove(A_Command, A_Args) {

	listName := getValue(A_Args, "listName")
	if (listName <> "") {
		entry := getNestedNode(A_Args, "Entry")
		syslist_Remove(listName, entry)
	} else {
		log("list_Remove->No list:" . A_Args)
		syslist_Add("Errors", "/type:error /error:list_Remove: No list name")
	}
}

clist_Add(A_Command, A_Args) {

	listName := getValue(A_Args, "listName")
	entry := getNestedNode(A_Args, "Entry")
	if (listName <> "") {
		syslist_Add(listName, entry)
	}
}

syslist_Add(listName, entry) {

	syslist_Replace(listName, entry, "")
}

syslist_Replace(listName, entry, removeEntry) {

logA("Add [ " . listName . " ] [" . entry . "]", 3)

	if (entry = "") {
		logA("Invalid list passed to syslist_Replace")
		return
	}

	replaceValue(entry, "listName", listName)

	listMeta := syslist_Get("Lists", "/single:Yes /filter:list=" . listName)
	unique := getValue(listMeta, "unique")
	persistent := getValue(listMeta, "persistent")
	addMode := getValue(listMeta, "addMode")
	notify := getValue(listMeta, "notify")

	list := syslist_Get(listName)
	if (list = "") {
		list := list_Create()
	}

	if (removeEntry <> "") {
		logA("Remove Passed [ " . listName . " ] " . removeEntry, 3)
		removed := list_Remove(list, removeEntry)
		if (removed) {
			logA("Remove Successful", 3)
		} else {
			logA("Remove Failed", 3)
		}
	}

	if (unique = "Yes") {
		removeEntry := syslist_FindByKeys(list, entry)
		if (removeEntry <> "") {
			uniqueAction := getValue(listMeta, "uniqueAction")
			if (uniqueAction = "ignore") {
				return list
			}
			logA("Remove [ " . listName . " ] " . removeEntry, 3)
			removed := list_Remove(list, removeEntry)
		}
	}

	if (addMode = "Insert") {
		list_Insert(list, entry)
	} else {
		list_Add(list, entry)
	}

	syslist_Set(listName, list)

	if (persistent = "Yes") {
		syslist_Write(list, listName)
	}

	if (listMeta <> "") AND (notify <> "No") {
		notifyArgs := createNode("/listName:" . listName)
		if (removed <> 1) {
			addNestedNode(notifyArgs, "Entry", entry)
		}
		NOTIFY("List Update", notifyArgs)
	}
	
	return list
}

syslist_Remove(listName, entry) {

logA("Remove [ " . listName . "] " . entry, 3)
	listMeta := syslist_Get("Lists", "/single:Yes /filter:list=" . listName)
	unique := getValue(listMeta, "unique")

	list := syslist_Get(listName)
	if (unique = "Yes") {
		entry := syslist_FindByKeys(list, entry)
		if (entry <> "") {
			removed := list_Remove(list, entry)
		}
	} else {
		removed := list_Remove(list, entry)
	}

	if (removed) {
		logA("Remove [ " . listName . " ] " . xpath_save(entry), 3)
		syslist_Set(listName, list)

		persistent := getValue(listMeta, "persistent")
		if (persistent = "Yes") {
			syslist_Write(list, listName)
		}
	
		NOTIFY("List Update", "/listName:" . listName)
	}

	return list
}

syslist_Get(listName, args="") {
	glist := STATE_GET("System " . listName)
	if (glist = "") {
		glist := list_Create()
	}
	
	if (args <> "") {
		filter := getValue(args, "filter")
		sort := getValue(args, "sort")
		if (filter <> "") {
			single := getValue(args, "single", "No")
			
			if (single = "Yes") {
				glist := xml_iterate(glist, iter, "[" . filter . "]")
				if (glist <> "") {
					field := getValue(args, "field")
					if (field <> "") {
						return getValue(glist, field)
					}
				}
			} else {
				list := list_Create()
				Loop {
					entry := xml_iterate(glist, iter, "[" . filter . "]")
					if (entry = "")
						break
					list_Add(list, entry)
				}
				if (sort <> "") {
					list_Sort(list, sort)
				}
				return list
			}
		}
		if (sort <> "") {
			list_Sort(glist, sort)
		}
	}
	
	return glist
}

syslist_Set(listName, list) {
	STATE_SET("System " . listName, list)
}

syslist_FindByKeys(list, entry) {

	type := getValue(entry, "type")
	typeMeta := getTypeMeta(type)
	keyFields := getValue(typeMeta, "keyFields")
	if (keyFields <> "") {
		filter := "[type=" . type . "]"
		Loop,Parse,keyFields,`,
		{
			fieldName := A_LoopField
			value := getValue(entry, fieldName)
			if (value = "") {
				value := "null"
			}
			filter := filter . "[" . fieldName . "=" . Enc_XML(value) . "]"
		}
		if (filter <> "") {
logA("FINDBYKEYS:" . filter)
			return xml_iterate(list, iter, filter)
		}
	}
	
	return
}

syslist_Merge(listName, mergeList) {

	list := STATE_GET("System " . listName)
	if (list = "") {
		list := list_Create()
	}

	listMeta := syslist_Get("Lists", "/single:Yes /filter:list=" . listName)
	unique := getValue(listMeta, "unique")
	persistent := getValue(listMeta, "persistent")
	notify := getValue(listMeta, "notify")

	list_Merge(list, mergeList)

	syslist_Set(listName, list)

	if (persistent = "Yes") {
		syslist_Write(list, listName)
	}

	if (listMeta <> "") AND (notify <> "No") {
		NOTIFY("List Update", "/listName:" . listName)
	}
}

syslist_Read(listName) {

	appName := STATE_GET("Application Name")

	list := list_Read(listName . ".xml")
	appList := list_Read(appName . "/" . listName . ".xml")
	
	if (list = "") {
		list := list_Create()
	}

	if (appList <> "") {
		list_Merge(list, appList)
	}
	syslist_Set(listName, list)
	
	return list
}

syslist_Write(list, listName) {
	appName := STATE_GET("Application Name")

	listMeta := syslist_Get("Lists", "/single:Yes /filter:list=" . listName)
	scope := getValue(listMeta, "scope")
	if (scope = "Application") {
		listName := appName . "/" . listName
	}
	list_Write(list, listName . ".xml")
}
