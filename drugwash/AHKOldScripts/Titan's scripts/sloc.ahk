#NoEnv
#NoTrayIcon

p = %1%
IfNotExist, %p%
	FileSelectFile, p, 3, , Analyze script..., AutoHotkey Script (*.ahk; *.ahi; *.aut; *.ini; *.txt)
IfNotExist, %p%
	ExitApp
SplitPath, p, f, d
SetWorkingDir, %d%

sloc_parse(p, lp := 0, ll := 0, ls := 0, lc := 0)

If (i := get_includes(p)) {
	tp := lp, tl := ll, ts := ls, tc := lc
	Loop, Parse, i, `n
	{
		sloc_parse(A_LoopField, ip := 0, il := 0, is := 0, ic := 0)
		tp += ip, tl += il, ts += is, tc += ic
	}
	tp = / %tp%
	tl = / %tl%
	ts = / %ts%
	tc = / %tc%
}

Gui, +ToolWindow
Gui, Color, White
Gui, Font, , Calibri
Gui, Font, s14
c = Maroon,Navy,Olive,Green
StringSplit, c, c, `,
Gui, Add, Text, vlb1 c%c1%, Logical:
GuiControlGet, z, Pos, lb1
x := Ceil(zw * 2)
Gui, Font, bold
Gui, Add, Text, c%c1% xm+%x% yp, %ll% %tl%
Gui, Font, Norm
Gui, Add, Text, xm c%c2%, Physical:
Gui, Font, bold
Gui, Add, Text, c%c2% xm+%x% yp, %lp% %tp%
Gui, Font, Norm
Gui, Add, Text, xm c%c3%, Space:
Gui, Font, bold
Gui, Add, Text, c%c3% xm+%x% yp, %ls% %ts%
Gui, Font, Norm
Gui, Add, Text, xm c%c4%, Comments:
Gui, Font, bold
Gui, Add, Text, c%c4% xm+%x% yp, %lc% %tc%
Gui, Show, , %f%
KeyWait, Enter, D
GuiClose:
GuiEscape:
ExitApp

sloc_parse(c, ByRef lp, ByRef ll, Byref ls, ByRef lc) {
	Loop, Read, %c%
	{
		lp = %A_Index%
		l = %A_LoopReadLine%
		If ic = 1
		{
			If (InStr(l, "*/") == 1)
				ic = 0
			lc++
			Continue
		}
		Else If (InStr(l, "/*") == 1) {
			ic = 1
			lc++
			Continue
		}
		If it = 1
		{
			If (InStr(l, ")") == 1)
				it = 0
			Continue
		}
		Else If (InStr(l, "(") == 1) {
			it = 1
			Continue
		}
		If l =
			ls++
		Else If l is space
			ls++
		Else If (InStr(l, ";") == 1)
			lc++
		Else If (RegExMatch(l, "\w") and l != "else")
			ll++
	}
}

get_includes(s, d = "`n") {
	Loop, Read, %s%
		If (RegExMatch(A_LoopReadLine, "i)\s*#include(?:again)?\s+(.+)\s*(?:\s;)?", m))
			If (FileExist(m1) and !InStr(l, d . m1))
				l .= d . m1
	Return, SubStr(l, StrLen(d))
}