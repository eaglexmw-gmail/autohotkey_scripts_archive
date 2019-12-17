animation_Initialize() {
	CommandRegister("Animation Start", "animation_Start")
	CommandRegister("Animation StartNow", "animation_Start")
	CommandRegister("Animation Stop", "animation_Stop")
}

animation_Start(A_Command, A_Args) {

	if (A_Command = "StartNow") {
		SetTimer, StartAnimation, 100
	} else {
		SetTimer, StartAnimation, 666
	}
}

animation_Stop(A_Command, A_Args) {
	gosub StopAnimation
}

StartAnimation:
	animation_Begin()
	SetTimer, StartAnimation, Off
Return

animation_Begin() {

	global gblAnimationControl

	saFileName := STATE_GET("Skin LoadingImage", "res\loading.gif")
	StringSplit,saArray,saFileName,`,
	saFileName := A_ScriptDir . "\" . saArray1

	entry := syslist_Get("Controls", "/single:Yes /filter:name=CTRLInfoIcon")
	control := getValue(entry, "control")
	hwnd := getValue(entry, "hwnd")
	GuiControlGet, dim, Pos, %control%

	gblAnimationControl := AniGif_CreateControl(hwnd, 0, 0, dimW, dimH, WAGS_AUTOSIZE)

	bgColor := STATE_GET("UI Background")

	if (bgColor <> "") {
		red := SubStr(bgColor, 3, 2)
		green := SubStr(bgColor, 5, 2)
		blue := SubStr(bgColor, 7, 2)
		bgColor := "0x" . blue . "" . green . "" . red  
		
		AniGif_SetBkColor(gblAnimationControl, bgColor)
	}
	AniGif_LoadGifFromFile(gblAnimationControl, saFileName)
}

StopAnimation:
	SetTimer, StartAnimation, Off
	AniGif_DestroyControl(gblAnimationControl)
Return

#include plugins/UI-Generic/Control_AniGif.ahk
