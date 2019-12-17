ui_Initialize() {

	CommandRegister("UI Create", "ui_Create")
	CommandRegister("UI Activate", "ui_Activate")
	CommandRegister("UI ActivateCentered", "ui_ActivateCentered")
	CommandRegister("UI Hide", "ui_Hide")
	CommandRegister("UI Show", "ui_Show")
	CommandRegister("UI ShowCentered", "ui_ShowCentered")
	CommandRegister("UI DisplayMode", "ui_DisplayMode")
	CommandRegister("UI ToggleDisplayMode", "ui_ToggleDisplayMode")
	CommandRegister("UI Register", "ui_Register")
	CommandRegister("UI AddControl", "ui_OnAddControl")
	CommandRegister("UI Process", "ui_OnProcess")
	CommandRegister("UI Move", "ui_OnMove")

	NotifyRegister("UI Deactivate", "ui_OnDeactivate")
}

addOptions(ByRef args, byRef options, field, prefix="") {

	x := getValue(args, field)
	if (x <> "") {
		options := options . " " . prefix . x
	}
}

ui_OnAddControl(A_Command, button) {

	button := createNode(button)
	name := getValue(button, "name")
	type := getValue(button, "type")

	skin := STATE_GET("UI Skin")
	skinOptions := xml_iterate(skin, iter, "[name=" . name . "]")
	nodeMerge(button, skinOptions)

	addOptions(button, options, "x", "x")
	addOptions(button, options, "y", "y")
	addOptions(button, options, "w", "w")
	addOptions(button, options, "h", "h")
	addOptions(button, options, "style")
	addOptions(button, options, "options")
	addOptions(button, options, "background", "+Background")

	Gui, 1:Font
	font := getValue(button, "font")
	fontOptions := getValue(button, "fontOptions")
	if (font <> "") OR (fontType <> "") {
		Gui, Font, %fontOptions%, %font%
		GuiControl, Font, %control%
	}

	if (type = "button") {
		Gui, 1:Add, Button, %options% HwndhWnd gPressed
	} else if (type = "text") {
		Gui, 1:Add, Text, %options% HwndhWnd gPressed
	} else if (type = "picture") {
		Gui, 1:Add, Picture, %options% HwndhWnd
	} else if (type = "listview") {
		text := getValue(button, "text")
		Gui, 1:Add, ListView, %options% HwndhWnd, %text%
	} else if (type = "progress") {
		Gui, 1:Add, Progress, %options% HwndhWnd 
	} else if (type = "edit") {
		Gui, 1:Add, Edit, %options% HwndhWnd
	} else if (type = "statusbar") {
		Gui, 1:Add, StatusBar, %options% HwndhWnd
	} else if (type = "toolbar") {
		hWnd := toolbar32_Create(button)
	}

	if (hWnd <> "") {
		control := getControlNN(hWnd)
		addValues(button, "/control:" . control . " /hwnd:" . hWnd)
	}
	syslist_Add("Controls", button)

	text := getValue(button, "text")
	if (text <> "") {
		GuiControl, , %control%, %text%
	}

;	styleEx := getValue(button, "styleEx")
;	if (styleEx <> "") {
;		GuiControl, %styleEx%, %control%
;	}

	image := getValue(button, "image")
	if (image <> "") {
		if (type = "button") {
			COMMAND("Button SetImage", "/name:" . name . " /image:" . image)
		} else {
			GuiControl, , %control%, %image%
			GuiControl, Show, %control%
		}
	}

	Return button
	
	Pressed:
		MouseGetPos, , , , control
		button := syslist_Get("Controls", "/single:Yes /filter:control=" . control)
		if (button <> "") {
			callback := getValue(button, "callback")
			COMMAND(callback, button)
		}
	Return
}

ui_OnMove(A_Command, A_Args) {
	PostMessage, 0xA1, 2,,, A
}

