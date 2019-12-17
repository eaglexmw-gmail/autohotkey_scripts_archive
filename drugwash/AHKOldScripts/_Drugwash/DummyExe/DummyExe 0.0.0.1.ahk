; DummyExe is supposed to replace any executable (exe) file on your machine
; that you don't want to be launched automatically by a poorly designed or ill-intended application.
; © Drugwash, September 8, 2008
; created with AutoHotkey 1.0.47.06
; version 0.0.0.1

#NoTrayIcon
StringReplace, 1, 1, ",, All
if 0 = 0
	param := "no parameters."
else
	{
	if 0 = 1
		param := "one parameter:"
	else
		param = %0% parameters:
	}
; Just for kicks I'll ty this
test = %0% parameters
MsgBox, 48, Warning !, An application tried to launch %A_ScriptFullPath% with %param%`n%1% %2% %3% %4% %5% %6% %7% %8% %9%
GuiClose:
ExitApp
