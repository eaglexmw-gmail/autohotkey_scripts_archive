help_Initialize() {
	NotifyRegister("UI Create", "help_OnUiCreate")
	CommandRegister("Help Tutorial", "help_OnTutorial")
}

help_OnUiCreate(A_Command, A_Args) {

	COMMAND("UI AddControl", "/name:CTRLHelp"
		. " /type:button"
		. " /x:493 /y:62 /w:16 /h:16"
		. " /style:-theme +0x8000"
		. " /tooltip:Tutorial"
		. " /anchor:x"
		. " /text:?"
		. " /callback:Help Tutorial")
}

help_OnTutorial(A_Command, A_Args) {
	command := createNode("/name:Redstone Tutorial"
		. " /type:website"
		. " /command:http://www.autohotkey.net/~JoeSchmoe/rstut/rstut.html")
	COMMAND("Command Run", command)
}
