button_Initialize() {
	CommandRegister("Button SetImage", "button_SetImage")
	CommandRegister("Control SetText", "control_OnSetText")
}

control_OnSetText(A_Command, A_Args) {
	name := getValue(A_Args, "name")
	text := getValue(A_Args, "text")
	control := getControl(name)
	GuiControl,,%control%,%text%
}

button_SetImage(A_Command, A_Args) {

	name := getValue(A_Args, "name")
	imgPath := getValue(A_Args, "image")

	entry := syslist_Get("Controls", "/single:Yes /filter:name=" . name)
	hWnd := getValue(entry, "hwnd")
	button := getValue(entry, "control")

	GuiControlGet, dim, Pos, %button% 

	static LR_LOADFROMFILE = 16

	static BS_ICON = 0x40
	static BS_BITMAP = 0x80
	static BS_FLAT = 0x8000

	static IMAGE_BITMAP = 0
	static IMAGE_ICON = 1

	imageType := IMAGE_ICON

	if (InStr(imgPath, ",")) {

		VarSetCapacity(fileName, 260)

		StringSplit,farray,imgPath,`,

		IfExist, %farray1%
			fileName := farray1
		IfExist, %A_WorkingDir%/%farray1%
			fileName = %A_WorkingDir%\%farray1%
		IfExist,%A_WinDir%\system32\%farray1%
			fileName = %A_WinDir%\system32\%farray1%

		iconNum := (farray2+1)

		hInst := DllCall("GetModuleHandle", "str", fileName)
		hIcon := DllCall("LoadImageA", "Uint", hInst, "Uint", iconNum, "Uint", IMAGE_ICON, "int", dimW-3, "int", dimH-3, "Uint", 0x8000)

;		hIcon := DllCall("Shell32\ExtractAssociatedIconA", UInt, 0, Str, fileName, UShortP, iconNum)

	} else {
		SplitPath, imgPath, , , FExt

		if (FExt = "bmp") {
			imageType := IMAGE_BITMAP
		}

		hIcon := DllCall("LoadImage", "UInt", NULL
			, "Str", imgPath
			, "UInt", imageType
			, "Int", dimW-3
			, "Int", dimH-3
			, "UInt", LR_LOADFROMFILE
			, "UInt")
	}

	static BM_SETIMAGE = 247
	
	style := BS_FLAT | (imageType = IMAGE_ICON ? BS_ICON : BS_BITMAP)

	GuiControl, +%style%, %button%

	DllCall("SendMessage", "UInt", hWnd, "UInt", BM_SETIMAGE, "UInt", imageType, "UInt", hIcon)
}
