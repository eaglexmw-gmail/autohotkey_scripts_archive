; Substitute for default tray icon routine in AHK
; Allows balloon tip in Win9x and separate click actions
; © Drugwash, April 2011-April 2012, v1.2
; file=icon index "|" file path
; par=LS LD RS RD MS MD + M/L (Left/Right/Middle button Single/Double click Menu/Label action), use delimiter '|'
TrayIcon(idx, hMain, file="", msg="", par="")
{
Static
ofi := A_FormatInteger
SetFormat, Integer, D
if file
	{
	StringSplit, i, file, |
	if A_IsCompiled
		{
		lib := DllCall("LoadLibrary", "Str", A_ScriptFullPath)
		hIcon := DllCall("LoadImageA", "UInt", lib, "Int", i1, "UInt", 1, "Int", 16, "Int", 16, "UInt", 0x20, "UInt")
		DllCall("FreeLibrary", "UInt", lib)
		}
	else
		hIcon := DllCall("LoadImageA", "UInt", 0, "Str", i2, "UInt", 1, "Int", 16, "Int", 16, "UInt", 0x10, "UInt")
	if !hIcon
		msgbox, Cannot load tray icon!
	}
else hIcon=
j := Abs(idx)
flg := 1*(msg<>"") + 2*(file<>"")
cbSize=88
VarSetCapacity(NID, cbSize, 0)	; NOTIFYICONDATA
NumPut(cbSize, NID, 0, "UInt")	; cbSize
NumPut(hMain, NID, 4, "UInt")	; hWnd
NumPut(j, NID, 8, "UInt")		; uID
NumPut(flg, NID, 12, "UInt")		; NIF_MESSAGE|NIF_ICON
NumPut(msg, NID, 16, "UInt")	; uCallbackMessage
NumPut(hIcon, NID, 20, "UInt")	; hIcon
if idx<0
	{
	OnMessage(_TrayIconBuf(j, "MSG", ""), "")
	_TrayIconBuf(j, "R", "")
	DllCall("shell32\Shell_NotifyIconA", "UInt", 2, "UInt", &NID)	; NIM_DELETE
	if hIcon
		DllCall("DestroyIcon", "UInt", hIcon)
	SetFormat, Integer, %ofi%
	return
	}
else if !_TrayIconBuf(j, "MSG", "")
	{
	_TrayIconBuf(j, "A", "MSG" msg "|" par)
	DllCall("shell32\Shell_NotifyIconA", "UInt", 0, "UInt", &NID)	; NIM_ADD
	}
else
	DllCall("shell32\Shell_NotifyIconA", "UInt", 1, "UInt", &NID)	; NIM_MODIFY
if hIcon
	DllCall("DestroyIcon", "UInt", hIcon)
OnMessage(msg, "_TrayIconAct")
SetFormat, Integer, %ofi%
}

TrayIconTip(idx, hMain, txt="", ttl="", col="", file="", args="")
{
Static
j := Abs(idx)
ControlGet, hTray, Hwnd,, TrayNotifyWnd1, ahk_class Shell_TrayWnd
if idx < 0
	{
	hwnd := _TrayIconBuf(j, "HWD", "")
	DllCall("SendMessage", "UInt", hwnd, "UInt", 0x401, "UInt", 0, "UInt", 0)			; TTM_ACTIVATE
	i%j%=
	return
	}
CoordMode, Mouse, Screen
MouseGetPos, mx, my
CoordMode, Mouse, Relative
par := "P$" mx "$" my i%j% " " col
par=%par%
if !i%j%
	i%j%=$N
hwnd := ShowBT(j, hTray "$" hMain, txt, ttl, par, file, args)
_TrayIconBuf(j, "A", "HWD" hwnd)
return hwnd
}
; ================ private functions ================
;===========================================
_TrayIconAct(wP, lP, msg, hwnd)
{
Static
Static v=1
ofi := A_FormatInteger
SetFormat, Integer, D
w := wP
c := DllCall("GetDoubleClickTime", "UInt")
SetFormat, Integer, H
lP += 0
SetFormat, Integer, %ofi%
if (lP=0x200 && v) OR lP=0x402 OR lP=0x406	; NIN_BALLOONSHOW NIN_POPUPOPEN
	{
	CoordMode, Mouse, Screen
	MouseGetPos, mx, my
	CoordMode, Mouse, Relative
	if my between 0 and 50
		{
		mx += 8
		my += 17
		}
	pos := (mx & 0xFFFF) | (my & 0xFFFF)<<16
	if (hwnd := _TrayIconBuf(w, "HWD"))
		{
		DllCall("SendMessage", "UInt", hwnd, "UInt", 0x412, "UInt", 0, "UInt", pos)	; TTM_TRACKPOSITION
		v=0
		SetTimer, pop, -3500
		}
ControlGet, hTray, Hwnd,, TrayNotifyWnd1, ahk_class Shell_TrayWnd
VarSetCapacity(TME, 16, 0)				; TRACKMOUSEEVENT struct
NumPut(16, TME, 0, "UInt")				; cbSize
NumPut(0x12, TME, 4, "UInt")			; dwFlags TME_LEAVE TME_NONCLIENT
NumPut(hTray, TME, 8, "UInt")			; hwndTrack
NumPut(0xFFFFFFFF, TME, 12, "UInt")		; dwHoverTime
DllCall("_TrackMouseEvent", "UInt", &TME)	; comctl32.dll
	}
else if lP in 0x201,0x203,0x204,0x206,0x207,0x209,0x2A2,0x2A3,0x403,0x404
	{
	ShowBT(w)
	if lP=0x201		; WM_LBUTTONDOWN
		{
		b=LS
		SetTimer, sc, -%c% 
		}
	else if lP=0x204	; WM_RBUTTONDOWN
		{
		b=RS
		SetTimer, sc, -%c% 
		}
	else if lP=0x207	; WM_MBUTTONDOWN
		{
		b=MS
		SetTimer, sc, -%c% 
		}
	else if lP=0x203	; WM_LBUTTONDBLCLK
		{
		SetTimer, sc, off
		b=LD
		goto sc
		}
	else if lP=0x206	; WM_RBUTTONDBLCLK
		{
		SetTimer, sc, off
		b=RD
		goto sc
		}
	else if lP=0x209	; WM_MBUTTONDBLCLK
		{
		SetTimer, sc, off
		b=MD
		goto sc
		}
	else if (lP=0x2A2 OR lP=0x2A3 OR lP=0x403 OR lP=0x404)	; NIN_BALLOONHIDE NIN_BALLOONTIMEOUT
		goto pop
	}
return

sc:
v=1
_TrayIconBuf(w, "L", b)
return

pop:
v=1
ShowBT(w)
return
}

_TrayIconBuf(idx, op="", par="")
{
Static
com=LSM,LSL,LDM,LDL,RSM,RSL,RDM,RDL,MSM,MSL,MDM,MDL,HWD,MSG
if op=A
	{
	Loop, Parse, par, |
		{
		StringLeft, pre, A_LoopField, 3
		StringTrimLeft, data, A_LoopField, 3
		%pre%%idx% := data
		}
	}
else if op=R
	{
	Loop, Parse, com, CSV
	%A_LoopField%%idx% := ""
	}
else if op=L
	{
	Transform, menu, Deref, %par%M%idx%
	Transform, label, Deref, %par%L%idx%
	if (act := %menu%)
		Menu, %act%, Show
	else if IsLabel(act := %label%)
		SetTimer, %act%, -1
	}
else if op in %com%
	return i := %op%%idx%
}
;===========================================
