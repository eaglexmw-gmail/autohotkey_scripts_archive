search_Initialize() {
	NotifyRegister("List Update", "search_OnListUpdate")
	CommandRegister("Search Refresh", "search_Refresh")
	CommandRegister("Search ProcessText", "search_OnProcessText")
	CommandRegister("Search ProcessText2", "search_OnProcessText2")
	CommandRegister("Search ProcessList", "search_OnProcessList")

	search_Rebuild()
}

search_Rebuild() {

	lists := syslist_Get("Lists", "/filter:search=Yes")
	list_Sort(lists, "searchOrder")

	searchList := list_Create()
	loop
	{
		list := list_Iterate(lists, iter)
		if (list = "") {
			break
		}
		listName := getValue(list, "list")
		list_Merge(searchList, syslist_Get(listName))
	}

	searchList := lister_SimpleDedupe(searchList)
	syslist_Set("Search", searchList)
}

search_OnListUpdate(A_Command, A_Args) {

	updatedListName := getValue(A_Args, "listName")

	lists := syslist_Get("Lists", "/filter:search=Yes")
	loop
	{
		list := list_Iterate(lists, iter)
		if (list = "") {
			break
		}
		listName := getValue(list, "list")
		if (listName = updatedListName) {
			search_Rebuild()
			NOTIFY("List Update", "/listName:Search")
			break
		}
	}
}

search_OnProcessList(A_Command, filter) {

logA("search_OnProcessList" . xpath_save(filter))
	text := getValue(filter, "searchedFor")

	if (text <> "") {
		COMMAND("Lister SetText", "/focus:Yes /select:Yes /text:" . text)
;	} else {
;		COMMAND("Lister SetText", "/focus:Yes /clear:Yes")
	}
	search_OnProcessText(A_Command, "/refresh:Yes /searchPhrase:" . text)
}

search_OnProcessText(A_Command, A_Args) {

;global stopProcessing
;logA("starting background command")
;stopProcessing := 1
;BACKGROUND_COMMAND("Search ProcessText2", A_Args)
;logA("done starting background command")
;Return

; TODO: http://search.cpan.org/src/TAREKA/String-Trigram-0.11/Trigram.pm

	filter := STATE_GET("Lister CurrentFilter")

	CurrText := getValue(A_Args, "searchPhrase")
	oldSearch := getValue(filter, "searchPhrase")
	refresh := getValue(A_Args, "refresh")

logA("search_OnProcessText:" . CurrText, 7)
logA("OldText:" . oldSearch, 7)
		
	if (refresh <> "Yes") AND (InStr(CurrText, oldSearch)) {

		list := list_Create()
		Loop % LV_GetCount()
		{
			LV_GetText(entry, A_Index, 2)
			list_Add(list, entry)
		}

		filteredList := FilterList(filter, CurrText, list)
logA("refiltered to:" . list_GetCount(filteredList))

		if (list_GetCount(filteredList) > 0)
		{
			ffentry := list_Get(filteredList, 1)
			weight := getValue(ffentry, "weight")
			Loop {
				entry := list_Iterate(filteredList, iter)
				if (entry = "") {
					break
				}
				eweight := getValue(entry, "weight")
				
				if (eweight < weight) {
					updateResults := 1
					break
				}
			}
			; if the count of items changed or the first entry has changed
			if (list_GetCount(filteredList) <> LV_GetCount()) OR (updateResults = 1) {
logA("Showing updated list", 7)
				ShowResults(filter, filteredList)
				LV_Modify(1, "Focus Select Vis")
			}

			replaceValue(filter, "searchedFor", CurrText)
			STATE_SET("Lister CurrentFilter", filter)

			filterHistory := syslist_Get("FilterHistory")
			oldFilter := list_Get(filterHistory, 1)
			if (oldFilter <> "") {
				syslist_Replace("FilterHistory", filter, oldFilter)
			}
			Return
		}
	}

;	minChars := getValue(filter, "minChars", 0)
;	StringLen, Check, CurrText
;	IfGreaterOrEqual, Check, 0
;		If (Check < minChars)
;		{
;			ClearResults()
;			Return
;		}

	StringLen, Check, CurrText
	IfGreaterOrEqual, Check, 0
		If (Check < 2) {
			if (!lister_selectMatchSimple(currText)) {
				ClearResults()
			}
			Return
		}

	list := syslist_Get("Search")
	filteredList := FilterList(filter, CurrText, list)

log("match search", 7)
;	syslist_Remove("FilterHistory", filter)
;	removeValue(filter, "searchPhrase")

	replaceValue(filter, "searchedFor", CurrText)
	STATE_SET("Lister CurrentFilter", filter)

			filterHistory := syslist_Get("FilterHistory")
			oldFilter := list_Get(filterHistory, 1)
			if (oldFilter <> "") {
				syslist_Replace("FilterHistory", filter, oldFilter)
			}

logA("showingResults")
	ShowResults(filter, filteredList)
}

