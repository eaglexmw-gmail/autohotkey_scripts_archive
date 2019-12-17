; http://www.autohotkey.com/docs/scripts/WindowShading.htm
; http://www.autohotkey.com/forum/viewtopic.php?p=50920#50920

#include CR_PluginClient.ahk

roller_Initialize() {
	CommandRegister("Roller Rollup", "roller_Rollup")
	CommandRegister("Roller Restore", "roller_Restore")

	NotifyRegister("AHK Closing", "roller_OnClosing")

	Hotkey, ~*RButton, onRButton
	Hotkey, ~WheelUp, onRButton
	Hotkey, ~WheelDown, onRButton
	Return
	
	onRButton:
		roller_ProcessClick(A_ThisHotkey)
	Return
}

roller_ProcessClick(pressed) {

	SetBatchLines, -1
	CoordMode, Mouse, Screen
	SetMouseDelay, -1 ; no pause after mouse clicks
	SetKeyDelay, -1 ; no pause after keys sent
	MouseGetPos, ClickX, ClickY, wid
	WinActivate, ahk_id %wid%

;                  0x16CF0000
;static WS_POPUP = 0x80000000
;static WS_CHILD = 0x40000000

;WinGet,s,Style,ahk_id %wid%
;log("style:" . s)
;DllCall("SetParent", Int, wid, Int, 0)
;WinSet, Style, +0x40000000, ahk_id %wid%

	; WM_NCHITTEST
	SendMessage, 0x84,, ( ClickY << 16 )|ClickX,, ahk_id %wid%
	WM_NCHITTEST_Result = %ErrorLevel%
	/*
	#define HTERROR             (-2)
	#define HTTRANSPARENT       (-1)
	#define HTNOWHERE           0
	#define HTCLIENT            1
	#define HTCAPTION           2
	#define HTSYSMENU           3
	#define HTGROWBOX           4
	#define HTSIZE              HTGROWBOX
	#define HTMENU              5
	#define HTHSCROLL           6
	#define HTVSCROLL           7
	#define HTMINBUTTON         8
	#define HTMAXBUTTON         9
	#define HTLEFT              10
	#define HTRIGHT             11
	#define HTTOP               12
	#define HTTOPLEFT           13
	#define HTTOPRIGHT          14
	#define HTBOTTOM            15
	#define HTBOTTOMLEFT        16
	#define HTBOTTOMRIGHT       17
	#define HTBORDER            18
	#define HTREDUCE            HTMINBUTTON
	#define HTZOOM              HTMAXBUTTON
	#define HTSIZEFIRST         HTLEFT
	#define HTSIZELAST          HTBOTTOMRIGHT
	#if(WINVER >= 0x0400)
	#define HTOBJECT            19
	#define HTCLOSE             20
	#define HTHELP              21
	*/
	; Check what was clicked on
	If WM_NCHITTEST_Result = 2
	{
		if (pressed = "~WheelUp") {
			Winget, trans, transparent, ahk_id %wid%
			if (trans = "") {
				trans = 255
			}
			if (trans < 235) {
				trans += 20
				Winset, transparent, %trans%, ahk_id %wid%
			} else {
				Winset, transparent, Off, ahk_id %wid%
			}
			
		} else if (pressed = "~WheelDown") {
			Winget, trans, transparent, ahk_id %wid%
			if (trans = "") {
				trans = 255
			}
			if (trans > 20) {
				trans -= 20
				Winset, transparent, %trans%, ahk_id %wid%
			}
		} else {
			entry := syslist_Get("RolledWindows", "/single:Yes /filter:wid=" . wid)
			if (entry <> "") {
				COMMAND("Roller Restore", "/wid:" . wid)
			} else {
				COMMAND("Roller Rollup", "/wid:" . wid)
			}
		}
	}
}

roller_Rollup(A_Command, A_Args) {
	static ws_MinHeight = 25

	wid := getValue(A_Args, "wid")

	WinGetPos,x, y, ws_Width, ws_Height, ahk_id %wid%
	WinMove, ahk_id %wid%,,,,200, %ws_MinHeight%
	
	syslist_Add("RolledWindows", "/wid:" . wid 
		. " /height:" . ws_Height 
		. " /width:" . ws_Width
		. " /x:" . x
		. " /y:" . y)
}

roller_Restore(A_Command, A_Args) {
	wid := getValue(A_Args, "wid")
	entry := syslist_Get("RolledWindows", "/single:Yes /filter:wid=" . wid)
log("roller restore:" . A_Args)
	if (entry <> "") {
		height := getValue(entry, "height")
		width := getValue(entry, "width")
		x := getValue(entry, "x")
		y := getValue(entry, "y")
		removeValue(entry, "listName")
		syslist_Remove("RolledWindows", entry)
		WinMove, ahk_id %wid%,,%x%,%y%, %width%, %height%
	}
}

roller_OnClosing(A_Command, A_Args) {
	list := syslist_Get("RolledWindows")
log("roller closing")
	Loop, Parse, list, `n
	{
		COMMAND("Roller Restore", A_LoopField)
	}
}
