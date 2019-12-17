; v1.6 Apr-Sept 2011, © Drugwash
; proc: in/out R=ARGB, B=ABGR
; g=GUI number (1-99) or hWnd or window name
ChgColor(res="0x00FFFFFF", proc="RR", g="1")
{
Static
hGUI := GetHwnd(g)
StringSplit, p, proc
sz=36
flags := 0x100 | 0x2 | 0x1	; CC_ANYCOLOR CC_FULLOPEN CC_RGBINIT
VarSetCapacity(CHOOSECOLOR, sz, 0)
if !init
	{
	VarSetCapacity(CustColors, 64)
	Loop, 16
		NumPut(0x00FFFFFF, CustColors, 4*(A_Index-1), "UInt")	; fix for NT-based systems
	init=1
	}
alpha := res & 0xFF000000
res &= 0x00FFFFFF
NumPut(sz, CHOOSECOLOR, 0, "UInt")
NumPut(hGUI, CHOOSECOLOR, 4, "UInt")
if p1=R
	res := SwColor(res)
NumPut(res, CHOOSECOLOR, 12, "UInt")
NumPut(&CustColors, CHOOSECOLOR, 16, "UInt")
NumPut(flags, CHOOSECOLOR, 20, "UInt")
r := DllCall("comdlg32\ChooseColorA", "UInt", &CHOOSECOLOR)
if (ErrorLevel || !r)
	{
	ErrorLevel:="1"
	Return 0
	}
ofi := A_FormatInteger
SetFormat, Integer, Hex
res := NumGet(CHOOSECOLOR, 12, "UInt")
if p2=R
	r := SwColor(res)
else r:= res+0
alpha+=0
r |= alpha
StringUpper, r, r
StringReplace, r, r, X, x
SetFormat, Integer, %ofi%
return r
}

SwColor(res)
{
ofi := A_FormatInteger
SetFormat, Integer, Hex
r := ((res & 0xFF0000) >> 16) + (res & 0xFF00) + ((res & 0xFF) << 16)
SetFormat, Integer, %ofi%
return r
}

#include func_GetHwnd.ahk
