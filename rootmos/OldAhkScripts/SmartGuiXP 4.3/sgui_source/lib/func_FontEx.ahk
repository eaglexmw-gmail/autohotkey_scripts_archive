; Font selector function by Drugwash
; June 16, 2009 - April 30, 2012
; v1.6
; FontEx(result type, GUI number, font size [pt], minimum size, maximum size, flags)
; result type: A=Add GUI command, R=return parameter string, AR=both
; flags:
; CF_NOVERTFONTS=0x1000000
; CF_NOSCRIPTSEL=0x800000
; CF_NOSIZESEL=0x200000
; CF_NOSTYLESEL=0x100000
; CF_NOFACESEL=0x80000
; CF_TTONLY=0x40000
; CF_SCALABLEONLY=0x20000
; CF_FORCEFONTEXIST=0x10000
; CF_LIMITSIZE=0x2000
; CF_NOSIMULATIONS=0x1000
; CF_NOVECTORFONTS=0x800 (CF_NOOEMFONTS)
; CF_SCRIPTSONLY=0x400 (CF_ANSIONLY)
; CF_EFFECTS=0x100
; CF_USESTYLE=0x80
; CF_INITTOLOGFONTSTRUCT=0x40
; CF_PRINTERFONTS=0x2
; CF_SCREENFONTS=0x1
; 
FontEx(proc="A", gid="1", iPointSize="8", nSizeMin="7", nSizeMax="72", flags="0x00121C3")
{
Global debug
Static init, ChSet, ChCode, chf, LogFont, Style, hwndOwner
if !(hwndOwner := GetHwnd(gid))
	return, ErrorLevel:="1"
if InStr(proc, "D")
	{
	if InStr(proc, "F")
		DllCall("lstrcpy", "UInt", &LogFont + 28, "Str", gid)
	if InStr(proc, "S")
		{
		hDC := DllCall("GetDC", UInt, hwndOwner)
		caps := DllCall("gdi32\GetDeviceCaps", "UInt", hDC, "Int", 90)		; LOGPIXELSY
		DllCall("ReleaseDC", "UInt", hwndOwner, "UInt", hDC)
		lfHeight := -DllCall("MulDiv", "Int", iPointSize, "Int", caps, "Int", 72)	; font size should be retrieved from the DC
		NumPut(lfHeight, LogFont, 0, "Int")	; lfHeight
		}
	return
	}
ofi := A_FormatInteger
off := A_FormatFloat
if !init
	{
	ChSet := "Western|Default|Symbol|MAC|Shift JIS|Hangeul|Johab|GB2312|Chinese BIG5|Greek|Turkish|Vietnamese|Hebrew|Arabic|Baltic|Cyrillic|Thai|Central European|OEM"
	ChCode := "0|1|2|77|128|129|130|134|136|161|162|163|177|178|186|204|222|238|255"
	lStructSize = 60
	VarSetCapacity(chf, lStructSize, 0)
	VarSetCapacity(LogFont, 60, 0)
	VarSetCapacity(Style, 32, 32)
	NumPut(lStructSize, chf, 0, "UInt")
	NumPut(&LogFont, chf, 12, "UInt")
	NumPut(&Style, chf, 44, "UInt")
	NumPut(400, LogFont, 16, "UInt")		; FW_REGULAR
	NumPut(1, LogFont, 23, "UChar")		; DEFAULT_CHARSET
	DllCall("lstrcpy", "UInt", &LogFont + 28, "Str", "Tahoma")
	DllCall("lstrcpy", "UInt", &Style, "Str", "Regular")
	hDC := DllCall("GetDC", UInt, hwndOwner)
	caps := DllCall("gdi32\GetDeviceCaps", "UInt", hDC, "Int", 90)		; LOGPIXELSY
	DllCall("ReleaseDC", "UInt", hwndOwner, "UInt", hDC)
	lfHeight := -DllCall("MulDiv", "Int", iPointSize, "Int", caps, "Int", 72)	; font size should be retrieved from the DC
	NumPut(lfHeight, LogFont, 0, "Int")	; lfHeight
	init=1
	}
NumPut(hwndOwner, chf, 4, "UInt")
NumPut(iPointSize*10, chf, 16, "Int")
NumPut(flags, chf, 20, "UInt")
NumPut(nSizeMin, chf, 52, "Int")
NumPut(nSizeMax, chf, 56, "Int")
ret := DllCall("comdlg32\ChooseFontA", "UInt", &chf)
if !ret
	{
	if debug
		{
		err := DllCall("comdlg32\CommDlgExtendedError")
		if err <= 0
			MsgBox, No font chosen or error occured.`nError: %err%, ChooseFontA returned %ret%.
		}
	return, ErrorLevel:="1"
	}
SetFormat, Float, 0.0
SetFormat, Integer, D
VarSetCapacity(fN, 32, 32)			; Name
;fH := NumGet(LogFont, 0, "Int")		; height (not used)
;fW := NumGet(LogFont, 4, "Int")		; width (not used)
fG := NumGet(LogFont, 16, "Int")		; Weight
fI := NumGet(LogFont, 20, "UChar")	; Italic
fU := NumGet(LogFont, 21, "UChar")	; Underline
fS := NumGet(LogFont, 22, "UChar")	; Strikeout
fC := NumGet(LogFont, 23, "UChar")	; Charset
;fP := NumGet(LogFont, 27, "UChar")	; pitch & family (not used)
DllCall("lstrcpy", "UInt", &fN, "UInt", &LogFont + 28)
VarSetCapacity(fN, -1)
i := (fI) ? " Italic" : ""
u := (fU) ? " Underline" : ""
s := (fS) ? " Strike" : ""
StringSplit, cc, ChCode, |
Loop, Parse, ChSet, |
	if (cc%A_Index% = fC)
		fC := A_LoopField		; Charset in readable form
size := NumGet(chf, 16, "Int") / 10	; size
SetFormat, Integer, H
color := NumGet(chf, 24, "UInt")		; color
col := (color >> 16 & 0xFF) | (color & 0xFF00) | (color << 16 & 0xFF0000)
SetFormat, Integer, D
result := size "|" col "|" fG "|" i "|" u "|" s "|" fN "|" fC
if InStr(proc, "A")
	Gui, %gid%:Font, s%size% c%col% w%fG% %i% %u% %s%, %fN%
SetFormat, Float, %off%
SetFormat, Integer, %ofi%
if InStr(proc, "R")
	return result
return 1
}

#include func_GetHwnd.ahk
