debug := 0
item := 1
Gui, Add, Button, x2 y2 w16 h70 gbck, <
Gui, Add, Button, x382 y2 w16 h70 gfwd, >
Gui, Add, Edit, x2 y72 w396 h48 -Wrap ReadOnly 0x80 -0x40 -0x200000
Gui, Add, Text, x2 y121 w396 h14 vdebg1
Gui, Add, Text, x2 y135 w396 h14 vdebg
Gui, Add, ListView, x20 y2 w360 h70 +LV0x8000 LV0x40 0x80 0x8 0x100 0x800 -E0x200 -Multi NoSortHdr -ReadOnly AltSubmit Icon -Sort vtlist ginfo
lib := IL_Create(1, 1, 1)
LV_SetImageList(lib, 0)

;+0x140F004C  +0x00010110

Process, Exist
WinGet, hw_this, ID, ahk_class AutoHotkeyGUI ahk_pid %ErrorLevel%

WS_EX_APPWINDOW = 0x40000
WS_EX_TOOLWINDOW = 0x80
GW_OWNER = 4
;TotCmd 0x17CF0000 0x00000100

DetectHiddenWindows, On
WinGet, list, List
count := 1
loop, %list%
	{
	wid := list%A_Index%
   	WinGet, es, ExStyle, ahk_id %wid%
   	WinGet, st, Style, ahk_id %wid%
	if ( ( ! DllCall( "GetWindow", "uint", wid, "uint", GW_OWNER ) and ! ( es & WS_EX_TOOLWINDOW ) )
	or ( es & WS_EX_APPWINDOW ) )
		{
		WinGet, pid, PID, ahk_id %wid%
;		WinGetClass, class, ahk_id %wid%
		WinGetTitle, title, ahk_id %wid%
		title%count% := title
		pid%count% := pid
		par_pid := GetParentProcessID(pid)
		par_pid%count% := par_pid
		procx%count% := GetLongPath(GetProcessName(pid))
		parent%count% := GetLongPath(GetProcessName(par_pid))

		;WM_GETICON
		;ICON_SMALL		0
		;ICON_BIG		1
		;ICON_SMALL2	2
		SendMessage, 0x7F, 1, 0,, ahk_id %wid%
		h_icon := ErrorLevel
		if ( ! h_icon )
			{
			SendMessage, 0x7F, 2, 0,, ahk_id %wid%
			h_icon := ErrorLevel
			if ( ! h_icon )
				{
				SendMessage, 0x7F, 0, 0,, ahk_id %wid%
				h_icon := ErrorLevel
				if ( ! h_icon )
					{
					;GCL_HICON	(-14)
					h_icon := DllCall( "GetClassLong", "uint", wid, "int", -14 )
					if ( ! h_icon )
/*
						{
						;GCL_HICONSM	(-34)
						h_icon := DllCall( "GetClassLong", "uint", wid, "int", -34 )
						if ( ! h_icon )
							{
							;IDI_APPLICATION	32512
							h_icon := DllCall( "LoadIcon", "uint", 0, "uint", 32512 )
							if ( ! h_icon )
								{
*/
								noicon := 1
/*
								}
							}
						}
*/
					}
				}
			}

		;STM_SETIMAGE	0x0172
		;IMAGE_ICON		1
		h_icon%count% := h_icon
		if noicon
			IL_Add(lib, "noimg.ico")
		else
			IL_Add(lib, procx%count%)
		noicon :=
		LV_Add("Icon" . count)
;		SendMessage, 0x172, 1, h_icon, Static%count%, ahk_id %hw_this%
		count += 1
		}
;			GuiControl,, debg, Window %wid% has Style %st%, ExStyle %es%
	}
Gui, Show, h150 w400, TaskManX by Drugwash
tot := LV_GetCount()
if debug
	MsgBox, total items=%tot%
goto info1
return

GuiClose:
ExitApp

info:
if (A_EventInfo is not number)
	return
if A_EventInfo in 0,%item%
	return