FilterList(filter, searchPhrase="", SearchList="") {

logA("FilterList:" . searchPhrase, 7)

	list := getValue(filter, "list", "Default")
	filters := getValue(filter, "typeFilter")

	if (SearchList = "") {
		SearchList := syslist_Get(list)
	}
	if (searchPhrase = "") {
;		undupe := getValue(filter, "undupe")
;		if (undupe = "Yes") {
;			SearchList := lister_SimpleDedupe(SearchList)
;		}
		Return SearchList
	}

logA("Filtering from " . list_GetCount(SearchList) . " entries", 7)
	StartTime := A_TickCount

	; Advanced Search
	matchList := list_Create()

	if (filter <> "") {
		headers := getValue(filter, "headers", "name")
		StringSplit, headerArray, headers , `,
		keyField := headerArray1
	}

;log("filter:" . filter)
;log("searchPhrase:" . searchPhrase)
;log("searchlist:" . SearchList)
log("filters:" . filters, 3)
	COMMAND("Status Display", "/status:Filtering")
	Loop
	{
		CurrEntry := list_Iterate(SearchList, iter, filters)
		if (CurrEntry = "") {
			break
		}

		if (searchPhrase = "") {
			list_Add(matchList, CurrEntry)
			Continue
		}

		StringLen, Len, searchPhrase

		; previously searched
		CurrItem := getValue(currEntry, "searchPhrase")
		if (CurrItem <> "") {
			StringLeft, LText, CurrItem, %Len%
			If (LText = searchPhrase) {
				if (Len = StrLen(CurrItem)) {
	;				log("type1 match:" . currItem)
					; exact match (type 1)
					replaceValue(currEntry, "weight", (10000+A_Index))
					list_Add(matchList, CurrEntry)
				} else {
	;				log("type2 match:" . currItem)
					; all chars match from beginning (type 2)
					replaceValue(currEntry, "weight", (20000+A_Index))
					list_Add(matchList, CurrEntry)
				}
				Continue
			}
		}

		CurrItem := getValue(currEntry, keyField)
		StringLeft, LText, CurrItem, %Len%
		If (LText = searchPhrase) {
			if (Len = StrLen(CurrItem)) {
;				log("type1 match:" . currItem)
				; exact match (type 1)
				replaceValue(currEntry, "weight", (30000+A_Index))
				list_Add(matchList, CurrEntry)
			} else {
;				log("type2 match:" . currItem)
				; all chars match from beginning (type 2)
				replaceValue(currEntry, "weight", (40000+A_Index))
				list_Add(matchList, CurrEntry)
			}
			Continue
		}

		matchType = 0
;log("matching:[" . currItem . "] to [" . searchPhrase . "]")
		tempItem := CurrItem
		Loop, Parse, searchPhrase, %A_Space%
		{
			; log("loop test:" . A_LoopField)

			if (A_Index > 1) {
				pos := InStr(tempItem, A_Space)
				if (pos = 0) {
;log("no match 1")
					matchType = 0
					break
				}
				tempItem := SubStr(tempItem, pos+1)
			}

			pos := InStr(tempItem, A_LoopField)
			lastPos = pos
			
			if (pos = 1) AND (matchType < 4) {
;				log("type3 loop match:" . A_LoopField)
				; each word in sequence matches at the start (type 3)
				matchType = 3
			} else if (pos <> 0) {

				if (SubStr(CurrItem, pos-1, 1) = A_Space) AND (matchType < 5) {
					; start of words match although not in sequence (type 4)
;					log("type4 loop match:" . A_LoopField)
					matchType = 4
				} else {
					; chars match in the middle
;					log("type5 loop match:" . A_LoopField)
					matchType = 5
				}
			} else {
;log("no match 2")
				matchType = 0
				break
			}
		}
		
		if (matchType > 0) {
;			log("MATCH:" . matchType . "->" . currItem)
			if (matchType = 3) {
				replaceValue(currEntry, "weight", (50000+A_Index))
				list_Add(matchList, CurrEntry)
			} else if (matchType = 4) {
				replaceValue(currEntry, "weight", (60000+A_Index))
				list_Add(matchList, CurrEntry)
			} else if (matchType = 5) {
				replaceValue(currEntry, "weight", (70000+A_Index))
				list_Add(matchList, CurrEntry)
			}
		}
	}

	log("Filter elapsed:" . A_TickCount - StartTime . " :" . filters, 7)
	COMMAND("Status Display")
	Return matchList
}

lister_SimpleDedupe(list) {

	total := list_GetCount(list)
logA("Deduping " . total . " entries", 7)
	StartTime := A_TickCount
	uniqueList=`n

	checked=0
	removed=0

	Loop {
		entry := list_Iterate(list, iter)
		if (entry = "") {
			break
		}
		checked++

		type := getValue(entry, "type")
		keyFields := STATE_GET("KeyFields " . type)
		if (keyFields = "") {
			typeMeta := getTypeMeta(type)
			keyFields := getValue(typeMeta, "keyFields")
			if (keyFields = "") {
				log("NO KEY FIELDS:" . A_LoopField)
			}
			STATE_SET("KeyFields " . type, keyFields)
		}

		fields := "/type:" . type
		Loop,Parse,keyFields,`,
		{
			value := getValue(entry, A_LoopField)
			if (value = "") {
				value := "<null>"
			}
			fields := fields . " /" . A_LoopField . ":" . value
		}

		IfInString, uniqueList, `n%fields%`n
		{
			xml_Remove(list, iter)
			iter--
			removed++
		} else {
			uniqueList = %uniqueList%%fields%`n
		}
	}
logA("total:" . total . " checked:" . checked . " removed:" . removed . " remaining:" . list_GetCount(list), 7)

	log("Deduped in:" . A_TickCount - StartTime . " :" . filters, 7)
	return list
}

