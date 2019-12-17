listView_Initialize() {
	NotifyRegister("UI Create", "listView_OnCreateUI")
	NotifyRegister("List Update", "listView_OnListAdd")
	CommandRegister("ListView RightClick", "listView_OnRightClick")
}

listView_OnCreateUI(A_Command, A_Args) {

	COMMAND("UI AddControl", "/name:CTRLListView"
		. " /type:listview"
		. " /x:5 /y:85 /w:504 /h:175"
		. " /text:|Index|Name|Type|Command|Args"
		. " /anchor:hw"
		. " /rightClickCallback:ListView RightClick"
		. " /options:Count1000 -Multi gSelection AltSubmit LV0x4000 vCTRLListView")

    ImageListID1 := IL_Create(5, 10, 1)
    LV_SetImageList(ImageListID1)
	LV_ModifyCol(1, "AutoHdr")
	LV_ModifyCol(2, 0)
	Return

	Selection:
		processSelection(A_GuiControlEvent, A_GuiEvent, A_EventInfo, ErrorLevel)
	Return
}

listView_OnRightClick(A_Command, A_Args) {
	entry := lister_GetCurrentCommandMeta()
	if (entry = "") {
		filter := STATE_GET("Lister CurrentFilter")
		entry := "/listName:" . getValue(filter, "list", "Default")
	}

	COMMAND("Menu Create", entry)
}

ClearResults() {
	LV_Delete()
}

lister_GetHeaders(filter) {

	headers := getValue(filter, "headers")

	if (headers = "") {
		list := getValue(filter, "list")
		listMeta := syslist_Get("Lists", "/single:Yes /filter:list=" . list)
		defaultType := getValue(listMeta, "defaultType")
		type := syslist_Get("Types", "/single:Yes /filter:typeType=" . defaultType)
		headers := getValue(type, "fields")
		if (headers = "") {
			headers := "name"
		}
	}
	
	return headers
}

