;***************************************
; Win9x variable declarations
;***************************************
MBmsg = 9
VarSetCapacity(MBstack, MBmsg*2, 0)	; 9 messages x 2 bytes (1 set, 1 enabled)
Loop, %MBmsg%
	hkl%A_Index%=
;oldWMmove := OnMessage(0x200, "MMfunc")	; WM_MOUSEMOVE
oldWMlbtndn := OnMessage(0x201, "MBfunc")	; WM_LBUTTONDOWN
oldWMlbtnup := OnMessage(0x202, "MBfunc")	; WM_LBUTTONUP
OnMessage(0x203, "MBfunc")	; WM_LBUTTONDBLCLK
OnMessage(0x204, "MBfunc")	; WM_RBUTTONDOWN
OnMessage(0x205, "MBfunc")	; WM_RBUTTONUP
OnMessage(0x206, "MBfunc")	; WM_RBUTTONDBLCLK
OnMessage(0x207, "MBfunc")	; WM_MBUTTONDOWN
OnMessage(0x208, "MBfunc")	; WM_MBUTTONUP
OnMessage(0x209, "MBfunc")	; WM_MBUTTONDBLCLK
OnMessage(0x20A, "MBfunc")	; WM_MOUSEWHEEL
OnMessage(0x20E, "MBfunc")	; WM_MOUSEHWHEEL
return
;*******************************************
; Win9x mouse functions
;**********************************************
MBfunc(wP, lP, msg, hwnd)
{
Global
Local cwnd, st1, st2, sta, idx, add, label, ctrl
MouseGetPos,,, cwnd, ctrl, 2
if (msg = 0x201 && oldWMlbtndn != A_ThisFunc)
	%oldWMlbtnup%(wP, lP, msg, hwnd)
if (msg = 0x202 && oldWMlbtnup != A_ThisFunc)
	%oldWMlbtnup%(wP, lP, msg, hwnd)
if  (msg = 0x201 && hwnd = hTB99)
	ShowBT(2)
if (cwnd != MainWndID)
		return
st1 := "513|514|515|516|517|518|519|520|521"
Loop, Parse, st1, |
	if (A_LoopField = msg)
		{
		idx := A_Index
		add := 3*((idx-1)//3)-1
		Loop, 3
			NumPut(0, MBstack, add+A_Index, "UChar")
		NumPut(1, MBstack, idx-1, "UChar")
		break
		}
if (NumGet(MBstack, MBmsg+idx-1, "UChar") = 1)	; if corresponding hotkey is enabled
	{
	label := hkl%idx%
	if label
		{
		NumPut(0, MBstack, idx-1, "UChar")
		if debug
			GuiControl, 5:, dbg3, Go to %label%
		SetTimer, %label%, -1
		}
	}
if drawMS(ctrl, lP, msg, MainWndID)
	return 0
}
;**********************************************
KeyWait9x(key, time="")
{
Global MBstack, debug
t1 := A_TickCount
st2 := "LD|LU|L2|RD|RU|R2|MD|MU|M2"
if time
	time *= 1000
Loop, Parse, st2, |
	if (key = A_LoopField)
		idx := A_Index
Loop
	{
	if idx
		res := NumGet(MBstack, idx-1, "UChar")
	else
		res := GetKeyState(key, "P")
	t2 := A_TickCount - t1
	if (time && (t2 > time))
		{
		ErrorLevel=1
		return
		}
	if res
		{
		ErrorLevel=
		return
		}
	if debug
		GuiControl, 5:, dbg1, Elapsed %t2%ms`nWaiting %time%ms`nfor %key%
	}
;NumPut(0, MBstack, idx-1, "UChar")
;return t2	; reaction time might come in handy sometime
}
;**********************************************
Hotkey9x(key, label)
{
Global MBstack, MBmsg, hkl1, hkl2, hkl3, hkl4, hkl5, hkl6, hkl7, hkl8, hkl9, debug
If StrLen(key) = 1
	key .= "D"
st2 := "LD|LU|L2|RD|RU|R2|MD|MU|M2"
Loop, Parse, st2, |
	if (key = A_LoopField)
		idx := A_Index
if !idx
	{
	ErrorLevel=1
	return
	}
if (label = "Off")
	{
	NumPut(0, MBstack, MBmsg+idx-1, "UChar")		; disable hotkey
	}
else if (label = "On")
	{
	if hkl%idx%
		NumPut(1, MBstack, MBmsg+idx-1, "UChar")	; enable hotkey
	else
		{
		ErrorLevel=1
		return
		}
	}
else
	{
	hkl%idx% := label							; assign label
	NumPut(1, MBstack, MBmsg+idx-1, "UChar")		; enable hotkey
	}
if debug
	{
	how := NumGet(MBstack, MBmsg+idx-1, "UChar")
	GuiControl, 5:, dbg2, Key %key%`nLabel: %label% %how%
	}
ErrorLevel=
}
;**********************************************