search_OnProcessText2(A_Command, A_Args) {

global gblSearching
global stopProcessing
if (gblSearching = 1) {
logA("already searching")
	Return
}
gblSearching := 1
logA("starting thread")
ClearResults()
	filter := STATE_GET("Lister CurrentFilter")
	CurrText := getValue(A_Args, "searchPhrase")
	list := syslist_Get("Search")
stopProcessing := 0
	FilterList2(filter, CurrText, list)
logA("done")
gblSearching := 0
}

FilterList2(filter, searchPhrase="", SearchList="") {

	global stopProcessing

logA("FilterList:" . searchPhrase, 7)

	list := getValue(filter, "list", "Default")
	filters := getValue(filter, "typeFilter")

	if (SearchList = "") {
		SearchList := syslist_Get(list)
	}
	if (searchPhrase = "") {
		Return SearchList
	}

logA("Filtering from " . list_GetCount(SearchList) . " entries", 7)
	; Advanced Search
	matchList := list_Create()

	if (filter <> "") {
		headers := getValue(filter, "headers", "name")
		StringSplit, headerArray, headers , `,
		keyField := headerArray1
	}

	Loop {
		CurrEntry := list_Iterate(SearchList, iter, filters)
		if (CurrEntry = "") {
			break
		}
if (stopProcessing = 1) {
logA("stopping processing")
	stopProcessing := 0
	break
}
		StringLen, Len, searchPhrase

		; previously searched
		CurrItem := getValue(currEntry, "searchPhrase")
		if (CurrItem <> "") {
			StringLeft, LText, CurrItem, %Len%
			If (LText = searchPhrase) {
				if (Len = StrLen(CurrItem)) {
					; exact match (type 1)
					replaceValue(currEntry, "weight", (10000+A_Index))
			entry := createNode("/listName:Search")
			addNestedNode(entry, "Entry", currEntry)
			listView_OnListAdd(A_Command, entry)
				} else {
					; all chars match from beginning (type 2)
					replaceValue(currEntry, "weight", (20000+A_Index))
			entry := createNode("/listName:Search")
			addNestedNode(entry, "Entry", currEntry)
			listView_OnListAdd(A_Command, entry)
				}
				Continue
			}
		}

		CurrItem := getValue(currEntry, keyField)
		StringLeft, LText, CurrItem, %Len%
		If (LText = searchPhrase) {
			if (Len = StrLen(CurrItem)) {
				; exact match (type 1)
				replaceValue(currEntry, "weight", (30000+A_Index))
			entry := createNode("/listName:Search")
			addNestedNode(entry, "Entry", currEntry)
			listView_OnListAdd(A_Command, entry)
			} else {
				; all chars match from beginning (type 2)
				replaceValue(currEntry, "weight", (40000+A_Index))
			entry := createNode("/listName:Search")
			addNestedNode(entry, "Entry", currEntry)
			listView_OnListAdd(A_Command, entry)
			}
			Continue
		}

		matchType = 0
		tempItem := CurrItem
		Loop, Parse, searchPhrase, %A_Space%
		{
			if (A_Index > 1) {
				pos := InStr(tempItem, A_Space)
				if (pos = 0) {
					matchType = 0
					break
				}
				tempItem := SubStr(tempItem, pos+1)
			}

			pos := InStr(tempItem, A_LoopField)
			lastPos = pos
			
			if (pos = 1) AND (matchType < 4) {
				; each word in sequence matches at the start (type 3)
				matchType = 3
			} else if (pos <> 0) {

				if (SubStr(CurrItem, pos-1, 1) = A_Space) AND (matchType < 5) {
					; start of words match although not in sequence (type 4)
					matchType = 4
				} else {
					; chars match in the middle
					matchType = 5
				}
			} else {
				matchType = 0
				break
			}
		}
		
		if (matchType > 0) {
;			log("MATCH:" . matchType . "->" . currItem)
			if (matchType = 3) {
				replaceValue(currEntry, "weight", (50000+A_Index))
			} else if (matchType = 4) {
				replaceValue(currEntry, "weight", (60000+A_Index))
			} else if (matchType = 5) {
				replaceValue(currEntry, "weight", (70000+A_Index))
			}
			
			entry := createNode("/listName:Search")
			addNestedNode(entry, "Entry", currEntry)
			listView_OnListAdd(A_Command, entry)
		}
	}

	log("Filter elapsed:" . A_TickCount - StartTime . " :" . filters, 7)
	Return matchList
}
