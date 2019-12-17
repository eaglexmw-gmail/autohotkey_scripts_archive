DebugBIF()
;#NoTrayIcon
DetectHiddenWindows, On

MsgBox % TrayIcons()
Return

/*
WM_MOUSEMOVE	= 0x0200
WM_LBUTTONDOWN	= 0x0201
WM_LBUTTONUP	= 0x0202
WM_LBUTTONDBLCLK= 0x0203
WM_RBUTTONDOWN	= 0x0204
WM_RBUTTONUP	= 0x0205
WM_RBUTTONDBLCLK= 0x0206
WM_MBUTTONDOWN	= 0x0207
WM_MBUTTONUP	= 0x0208
WM_MBUTTONDBLCLK= 0x0209

PostMessage, nMsg, uID, WM_RBUTTONDOWN, , ahk_id %hWnd%
PostMessage, nMsg, uID, WM_RBUTTONUP  , , ahk_id %hWnd%
*/


TrayIcons(sExeName = "")
{
SetFormat, Integer, H
	WinGet,	pidTaskbar, PID, ahk_class Shell_TrayWnd
	hProc:=	DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", pidTaskbar)
;	if !pProc:=	DllCall("VirtualAllocEx", "Uint", hProc, "Uint", 0, "Uint", 32, "Uint", 0x1000|0x2000, "Uint", 0x4, "UInt")	; PAGE_READWRITE
	if !pProc := VirtualAllocEx(hProc, 0, 32, 0x1000, 0x4)
		msgbox, % "Error " DllCall("GetLastError")
	idxTB:=	GetTrayBar()
		SendMessage, 0x418, 0, 0, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_BUTTONCOUNT
	i := ErrorLevel
msgbox, pidTaskbar=%pidTaskbar% hProc=%hProc% pProc=%pProc% idxTB=%idxTB%
SetFormat, Integer, D
;	Loop,	%ErrorLevel%
	Loop,	%i%
	{
		SendMessage, 0x417, A_Index-1, pProc, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_GETBUTTON
		VarSetCapacity(btn,32,0), VarSetCapacity(nfo,32,0)
		DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pProc, "Uint", &btn, "Uint", 32, "Uint", 0)
			iBitmap	:= NumGet(btn, 0)
			idn	:= NumGet(btn, 4)
			Statyle := NumGet(btn, 8)
		If	dwData	:= NumGet(btn,12)
			iString	:= NumGet(btn,16)
		Else	dwData	:= NumGet(btn,16,"int64"), iString:=NumGet(btn,24,"int64")
		DllCall("ReadProcessMemory", "Uint", hProc, "Uint", dwData, "Uint", &nfo, "Uint", 32, "Uint", 0)
		If	NumGet(btn,12)
			hWnd	:= NumGet(nfo, 0)
		,	uID	:= NumGet(nfo, 4)
		,	nMsg	:= NumGet(nfo, 8)
		,	hIcon	:= NumGet(nfo,20)
		Else	hWnd	:= NumGet(nfo, 0,"int64"), uID:=NumGet(nfo, 8), nMsg:=NumGet(nfo,12)
		WinGet, pid, PID,              ahk_id %hWnd%
		WinGet, sProcess, ProcessName, ahk_id %hWnd%
		WinGetClass, sClass,           ahk_id %hWnd%
		If !sExeName || (sExeName = sProcess) || (sExeName = pid)
			VarSetCapacity(sTooltip,128), VarSetCapacity(wTooltip,128*2)
		,	DllCall("ReadProcessMemory", "Uint", hProc, "Uint", iString, "Uint", &wTooltip, "Uint", 128*2, "Uint", 0)
		,	DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "str", wTooltip, "int", -1, "str", sTooltip, "int", 128, "Uint", 0, "Uint", 0)
		,	sTrayIcons .= "idx: " . A_Index-1 . " | idn: " . idn . " | Pid: " . pid . " | uID: " . uID . " | MessageID: " . nMsg . " | hWnd: " . hWnd . " | Class: " . sClass . " | Process: " . sProcess . "`n" . "   | Tooltip: " . sTooltip . "`n"
	}
;	DllCall("VirtualFreeEx", "Uint", hProc, "Uint", pProc, "Uint", 0, "Uint", 0x8000)
	VirtualFreeEx(hProc, pProc, 0, 0x8000)
	DllCall("CloseHandle", "Uint", hProc)
	Return	sTrayIcons
}

RemoveTrayIcon(hWnd, uID, nMsg = 0, hIcon = 0, nRemove = 2)
{
	NumPut(VarSetCapacity(ni,444,0), ni)
	NumPut(hWnd , ni, 4)
	NumPut(uID  , ni, 8)
	NumPut(1|2|4, ni,12)
	NumPut(nMsg , ni,16)
	NumPut(hIcon, ni,20)
	Return	DllCall("shell32\Shell_NotifyIconA", "Uint", nRemove, "Uint", &ni)
}

HideTrayIcon(idn, bHide = True)
{
	idxTB := GetTrayBar()
	SendMessage, 0x404, idn, bHide, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_HIDEBUTTON
	SendMessage, 0x1A, 0, 0, , ahk_class Shell_TrayWnd
}

DeleteTrayIcon(idx)
{
	idxTB := GetTrayBar()
	SendMessage, 0x416, idx - 1, 0, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_DELETEBUTTON
	SendMessage, 0x1A, 0, 0, , ahk_class Shell_TrayWnd
}

MoveTrayIcon(idxOld, idxNew)
{
	idxTB := GetTrayBar()
	SendMessage, 0x452, idxOld - 1, idxNew - 1, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd ; TB_MOVEBUTTON
}

GetTrayBar()
{
	ControlGet, hParent, hWnd,, TrayNotifyWnd1  , ahk_class Shell_TrayWnd
	ControlGet, hChild , hWnd,, ToolbarWindow321, ahk_id %hParent%
	Loop
	{
		ControlGet, hWnd, hWnd,, ToolbarWindow32%A_Index%, ahk_class Shell_TrayWnd
		msgbox, hParent=%hParent% hChild=%hChild% hWnd %A_Index%=%hWnd%
		If  Not	hWnd
			Break
		Else If	hWnd = %hChild%
		{
			idxTB := A_Index
			Break
		}
	}
	Return	idxTB
}

; based on the 'Remote Library' article posted at CodeProject
; http://www.codeproject.com/KB/winsdk/Remote.aspx?display=Print
VirtualAllocEx(hProcess, lpAddress, dwSize, flAllocationType, flProtect)
{
return DllCall("VirtualAlloc", "UInt", lpAddress, "UInt", dwSize, "UInt", flAllocationType | 0x8000000, "UInt", flProtect, "UInt")
}

VirtualFreeEx(hProcess, lpAddress, dwSize, flFreeType)
{
return DllCall("VirtualFree", "UInt",  lpAddress, "UInt", dwSize, "UInt", flFreeType)
}
