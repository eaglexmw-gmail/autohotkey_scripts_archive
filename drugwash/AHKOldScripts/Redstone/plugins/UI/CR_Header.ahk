header_Initialize() {
	NotifyRegister("UI Create", "header_OnUiCreate")
	NotifyRegister("Lister SetFilter", "header_OnSetFilter")
}

header_OnUiCreate(A_Command, A_Args) {

	COMMAND("UI AddControl", "/name:CTRLHeader"
		. " /type:text"
		. " /x:50 /y:55 /w:412 /h:24"
		. " /anchor:w /redraw:Yes"
		. " /callback:UI Move")
}

header_OnSetFilter(A_Command, A_Args) {
	name := getValue(A_Args, "name", "--Unknown--")
	COMMAND("Control SetText", "/name:CTRLHeader /text:" . name)
}
