#SingleInstance force
#NoEnv
SetWorkingDir %A_ScriptDir%

#Include ILButton.ahk
;#include func_DllCallDebugger104706.ahk

Gui, +ToolWindow +AlwaysOnTop
Loop 5 {
	Gui, Add, Button, w64 h32 xm hwndhBtn
		ILButton(hBtn, "shell32.dll:" A_Index-1, 16, 16, A_Index-1)
	Gui, Add, Button, w100 h32 x+10 hwndhBtn, text
		ILButton(hBtn, "shell32.dll:" A_Index-1, 16, 16, A_Index-1)
	}
Gui, Add, Button, xm w174 h48 vStates hwndhBtn, pushbuttonstates
	ILButton(hBtn, "shell32.dll:0|:1|:2|:3|:4|:5", 32, 32, 0, "16,1,-16,1")
Gui, Add, Button, w100 h26 xm+74 gToggle, Enable/disable

Gui, Show, , ILButton demo
return

Toggle:
	GuiControlGet, s, Enabled, States
	GuiControl, Disable%s%, States
	return

GuiClose:
GuiEscape:
	ExitApp
	return