ui_Create(A_Command, A_Args) {

	Gui, 1:+MinSize514x372

	skinName := getValue(A_Args, "skin")

	if (skinName <> "") {
		skin := list_Read("skins/" . skinName . "/skin.xml")
		STATE_SET("UI Skin", skin)

		skinOptions := xml_iterate(skin, iter, "[name=UI]")
		bgColor := getValue(skinOptions, "background")
		ctlColor := getValue(skinOptions, "controlColor", "000000")
		Gui, 1:Color, %bgColor%, %ctlColor%
		STATE_SET("UI Background", "0x" . bgColor)

		options := getValue(skinOptions, "options")
		if (InStr(skinOptions, "-Border")) {
			STATE_SET("UI Border", "No")
		    OnMessage(0x83, "WM_NCCALCSIZE")
		    OnMessage(0x86, "WM_NCACTIVATE")
		 	OnMessage(0x84, "WM_NCHITTEST")
		 }
	}

	minSize := getValue(skinOptions, "minSize")
	if (minSize <> "") {
		Gui, 1:+MinSize%minSize%
	}

	COMMAND("UI AddControl", "/name:Background"
		. " /type:picture"
		. " /x:0 /y:0 /w:1 /h:1"
		. " /anchor:w /guiRedraw:Yes"
		. " /style:Hidden 0x4000000")

	COMMAND("UI AddControl", "/name:CTRLDisplayMode"
		. " /type:button"
		. " /x:5 /y:62 /w:16 /h:16"
		. " /style:-theme +0x8000"
		. " /tooltip:Toggle On Top"
		. " /callback:UI ToggleDisplayMode")

	mode := STATE_GET("UI DisplayMode", "AutoHide")
	COMMAND("UI DisplayMode", "/mode:" . mode)

	NOTIFY("UI Create", "/guiId:" . STATE_GET("Redstone WID"))

	width := STATE_GET("UI Width")
	height := STATE_GET("UI Height")

	WinMove, , , , , 522, 380

if (STATE_GET("UI Border") = "No") {
	width-=8
	height-=8
}
	STATE_SET("UI Width", width)
	STATE_SET("UI Height", height)

	NOTIFY("UI Created")
	log("UI CREATED***************************")
}

ui_OnProcess(A_Command, A_Args) {

	BACKGROUND_COMMAND("UI ActivateCentered")

	loop
	{
		WinWaitActive, RedStone
		{
			log("ACTIVATED+++++++++++++++++++++++++++++++++++")
			activated := STATE_GET("UI Activated")
			if (activated = 0) {
				STATE_SET("UI Activated", 1)
				Notify("UI Activate")
			}
		}
		WinWaitNotActive, RedStone
		{
			log("DEACTIVATED+++++++++++++++++++++++++++++++++++")
			STATE_SET("UI Activated", 0)
			Notify("UI Deactivate")
		}
	}
}

ui_OnDeactivate(A_Command, A_Args) {
	mode := STATE_GET("UI DisplayMode")
	if (mode = "AutoHide") {
		COMMAND("UI Hide")
	}
}

ui_ToggleDisplayMode(A_Command, A_Args) {

	mode := STATE_GET("UI DisplayMode")
	if (mode = "OnTop") {
		COMMAND("UI DisplayMode", "/mode:Normal")
	} else if (mode = "Normal") {
		COMMAND("UI DisplayMode", "/mode:AutoHide")
	} else {
		COMMAND("UI DisplayMode", "/mode:OnTop")
	}
}

ui_Register(A_Command, A_Args) {
	control := getValue(A_Args, "control")
	hwnd := getValue(A_Args, "hwnd")
	if (hwnd = "") AND (control <> "") {
		GuiControlGet,hwnd,Hwnd,%control%
		if (hwnd <> "") {
			replaceValue(A_Args, "hwnd", hwnd)
		}
	}
	name := getValue(A_Args, "name")
	if (name = "") {
		addValues(A_Args, "/name:" . control)
	}
	syslist_Add("Controls", A_Args)
}

ui_ActivateCentered(A_Command, A_Args) {

	STATE_SET("UI Activated", 1)
	Notify("UI Activate")
	COMMAND("UI ShowCentered")
}

ui_Activate(A_Command, A_Args) {

	STATE_SET("UI Activated", 1)
	Notify("UI Activate")
	COMMAND("UI Show")
}

ui_ShowCentered(A_Command, A_Args) {
	width := STATE_GET("UI Width")
	height := STATE_GET("UI Height")
	Gui, 1:Show, h%height% w%width% Center, RedStone

	NOTIFY("UI Show")
}

