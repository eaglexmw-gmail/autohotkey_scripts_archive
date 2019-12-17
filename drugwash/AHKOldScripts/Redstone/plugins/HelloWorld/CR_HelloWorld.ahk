; Enable plugin (Configuration->plugins->right click and enable Hello World)
; Restart RedStone
; type: *hello world

#include CR_PluginClient.ahk

helloWorld_Initialize() {

	CommandRegister("Hello World", "helloWorld_Command")
	CommandRegister("Hello Data", "helloWorld_Data")
}

helloWorld_Command(A_Command, A_Args) {

	MsgBox,Hello World
}

helloWorld_Data(A_Command, A_Args) {

	value := syslist_Get("Categories", "/filter:name=Configuration /single:Yes")
	
	logA("got:" . xpath_save(value))
}