if A_EventInfo = 38
	if item not in 37,39
		return
if A_EventInfo = 40
	if item not in 39,41
		return
;if A_EventInfo in 38,40
;		return
if (A_EventInfo = 37 and item = 1)
	goto bck
if (A_EventInfo = 39 and item = tot)
	goto fwd
item := A_EventInfo
GuiControl,, debg1, current A_EventInfo is %item%
goto info2

bck:
if item
	LV_Modify(item, "-Select")
if item <= 1
	item := tot + 1
item -= 1
goto info1

fwd:
if item
	LV_Modify(item, "-Select")
if (item = tot)
	item := 0
item += 1
goto info1

info1:
LV_Modify(item, "Vis")
LV_Modify(item, "Select")
LV_Modify(item, "Focus")

info2:
GuiControl,, Edit1, %
	( Join
	"title = " title%item%
	"`ntask = " procx%item%
	"`ncaller = " parent%item%
	)

;	"pid = " pid
;	"`np_pid = " par_pid
;	"`n`nwid = " wid
;	"`nclass = " class
;	"`n`nfile = " name
GuiControl,, debg, current item is %item%
return

GetProcessName(p_pid)
{
  Return GetProcessInformation(p_pid, "Str", 0xFF, 36)  ; TCHAR szExeFile[MAX_PATH]
}

GetParentProcessID(p_pid)
{
  Return GetProcessInformation(p_pid, "UInt *", 4, 24)  ; DWORD th32ParentProcessID
}

GetProcessInformation(p_pid, CallVariableType, VariableCapacity, DataOffset)
{
  hSnapshot := DLLCall("CreateToolhelp32Snapshot", "UInt", 2, "UInt", 0)  ; TH32CS_SNAPPROCESS = 2
  if (hSnapshot >= 0)
  {
    VarSetCapacity(PE32, 304, 0)  ; PROCESSENTRY32 structure -> http://msdn2.microsoft.com/ms684839.aspx
    if A_OSVersion in WIN_95,WIN_98,WIN_ME
	    DllCall("radmin32.dll\RtlFillMemoryUlong", "UInt", &PE32, "UInt", 4, "UInt", 304)  ; Set dwSize
   else
    DllCall("ntdll.dll\RtlFillMemoryUlong", "UInt", &PE32, "UInt", 4, "UInt", 304)  ; Set dwSize
    VarSetCapacity(th32ProcessID, 4, 0)
    if (DllCall("Process32First", "UInt", hSnapshot, "UInt", &PE32))  ; http://msdn2.microsoft.com/ms684834.aspx
      Loop
      {
        DllCall("RtlMoveMemory", "UInt *", th32ProcessID, "UInt", &PE32 + 8, "UInt", 4)  ; http://msdn2.microsoft.com/ms803004.aspx
        if (p_pid = th32ProcessID)
        {
          VarSetCapacity(th32DataEntry, VariableCapacity, 0)
          DllCall("RtlMoveMemory", CallVariableType, th32DataEntry, "UInt", &PE32 + DataOffset, "UInt", VariableCapacity)
          DllCall("CloseHandle", "UInt", hSnapshot)  ; http://msdn2.microsoft.com/ms724211.aspx
          Return th32DataEntry  ; Process data found
        }
        if not DllCall("Process32Next", "UInt", hSnapshot, "UInt", &PE32)  ; http://msdn2.microsoft.com/ms684836.aspx
          Break
      }
    DllCall("CloseHandle", "UInt", hSnapshot)
  }
  Return  ; Cannot find process
}

GetLongPath(name)
{
	name_size := 260
	VarSetCapacity(fpath, name_size, 0)
;	result := DllCall("GetFullPathNameA", "Str", name, "UInt", name_size, "Str", fpath, "Str", 0)
	result := DllCall("GetLongPathNameA", "Str", name, "Str", fpath, "UInt", name_size)
	if (ErrorLevel or result = 0)
;		MsgBox, [GetLongPath] failed
		return "nobody"
	return fpath
}