ui_Show(A_Command, A_Args) {

	hwnd := STATE_GET("Redstone WID")
	WinGet, style, Style, ahk_id %hwnd%

	if (style & 0x10000000)   ; WS_VISIBLE
	{
		Gui, 1:Show, , RedStone

	} else {
	
		CoordMode, Mouse, Screen
		MouseGetPos, xpos, ypos
		CoordMode, Mouse, Relative
	
		width := STATE_GET("UI Width")
		height := STATE_GET("UI Height")

borderWidth := 8
if (STATE_GET("UI Border") = "No") {
	width-=16
	height-=16
	xpos+=8
	ypos+=8
}
		ww := width+borderWidth
		wh := height+borderWidth

		gosub GetMonitorAt
		xpos -= ww/2
		ypos -= wh/2
		if (xpos < monLeft)
			xpos := monLeft
		if (ypos < monTop)
			ypos := monTop
		if xpos+ww > monRight
			xpos := monRight - ww
		if ypos + wh > monBottom
			ypos := monBottom - wh
	
		Gui, 1:Show, h%height% w%width% x%xpos% y%ypos%, RedStone
		NOTIFY("UI Show")
	}

	Return

	GetMonitorAt:
		m = 1

	    SysGet, ms, MonitorCount
	    ; Iterate through all monitors.
	    Loop, %ms%
	    {   ; Check if the window is on this monitor.
	        SysGet, Mon, Monitor, %A_Index%
	        if (xpos >= MonLeft && xpos <= MonRight && ypos >= MonTop && ypos <= MonBottom)
			{
				m := ms
	            break
			}
	    }
	Return
}

ui_DisplayMode(A_Command, A_Args) {

	mode := getValue(A_Args, "mode")

	STATE_SET("UI DisplayMode", mode)
	STATE_WRITE("UI DisplayMode")
	if (mode = "OnTop") {
		Gui, 1:+AlwaysOnTop
		COMMAND("Button SetImage", "/name:CTRLDisplayMode /image:res\OnTop.bmp")
	} else {
		Gui, 1:-AlwaysOnTop
		if (mode = "AutoHide") {
			COMMAND("Button SetImage", "/name:CTRLDisplayMode /image:res\AutoHide.bmp")
		} else {
			COMMAND("Button SetImage", "/name:CTRLDisplayMode /image:res\Normal.bmp")
		}
	}
}

GuiSize:
	ui_Resize()
Return

ui_Resize() {

	list := syslist_Get("Controls")
	loop
	{
		entry := list_Iterate(list, iter)
		if (entry = "") {
			break
		}

		anchor := getValue(entry, "anchor")
		if (anchor <> "") {
			control := getValue(entry, "control")
			if (control = "") {
				control := getValue(entry, "hwnd")
			}
			redraw := getValue(entry, "redraw")

			Anchor(control, anchor, redraw = "Yes")
			if (getValue(entry, "guiRedraw") = "Yes") {
				GuiControlGet, MyEdit, Pos, %control%
				GuiControl, MoveDraw, %control%, x%MyEditX% y%MyEditY% w%MyEditW% h%MyEditH%
			}
		}
	}
	
	width := STATE_GET("UI Width")
	height := STATE_GET("UI Height")
	if (width <> A_GuiWidth) OR (height <> A_GuiHeight) {
		STATE_SET("UI Height", A_GuiHeight)
		STATE_SET("UI Width", A_GuiWidth)
		SetTimer, SavePosition, 200
	}

	Return

	SavePosition:
		SetTimer, SavePosition, Off
		STATE_WRITE("UI Height")
		STATE_WRITE("UI Width")
	Return
}

ui_Hide(A_Command, A_Args) {

	mode := STATE_GET("UI DisplayMode")
	if (mode = "AutoHide") {
		hwnd := STATE_GET("Redstone WID")
		WinGet, style, Style, ahk_id %hwnd%

		if (style & 0x10000000)
		{
			Gui,1:Show,Hide
			NOTIFY("UI Hide")
		}
	}
}

WM_NCCALCSIZE() {
    if A_Gui
        return 0
}

; Prevents a border from being drawn when the window is activated.
WM_NCACTIVATE() {
    if A_Gui
        return 1
}

WM_NCHITTEST(wParam, lParam) {
    static border_size = 4
   
    if !A_Gui
        return
   
    WinGetPos, gX, gY, gW, gH
   
    x := lParam<<48>>48, y := lParam<<32>>48
   
    hit_left    := x <  gX+border_size
    hit_right   := x >= gX+gW-border_size
    hit_top     := y <  gY+border_size
    hit_bottom  := y >= gY+gH-border_size

    if hit_top
    {
        if hit_left
            return 0xD
        else if hit_right
            return 0xE
        else
            return 0xC
    }
    else if hit_bottom
    {
        if hit_left
            return 0x10
        else if hit_right
            return 0x11
        else
            return 0xF
    }
    else if hit_left
        return 0xA
    else if hit_right
        return 0xB
   
    ; else let default hit-testing be done
}
