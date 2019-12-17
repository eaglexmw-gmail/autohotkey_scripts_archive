ahk_Initialize()
{
	CommandRegister("AHK Reload", "ahk_Reload")
	CommandRegister("AHK Exit", "ahk_Exit")
	CommandRegister("AHK CompactMemory", "ahk_CompactMemory")

	OnMessage(0x404, "AHK_NOTIFYICON")
}

ahk_Exit(A_Command, A_Args) {
	NOTIFY("AHK Closing")
	NOTIFY("AHK Exit")
	ExitApp
}

ahk_Reload(A_Command, A_Args) {
	SplashTextOn,,,Restarting RedStone,
	NOTIFY("AHK Closing")
	NOTIFY("AHK Exit")
	SplashTextOff
	Reload
}

; Tray left click
AHK_NOTIFYICON(wParam, lParam)
{
    if (lParam = 0x201) ; WM_LBUTTONDOWN
    {
		NOTIFY("AHK IconClicked")
        return 0
    }
}

ahk_CompactMemory(A_Command, A_Args) {

	pid := STATE_GET("Application PID")
    h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
    DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
    DllCall("CloseHandle", "Int", h)
}