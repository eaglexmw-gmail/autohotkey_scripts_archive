info_Initialize() {
	NotifyRegister("UI Create", "info_OnUiCreate")
	NotifyRegister("Lister Selected", "info_OnSelected")
}

info_OnUiCreate(A_Command, A_Args) {

    global WindowProcOld
    global hbr

	COMMAND("UI AddControl", "/name:CTRLInfo"
		. " /type:text"
		. " /style:-Wrap"
		. " /x:50 /y:279 /w:459 /h:40"
		. " /anchor:yw /redraw:Yes"
		. " /callback:UI Move")

	pictureControl := COMMAND("UI AddControl", "/name:CTRLInfoIcon"
		. " /type:picture"
		. " /image:C:\work\apps\eclipse\eclipse\eclipse.exe"
		. " /background:0f0f0f"
;		. " /options:AltSubmit"
		. " /rightClickCallback:ListView RightClick"
		. " /x:8 /y:282 /w:32 /h:32"
		. " /anchor:y")

	hWnd := getValue(pictureControl, "hwnd")

	WindowProcNew := RegisterCallback("WindowProcPict")
	WindowProcOld := DllCall("SetWindowLong", "uint", hWnd, "int", -4, "int", WindowProcNew, "uint")
	
	bgColor := STATE_GET("UI Background")
	if (bgColor <> "") {
	
		red := SubStr(bgColor, 3, 2)
		green := SubStr(bgColor, 5, 2)
		blue := SubStr(bgColor, 7, 2)
		bgColor := "0x" . blue . "" . green . "" . red  
	
		hbr := DllCall( "CreateSolidBrush", UInt, bgColor )
	} 
}

info_OnSelected(A_Command, A_Args) {

	command := A_Args

	logA("command:" . xpath_save(command))

	type := getValue(command, "type")
	typeMeta := getTypeMeta(type)
	detailFields := getValue(typeMeta, "details")

	entry := getValue(command, "name")

	Loop,Parse,detailFields, `,
	{
		detailField := getValue(command, A_LoopField)
		if (detailField <> "") {
			if (details = "") {
				details := detailField
			} else {
				details := details . " " . detailField
			}
		}
	}
	if (details <> "") {
		entry := entry . "`n" . details
	}

	description := getValue(command, "description")
	if (description <> "") {
		entry := entry . "`n" . description
	}

	searchPhrase := getValue(command, "searchPhrase")
	entry := entry . "`n"
	if (searchPhrase <> "") {
		entry := entry . "Keyword: " . searchPhrase
	}
	
	control := getControl("CTRLInfo")
	GuiControl,,%control%,%entry%

	hIcon := getIcon(command, "Large")

	pictureControl := syslist_Get("Controls", "/single:Yes /filter:name=CTRLInfoIcon")
	hWnd := getValue(pictureControl, "hwnd")
	SendMessage, 0x170, hIcon,,, ahk_id %hWnd%
}

WindowProcPict(hwnd, uMsg, wParam, lParam)
{
    global WindowProcOld
    global hbr
    Critical 500 ; Must ensure AutoHotkey doesn't check for messages.
   
    if (uMsg = 0x14) {
        return 1
    }
   
    if (uMsg = 0xF)
    {
        if hicon := CallWindowProc(WindowProcOld, hwnd, 0x171,0,0) ; STM_GETICON
        {
        	WinGetPos,,, w, h, ahk_id %hwnd%
        	VarSetCapacity(ps,64,0)
      	  	DllCall("BeginPaint","uint",hwnd,"uint",&ps)
        	hdc := NumGet(ps,0)
            ; Get a brush to be used as the background.
            ; DrawIconEx draws the background and icon into a temporary buffer,
            ; then draws the buffer onto the window. (It draws directly onto the
            ; window if hbr is not a valid brush handle.)
            DllCall("DrawIconEx","uint",hdc,"int",0,"int",0,"uint",hicon
                ,"int",w,"int",h,"uint",0,"uint",hbr,"uint",0x3)
        	DllCall("EndPaint","uint",hwnd,"uint",&ps)
        	return 0
        }
    }
   
    res := CallWindowProc(WindowProcOld, hwnd, uMsg, wParam, lParam)
   
    return res
}

CallWindowProc(wndProc, hwnd, uMsg, wParam, lParam) {
    return DllCall("CallWindowProc","uint",wndProc,"uint",hwnd,"uint",uMsg,"uint",wParam,"uint",lParam)
}