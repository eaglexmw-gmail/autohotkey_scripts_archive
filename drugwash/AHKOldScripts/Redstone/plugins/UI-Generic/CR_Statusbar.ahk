statusbar_Initialize()
{
	CommandRegister("Status Display", "statusbar_Display")

	NotifyRegister("UI Create", "statusbar_CreateUI")
	NotifyRegister("UI Show", "statusbar_Activate")
	NotifyRegister("UI Hide", "statusbar_Deactivate")
}

statusbar_CreateUI(A_Command, A_Args) {

	COMMAND("UI AddControl", "/name:CTRLStatusBar /type:statusbar")
	
	STATE_SET("Status Displayed", "0")

	SB_Width := 504 / 4
	SB_SetParts(45)
}

statusbar_Display(A_Command, A_Args) {
	status := getValue(A_Args, "status")
	SB_SetText(status, 2)
	duration := getValue(A_Args, "duration")
	if (timed <> "") {
		SetTimer, SB_TimedStatus, %duration%
	} else {
		SetTimer, SB_TimedStatus, Off
	}
	if (status = "") {
		STATE_SET("Status Displayed", "0")
	} else {
		STATE_SET("Status Displayed", "1")
	}
}

SB_TimedStatus:
	COMMAND("Status Display")
Return

statusbar_Activate(A_Command, A_Args) {
	SetTimer, SB_StatusBar, 1000
	gosub SB_StatusBar
}

statusbar_Deactivate(A_Command, A_Args) {
	SetTimer, SB_StatusBar, Off
}

SB_StatusBar:
	statusbar_Update()
Return

statusbar_Update() {
	text := GetSystemTimes() . "%"

	SB_SetText(text, 1)

	if (STATE_GET("Status Displayed") = "0") {
		FormatTime, OutputVar,,dddd MMMM d, yyyy hh:mm:ss tt 
		SB_SetText(OutputVar, 2)
	}
}

; Total CPU Load
GetSystemTimes() {
	Static oldIdleTime, oldKrnlTime, oldUserTime
	Static newIdleTime, newKrnlTime, newUserTime

	Format_Float := A_FormatFloat
	SetFormat, Float, 4.1

	oldIdleTime := newIdleTime
	oldKrnlTime := newKrnlTime
	oldUserTime := newUserTime

	DllCall("GetSystemTimes", "int64P", newIdleTime, "int64P", newKrnlTime, "int64P", newUserTime)
	text := (1 - (newIdleTime-oldIdleTime)/(newKrnlTime-oldKrnlTime + newUserTime-oldUserTime)) * 100
	SetFormat, Float, %Format_Float%
	
	return text
}
