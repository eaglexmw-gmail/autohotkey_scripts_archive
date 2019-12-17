list_Create(rootNode="Redstone") {
	xpath(alist, iter, "/" . rootNode . "[+1]")
	return alist
}

list_Get(ByRef glist, indexNo) {

	Loop {
		entry := list_Iterate(glist, iter)
		if (entry = "") {
			break
		}
		if (A_Index = indexNo) {
			return entry
		}
	}
	return ""
}

list_Iterate(ByRef list, ByRef iter, filter="") {

	if (filter <> "") {
		filter := "[" . filter . "]"
	}

	return xml_iterate(list, iter, filter)
}

list_GetCount(ByRef glist) {
	if (glist = "") {
		return 0
	}
	return xpath(glist, iter, "/*/*/count()")
}

list_Replace(ByRef list, iter, entry) {
	xml_addRoot(getRoot(list), entry)
	xml_replace(list, iter, entry)
}

list_Add(ByRef list, entry) {

	if (isXML(entry) = 0) {
		entry := createNode(entry)
	}

	root := getRoot(list)
	eroot := getRoot(entry)

	; TODO: use reroot
	stag := "<" . eroot . "/"
	etag := "</" . eroot . "/"

	srtag := "<" . root . "/" . eroot . "/"
	ertag := "</" . root . "/" . eroot . "/"
	
    StringReplace, entry, entry, %stag%, %srtag%, All
    StringReplace, entry, entry, %etag%, %ertag%, All

	; TODO: Inefficient
	osx := InStr(list, "</" . root . "/>")

	list := SubStr(list, 1, osx - 1) . entry . SubStr(list, osx)
}

list_Merge(ByRef lista, listb) {

	root := getRoot(lista)
	eroot := getRoot(listb)

	if (root <> eroot) {
		stag := "<" . eroot . "/"
		etag := "</" . eroot . "/"
	
		srtag := "<" . root . "/"
		ertag := "</" . root . "/"
		
	    StringReplace, listb, listb, %stag%, %srtag%, All
	    StringReplace, listb, listb, %etag%, %ertag%, All
	}

	btag := "<" . root . "/:: >"

	osx := InStr(lista, "</" . root . "/>")
	osb := InStr(listb, btag) + StrLen(btag)  
	osxb := InStr(listb, "</" . root . "/>")

	lista := SubStr(lista, 1, osx - 1) . SubStr(listb, osb, osxb - osb) . SubStr(lista, osx)
}

list_Insert(ByRef list, entry) {

	if (isXML(entry) = 0) {
		entry := createNode(entry)
	}

	; TODO: use reroot
	root := getRoot(list)
	eroot := getRoot(entry)

	stag := "<" . eroot . "/"
	etag := "</" . eroot . "/"

	srtag := "<" . root . "/" . eroot . "/"
	ertag := "</" . root . "/" . eroot . "/"
	
    StringReplace, entry, entry, %stag%, %srtag%, All
    StringReplace, entry, entry, %etag%, %ertag%, All

	btag := "<" . root . "/:: >"
	osx := InStr(list, btag) + StrLen(btag)  

	list := SubStr(list, 1, osx - 1) . entry . SubStr(list, osx)
}

list_Contains(ByRef clist, centry) {

	Loop
	{
		entry := list_Iterate(clist, iter)
		if (entry = "") {
			break
		}
		if (entry = centry) {
			return 1
		}
	}

	return 0
}

list_Write(zlist, fileName) {

	fileName := A_ScriptDir . "/config/" . fileName
	xpath_save(zlist, fileName)
}

list_SortOld(ByRef list, key) {
	global gblKeyField := key

	xml_quicksort(list, 1, list_GetCount(list))
}

list_SortCompare(a1, a2) {

	StringSplit, a1Name, a1, |
	StringSplit, a2Name, a2, |
    return a1Name1 > a2Name1 ? 1 : a1Name1 < a2Name1 ? -1 : 0
}

list_Sort(ByRef list, key) {
	slist := ""
	Loop {
		entry := list_Iterate(list, iter)
		if (entry = "") {
			break
		}
		value := getValue(entry, key)
		slist := slist . value . "|" . iter . "`n"
	}

	Sort, slist, F list_SortCompare
	StringTrimRight, slist, slist, 1
	
	nlist := list_Create()
	Loop,Parse,slist,`n
	{
		StringSplit, ss, A_LoopField, |
		ss2--
		entry := list_Iterate(list, ss2)
		if (entry <> "") {
			list_Add(nlist, entry)
		}
	}
	list := nlist
}

list_Compare(entry1, entry2) {
	global gblKeyField

	field1 := getValue(entry1, gblKeyField)
	field2 := getValue(entry2, gblKeyField)

	return field1 > field2 ? 1 : field1 < field2 ? -1 : 0
}

list_Read(fileName, maxLines=0) {

	xpath_load(list, "config/" . fileName)
	return list
}

list_Remove(ByRef rlist, ByRef rmentry) {

	removed := 0
	Loop
	{
		entry := list_Iterate(rlist, iter)
		if (entry = "") {
			break
		}
		if (entry = rmentry) {
			removed := 1
			xml_remove(rlist, iter)
			break
		}
	}

	return removed
}
