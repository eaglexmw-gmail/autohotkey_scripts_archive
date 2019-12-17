createNode(fields, nodeName="command") {

	if (isXML(fields)) {
		return fields
	}

	xml := "<" . nodeName . "/:: >"
	
	loop
	{
		StringGetPos, epos, fields, :
		if epos = -1
			break
		name := SubStr(fields, 2, epos-1)
		value := removeValue(fields, name)

		node := nodeName . "/" . name . "/"
		xml := xml . "<" . node . ":: >" . value . "</" . node . ">"
	}

	return xml . "</" . nodeName . "/>" 
}

nodeMerge(ByRef iNode, mNode) {
	if (mNode <> "") {
		entries := xpath(mNode, iter, "/*/*/nodes()")
        StringReplace, entries, entries, </, , All
        StringReplace, entries, entries, >, , All
		Loop,Parse,entries,`,
		{
			value := getValue(mNode, A_LoopField)
			replaceValue(iNode, A_LoopField, value)
		}
	}
}

setNode(ByRef args, nodeName, entry) {
	removeValue(args, nodeName)
	if (!isXML(entry)) {	
		entry := createNode(entry)
	}
	xml_reroot(nodeName, entry)
	list_Add(args, entry)
}

getNode(args, argName= "") {

	if (argName = "") {
		list_Get(args, 1)
	} else {
		entry := xpath(args, iter, "/*/" . argName)
		if (entry <> "") {
			xpath_load(entry)
		}
	}
	return entry
}

addNestedNode(ByRef args, entryName, entry) {

	subEntry := list_Create(entryName)
	list_Add(subEntry, entry)
	list_Add(args, subEntry)
}

getNestedNode(args, name) {
	list := getNode(args, name)
	return list_Get(list, 1)
}

getValues(ByRef args, argName) {
	return xpath(args, iter, "/*/" . argName . "/*/text()")
}

addValues(ByRef args, fields) {

	if (args = "") {
		args := fields
	} else  if (isXML(args)) {
	
		if (isXML(fields)) {
			list_Add(args, fields)
		} else {
			xroot := getRoot(args)
			loop
			{
				StringGetPos, epos, fields, :
				if epos = -1
					break
				name := SubStr(fields, 2, epos-1)
				value := removeValue(fields, name)
				xpath(args, iter, "/" . xroot . "/" . name . "[+1]/text()", value)
			}
		}
	} else {
		args := fields . " " . args
	}
}

getValue(args, argName, default="") {

	if (isXML(args)) {
		value := xml_value(args, argName)
		if (value = "")
			return default
		return value
	}

	if (InStr(args, "`n")) {
	logA("Parse Args->Carriage return in entry:" . args, 6)
	;	syslist_Add("Errors", "/type:error /error:getValue failed=" . argName)
		Return
	}

	StringGetPos, bpos, args, /%argName%:
	if bpos = -1
		return default
	bpos := bpos + StrLen(argName) + 3
	StringGetPos, epos, args, %A_Space%/, , %bpos%
	if epos = -1
		epos = 9999999
	value := SubStr(args, bpos, epos-bpos+1)

	return value
}

replaceValue(ByRef args, fieldName, fieldValue) {
	if (isXML(args)) {
		xroot := getRoot(args)
		xpath(args, iter, "/" . xroot . "/" . fieldName . "/remove()")
		xpath(args, iter, "/" . xroot . "/" . fieldName . "[+1]/text()", fieldValue)

	} else {
		removeValue(args, fieldName)
		if (fieldValue <> "")
			args := args . " /" . fieldName . ":" . fieldValue
	}
}

removeValue(ByRef args, argName, default="") {

	if (isXML(args)) {
		value := xml_value(args, argName)
		xpath(args, iter, "/*/" . argName . "/remove()")
		if (value = "") {
			value := default
		}
		return value
	}

	StringGetPos, bpos, args, /%argName%:
	if bpos = -1
		return default
	apos := bpos
	bpos := bpos + StrLen(argName) + 3
	StringGetPos, epos, args, %A_Space%/, , %bpos%
	if epos = -1
		epos = 9999999
	value := SubStr(args, bpos, epos-bpos+1)
	nArgs := ""
	if (apos = 0) {
		nargs := SubStr(args, epos+2)
	} else {
		nargs := SubStr(args, 1, apos-1)
		if (epos != 9999999) {
			nargs := nargs . SubStr(args, epos+1)
		}
	}
	args := nargs
	return value
}

