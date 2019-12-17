/*
Control_IPAddress.ahk

Add a SysIPAddress32 (IP Address input) control to your AHK Gui.
http://msdn.microsoft.com/library/default.asp?url=/library/en-us/shellcc/platform/commctls/ipaddress/reflist.asp
Base code from my CreateWindow_AVI based on daonlyfreez' work.
Note that to control this... control, you have to use Control commands, not GuiControl ones.

http://www.autohotkey.com/forum/viewtopic.php?t=17405

// by Philippe Lhoste <PhiLho(a)GMX.net> http://Phi.Lho.free.fr
// File/Project history:
 1.03.000 -- 2007/05/25 (PL) -- Added IPM_CLEARADDRESS on request of aCkRiTe.
 1.02.000 -- 2007/05/23 (PL) -- Added IPM_SETADDRESS and improved encapsulation.
 1.01.000 -- 2007/05/16 (PL) -- Changed API for consistency with CreateWindow_AniGif.
 1.00.000 -- 2007/03/12 (PL) -- Creation.
*/
/* Copyright notice: For details, see the following file:
http://Phi.Lho.free.fr/softwares/PhiLhoSoft/PhiLhoSoftLicence.txt
This program is distributed under the zlib/libpng license.
Copyright (c) 2007 Philippe Lhoste / PhiLhoSoft
*/

/**
 * Control creation: you have to provide the ID of the GUI in which the control goes,
 * its position (_x, _y) and it size (_w, _h).
 */
IPAddress_CreateControl(_guiHwnd, _x, _y, _w, _h)
{
	local structICCE, ipaHwnd
	local msg
	static $bFirstCall := true

	If ($bFirstCall)
	{
		$bFirstCall := false
		; http://msdn.microsoft.com/library/en-us/shellcc/platform/commctls/common/structures/initcommoncontrolsex.asp
		VarSetCapacity(structICCE, 8)
		DllCall("ntdll\RtlFillMemoryUlong", "UInt", &structICCE, "UInt", 4, "UInt", 8)
		DllCall("ntdll\RtlFillMemoryUlong", "UInt", &structICCE + 4, "UInt", 4, "UInt", 0x800) ; ICC_INTERNET_CLASSES
		DllCall("InitCommonControlsEx", "UInt", &structICCE)
	}

	; http://msdn.microsoft.com/library/en-us/winui/winui/windowsuserinterface/windowing/windows/windowreference/windowfunctions/createwindowex.asp
	ipaHwnd := DLLCall("CreateWindowEx"
			, "UInt", 0               ; Style, can be WS_EX_CLIENTEDGE = 0x200
			, "Str", "SysIPAddress32" ; Class Name
			, "UInt", 0               ; Window name
			, "UInt", 0x50010000      ; Window style:  WS_CHILD | WS_VISIBLE | WS_TABSTOP
			, "Int", _x               ; X position
			, "Int", _y               ; Y position
			, "Int", _w               ; Width
			, "Int", _h               ; Height
			, "UInt", _guiHwnd        ; Handle of parent
			, "UInt", 0               ; Menu
			, "UInt", 0             ; hInstance, unneeded with User32 components
			, "UInt", 0)              ; User defined style
	If (ErrorLevel != 0 or ipaHwnd = 0)
	{
		msg = %msg% Cannot create IP Address control (%ErrorLevel%/%A_LastError%)
		Gosub IPAddress_CreateControl_CleanUp
		Return msg
	}

	Return ipaHwnd

IPAddress_CreateControl_CleanUp:	; In case of error
	; Nothing to do here
Return
}

; WM_USER := 0x400 ; 1024

/**
 * Set the IP address of this control.
 * It must be in format "192.168.0.1" (dotted form) or as a number.
 */
IPAddress_SetAddress(_ipaHwnd, _ipAddress)
{
	local binIPAddress

	If (_ipaHwnd = 0)
		Return
	If (RegExMatch(_ipAddress, "^(?:\d{1,3}\.){3}\d{1,3}$") = 1)
	{
		binIPAddress := 0
		Loop Parse, _ipAddress, .
		{
			binIPAddress |= A_LoopField << 8*(4 - A_Index)
		}
	}
	Else If _ipAddress is integer
		binIPAddress := _ipAddress
	Else
		Return	; Bad format

	; IPM_SETADDRESS := WM_USER + 101
	PostMessage 1125, 0, binIPAddress, , ahk_id %_ipaHwnd%
}

/**
 * Reset the control (blank the fields).
 */
IPAddress_ClearAddress(_ipaHwnd)
{
	; IPM_CLEARADDRESS := WM_USER + 100
	PostMessage 1124, 0, 0, , ahk_id %_ipaHwnd%
}

; GuiControlGet for this control
/**
 * Return the IP address from this control.
 * By default, it is in format "192.168.0.1" (dotted form)
 * but you can specify "i" or "integer" as second parameter to get the numerical value.
 * Returns an empty string in case of error.
 */
IPAddress_GetAddress(_ipaHwnd, _mode="")
{
	local binIPAddress, a

	If (_ipaHwnd = 0)
		Return

	binIPAddress = 0000 ; 4 bytes = DWORD
	; IPM_GETADDRESS := WM_USER + 102
	SendMessage 1126, 0, &binIPAddress, , ahk_id %_ipaHwnd%
	If ErrorLevel = FAIL
		Return
	a := &binIPAddress

	If (SubStr(_mode, 1, 1) = "i")	; Integer mode
		Return *a + (*(a + 1) << 8) +  (*(a + 2) << 16) + (*(a + 3) << 24)
	Else	; String mode
		Return *(a + 3) . "." . *(a + 2) . "." . *(a + 1) . "." . *a
}

; Probably optional, automatic on script close
IPAddress_DestroyControl(_ipaHwnd)
{
	If (_ipaHwnd != 0)
		DllCall("DestroyWindow", "UInt", _ipaHwnd)
}

; Run test code only if the file is ran standalone
If (A_ScriptName = "Control_IPAddress.ahk")
{

Gui +LastFound
guiID := WinExist()

width := 300

hipa := IPAddress_CreateControl(guiID, 10, 10, 150, 20)
If hipa is not integer
	MsgBox %hipa%

Gui Add, Button, x10 y200 w50 gControl_IPAddress_Show Default, OK
Gui Add, Button, x+20 w50 gControl_IPAddress_Exit, Cancel

Gui Show, w500, IP Address Demo

IPAddress_SetAddress(hipa, "192.168.0.11")
Return

Control_IPAddress_Exit:
GuiEscape:
ExitApp

Control_IPAddress_Show:
	MsgBox % IPAddress_GetAddress(hipa) . " (" . IPAddress_GetAddress(hipa, "Integer") . ")"
	IPAddress_ClearAddress(hipa)
Return
}
