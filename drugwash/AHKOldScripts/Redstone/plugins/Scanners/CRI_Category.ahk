category_Initialize() {
	CommandRegister("Category Scan", "category_OnScan")
}

category_OnScan(A_Command, filter) {
	filterList := list_Read("RedStone/filters.xml")
	list := list_Create()

	Loop {
		entry := list_Iterate(filterList, iter)
		if (entry = "")
			break
		category := getValue(entry, "category")
		if (category <> "") {
			name := getValue(entry, "name")
			icon := Enc_XML(getValue(entry, "icon", "res/Ico22EA.ico"))
			command := commandCreate("Filter Apply", "/name:" . name)
			addValues(command, "/name:" . name . " /icon:" . icon . " /category:" . category)
			description := getValue(entry, "description")
			if (description <> "") {
				addValues(command, "/description:" . description)
			}
			list_Add(list, command)
		}
	}
	syslist_Merge("default", list)
}
