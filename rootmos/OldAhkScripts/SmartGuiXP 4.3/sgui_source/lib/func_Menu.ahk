; t=type (bar/popup) b=break at x lines
; returns handle to menu
MenuCreate(t="", b="")
{
h := DllCall("Create" (t ? "" : "Popup") "Menu")
if b
	_MenuStack(h, "B" b)
return h
}
;###################################
; type=bmp (use 'name' as handle to the bitmap image)
; type=sub (use 'label' as handle to the submenu)
; type=own (use 'name' as value to pass to WM_MEASUREITEM and WM_DRAWITEM in itemData)
; type=sep (name and label are ignored)
MenuAdd(hMenu, name="", label="", type="sep", pos="")
{
flags := 0x4*(type="bmp") + 0x100*(type="own") + 0x800*(type="sep") + 0x10*(type="sub") + 0
if type != sep
	{
	_MenuStack(hMenu, "P")
	_MenuStack(hMenu, "L" label)
	}
idx := _MenuStack(hMenu, "", "P")
if br := _MenuStack(hMenu, "", "B")
	if (idx-br*Floor(idx/br)="1" && idx>br)
		flags += 0x20
if !pos
	{
	if type=str
		DllCall("AppendMenu", "UInt", hMenu, "UInt", flags, "UInt", idx, "Str", name)
	if type=bmp
		DllCall("AppendMenu", "UInt", hMenu, "UInt", flags, "UInt", idx, "UInt", name)
	if type=sub
		DllCall("AppendMenu", "UInt", hMenu, "UInt", flags, "UInt", idx, "UInt", label)
	if type=own
		DllCall("AppendMenu", "UInt", hMenu, "UInt", flags, "UInt", idx, "UInt", name)
	if type=sep
		DllCall("AppendMenu", "UInt", hMenu, "UInt", flags, "UInt", 0, "UInt", 0)
	}
return idx
}
;###################################
MenuCount(h)
{
return DllCall("GetMenuItemCount", "UInt", h)
}
;###################################
MenuHmenu(h)
{
return DllCall("GetMenu", "UInt", h, "UInt")
}
;###################################
MenuHsub(h, i)
{
return DllCall("GetSubMenu", "UInt", h, "UInt", i-1, "UInt")	; zero-based index
}
;###################################
MenuShow(h)
{
Global A_ThisMenuItem2
WinGet, hMain, ID, A
CoordMode, Mouse, Screen
MouseGetPos, mx, my
uFlags := 0x2 | 0x40 | 0x100 | 0x1000	; TPM_VERTICAL|TPM_TOPALIGN|TPM_LEFTALIGN|TPM_LEFTBUTTON|TPM_RIGHTBUTTON|TPM_RETURNCMD|TPM_VERPOSANIMATION
curItem := DllCall("TrackPopupMenuEx", "UInt", h, "UInt", uFlags, "Int", mx, "Int", my, "UInt", hMain, "UInt", 0)
VarSetCapacity(selItem, 256, 0)
DllCall("GetMenuString", "UInt", h, "UInt", curItem, "UInt", &selItem, "UInt", 255, "UInt", 0)
VarSetCapacity(selItem, -1)
CoordMode, Mouse, Relative
A_ThisMenuItem2 := selItem
if i := _MenuStack(h, "", "L", curItem)
	SetTimer, %i%, -1
;return selItem
return curItem
}
;###################################
MenuCheckEx(h, i, r="", e="")
{
Static
p := e ? 0x0 : 0x1				; MF_BYCOMMAND/MF_BYPOSITION
s := r ? 0x8 : 0x0
VarSetCapacity(MII, 48, 0)
NumPut(48, MII, 0, "UInt")
NumPut(0x101, MII, 4, "UInt")	; MIIM_FTYPE|MIIM_STATE
NumPut(0x200, MII, 8, "UInt")	; MFT_RADIOCHECK
NumPut(s, MII, 12, "UInt")		; MFS_CHECKED
DllCall("SetMenuItemInfo", "UInt", h, "UInt", i-1, "UInt", p, "UInt", &MII)
h0 := h, i0 := i
}
;###################################
; r=(1-check, 0-uncheck, 2-toggle)
MenuCheck(h, i, r="1", e="")
{
p := e ? 0x400 : 0x0	; MF_BYCOMMAND/MF_BYPOSITION
p += 0x8*(r="1")
if !DllCall("CheckMenuItem", "UInt", h, "UInt", i-1, "UInt", p)
	DllCall("CheckMenuItem", "UInt", h, "UInt", i-1, "UInt", p+0x8)
}
;###################################
MenuRight(h, i, e="")
{
p := e ? 0x0 : 0x1				; MF_BYCOMMAND/MF_BYPOSITION
VarSetCapacity(MII, 48, 0)
NumPut(48, MII, 0, "UInt")
NumPut(0x100, MII, 4, "UInt")	; MIIM_FTYPE
NumPut(0x4000, MII, 8, "UInt")	; MFT_RIGHTJUSTIFY
DllCall("SetMenuItemInfo", "UInt", h, "UInt", i-1, "UInt", p, "UInt", &MII)
}
;###################################
MenuSkin(hMenu="", file="", sbm="1")
{
Static hBr
;SysGet, ms, 55	; SM_CYMENUSIZE
if file is integer
	hB := file	; assume 'file' is a bitmap handle
else IfNotExist, %file%
	{
	if (!hMenu && hBr)
		DllCall("DeleteObject", "UInt", hBr)
	return
	}
else hB := DllCall("LoadImage", "UInt", 0, "Str", file, "UInt", 0, "UInt", 0, "UInt", 17, "UInt", 0x2010)	; LR_CREATEDIBSECTION LR_LOADFROMFILE
hBr := DllCall("CreatePatternBrush", "UInt", hB)
if (hB != file)	; don't delete handle if passed as parameter
	DllCall("DeleteObject", "UInt", hB)
VarSetCapacity(MI, 28, 0)				; MENUINFO struct
NumPut(28, MI, 0, "UInt")				; cbSize
NumPut(sbm ? 0x80000002 : 0x2, MI, 4, "UInt")		; fMask, MIM_APPLYTOSUBMENUS? MIM_BACKGROUND
NumPut(hBr, MI, 16, "UInt")				; hbrBack
DllCall("SetMenuInfo", "UInt", hMenu, "UInt", &MI)
return hBr	; requires cleanup on exit !
}
;###################################
; uID=item index type=0-checkmark/1-bitmap, call with no params to delete bitmap and brush on exit
; PATINVERT=0x5A0049 PATCOPY=0xF00021 DSTINVERT=0x550009 WHITENESS=0xFF0062 BLACKNESS=0x42
MenuBitmap(hMenu="", i="1", color="0", type="0")
{
Static
Static x=0
if (x && !hMenu)
	{
	Loop, %x%
		DllCall("DeleteObject", "UInt", hBM%A_Index%)
	return
	}
SysGet, w, 71	; SM_CXMENUCHECK
SysGet, h, 72	; SM_CXMENUCHECK
if (!w OR !h)
	return, ErrorLevel=1
hDC := DllCall("GetDC", UInt, 0)
hDCB := DllCall("CreateCompatibleDC", "UInt", hDC)
hBM%x% := DllCall("CreateCompatibleBitmap", "UInt", hDC, "Int", w-3, "Int", h)
hBMold := DllCall("SelectObject", "UInt", hDCB, "UInt", hBM%x%)
hBr := DllCall("CreateSolidBrush", "UInt", color)
DllCall("SelectObject", "UInt", hDCB, "UInt", hBr)
DllCall("PatBlt", "UInt", hDCB, "Int", 0, "Int", 0, "Int", w-3, "Int", h, "UInt", 0xF00021)	; PATCOPY
DllCall("SelectObject", "UInt", hDCB, "UInt", hBMold)
DllCall("DeleteObject", "UInt", hBr)
DllCall("DeleteDC", "UInt", hDCB)
DllCall("ReleaseDC", "UInt", 0, "UInt", hDC)
if !type
	{
	DllCall("SetMenuItemBitmaps", "UInt", hMenu, "UInt", i-1, "UInt", 0x400, "UInt", hBM%x%, "UInt", 0)	; MF_BYPOSITION
	return hBM%x%
	}
VarSetCapacity(MI, 28, 0)			; MENUINFO struct
NumPut(28, MI, 0, "UInt")			; cbSize
NumPut(0x10, MI, 4, "UInt")			; fMask, MIM_STYLE
NumPut(0x4000000, MI, 8, "UInt")		; MNS_CHECKORBMP
DllCall("SetMenuInfo", "UInt", hMenu, "UInt", &MI)	; Win98+
VarSetCapacity(MII, 48, 0)			; MENUITEMINFO struct
NumPut(48, MII, 0, "UInt")			; cbSize
NumPut(0x80, MII, 4, "UInt")			; fMask, MIIM_BITMAP/+MIIM_TYPE
NumPut(hBM%x%, MII, 44, "UInt")		; hbmpItem
DllCall("SetMenuItemInfo", "UInt", hMenu, "UInt", i-1, "UInt", 1, "UInt", &MII)	; ByPosition
return hBM%x%
}
;###################################
; To be completed with disable/enable routines and whatever else missing
;********** INTERNAL FUNCTIONS **********
_MenuStack(h, p="", g="", i="")
{
Static
ofi := A_FormatInteger
SetFormat, Integer, D
h+=0
StringLeft, id, p, 1
StringTrimLeft, p, p, 1
if p is integer
	p+=0
c := i ? i : P%h%_
SetFormat, Integer, %ofi%
if g
	{
Transform, x, Deref, % %g%%h%_%i%
	return x
	}
if id=B
	B%h%_ := p
if id=L
	L%h%_%c% := p
if id=P
	{
	if !P%h%_
		P%h%_=0
	return ++P%h%_
	}
}
