; TODO: add desktop list ala start menu

editor2_Initialize() {

	CommandRegister("Editor2 Create", "editor2_Create")
	CommandRegister("Editor2 Save", "editor2_Save")
}


SubGuiHotkey4:
   CoordMode, ToolTip, relative

   text = VarGuiHotkey4 = %VarGuiHotkey4%
   text := text "`nVarGuiHotkey4@name = " QueryComponent( "VarGuiHotkey4@name" )

;   ToolTip, %text%, 320, 115, 4
return


editor2_Create(A_Command, A_Args) {

	global VarGuiHotkey4

	command := getNestedNode(A_Args, "Entry")

	type := getValue(A_Args, "type")
	if (type = "") {
		type := getValue(command, "type")
		addValues(A_Args, "/type:" . type)
	}
	
	listName := getValue(A_Args, "listName")
	if (listName = "") {
		listName := getValue(command, "listName")
		addValues(A_Args, "/listName:" . listName)
	}

	typeEntry := getTypeMeta(type)
	typeType := getValue(typeEntry, "typeType")

	typeTemplate := "config\templates\" . type . ".xml"
	IfExist,%typeTemplate%
	{
		template := list_Read("templates/" . type . ".xml")
	} else {
		template := list_Read("templates/" . typeType . ".xml")
	}
	
;	COMMAND("Hotkeys Enable", "/state:Off")

	Gui, 3:+ToolWindow +Border
	Gui, 3:Color, D1D6CF, FFFFFF
	Gui, 3:Default
	Gui, +LastFound

;	Gui, 3:Add, Text, x10  y15, Target type:
;	Gui, 3:Add, Text, x145 y15, %type%

	yPosT = 10
;	yPosE = 37

	Loop
	{
		entry := list_Iterate(template, iter)
		if (entry = "") {
			break
		}
		name := getValue(entry, "name")
		required := getValue(entry, "required")
		type := getValue(entry, "type")
		display := getValue(entry, "display", "Yes")
		prompt := getValue(entry, "prompt", name)

		if (display = "Yes") {
			Gui, 3:Add, Text, x15  y%yPosT%, %prompt%
			yPosT += 15
			
			currValue := getValue(command, name)

			if (type = "String") {
				Gui, 3:Add, Edit, x15 y%yPosT% w300 -Border R1 HwndhWndControl, %currValue%
				className := getControlNN(hWndControl)
			} else if (type = "File") {
				Gui, 3:Add, Edit, x15 y%yPosT% w270 -Border R1 HwndhWndControl, %currValue%
				Gui, 3:Add, Button, x290 y%yPosT% h21 w25 -Wrap gSelectFile -theme +0x8000, ...
				className := getControlNN(hWndControl)
			} else if (type = "Hotkey") {
;				Gui, 3:Add, Hotkey, x140 y%yPosE% w100 -Border R1 HwndhWndControl
Gui( "3:Add", "Hotkey", "x15 y" . yPosT . " w270 gSubGuiHotkey4 vVarGuiHotkey4", "" )
				className := getControlNN(hWndControl)
				GuiControl, , %className%, %currValue%
			} else if (type = "DropDown") {
				
				dropList := getValues(entry, "DropDownList")
				StringReplace, dropList, dropList, `, , |, ReplaceAll
	
				Gui, 3:Add, DropDownList, x15 y%yPosT% R9 H9 w100 HwndhWndControl, %dropList%
				className := getControlNN(hWndControl)
				GuiControl, ChooseString, %className%, %currValue%
			}
			yPosT += 25

			addValues(entry, "/control:" . className)
			list_Replace(template, iter, entry)
		}
	}

	yPosT += 15
	Gui, 3:Add, Button, x180 y%yPosT% w65 -Wrap gEditor2SaveButton -theme +0x8000 Default, OK
	Gui, 3:Add, Button, x250 y%yPosT% w65 -Wrap gEditor2CancelButton -theme +0x8000, Cancel

	yPosT += 30
	Gui,3:Add, GroupBox, x10 y0 w325 h%yPosT%

	addNestedNode(A_Args, "Template", template)
	STATE_SET("Editor Data", A_Args)

	Gui, 1:+Disabled 
	Gui,3:+owner
	Gui,3:Show
	Return

	SelectFile:
		Gui 3:+OwnDialogs 
		FileSelectFile, selectedFile, 3, , Select a file, All Documents (*.*)
		if (selectedFile <> "") {
			A_Args := STATE_GET("Editor Data")
			template := getNestedNode(A_Args, "Template")
			Loop
			{
				entry := list_Iterate(template, iter)
				if (entry = "") {
					break
				}
				type := getValue(entry, "type")
				if (type = "File") {
					control := getValue(entry, "control")
					GuiControl, , %control%, %selectedFile%
					break
				}
			}
		}
	Return
	
	Editor2CancelButton:
	3GuiClose:
		Gui, 1:Default
		Gui, 1:-Disabled
		Gui, 3:Destroy
	Return

	Editor2SaveButton:
		A_Args := STATE_GET("Editor Data")

		listName := getValue(A_Args, "listName")
		type := getValue(A_Args, "type")
		command := getNestedNode(A_Args, "Entry")
		template := getNestedNode(A_Args, "Template")
		replace := getValue(A_Args, "replace", "No")

		addEntry := list_Create(type)
	
		Loop
		{
			entry := list_Iterate(template, iter)
			if (entry = "") {
				break
			}
			name := getValue(entry, "name")
			required := getValue(entry, "required")
			type := getValue(entry, "type")
			control := getValue(entry, "control")
			value := getValue(entry, "value")

			if (type = "String") OR (type = "File") {
				GuiControlGet, value, , %control%
			} else if (type = "addEntry") {
				GuiControlGet, value, , %control%
			} else if (type = "Hotkey") {
				GuiControlGet, value, , %control%
			} else if (type = "DropDown") {
				GuiControlGet, value, , %control%
			} else if (type = "PassedNode") {
				setNode(addEntry, name, command)
			}

			if (value <> "") {
				addValues(addEntry, "/" . name . ":" . Enc_XML(value))
			}
		}
;		COMMAND("Hotkeys Enable", "/state:On")

logA("entry:" . xpath_save(addEntry))
		Gui, 1:Default
		Gui, 1:-Disabled
		Gui, 3:Destroy

		if (replace = "Yes") {
			syslist_Replace(listName, addEntry, command)
		} else {
			syslist_Add(listName, addEntry)
		}
	Return
}


