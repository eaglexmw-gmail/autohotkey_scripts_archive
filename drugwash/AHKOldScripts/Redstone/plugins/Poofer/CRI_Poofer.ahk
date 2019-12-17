; Poofer by Gosugenji
; http://www.autohotkey.com/forum/viewtopic.php?t=31753

#include CR_PluginClient.ahk

poofer_Initialize() {
	CommandRegister("Poofer HideWindow", "poofer_HideWindow")
	CommandRegister("Poofer RestoreWindow", "poofer_RestoreWindow")

	NotifyRegister("AHK Closing", "poofer_OnClosing")
	NotifyRegister("UI BuildMenu", "poofer_OnBuildMenu")
}

poofer_OnBuildMenu(A_Command, A_Args) {

	type := getValue(A_Args, "type")

	if (type = "Hidden Window") {
		menu := removeValue(A_Args, "menu")
		COMMAND("Menu Add", "/menu:" . menu . " /item:Restore /menuCommand:Poofer RestoreWindow " . A_Args)

	} else if (type = "Window") {
		menu := removeValue(A_Args, "menu")
		COMMAND("Menu Add", "/menu:" . menu . " /item:Hide /menuCommand:Poofer HideWindow " . A_Args)
	}
}

poofer_HideWindow(A_Command, A_Args) {

	wid := getValue(A_Args, "wid")

	WinMinimize, ahk_id %wid%
	WinHide, ahk_id %wid%

	replaceValue(A_Args, "type", "Hidden Window")
	syslist_Add("HiddenWindows", A_Args)
}

poofer_RestoreWindow(A_Command, A_Args) {

	wid := getValue(A_Args, "wid")

	WinShow, ahk_id %wid%
	WinRestore, ahk_id %wid%
	WinShow, ahk_id %wid%

	removeValue(A_Args, "ListName")
	syslist_Remove("HiddenWindows", A_Args)
}

poofer_OnClosing(A_Command, A_Args) {

	list := syslist_Get("HiddenWindows")
	Loop, Parse, list, `n
	{
		Command("Poofer RestoreWindow", A_LoopField)
	}
}
