debug_Initialize() {

	NotifyRegister("System Initialized", "debug_OnInitialized")
	CommandRegister("Debug ListVars", "debug_listVars")
}

debug_ListVars(A_Command, A_Args) {
	ListVars
}

debug_OnInitialized(A_Command, A_Args) {

	FileSetAttrib,-A,%A_ScriptFullPath%
	Loop,%A_ScriptDir%\*.ahk,0
		FileSetAttrib,-A,%A_LoopFileFullPath%

	SetTimer,UPDATEDSCRIPT,3000
	Return

	UPDATEDSCRIPT:
		FileGetAttrib,attribs,%A_ScriptFullPath%
		reload := False
		IfInString,attribs,A
		{
			FileSetAttrib,-A,%A_ScriptFullPath%
			reload := True
		}
		Loop,%A_ScriptDir%\*.ahk,0
		{
			FileGetAttrib,attribs,%A_LoopFileFullPath%
			IfInString,attribs,A
			{
				FileSetAttrib,-A,%A_LoopFileFullPath%
				reload := True
			}
		}
		if reload
			COMMAND("AHK Reload")
	Return
}