listView_OnListAdd(A_Command, A_Args) {

	listName := getValue(A_Args, "listName")
	filter := STATE_GET("Lister CurrentFilter")
	currentListName := getValue(filter, "list", "Default")

	if (currentListName = listName)
	{
		entry := getNestedNode(A_Args, "Entry")
		if (entry <> "") {
			listMeta := syslist_Get("Lists", "/single:Yes /filter:list=" . listName)
			addMode := getValue(listMeta, "addMode", "Add")
	
			headers := lister_GetHeaders(filter)
			ShowSingleItem(filter, entry, LV_GetCount()+1, headers, addMode)
	
			if (LV_GetCount() = 1) {
				allheaders := ",," . headers
				Loop, Parse, allheaders, `,
				{
					if (A_Index = 1) {
						LV_ModifyCol(1, "AutoHdr Focus Select Vis")
					} else if (A_Index > 2) {
						LV_ModifyCol(A_Index, "AutoHdr")
					}
				}
			}
		}
	}
}

processSelection(GuiControlEvent, GuiEvent, EventInfo, errLevel) {

	IfEqual, GuiControlEvent, DoubleClick
	{
		if (lister_GetCurrentCommandMeta() <> "")
			BACKGROUND_COMMAND("Lister RunCommand")
;	} else if (GuiEvent = "Normal") {
;		command := lister_GetCurrentCommandMeta()
;		NOTIFY("Lister Selected", command)

	} else if GuiEvent = ColClick
	{
		filter := STATE_GET("Lister CurrentFilter")
		headers := ",," . lister_GetHeaders(filter)
		StringSplit,farray,headers,`,

		sortHeader := "farray" . EventInfo
		sortHeader := %sortHeader%
		NOTIFY("Lister ColClick", "/column:" . sortHeader)
	} else if (GuiEvent = "I") {
		if (InStr(ErrorLevel, "S", true)) {
			command := lister_GetCurrentCommandMeta()
			NOTIFY("Lister Selected", command)
		}
	}
}

lister_GetHeaderIndex(filter, header) {
	headers := ",," . lister_GetHeaders(filter)
	StringSplit,farray,headers,`,
	Loop,parse,headers,`,
	{
		if (A_LoopField = header)
			return A_Index
	}
}

lister_GetCurrentCommandMeta() {

	rowNum := LV_GetNext()
	if (rowNum = 0)
		return ""

	LV_GetText(entry, rowNum, 2)

	return entry
}

ShowResults(filter, MatchList) {

	if (MatchList = "") AND (LV_GetCount() = 0)
		Return
	StartTime := A_TickCount

	mode := getValue(filter, "mode", "Small")
	maxResults := getValue(filter, "maxResults", 1000)
	filters := getValue(filter, "typeFilter")

; start 14047
; getValue by ref 12515
; different dll call for icons 10172
; full speed 3945

	GuiControl, -Redraw, SysListView321
;	COMMAND("Status Display", "/status:Showing results")

	ClearResults()

	headers := lister_GetHeaders(filter)
	allheaders := ",," . headers

	Loop, Parse, allheaders, `,
		hdrCount++

	if (hdrCount <> LV_GetCount("Column")) {
		Loop,
			if LV_DeleteCol(3) = 0
				break

		Loop, Parse, headers, `,
			LV_InsertCol(A_Index+2, "", A_LoopField)
	}

	global ImageListID1
	IL_Destroy(ImageListID1)

	if (Mode = "Large") {
		GuiControl, +Report, SysListView321
		ImageListID1 := IL_Create(MaxResults, 50, 1)
		LV_SetImageList(ImageListID1, 1)
		;GuiControl, -hdr, SysListView321
	} else if (Mode = "Tile") {
		GuiControl, +Tile, SysListView321
		ImageListID1 := IL_Create(MaxResults, 50, 1)
		LV_SetImageList(ImageListID1, 1)
		Mode = "Large"
	} else {
		GuiControl, +Report, SysListView321
		ImageListID1 := IL_Create(MaxResults, 50)
		LV_SetImageList(ImageListID1)
		;GuiControl, +hdr, SysListView321
	}

	StartTime2 := A_TickCount
	Loop
	{
		entry := list_Iterate(MatchList, iter, filters)
		if (entry = "") {
			break
		}

		ShowSingleItem(filter, entry, A_Index, headers, "Add", Mode)

		if (A_Index >= MaxResults)
			break
	}
	log("Loop items elapsed:" . A_TickCount - StartTime2, 4)

	sort := getValue(filter, "sort")
	sortDir := getValue(filter, "sortDir")
	Loop, Parse, allheaders, `,
	{
		if A_Index = 1
			LV_ModifyCol(1, "AutoHdr")
		else if (A_Index > 2) {
			if (A_LoopField = "*") {
				header := "Details"
			} else {
				header := A_LoopField
			}
			if (sort = header) {
				if (sortDir = "Desc") {
					sortOption := "SortDesc"
				} else {
					sortOption := "Sort"
				}
				LV_ModifyCol(A_Index, sortOption, header)
			}
			LV_ModifyCol(A_Index, "AutoHdr", header)
		}
	}

;	COMMAND("Status Display", "")
	LV_Modify(1, "Focus Select Vis")
	GuiControl, +Redraw, SysListView321

	log("Show Results elapsed:" . A_TickCount - StartTime, 4)
}

ShowSingleItem(filter, Command, index, headers, addMode="Add", iconSize="Small") {

	global ImageListID1

	iconNum := lister_AddIconToImageList(Command, ImageListID1, iconSize)

	if (addMode = "Add") {
		LV_Add( "Icon" . iconNum)
	} else {
		LV_Insert(1, "Icon" . iconNum)
		index = 1
	}

	LV_Modify(index, "Col2" , command)
	Loop, Parse, headers, `,
	{
		if (A_LoopField = "*") {
			entry := command
			type := getValue(command, "type")
			typeMeta := getTypeMeta(type)
			detailFields := getValue(typeMeta, "details")
			if (detailFields <> "") {
				entry := ""
				Loop,Parse,detailFields, `,
				{
					details := getValue(command, A_LoopField)
					if (details <> "") {
						if (entry = "") {
							entry := details
						} else {
							entry := entry . " /" . A_LoopField . ":" . details
						}
					}
				}
			}
		} else {
			entry := getValue(command, A_LoopField)
		}
		LV_Modify(index, "Col" . (A_Index+2), entry)
	}
}
