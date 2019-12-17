; DummyExe is supposed to replace any executable (exe) file on your machine
; that you don't want to be launched automatically by a poorly designed or ill-intended application.
; © Drugwash, September 8, 2008
; created with AutoHotkey 1.0.47.06
; version 0.0.0.1

#NoTrayIcon
StringReplace, 1, 1, ",, All
if 0 = 0
	param := "no parameters."
else
	{
	if 0 = 1
		param := "one parameter:"
	else
		param = %0% parameters:
	}
pid := DllCall("GetCurrentProcessId", "Cdecl UInt")	; wouldn't work unless Cdecl used!!!
par := GetParentProcessID(pid)
par1 := GetParentProcessID(par)
par2 := GetParentProcessID(par1)
par3 := GetParentProcessID(par2)
par4 := GetParentProcessID(par3)
app1 := GetLongPath(GetProcessName(par1))
app2 := GetLongPath(GetProcessName(par2))
app3 := GetLongPath(GetProcessName(par3))
app4 := GetLongPath(GetProcessName(par4))
app := GetLongPath(GetProcessName(GetParentProcessID(pid)))
nam := GetLongPath(GetProcessName(pid))
MsgBox, 48, Warning !, %app%`ntried to launch`n%A_ScriptFullPath%`nwith %param%`n%1% %2% %3% %4% %5% %6% %7% %8% %9%
MsgBox, Data:`n`n`npid = %pid% ( %nam% )`npar = %par% ( %app% )`n`n%app4% called`n%app3% called`n%app2% called`n%app1% called`n%app% called this script.
GuiClose:
ExitApp

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
