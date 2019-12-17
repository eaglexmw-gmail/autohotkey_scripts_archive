fileutil_Initialize() {
	NotifyRegister("UI BuildMenu", "fileutil_OnBuildMenu")
}

fileutil_OnBuildMenu(A_Command, A_Args) {

	entry := getNestedNode(A_Args, "Entry")
	type := getPrimitiveType(entry)

	if (type = "file" OR type = "folder") {
		file := getValue(entry, "command")
log("building context menu for:" . file)
		ShellContextMenu("uiMenu", file)
	}
}

getMenuHandle( p_menu) {
	Menu, menuDummy, Add 
	Menu, menuDummy, DeleteAll 

	Gui, 99:Menu, menuDummy 
	Gui, 99:Show, Hide, guiDummy 

	old_DetectHiddenWindows := A_DetectHiddenWindows 
	DetectHiddenWindows, on 

	Process, Exist 
	h_menuDummy := DllCall( "GetMenu", "uint", WinExist( "guiDummy ahk_class AutoHotkeyGUI ahk_pid " ErrorLevel ) ) 
	if ( ErrorLevel or h_menuDummy = 0) {
		log("getmenu failed")
		return, false 
	}

	Gui, 99:Menu 

	Menu, menuDummy, Add, :%p_menu% 

	h_menu := DllCall( "GetSubMenu", "uint", h_menuDummy, "int", 0 ) 
	if ( ErrorLevel or h_menu = 0) {
		log("getsubmenu failed")
	}

	success := DllCall( "RemoveMenu", "uint", h_menuDummy, "uint", 0, "uint", 0x400 ) 
	if (ErrorLevel or ! success) {
		log("remove failed")
	}

	Gui, 99:Destroy 
	DetectHiddenWindows, %old_DetectHiddenWindows% 

	return h_Menu
} 

ShellContextMenu(xmenu, sPath)
{
	CoInitialize()

	DllCall("shell32\SHParseDisplayName", "Uint", Unicode4Ansi(wPath,sPath)
		, "Uint", 0, "UintP", pidl, "Uint", 0, "Uint", 0)

	DllCall("shell32\SHBindToParent", "Uint", pidl
		, "Uint", GUID4String(IID_IShellFolder,"{000214E6-0000-0000-C000-000000000046}")
		, "UintP", psf, "UintP", pidlChild)
	DllCall(NumGet(NumGet(1*psf)+40), "Uint", psf
		, "Uint", 0, "Uint", 1, "UintP", pidlChild
		, "Uint", GUID4String(IID_IContextMenu,"{000214E4-0000-0000-C000-000000000046}")
		, "Uint", 0, "UintP", pcm)

;	DllCall("shell32\SHBindToParent", "Uint", pidl
;		, "Uint", GUID4String(IID_IShellFolder,"{BCFCE0A0-EC17-11D0-8D10-00A0C90F2719}")
;		, "UintP", psf, "UintP", pidlChild)
;	DllCall(NumGet(NumGet(1*psf)+40), "Uint", psf
;		, "Uint", 0, "Uint", 1, "UintP", pidlChild
;		, "Uint", GUID4String(IID_IContextMenu,"{BCFCE0A0-EC17-11D0-8D10-00A0C90F2719}")
;		, "Uint", 0, "UintP", pcm)

	Release(psf)
	CoTaskMemFree(pidl)
 
	hMenu := getMenuHandle(xmenu)

	DllCall(NumGet(NumGet(1*pcm)+12), "Uint", pcm, "Uint", hMenu, "Uint", 0, "Uint", 3, "Uint", 0x7FFF, "Uint", 0)   ; QueryContextMenu
	DetectHiddenWindows, On
	Process, Exist
	WinGet, hAHK, ID, ahk_pid %ErrorLevel%
;	WinActivate, ahk_id %hAHK%
	Global   pcm2 := QueryInterface(pcm,IID_IContextMenu2:="{000214F4-0000-0000-C000-000000000046}")
	Global   pcm3 := QueryInterface(pcm,IID_IContextMenu3:="{BCFCE0A0-EC17-11D0-8D10-00A0C90F2719}")
	Global   WPOld:= DllCall("SetWindowLong", "Uint", hAHK, "int",-4, "int",RegisterCallback("WindowProc"))

;	DllCall("InsertMenu", "Uint", hMenu, "Uint", 0, "Uint", 0x0400|0x800, "Uint", 2, "Uint", 0)
;	DllCall("InsertMenu", "Uint", hMenu, "Uint", 0, "Uint", 0x0400|0x002, "Uint", 1, "Uint", &sPath)
	DllCall("GetCursorPos", "int64P", pt)
	idn := DllCall("TrackPopupMenu", "Uint", hMenu, "Uint", 0x0100, "int", pt << 32 >> 32, "int", pt >> 32, "Uint", 0, "Uint", hAHK, "Uint", 0)
log("idn:" . idn)
	NumPut(VarSetCapacity(ici,64,0),ici)
	NumPut(0x4000|0x20000000,ici,4)
	NumPut(1,NumPut(hAHK,ici,8),12)
;	NumPut(idn-3,NumPut(idn-3,ici,12),24)
	NumPut(idn-3,NumPut(idn-3,ici,12),24)
	NumPut(pt,ici,56,"int64")
	DllCall(NumGet(NumGet(1*pcm)+16), "Uint", pcm, "Uint", &ici)   ; InvokeCommand

	VarSetCapacity(sName,512)
	DllCall(NumGet(NumGet(1*pcm)+20), "Uint", pcm, "Uint", idn-3, "Uint", 1, "Uint", 0, "str", sName, "Uint", 260)   ; GetCommandString
log("sName:" . sName)
	DllCall("GetMenuString", "uint", hMenu, "uint", idn, "str", sName, "uint", 512, "uint", 0x0) ;MF_BYPOSITION = 0x400
log("menuString:" . sName)
if (sName <> "") {
	entry := syslist_Get("Menu_uiMenu", "/single:Yes /filter:menuItem=" . sName)
	if (entry <> "") {
log("running:" . sName)
		MenuCommandRun("uiMenu", sName)
	} else {
		filter := STATE_GET("Lister CurrentFilter")
		name := getValue(filter, "name")
		if (name = "files") {
			lister_UpdateFilter(filter)
		}
	}
}
	DllCall("GlobalFree", "Uint", DllCall("SetWindowLong", "Uint", hAHK, "int", -4, "int", WPOld))


DllCall("DestroyMenu", "Uint", hMenu)
	Release(pcm3)
	Release(pcm2)
	Release(pcm)
	CoUninitialize()
	pcm2:=pcm3:=WPOld:=0
}

WindowProc(hWnd, nMsg, wParam, lParam)
{
	Critical
	Global   pcm2, pcm3, WPOld

	If pcm3
	{
		If (!DllCall(NumGet(NumGet(1*pcm3)+28), "Uint", pcm3, "Uint", nMsg, "Uint", wParam, "Uint", lParam, "UintP", lResult)) {
			; log("returning:" . lResult)
			Return   lResult
		}
	}
	Else If pcm2
	{
		If (!DllCall(NumGet(NumGet(1*pcm2)+24), "Uint", pcm2, "Uint", nMsg, "Uint", wParam, "Uint", lParam)) {
			; log("returning 0")
			Return   0
		}
	}
	
	Return DllCall("user32.dll\CallWindowProcA", "Uint", WPOld, "Uint", hWnd, "Uint", nMsg, "Uint", wParam, "Uint", lParam)
}

#Include plugins/ExplorerContextMenu/CoHelper.ahk
