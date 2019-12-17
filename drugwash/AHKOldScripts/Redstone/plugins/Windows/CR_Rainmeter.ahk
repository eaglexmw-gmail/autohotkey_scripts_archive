; include CR_PluginClient.ahk

rainmeter_Initialize() {
	CommandRegister("Rainmeter CheckPosition", "rainmeter_CheckPosition")
	NotifyRegister("List Update", "rainmeter_CheckPosition")
;	SetTimer, rainmeter_Timer, 15000
	Return
	
	rainmeter_Timer:
		COMMAND("Rainmeter CheckPosition")
	Return
}

rainmeter_CheckPosition(A_Command, A_Args) {

	listName := getValue(A_Args, "listName")
	if (listName <> "Windows") {
		return
	}

	WinGet, Window_List, List ; Gather a list of running programs

	list =
	Loop, %Window_List%
	{
		wid := Window_List%A_Index%

		WinGetClass,class,ahk_id %wid%
		if (class = "RainmeterMeterWindow") {
			rainWid := wid
		} else if (class = "EmergeDesktopApplet") {
			emergeWid := wid
		}
	}

	if (rainWid <> "") {
		WinGetPos, x, y, width, height, ahk_id %rainWid%
        SysGet, Mon, Monitor, 1
        rpos := MonRight + 249
		
		if (x <> rpos) OR (y <> 25) {
			WinMove, ahk_id %rainWid%, , %rpos%, 25
			if (emergeWid <> "") {
				WinGetPos, x, y, width, height, ahk_id %emergeWid%
				epos := MonRight + 1120
				WinMove, ahk_id %emergeWid%, , %epos%, 33
				WinSet,Top,,ahk_id %emergeWid%
			}
		}
	}
}
