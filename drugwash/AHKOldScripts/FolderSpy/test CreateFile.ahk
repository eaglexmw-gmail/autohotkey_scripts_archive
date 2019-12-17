#NoEnv
SetBatchLines -1
SetWinDelay -1
DebugBIF()
MAX_PATH = 260
stop=1
SHORT = 14	; short file name
thepath := A_Temp "orary Internet Files"
;SplitPath, thepath, filename, dir,,, drv
dir := thepath
drv := dir
Gui, Add, ListView, w800 r30 vlist, File name
Gui, Add, Button, vonoff gonbut, Start
Gui, Add, Button, x+5 yp gref, Refresh
Gui, Add, Text, x+10 yp, Total items:
Gui, Add, Text, x+2 yp w40 vitems
Gui, Add, Text, x+2 yp, Drive: %drv%, Dir: %dir%
Gui, Add, Text, x+2 yp w100 vsts
Gui, Add, Text, xp y+2 w130 vfirst
Refresh(thepath)
Gui, Show,, FAM
return

runit:
VarSetCapacity(cHandles, 2*4, 0)	; 2 DWORDs, one for each handle
chFile := DllCall("FindFirstChangeNotification", UInt, &thepath, Int, 0, UInt, 0x1)	; FILE_NOTIFY_CHANGE_FILE_NAME
if chFile <= 0
	goto error
else
	NumPut(chFile, cHandles, 0, "UInt")
chDir := DllCall("FindFirstChangeNotification", UInt, &thepath, Int, 1, UInt, 0x2)	; FILE_NOTIFY_CHANGE_DIR_NAME
if chFile <= 0
	goto error
else
	NumPut(chDir, cHandles, 4, "UInt")
GuiControl,, first, chFile: %chFile%, chDir: %chDir%
Loop
	{
;	status := DllCall("WaitForMultipleObjects", UInt, 2, UInt, &cHandles, Int, 0, Int, 0xFFFFFFFF)	; timeout should not be INFINITE
	status := DllCall("WaitForMultipleObjects", UInt, 2, UInt, &cHandles, Int, 0, Int, 1000)	; timeout is 3000ms
	if status = 0	; file operation detected
		{
		GuiControl,, sts, Status: %status%
		Refresh(dir)
		if !DllCall("FindNextChangeNotification", UInt, chFile)
			goto error		
		}
	else if status = 1	; directory operation detected
		{
		GuiControl,, sts, Status: %status%
		Refresh(drv)
		if !DllCall("FindNextChangeNotification", UInt, chDir)
			goto error		
		}
	else if (status != 0x102 || stop > 0)	; timeout not occured
		break
	}
return

onbut:
stop := !stop
bTxt := stop ? "Start" : "Stop"
GuiControl,, onoff, %bTxt%
;msgbox, It's %bTxt%
if !stop
	SetTimer, runit, 500
return

ref:
Refresh(thepath)
return

error:
msgbox, Error! Function returned %ret%.
GuiClose:
if chFile
	DllCall("FindCloseChangeNotification", UInt, chFile)
if chDir
	DllCall("FindCloseChangeNotification", UInt, chDir)
ExitApp

Refresh(apath)
{
global list
GuiControl, -Redraw, list
LV_Delete()
Loop, %apath%\*, 1, 1
	{
	LV_Add("", A_LoopFileLongPath)
	items++
	}
GuiControl, +Redraw, list
GuiControl,, items, %items%
}
