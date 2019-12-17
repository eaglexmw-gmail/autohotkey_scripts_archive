windows_Initialize()
{
	CommandRegister("Windows Activate", "windows_Command")
	CommandRegister("Windows Maximize", "windows_Command")
	CommandRegister("Windows Restore", "windows_Command")
	CommandRegister("Windows RestoreAll", "windows_Command")
	CommandRegister("Windows MinimizeAll", "windows_Command")
	CommandRegister("Windows Minimize", "windows_Command")
	CommandRegister("Windows Close", "windows_Command")
	CommandRegister("Windows Terminate", "windows_Command")
	CommandRegister("Windows FullScreen", "windows_Command")
	CommandRegister("Windows ActivatePrevious", "windows_ActivatePrevious")
	CommandRegister("Process Terminate", "process_Terminate")

	NotifyRegister("UI BuildMenu", "windows_BuildMenu")
}

windows_BuildMenu(A_Command, A_Args) {

	entry := getNestedNode(A_Args, "Entry")
	type := getValue(entry, "type")

	if (type = "Window")
	{
		wid := getValue(entry, "wid")

		WinGet, state, MinMax, ahk_id %wid%

		menuAdd(A_Args, "/item:Activate", commandCreate("Windows Activate", "/wid:" . wid))
		if (state <> 1)
			menuAdd(A_Args, "/item:Maximize", commandCreate("Windows Maximize", "/wid:" . wid))
		if (state <> 0) {
			menuAdd(A_Args, "/item:Restore", commandCreate("Windows Restore", "/wid:" . wid))
			menuAdd(A_Args, "/item:FullScreen", commandCreate("Windows FullScreen", "/wid:" . wid))
		}
		menuAdd(A_Args)
		if (state <> -1)
		{
			menuAdd(A_Args, "/item:Minimize", commandCreate("Windows Minimize", "/wid:" . wid))
			menuAdd(A_Args)
		}
		menuAdd(A_Args, "/item:Minimize All", commandCreate("Windows MinimizeAll", "/wid:" . wid))
		menuAdd(A_Args, "/item:Restore All", commandCreate("Windows RestoreAll", "/wid:" . wid))
		menuAdd(A_Args)
		menuAdd(A_Args, "/item:Close", commandCreate("Windows Close", "/wid:" . wid))
		menuAdd(A_Args)
		menuAdd(A_Args, "/item:Terminate", commandCreate("Windows Terminate", "/wid:" . wid))
	}
}

windows_Command(A_Command, A_Args) {

	wid := getValue(A_Args, "wid")
	A_Command := getValue(A_Command, "command")

	WinGetTitle,title,ahk_id %wid%
;	log("title: " . title . " wid:[" . wid . "] args:[" . A_Args . "]")

	ifEQual,A_Command,Windows Activate
	{
		COMMAND("UI Hide")
		WinActivate, ahk_id %wid%
	}
	else ifEQual,A_Command,Windows Maximize
	{
		COMMAND("UI Hide")
		WinActivate, ahk_id %wid%
		PostMessage, 0x112, 0xF030,,, ahk_id %wid%  ; SC_MAXIMIZE
	}
	else ifEQual,A_Command,Windows Restore
	{
		COMMAND("UI Hide")
		WinActivate, ahk_id %wid%
		PostMessage, 0x112, 0xF120,,, ahk_id %wid%
	}
	else ifEqual,A_Command,Windows RestoreAll
	{
		COMMAND("UI Hide")

		windows := syslist_Get("Windows")
		Loop
		{
			window := list_Iterate(windows, iter)
			if (window = "") {
				break
			}
			lwid := getValue(window, "wid")

			If ( lwid <> wid ) {
				PostMessage, 0x112, 0xF120,,, ahk_id %lwid%  ; 0x112 = WM_SYSCOMMAND, 0xF020 = SC_MAXIMIZE
			}
		}
		WinActivate, ahk_id %wid%
	}
	else ifEqual,A_Command,Windows MinimizeAll
	{
		windows := syslist_Get("Windows")
		Loop
		{
			window := list_Iterate(windows, iter)
			if (window = "") {
				break
			}
			lwid := getValue(window, "wid")
			WinMinimize, ahk_id %lwid%
		}
	}
	else ifEqual,A_Command,Windows Minimize
	{
		WinMinimize, ahk_id %wid%
		COMMAND("Windows Update")
	}
	else ifEqual,A_Command,Windows Close
	{
		COMMAND("UI Hide")
		PostMessage, 0x112, 0xF060,,, ahk_id %wid%
	}
	else ifEqual,A_Command,Windows Terminate
	{
		WinGet, pid, PID, ahk_id %wid%
		COMMAND("Process Terminate", "/pid:" . pid . " /name:" . title)
		COMMAND("Windows Update")
	}
	else ifEqual,A_Command,Windows FullScreen
	{
		WinGet, acw_m, MinMax, ahk_id %wid%
		if (acw_m = 1) {
			WinActive("A")
		  	WinGet, acw_s, Style, ahk_id %wid%
		    if (acw_s & 0xC00000)
		    {
				WinSet, Style, -0xC40000, ahk_id %wid%
				WinMove, ahk_id %wid%, , 0, 0, %A_ScreenWidth%, %A_ScreenHeight%
			} else {
				WinSet, Style, +0xC40000, ahk_id %wid%
			}
		}
	}
}

process_Terminate(A_Command, A_Args) {

	pid := getValue(A_Args, "pid")
	name := getValue(A_Args, "name")

	warningText = WARNING: Terminating a process can cause undesired results.`n`nTerminate %name%?`n(Process ID: %pid%)
	MsgBox, 4100, RedStone Warning, %warningText%
	IfMsgBox Yes
	{
		Process, Close, %pid%
	}
}

windows_ActivatePrevious(A_Command, A_Args) {

	COMMAND("Windows", "Refresh")
	windows := syslist_Get("Windows")
	entry := list_Get(windows, 2)
	if (entry <> "") {
		COMMAND("Command Run", entry)
	}
}
