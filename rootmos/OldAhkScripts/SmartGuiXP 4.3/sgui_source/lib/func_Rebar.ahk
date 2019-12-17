; RBS_TOOLTIPS=0x100 RBS_VARHEIGHT=0x200 RBS_BANDBORDERS=0x400 RBS_FIXEDORDER=0x800
; RBS_REGISTERDROP=0x1000 RBS_AUTOSIZE=0x2000 RBS_VERTICALGRIPPER=0x4000 RBS_DBLCLKTOGGLE=0x8000

; CCS_TOP=0x1 CCS_NOMOVEY=0x2 CCS_BOTTOM=0x3 CCS_NORESIZE=0x4 CCS_NOPARENTALIGN=0x8 CCS_ADJUSTABLE=0x20 CCS_NODIVIDER=0x40 CCS_VERT=0x80
; CCS_LEFT=CCS_VERT|CCS_TOP CCS_NOMOVEX=CCS_VERT|CCS_NOMOVEY CCS_RIGHT=CCS_VERT|CCS_BOTTOM

RB_Create(g="1", p="pT s0x2740", hIL="0")
{
Static init=0, idx=1, pos="TBLR", ps="0x1|0x3|0x81|0x83"
if !init
	{
	sz=8
	VarSetCapacity(icex, sz, 0)	; INITCOMMONCONTROLSEX
	NumPut(sz, icex, 0, "UInt")
	NumPut(0x400, icex, 4, "UInt")	; ICC_COOL_CLASSES
	if !init := DllCall("comctl32\InitCommonControlsEx", "UInt", &icex)
		{
		msgbox, Error in %A_ThisFunc%():`nCannot initiate Common Controls.
		Return 0
		}
	}
if !(hGUI := GetHwnd(g))
	{
	msgbox, Error in %A_ThisFunc%():`nInvalid GUI count/handle: %g%.
	Return 0
	}
style=0x50000000
Loop, Parse, p, %A_Space%, %A_Space%%A_Tab%
	{
	StringLeft, p1, A_LoopField, 1
	StringTrimLeft, p2, A_LoopField, 1
	if p1=s
		style |= p2
	if p1=p
		Loop, Parse, ps, |
			if (A_Index=InStr(pos, p2))
				style |= A_LoopField
	}
;style=0x56006760
if !hwnd := DllCall("CreateWindowEx"
;		, "UInt", 0x80	; WS_EX_TOOLWINDOW (WS_EX_TRANSPARENT=0x20, WS_EX_TOPMOST=0x8)
		, "UInt", 0x0
		, "Str", "ReBarWindow32"
		, "Str", ""
		, "UInt", style	; WS_CHILD WS_VISIBLE WS_CLIPSIBLINGS WS_CLIPCHILDREN RBS_BANDBORDERS RBS_VARHEIGHT RBS_TOOLTIPS CCS_NODIVIDER
		, "Int", 0
		, "Int", 0
		, "UInt", 0
		, "UInt", 0
		, "UInt", hGUI	; hWndParent
		, "UInt", 0		; hMenu
		, "UInt", 0		; hInstance
		, "UInt", 0)		; lpParam
	{
;	ErrorLevel := DllCall("GetLastError")
	msgbox, % A_ThisFunc "() failed with error " DllCall("GetLastError")
	Return 0
	}
sz=12
VarSetCapacity(rbi, sz, 0)	; REBARINFO
NumPut(sz, rbi, 0, "UInt")
NumPut(hIL ? "1" : "0", rbi, 4, "UInt")	; only RBIM_IMAGELIST (0x1) is valid
NumPut(hIL, rbi, 8, "UInt")
if !DllCall("SendMessage", "UInt", hwnd, "UInt", 0x404, "UInt", 0, "UInt", &rbi)	; RB_SETBARINFO
	{
	msgbox, % A_ThisFunc "() failed in RB_SETBARINFO."
	Return 0
	}
idx++
Return hwnd
}
;===========================================
; RBBS_BREAK=0x1 RBBS_FIXEDSIZE=0x2 RBBS_CHILDEDGE=0x4 RBBS_HIDDEN=0x8 RBBS_NOVERT=0x10 RBBS_FIXEDBMP=0x20 RBBS_VARIABLEHEIGHT=0x40 
; RBBS_GRIPPERALWAYS=0x80 RBBS_NOGRIPPER=0x100 RBBS_USECHEVRON=0x200 RBBS_HIDETITLE=0x400 RBBS_TOPALIGN=0x800

; RBBIM_STYLE=0x1 RBBIM_COLORS=0x2 RBBIM_TEXT=0x4 RBBIM_IMAGE=0x8 RBBIM_CHILD=0x10 RBBIM_CHILDSIZE=0x20
; RBBIM_SIZE=0x40 RBBIM_BACKGROUND=0x80 RBBIM_ID=0x100 RBBIM_IDEALSIZE=0x200 RBBIM_LPARAM=0x400 RBBIM_HEADERSIZE=0x800

RB_Add(hRB, hCW, txt="", sb="", pos="0", cx="", tbbh="", fStyle="0x4C1", hs="")	; provide bitmap handle through 'sb'
{
Static idx=0
IEver=4	; assume IE version > 3
sz := 4*(14+(IEver>3)*6+(A_OSVersion="WIN_VISTA")*5)
VarSetCapacity(rbbi, sz, 0)	; REBARBANDINFO
; RBBIM_COLORS RBBIM_TEXT RBBIM_BACKGROUND RBBIM_STYLE RBBIM_CHILD RBBIM_CHILDSIZE RBBIM_SIZE RBBIM_ID RBBIM_IDEALSIZE
;fMask := 0x1|0x2|0x4|0x10|0x200|0x40|(sb ? 0x80 : 0)|0x100|(fStyle & 0x40 ? 0 : 0x20)|(hs ? 0x800: 0)
fMask := 0x1|0x2|0x4|0x10|0x200|0x40|(sb ? 0x80 : 0)|0x100|0x20|(hs ? 0x800: 0)
;fStyle := 0x1|0x40|0x80|0x400 ; RBBS_BREAK RBBS_CHILDEDGE RBBS_VARIABLEHEIGHT RBBS_GRIPPERALWAYS RBBS_HIDETITLE
ControlGetPos,,, w, h,, ahk_id %hCW%
cx := cx ? cx : (w ? w+4 : "200")
cyMinChild := tbbh ? tbbh+1 : (h ? h+2 : "22")
NumPut(sz, rbbi, 0, "UInt")
NumPut(fMask, rbbi, 4, "UInt")
NumPut(fStyle, rbbi, 8, "UInt")
NumPut(&txt, rbbi, 20, "UInt")		; lpText
NumPut(hCW, rbbi, 32, "UInt")		; hwndChild
NumPut(cx, rbbi, 36, "UInt")			; cxMinChild
NumPut(cyMinChild, rbbi, 40, "UInt")	; cyMinChild
NumPut(cx, rbbi, 44, "UInt")			; cx
NumPut(sb, rbbi, 48, "UInt")
NumPut(idx, rbbi, 52, "UInt")		; wID
NumPut(cyMinChild, rbbi, 56, "UInt")	; cyChild
;NumPut(tbbh, rbbi, 60, "UInt")		; cyMaxChild
NumPut(5*cyMinChild, rbbi, 60, "UInt")	; cyMaxChild
NumPut(cyMinChild, rbbi, 64, "UInt")	; cyIntegral
NumPut(cx, rbbi, 68, "UInt")			; cxIdeal
NumPut(hs, rbbi, 76, "UInt")			; cxHeader
if !DllCall("SendMessage", "UInt", hRB, "UInt", 0x401, "UInt", pos-1, "UInt", &rbbi)	; RB_INSERTBANDA
	{
	msgbox, % A_ThisFunc "() failed in RB_INSERTBANDA."
	Return 0
	}
idx++
Return NumGet(rbbi, 52, "UInt")+1
}
;===========================================
RB_SizeBand(hRB, idx="1", d="1", i="0")
{
DllCall("SendMessage", "UInt", hRB, "UInt", 0x41E + d, "UInt", idx-1, "UInt", (d ? i : "0"))	; RB_MAXIMIZEBAND/RB_MINIMIZEBAND
}
;===========================================
RB_Size(hRB, nw="", nh="")
{
;WinGetPos, x, y, w, h, % "ahk_id " DllCall("GetAncestor", "UInt", hRB, "UInt", 1)	; GA_PARENT
WinGetPos, x, y, w, h, % "ahk_id " DllCall("GetParent", "UInt", hRB)
VarSetCapacity(RC, 16, 0)
NumPut(0, RC, 0, "Int")
NumPut(0, RC, 4, "Int")
;NumPut(nw ? nw: w, RC, 8, "Int")
;NumPut(nh ? nh : h, RC, 12, "Int")
NumPut(nw ? nw: 0, RC, 8, "Int")
NumPut(nh ? nh : 0, RC, 12, "Int")
return DllCall("SendMessage", "UInt", hRB, "UInt", 0x417, "UInt", 0, "UInt", &RC)	; RB_SIZETORECT
}
;===========================================
RB_Show(hRB, idx="1", s="1")
{
return DllCall("SendMessage", "UInt", hRB, "UInt", 0x423, "UInt", idx-1, "UInt", (s ? "1" : "0"))	; RB_SHOWBAND
}
;===========================================
RB_Set(hRB, idx, p)
{
Static hBmp, band
band := idx
IEver=4
sz := 4*(14+(IEver>3)*6+(A_OSVersion="WIN_VISTA")*5)
VarSetCapacity(rbbi, sz, 0)	; REBARBANDINFO
NumPut(sz, rbbi, 0, "UInt")
fMask=0
Loop, Parse, p, %A_Space%, %A_Space%%A_Tab%
	{
	StringLeft, i, A_LoopField, 2
	StringTrimLeft, c, A_LoopField, 2
	if i=ic	; ic[height]|[integral]|[min]|[max]
		{
		fMask |= 0x20	; RBBIM_CHILDSIZE
		StringSplit, h, c, |
		cyChild := ++h1
		NumPut(h3 ? h3 : cyChild, rbbi, 40, "UInt")		; cyMinChild
		NumPut(cyChild, rbbi, 56, "UInt")		; cyChild
		NumPut(h4 ? h4 : 5*cyChild, rbbi, 60, "UInt")		; cyMaxChild
		NumPut(h2 ? h2 : cyChild, rbbi, 64, "UInt")		; cyIntegral
		}
	else if i=st
		{
		fMask |= 0x1			; RBBIM_STYLE
		NumPut(c, rbbi, 8, "UInt")	; fStyle
		}
	else if i=ch
		{
		fMask |= 0x10			;  RBBIM_CHILD
		NumPut(c, rbbi, 32, "UInt")	; hwndChild
		}
	else if i=bk
		{
		fMask |= 0x80			;  RBBIM_BACKGROUND
		NumPut(c, rbbi, 48, "UInt")	; hbmBack
		}
	}
NumPut(fMask, rbbi, 4, "UInt")
if !DllCall("SendMessage", "UInt", hRB, "UInt", 0x406, "UInt", idx-1, "UInt", &rbbi)	; RB_SETBANDINFO
	msgbox, Error in %A_ThisFunc%() : RB_SETBANDINFO
}
;===========================================
RB_Get(hRB, p)
{
Static
StringLeft, c, p, 1
StringTrimLeft, v, p, 1
if c=h
	return DllCall("SendMessage", "UInt", hRB, "UInt", 0x41B, "UInt", 0, "UInt", 0)	; RB_GETBARHEIGHT
if c=r
	{
	VarSetCapacity(RC, 16, 0)
	DllCall("SendMessage", "UInt", hRB, "UInt", 0x409, "UInt", v-1, "UInt", &RC)	; RB_GETRECT, zero-based band index
	return &RC
	}
}

#include func_GetHwnd.ahk
