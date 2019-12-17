;include CR_PluginClient.ahk

miro_Initialize() {

	CommandRegister("Miro Command", "miro_Command")
}

miro_Command(A_Command, A_Args) {

	entry := syslist_Get("Windows", "/single:Yes /filter:name=Miro")
	if (entry <> "") {
		wid := getValue(entry, "wid")
		WinActivate, ahk_id %wid%
		
		command := getValue(A_Args, "option")

		if (command = "Play") {
			ControlSend,MozillaWindowClass1,^{Space},ahk_id %wid%
		} else if (command = "Pause") {
			ControlSend,MozillaWindowClass1,^{Space},ahk_id %wid%
		} else if (command = "Stop") {
			ControlSend,MozillaWindowClass1,^D,ahk_id %wid%
		} else if (command = "Next") {
			ControlSend,MozillaWindowClass1,^{Right},ahk_id %wid%
		} else if (command = "Rewind") {
			ControlSend,MozillaWindowClass1,^{Left},ahk_id %wid%
		} else if (command = "Forward") {
			ControlSend,MozillaWindowClass1,{Right},ahk_id %wid%
		} else if (command = "Back") {
			ControlSend,MozillaWindowClass1,{Left},ahk_id %wid%
		} else if (command = "Fullscreen") {
			ControlSend,MozillaWindowClass1,!{Enter},ahk_id %wid%
		}

		WinActivate, RedStone
	}
}
