Return

getDomain(url) {
	StringGetPos, pos, url, ://
	pos := pos + 4
	OutputVar := SubStr(url, pos)
	StringSplit, lsrArray, OutputVar , /
	StringSplit, lsrArray, lsrArray1, :
	Return lsrArray1
}

ShowEventInfo:
	logA("`nA_GuiControl: " . A_GuiControl . "`n"
	. "A_Gui: " . A_Gui . "`n"
	. "A_GuiEvent: " . A_GuiEvent . "`n"
	. "A_GuiControlEvent: " . A_GuiControlEvent . "`n"
	. "A_EventInfo: " . A_EventInfo . "`n"
	. "A_ThisMenuItem: " . A_ThisMenuItem . "`n"
	. "A_ThisMenuItemPos: " . A_ThisMenuItemPos . "`n"
	. "ErrorLevel: " . ErrorLevel)
Return

getControl(name) {
	entry := syslist_Get("Controls", "/single:Yes /filter:name=" . name)
	return getValue(entry, "control")
}

getPrimitiveType(entry) {
	type := getValue(entry, "type")
	typeEntry := getTypeMeta(type)
	return getValue(typeEntry, "typeType")
}

getTypeMeta(type) {

	return syslist_Get("typeMeta", "/single:Yes /filter:handleType=" . type)
}

commandCreate(cmd, args="") {
 	node := createNode("/type:command /command:" . cmd, "command")
 	if (args <> "") {
 		args := createNode(args, "Args")
		setNode(node, "Args", args)
	}

 	return node
}

addNamedArgument(ByRef command, nodeName, node) {
	args := getNode(command, "Args")
	
	if (args = "") {
		args := createNode("", "Args")
	}
	
	addNestedNode(args, nodeName, node)
	setNode(command, "Args", args)	
}

getControlNN(hWnd) {

	if (hWnd <> "") {
		WinGet, controls, ControlList
		loop,Parse,controls,`n
		{
			control := A_LoopField
			GuiControlGet,chwnd,Hwnd,%control%
			if (chwnd = hWnd) {
				Return %control%
			}
		}
	}
	Return ""
}

Decimal_to_Hex(var) {
  SetFormat, integer, hex
  var += 0
  SetFormat, integer, d
  return var
}

Dec_Uri(str) {
	Loop {
      if RegExMatch(str, "i)(?<=%)[\da-f]{1,2}", hex)
         StringReplace, str, str, `%%hex%, % Chr("0x" . hex), All
      else
      	break
	}
	Return, str
}
