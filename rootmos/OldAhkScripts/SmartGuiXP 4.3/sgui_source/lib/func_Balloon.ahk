; TTF_IDISHWND=0x1 TTF_CENTERTIP=0x2 TTF_RTLREADING=0x4 TTF_SUBCLASS=0x10 TTF_TRACK=0x20 TTF_ABSOLUTE=0x80 TTF_TRANSPARENT=0x100 TTF_PARSELINKS=0x1000 TTF_DI_SETITEM=0x8000
; TTS_ALWAYSTIP=0x1 TTS_NOPREFIX=0x2 TTS_NOANIMATE=0x10 TTS_NOFADE=0x20 TTS_BALLOON=0x40 TTS_CLOSE=0x80 TTS_USEVISUALSTYLE=0x100
; CLR_NONE=0xFFFFFFFF ILD_IMAGE=0x20 ILD_TRANSPARENT=0x1 ILD_BLEND=0x4
; create balloon tooltip

ShowBT(idx="1", h="0", txt="", ttl="", par="C$0x00AD22A2$0x00FFEEFF", file="", args="")
{
Static
ofi := A_FormatInteger
SetFormat, Integer, D
j := Abs(idx)
if !h
	{
	i := a%j%
	if idx>0
		WinHide, ahk_id %i%
	else if idx<0
		{
		WinClose, ahk_id %i%
		a%j%=
		}
	SetFormat, Integer, %ofi%
	return
	}
h=%h%
par=%par%
StringSplit, h, h, $	; h1=control handle, h2=owner handle
if !h2
	h2 := DllCall("GetParent", "UInt", h1)
if !a%idx%
	{
	if !hwnd := DllCall("CreateWindowEx"
					, "UInt", 0x8
					, "Str", "tooltips_class32"
					, "Str", ""
					, "UInt", 0x73	; TTS_BALLOON|TTS_NOFADE|TTS_NOANIMATE|TTS_NOPREFIX|TTS_ALWAYSTIP
					, "Int", 0x80000000
					, "Int", 0x80000000
					, "Int", 0x80000000
					, "Int", 0x80000000
					, "UInt", h2	; hOwner
					, "UInt", 0
					, "UInt", 0
					, "UInt", 0)
		msgbox, no balloon
	DllCall("SendMessage", "UInt", hwnd, "UInt", 0x418, "UInt", 0, "UInt", A_ScreenWidth)	; TTM_SETMAXTIPWIDTH
	DllCall("SendMessage", "UInt", hwnd, "UInt", 0x403, "UInt", 2, "UInt", 3500)	; TTDT_AUTOPOP
	DllCall("SendMessage", "UInt", hwnd, "UInt", 0x403, "UInt", 3, "UInt", 500)	; TTDT_INITIAL
	DllCall("SendMessage", "UInt", hwnd, "UInt", 0x403, "UInt", 1, "UInt", -1)		; TTDT_RESHOW
	}
if h1 is not integer
	ControlGet, h1, Hwnd,,%h1%, ahk_id %h2%
if file
	{
	if ttl is integer
		IniRead, ttl, %file%, Tooltip title, %ttl%, <tooltip title %ttl% missing in language file %file%>
	if txt is integer
		IniRead, txt, %file%, Tooltip body, %txt%, <tooltip body %txt% missing in language file %file%>
	i := ttl Chr(31) txt
	if args
		{
		Loop, Parse, args, |, %A_Space%
			StringReplace, i, i, `%s, %A_LoopField%
		}
	Transform, i, Deref, %i%
	StringSplit, i, i, % Chr(31)
	ttl := i1
	txt := i2
	}
sz := A_OSType="WIN32_NT" ? "48" : "44"
;sz=40
flags := 0x11 | 0x20*(InStr(par, "P$"))	; TTF_SUBCLASS|TTF_IDISHWND (|TTF_TRACK)
VarSetCapacity(TOOLINFO, sz, 0)
NumPut(sz, TOOLINFO, 0, "UInt")		; cbSize
NumPut(flags, TOOLINFO, 4, "UInt")	; uFlags
NumPut(h2, TOOLINFO, 8, "UInt")		; hOwner
NumPut(h1, TOOLINFO, 12, "UInt")	; uID
;NumPut(?, TOOLINFO, 16, "UInt")	; RECT
;NumPut(?, TOOLINFO, 32, "UInt")	; hinst
NumPut(&txt, TOOLINFO, 36, "UInt")
if !a%idx%
	{
	DllCall("SendMessage", "UInt", hwnd, "UInt", 0x409, "UInt", 0, "UInt", &TOOLINFO)	; TTM_SETTOOLINFOA
	VarSetCapacity(RECT,16)
	Loop, 4
		NumPut(1, RECT, 4*(A_Index-1), "UInt")
	DllCall("SendMessage", "UInt", hwnd, "UInt", 0x41A, "UInt", 0, "UInt", &RECT)		; TTM_SETMARGIN
	DllCall("SendMessage", "UInt", hwnd, "UInt", 0x404, "UInt", 0, "UInt", &TOOLINFO)	; TTM_ADDTOOLA
	}
else
	hwnd := a%idx%
if par
Loop, Parse, par, %A_Space%, %A_Space%
	{
	c4=
	StringSplit, c, A_LoopField, $
	if c1=C	; text and background color
		{
		DllCall("SendMessage", "UInt", hwnd, "UInt", 0x414, "UInt", c2, "UInt", 0)		; TTM_SETTIPTEXTCOLOR
		DllCall("SendMessage", "UInt", hwnd, "UInt", 0x413, "UInt", c3, "UInt", 0)		; TTM_SETTIPBKCOLOR
		}
	if c1=P	; tooltip position
		{
		pos := (c2 & 0xFFFF)|((c3 & 0xFFFF)<<16)
		DllCall("SendMessage", "UInt", hwnd, "UInt", 0x411, "UInt", 1, "UInt", &TOOLINFO)	; TTM_TRACKACTIVATE
		if !c4
			DllCall("SendMessage", "UInt", hwnd, "UInt", 0x412, "UInt", 0, "UInt", pos)	; TTM_TRACKPOSITION
		}
	}
if ttl
	{
	StringLeft, icon, ttl, InStr(ttl, "$")-1
	StringTrimLeft, ttl, ttl, InStr(ttl, "$")
	DllCall("SendMessage", "UInt", hwnd, "UInt", 0x420, "UInt", icon, "UInt", &ttl)		; TTM_SETTITLEA
	}
if !a%idx%
	a%idx% := hwnd
if (pos="")
	DllCall("SendMessage", "UInt", hwnd, "UInt", 0x401, "UInt", 1, "UInt", 0)			; TTM_ACTIVATE
if txt
	DllCall("SendMessage", "UInt", hwnd, "UInt", 0x40C, "UInt", 0, "UInt", &TOOLINFO)		; TTM_UPDATETIPTEXTA
SetFormat, Integer, %ofi%
return hwnd
}

TrackBT(hwnd, sw="1")
{
sw := sw ? TRUE : FALSE
DllCall("SendMessage", "UInt", hwnd, "UInt", 0x401, "UInt", sw, "UInt", 0)	; TTM_ACTIVATE disabled
}
