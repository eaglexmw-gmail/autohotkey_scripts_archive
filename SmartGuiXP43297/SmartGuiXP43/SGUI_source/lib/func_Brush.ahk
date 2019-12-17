; © Drugwash, April 2, 2012 v1.0
;=============================
Brush(stl="1", chp="", dib="0")
{
ofi := A_FormatInteger
SetFormat, Integer, D
stl+=0
if stl=3
	{
	dib := dib<>"" ? dib : "0x0"
	StringSplit, s, dib, x
	IfExist, %chp%
		hnd := DllCall("LoadImage", "UInt", 0, "Str", chp, "UInt", 0, "UInt", s1, "UInt", s2, "UInt", 0x10)	; LR_LOADFROMFILE
	else if chp is integer
		hnd := chp
	}
else if stl in 5,6
	{
	clr := dib ? 1 : 0
	hnd := chp
	}
else if stl in 0,2
	{
	clr := chp
	if dib between 0 and 7	; hatch styles
		hnd := dib
	}
else
	{
	clr := dib
	hnd := chp
	}
VarSetCapacity(LB, 12, 0)				; LOGBRUSH struct
NumPut((stl<>"" ? stl : "1"), LB, 0, "UInt")	; lbStyle
NumPut((clr<>"" ? clr : "0"), LB, 4, "UInt")	; lbColor
NumPut((hnd ? hnd : "0"), LB, 8, "UInt")		; lbHatch
SetFormat, Integer, %ofi%
r := DllCall("CreateBrushIndirect", "UInt", &LB)
if stl=3
	DllCall("DeleteObject", "UInt", hnd)
return r
}

/*
brush style:
BS_DIBPATTERN=5
BS_DIBPATTERNPT=6
BS_HATCHED=2
BS_HOLLOW=BS_NULL=1
BS_PATTERN=3
BS_SOLID=0

dib_style:
DIB_PAL_COLORS=1
DIB_RGB_COLORS=0

hatch style:
HS_BDIAGONAL=3
HS_BDIAGONAL1=7
HS_CROSS=4
HS_DIAGCROSS=5
HS_FDIAGONAL=2
HS_FDIAGONAL1=6
HS_HORIZONTAL=0
HS_VERTICAL=1

examples:
Brush()					; hollow brush
Brush(0, 0xFF0000)		; solid brush
Brush(2, 0xFF0000, 4)		; hatched brush, cross
Brush(3, GridFile, "20x20")	; pattern brush, 20x20px
Brush(5, hDIB, 1)			; pattern DIB brush, palette
*/
