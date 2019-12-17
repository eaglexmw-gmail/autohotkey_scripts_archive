#NoEnv
#SingleInstance ignore
#Persistent
SetBatchLines, -1

AutoTrim, Off

Menu Tray, Icon, SHELL32.dll, 22
Menu, Tray, Tip, RedStone Scanner
Menu, Tray, NoStandard
Menu, Tray, Add, S&can, DoScan
Menu, Tray, Add, Reload Script, DoReload
Menu, Tray, Add, L&ist Vars, DoListVars
Menu, Tray, Add, E&xit, GuiClose

params = %1%
STATE_SET("Host PID", getValue(params, "pid"))

params = %2%
STATE_SET("Host WID", getValue(params, "wid"))

CR_Initialize("Scanner")

; TODO:1 Hearbeat - if host is gone, exit client

if (CLIENT_COMMAND("Plugin Ready", "/pid:" . STATE_GET("Application PID")) = "Fail") {
	ExitApp
}

ClientNotifyRegister("AHK Reload", "plugin_Exit")
ClientNotifyRegister("AHK Exit", "plugin_Exit")
SetTimer, plugin_Heartbeat, 3000

COMMAND("Scan Start")

COMMAND("AHK CompactMemory")
Return

plugin_Heartbeat:
	pid := STATE_GET("HOST PID")
	Process,Exist,%pid%
	if (ErrorLevel = 0) {
		logA("PID DOES NOT EXIST")
		ExitApp
	}
Return

plugin_Exit(A_Command, A_Args) {
	ExitApp
}

DoScan:
	COMMAND("Scan Refresh")
Return

DoListVars:
	COMMAND("Debug ListVars")
Return

DoReload:
	COMMAND("AHK Reload")
Return

GuiClose:
	COMMAND("AHK Exit")
Return

#include CR_Main.ahk
;#include plugins/Scanners/CRI_RSS.ahk
#include plugins/Scanners/CRI_StartMenu.ahk
#include plugins/Scanners/CRI_Category.ahk
#include plugins/Scanners/CRI_Skype.ahk
#include plugins/Scanners/CRI_Firefox.ahk
#include plugins/Scanners/CR_Scan.ahk
#include plugins/Scanners/CRI_Skins.ahk
#include plugins/Scanners/CR_System.ahk
#include plugins/Scanners/CRI_IE.ahk
#include plugins/Scanners/CRI_ControlPanel.ahk
#include plugins/Types/CR_Website.ahk
