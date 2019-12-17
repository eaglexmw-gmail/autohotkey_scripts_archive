GetHwnd(gid="1")
{
i := A_Gui
old := A_DetectHiddenWindows
ofi := A_FormatInteger
SetFormat, Integer, D
DetectHiddenWindows, on
gid := gid ? gid : 1
if gid is not number
	hwnd := WinExist(gid)
else if gid < 1
	hwnd := 0
else if gid between 1 and 99
	{
	gid+=0
	Gui, %gid%:+LastFoundExist
	WinGet, hwnd, ID
	if i
		Gui, %i%:+LastFound
	}
else hwnd := gid
DetectHiddenWindows, %old%
SetFormat, Integer, Hex
hwnd+=0
SetFormat, Integer, %ofi%
return hwnd
}
