tasklist_Initialize() {

	CommandRegister("Windows Update", "windows_Update")
	CommandRegister("Windows Refresh", "windows_Refresh")

	NotifyRegister("UI Created", "windows_Update")
	NotifyRegister("UI Created", "windows_OnInitialized")
}

windows_OnInitialized(A_Command, A_Args) {
;	Gui +LastFound
	guiID := STATE_GET("Application Wid")
	; WinExist()
	DllCall("RegisterShellHookWindow",UInt,guiID)
	ShellHook:=DllCall("RegisterWindowMessage",Str,"SHELLHOOK")
	OnMessage(ShellHook,"ShellMessage")
}

windows_Update(A_Command, A_Args) {

	COMMAND("Windows Refresh")
	NOTIFY("List Update", "/listName:Windows")
}

windows_Refresh(A_Command, A_Args) {

	WinGet, Window_List, List ; Gather a list of running programs

	list := list_Create()
	Loop, %Window_List%
	{
		wid := Window_List%A_Index%

		If ( isNormalWindow(wid) ) {

			WinGetTitle, Title, ahk_id %wid%
			title := Enc_XML(title)
			list_Add(list, "/listName:Windows /name:" . title . " /type:window /wid:" . wid)
		}
	}
	syslist_Set("Windows", list)
}

ShellMessage(nCode, wParam,lParam) {
	static HSHELL_WINDOWACTIVATED = 4
	static HSHELL_WINDOWDESTROYED = 2
	static HSHELL_WINDOWCREATED = 1

if (nCode > 32768) {
	nCode -= 32768
}
	if (nCode = HSHELL_WINDOWCREATED) {

		BACKGROUND_COMMAND("Windows Update")

	} else if (nCode = HSHELL_WINDOWACTIVATED) {

		if (wParam <> 0) {
			SetFormat, Integer, Hex
			wid := 0x0
			wid += wParam
			SetFormat, integer, d
			list := syslist_Get("Windows")
			entry := list_Get(list, 1)
			if (getValue(entry, "wid") <> wid) {

				BACKGROUND_COMMAND("Windows Update")
			}
		}
	} else if (nCode = HSHELL_WINDOWDESTROYED) {
		
		SetFormat, Integer, Hex
		wid := 0x0
		wid += wParam
		SetFormat, integer, d
		if (syslist_Get("Windows", "/single:Yes /filter:wid=" . wid) <> "") {
			BACKGROUND_COMMAND("Windows Update")
		}
	}

	Return 0
}

isNormalWindow(wid) {

	; This function found at http://file.autohotkey.net/evl/AltTab/AltTab.ahk

	static WS_EX_CONTROLPARENT =0x10000
	static WS_EX_DLGMODALFRAME =0x1
	static WS_CLIPCHILDREN =0x2000000
	static WS_EX_APPWINDOW =0x40000
	static WS_EX_TOOLWINDOW =0x80
	static WS_DISABLED =0x8000000
	static WS_VSCROLL =0x200000
	static WS_POPUP =0x80000000

	WinGetTitle, wid_Title, ahk_id %wid%
	WinGet, Style, Style, ahk_id %wid%

	If ((Style & WS_DISABLED) or ! (wid_Title)) ; skip unimportant windows ; ! wid_Title or 
		return FALSE

	WinGet, es, ExStyle, ahk_id %wid%
	Parent := Decimal_to_Hex( DllCall( "GetParent", "uint", wid ) )
	WinGetClass, Win_Class, ahk_id %wid%
	WinGet, Style_parent, Style, ahk_id %Parent%

	If (((es & WS_EX_TOOLWINDOW) and !(es & ws_ex_controlparent))
		or ((es & ws_ex_controlparent) and ! (Style & WS_POPUP) and !(Win_Class ="#32770") and ! (es & WS_EX_APPWINDOW)) ; pspad child window excluded
		or ((Style & WS_POPUP) and (Parent) and ((Style_parent & WS_DISABLED) =0))) ; notepad find window excluded ; note - some windows result in blank value so must test for zero instead of using NOT operator!
		return FALSE

	return TRUE
}
