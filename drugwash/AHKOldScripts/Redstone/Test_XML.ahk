testXML_Initialize() {

	CommandRegister("XML Test", "xml_Test")
}

xml_Test(A_Command, A_Args) {
setLogExtended(1)
log("TEST***************************")
log("TEST***************************")
log("TEST***************************")
log("TEST***************************")
;	xml_TestIterator()
;	xml_TestcreateNode()
;	xml_TestAdd()
;	xml_TestMerge()
;	xml_TestLoad()
;	xml_TestFind()
;	xml_TestMenu()
;	xml_TestSort()
	xml_TestSortPerf()
;	xml_TestInsert()
;	xml_TestFindByKeys()
;	xml_TestFindPerf()
setLogExtended(0)
}

xml_TestMenu() {

	StartTime := A_TickCount

	filterName := getValue(entry, "Favorites")
	icon := " /icon:xxxxx"

			filterCommand := commandCreate("Filter Apply", "/name:" . filterName)
			addValues(filterCommand, "/name:" . filterName . icon)

	lists := syslist_Get("Lists", "/filter:persistent=Yes")
	list_Sort(lists, "name")
	COMMAND("Menu Clear", "/menu:AddToList2")
	loop
	{
		list := list_Iterate(lists, iter)
		if (list = "") {
			break
		}
		defaultType := getValue(list, "defaultType")
		typeMeta := syslist_Get("Types", "/single:Yes /filter:typeType=" . defaultType)
		editable := getValue(typeMeta, "editable")

		if (editable <> "No") {
			name := getValue(list, "name")
			addListName := getValue(list, "list")

			command := commandCreate("List Add", "/listName:" . addListName)
			addNamedArgument(command, "Entry", filterCommand)

			menuAdd("/menu:AddToList2", "/item:" . name, command)
		}
	}
	menuAdd("/menu:uiMenu", "/item:Add to List /submenu:AddToList2")
	log("menu Elapsed:" . A_TickCount - StartTime)
}

xml_TestcreateNode() {
	StartTime := A_TickCount
	Loop,100 {
		buttonCommand := createNode("/command:Filter Apply /type:command /name:filterName", "command")
		command := createNode("/command:List Add /type:command /listName:Buttons", "command")
	}
	log("Old Elapsed:" . A_TickCount - StartTime)

	logA("args:" . createNode("/command:Filter Apply /type:command /name:filterName", "command"))
}

xml_TestSort() {
	list := list_Create()
	list_Add(list, createNode("/name:entryC"))
	list_Add(list, createNode("/name:entryB"))
	list_Add(list, createNode("/name:entryA"))

	list_Sort(list, "name")
	logA("sorted:" . xpath_save(list))
	
	list := syslist_Get("favorites")
	list_Sort(list, "name")
	logA("sorted:" . xpath_save(list))
}

xml_TestSortPerf() {
	StartTime := A_TickCount

	list := syslist_Get("Search")
;	list_SortOld(list, "name")
	log("Old sort Elapsed:" . A_TickCount - StartTime)
	logA(list_GetCount(list))
	
	StartTime := A_TickCount
	list := syslist_Get("Search")
	logA(list_GetCount(list))
	list_Sort(list, "name")
	log("new sort Elapsed:" . A_TickCount - StartTime)
	logA(list_GetCount(list))

;	logA(xpath_save(list))
}

xml_TestInsert() {
	list := list_Create()
	entry1 := createNode("/filter:test", "entry1")
	entry2 := createNode("/yyyy:test /zzzzz:test /wwww:test /ffff:test", "entry2")
	addNestedNode(entry2, "foo", entry1)

	StartTime := A_TickCount
	Loop,1
	{
		list_Insert(list, entry1)
		list_Insert(list, entry2)
	}
	log("list_Add Elapsed:" . A_TickCount - StartTime)
	logA("list:" . list)
	logA("list:" . xpath_save(list))
}

xml_TestFindByKeys() {
	entry := createNode("/name:testsearch /type:webSearch /description:test /term:xxx")
	syslist_Add("Favorites", entry)
	
	favorites := syslist_Get("Favorites")
	logA("found:" . syslist_FindByKeys(favorites, entry))
}

xml_TestLoad() {
	list := syslist_Get("Favorites")
	logA("list:" . list)	
}

xml_TestFind() {
	
	list := syslist_Get("Redstone", "/filter:name!=null")
	logA("found:" . xpath_save(list))

	list := syslist_Get("Lists", "/single:Yes /filter:list=")
	logA("found:" . xpath_save(list))
}

xml_TestFindPerf() {
	
	StartTime := A_TickCount
	Loop,100
		syslist_Get("History", "/filter:name=Lock Workstation")
	log("Old Elapsed:" . A_TickCount - StartTime)
}

xml_TestMerge() {
	lista := list_Create()
	listb := list_Create()
	entry1 := createNode("/filter:test", "entry1")
	entry2 := createNode("/yyyy:test /zzzzz:test /wwww:test /ffff:test", "entry2")

	list_Add(lista, entry1)
	list_Add(listb, entry2)
	list_Merge(lista, listb)
	
	logA("lista:" . lista)
	logA("lista:" . xpath_save(lista))
}

xml_TestAdd() {
	list := list_Create()
	entry1 := createNode("/filter:test", "entry1")
	entry2 := createNode("/yyyy:test /zzzzz:test /wwww:test /ffff:test", "entry2")
	addNestedNode(entry2, "foo", entry1)

	StartTime := A_TickCount
	Loop,1
	{
		list_Add(list, entry1)
		list_Add(list, entry2)
	}
	log("list_Add Elapsed:" . A_TickCount - StartTime)
	logA("list:" . list)
	logA("list:" . xpath_save(list))
}


