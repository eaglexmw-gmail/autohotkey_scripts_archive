; *TBSTYLE_SEP=0x1 *TBSTYLE_CHECK=0x2 *TBSTYLE_GROUP=0x4 *TBSTYLE_DROPDOWN=0x8 *TBSTYLE_AUTOSIZE=0x10
; *TBSTYLE_NOPREFIX=0x20 *BTNS_SHOWTEXT=0x40 *BTNS_WHOLEDROPDOWN=0x80 TBSTYLE_TOOLTIPS=0x100 TBSTYLE_WRAPABLE=0x200 TBSTYLE_ALTDRAG=0x400
; TBSTYLE_FLAT=0x800 TBSTYLE_LIST=0x1000 TBSTYLE_CUSTOMERASE=0x2000 TBSTYLE_REGISTERDROP=0x4000 TBSTYLE_TRANSPARENT=0x8000
; TBSTYLE_EX_DRAWDDARROWS=0x1 TBSTYLE_EX_MIXEDBUTTONS=0x8 TBSTYLE_EX_HIDECLIPPEDBUTTONS=0x10 TBSTYLE_EX_DOUBLEBUFFER=0x80
; CCS_TOP=0x1 CCS_NOMOVEY=0x2 CCS_BOTTOM=0x3 CCS_NORESIZE=0x4 CCS_NOPARENTALIGN=0x8 CCS_ADJUSTABLE=0x20 CCS_NODIVIDER=0x40 CCS_VERT=0x80
; CCS_LEFT=CCS_VERT|CCS_TOP CCS_NOMOVEX=CCS_VERT|CCS_NOMOVEY CCS_RIGHT=CCS_VERT|CCS_BOTTOM
;===========================================
TB_Create(g="1", c="0|0|0|0", style="0x9B15", exstyle="0x89")
{
Static idx=1
cs = xywh
StringSplit, c, c, |
Loop, Parse, cs
	%A_LoopField% := c%A_Index% ? c%A_Index% : "0"
; get window handle
if !(hGUI := GetHwnd(g))
	{
	msgbox, Error in %A_ThisFunc%():`nInvalid GUI count/handle: %g%.
	Return 0
	}
if !hwnd := DllCall("CreateWindowEx"
		, "UInt", 0
		, "Str", "ToolbarWindow32"
		, "Str", ""
		, "UInt", 0x5400880E	; WS_CHILD WS_VISIBLE WS_CLIPSIBLINGS WS_CLIPCHILDREN
		, "Int", x
		, "Int", y
		, "UInt", w
		, "UInt", h
		, "UInt", hGUI		; hWndParent
		, "UInt", 0		; hMenu
		, "UInt", 0		; hInstance
		, "UInt", 0)		; lpParam
	{
;	ErrorLevel := DllCall("GetLastError")
	msgbox, % A_ThisFunc "() failed with error " DllCall("GetLastError")
	Return 0
	}
idx++
; for WIN64 sz=24, else 20
sz=20
DllCall("SendMessage", "UInt", hwnd, "UInt", 0x41E, "UInt", sz, "UInt", 0)		; TB_BUTTONSTRUCTSIZE
DllCall("SendMessage", "UInt", hwnd, "UInt", 0x438, "UInt", 0, "UInt", style)	; TB_SETSTYLE
DllCall("SendMessage", "UInt", hwnd, "UInt", 0x454, "UInt", 0, "UInt", exstyle)	; TB_SETEXTENDEDSTYLE
Return hwnd
}
;===========================================
; TBSTATE_CHECKED=0x1 TBSTATE_ELLIPSES=0x40 TBSTATE_ENABLED=0x4 TBSTATE_HIDDEN=0x8
; TBSTATE_INDETERMINATE=0x10 TBSTATE_MARKED=0x80 TBSTATE_PRESSED=0x2 TBSTATE_WRAP=0x20
TB_AddBtn(hwnd, txt, cmd, stt, stl, idx, dat="0")
{
; for WIN64 sz=24, else 20
sz=20
VarSetCapacity(TBBUTTON, sz, 0)	; struct size
NumPut(idx, TBBUTTON, 0, "UInt")	; iBitmap
NumPut(cmd, TBBUTTON, 4, "UInt")	; idCommand
NumPut(stt, TBBUTTON, 8, "UChar")	; fsState
NumPut(stl, TBBUTTON, 9, "UChar")	; fsStyle
NumPut(dat, TBBUTTON, 12, "UInt")	; dwData
NumPut(&txt, TBBUTTON, 16, "UInt")	; iString
if !DllCall("SendMessage", "UInt", hwnd, "UInt", 0x414, "UInt", 1, "UInt", &TBBUTTON)	; TB_ADDBUTTONS
;	ErrorLevel := DllCall("GetLastError")
	msgbox, % A_ThisFunc "() failed with error " DllCall("GetLastError")
return (DllCall("SendMessage", "UInt", hwnd, "UInt", 0x43A, "UInt", 0,  "UInt", 0) >> 16) & 0xFFFF	; TB_GETBUTTONSIZE
}
;===========================================
TB_SetIL(hwnd, p, i="0")	; [x] list type [xx...x|] list number (only where required) [xx...x] handle
{
r=
ofi := A_FormatInteger
SetFormat, Integer, Hex
Loop, Parse, p, %A_Space%, %A_Space%%A_Tab%
	{
	StringLeft, p1, A_LoopField, 1
	StringTrimLeft, p2, A_LoopField, 1
	if p1=D
		r .= ",D" DllCall("SendMessage", "UInt", hwnd, "UInt", 0x436, "UInt", 0,  "UInt", p2)	; TB_SETDISABLEDIMAGELIST
	if p1=H
		r .= ",H" DllCall("SendMessage", "UInt", hwnd, "UInt", 0x434, "UInt", 0,  "UInt", p2)	; TB_SETHOTIMAGELIST
	if p1=P
		{
		v := i ? DllCall("SendMessage", "UInt", hwnd, "UInt", 0x2007, "UInt", i, "UInt", 0) : 0	; CCM_SETVERSION
		StringSplit, m, p2, |
		r .= ",P" DllCall("SendMessage", "UInt", hwnd, "UInt", 0x437, "UInt", m1,  "UInt", m2)	; TB_SETPRESSEDIMAGELIST* (Vista+)
		}
	if p1=I
		{
		v := i ? DllCall("SendMessage", "UInt", hwnd, "UInt", 0x2007, "UInt", i, "UInt", 0) : 0	; CCM_SETVERSION
		StringSplit, m, p2, |
		r .= ",I" DllCall("SendMessage", "UInt", hwnd, "UInt", 0x430, "UInt", m1,  "UInt", m2)	; TB_SETIMAGELIST
		}
	}
SetFormat, Integer, %ofi%
return v r
}
; TB_SETPRESSEDIMAGELIST message value is not accurate as I have no access to Vista SDK; will update when possible
;===========================================
TB_Size(hwnd)
{
DllCall("SendMessage", "UInt", hwnd, "UInt", 0x421, "UInt", 0,  "UInt", 0)	; TB_AUTOSIZE
}
;===========================================
TB_Get(hwnd, p)	; sWHS=toolbar metrics, bWHRS=button metrics dd=padding
{
StringSplit, p, p
if p1=s
	{
	VarSetCapacity(SIZE, 8, 0)
	if !DllCall("SendMessage", "UInt", hwnd, "UInt", 0x453, "UInt", 0, "UInt", &SIZE)	; TB_GETMAXSIZE
		return 0
	w := NumGet(SIZE, 0, "UInt")
	h := NumGet(SIZE, 4, "UInt")
	return r := (p2="W" ? w : (p2="H" ? h : (p2="S" ? w | h<<16 : 0)))
	}
if p1=b
	{
	r := DllCall("SendMessage", "UInt", hwnd, "UInt", 0x428, "UInt", 0,  "UInt", 0)		; TB_GETROWS
	s := DllCall("SendMessage", "UInt", hwnd, "UInt", 0x43A, "UInt", 0,  "UInt", 0)	; TB_GETBUTTONSIZE
	w := s & 0xFFFF
	h := (s >> 16) & 0xFFFF
	return r := (p2="W" ? w : (p2="H" ? h : (p2="R" ? r : (p2="S" ? s : 0))))
	}
if p1=d
	{
	return DllCall("SendMessage", "UInt", hwnd, "UInt", 0x456, "UInt", 0, "UInt", 0)	; TB_GETPADDING
	}
}
;===========================================
TB_Set(hwnd, p)
{
Loop, Parse, p, %A_Space%, %A_Space%%A_Tab%
	{
	StringLeft, p1, A_LoopField, 1
	StringTrimLeft, p2, A_LoopField, 1
	if p1=s
		DllCall("SendMessage", "UInt", hwnd, "UInt", 0x438, "UInt", 0, "UInt", p2)	; TB_SETSTYLE
	if p1=e
		DllCall("SendMessage", "UInt", hwnd, "UInt", 0x454, "UInt", 0, "UInt", p2)	; TB_SETEXTENDEDSTYLE
	if p1=b
		DllCall("SendMessage", "UInt", hwnd, "UInt", 0x41F, "UInt", 0, "UInt", p2)	; TB_SETBUTTONSIZE
	if p1=d
		DllCall("SendMessage", "UInt", hwnd, "UInt", 0x457, "UInt", 0, "UInt", p2)	; TB_SETPADDING
	}
}
;===========================================
TB_BtnSet(hwnd, idx, p)
{
dwMask=0
sz := A_OSVersion=WIN_VISTA ? 36 : 32
VarSetCapacity(TBBI, sz, 0)
NumPut(sz, TBBI, 0, "UInt")
Loop, Parse, p, |, %A_Space%
	{
	StringLeft, p1, A_LoopField, 1
	StringTrimLeft, p2, A_LoopField, 1
	if p1=c	; idCommand
		{
		dwMask |= 0x20	; TBIF_COMMAND
		NumPut(p2+0, TBBI, 8, "Int")
		}
	if p1=i	; iImage
		{
		dwMask |= 0x1	; TBIF_IMAGE
		NumPut(p2+0, TBBI, 12, "Int")
		}
	if p1=s	; fsState
		{
		dwMask |= 0x4	; TBIF_STATE
		NumPut(p2+0, TBBI, 16, "UChar")
		}
	if p1=y	; fsStyle
		{
		dwMask |= 0x8	; TBIF_STYLE
		NumPut(p2+0, TBBI, 17, "UChar")
		}
	if p1=w	; cx
		{
		dwMask |= 0x40	; TBIF_SIZE
		NumPut(p2+0, TBBI, 18, "UShort")
		}
	if p1=p	; lParam
		{
		dwMask |= 0x10	; TBIF_LPARAM
		NumPut(p2+0, TBBI, 20, "UInt")
		}
	if p1=t	; pszText
		{
		dwMask |= 0x2	; TBIF_TEXT
		NumPut(&p2, TBBI, 24, "UInt")
		}
	if p1=l	; iImageLabel
		{
		dwMask |= 0x80	; TBIF_IMAGELABEL (guessed!!!)
		NumPut(p2+0, TBBI, 32, "Int")
		}
	}
NumPut(dwMask, TBBI, 4, "UInt")
if !DllCall("SendMessage", "UInt", hwnd, "UInt", 0x442, "UInt", idx, "UInt", &TBBI)	; TB_SETBUTTONINFO
	msgbox, Error in %A_ThisFunc%() -> TB_SETBUTTONINFO
}
;===========================================
TB_BtnState(hwnd, idx, p)	; e=enabled c=checked p=pressed h=hidden i=indeterminate l=highlighted
{
c=ecphil9ABCDE
v := "0x" SubStr(c, InStr(c, p)+6, 1)
return DllCall("SendMessage", "UInt", hwnd, "UInt", 0x400+v, "UInt", idx, "UInt", 0)	; TB_ISBUTTON []
}
#include func_GetHwnd.ahk

