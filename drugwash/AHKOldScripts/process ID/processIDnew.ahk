Gui, Add, Edit, x5 y5 w400 h200 -Wrap ReadOnly HScroll
Gui, Add, Picture, x5 y210 +0x3
Gui, Add, Button, x315 y220 w90 h20 gShowNext, Show Next
Gui, Show, x10 y10 w410 h245

Process, Exist
WinGet, hw_this, ID, ahk_class AutoHotkeyGUI ahk_pid %ErrorLevel%

WS_EX_APPWINDOW = 0x40000
WS_EX_TOOLWINDOW = 0x80

GW_OWNER = 4

WinGet, list, List

loop, %list%
{
   wid := list%A_Index%
   
   WinGet, es, ExStyle, ahk_id %wid%
   
   if ( ( ! DllCall( "GetWindow", "uint", wid, "uint", GW_OWNER ) and ! ( es & WS_EX_TOOLWINDOW ) )
         or ( es & WS_EX_APPWINDOW ) )
   {
      WinGet, pid, PID, ahk_id %wid%
   
      WinGetClass, class, ahk_id %wid%
      WinGetTitle, title, ahk_id %wid%
par_pid := GetParentProcessID(pid)
name := GetModuleFileNameEx(pid)
procx := GetLongPath(GetProcessName(pid))
parent := GetLongPath(GetProcessName(par_pid))
      GuiControl,, Edit1, %
         ( Join
            "pid = " pid
            "`np_pid = " par_pid
            "`nprocess = " procx
            "`nparent = " parent
            "`n`nwid = " wid
            "`nclass = " class
            "`ntitle = " title
            "`n`nfile = " name
         )

      ;WM_GETICON
      ;   ICON_SMALL          0
      ;   ICON_BIG            1
      ;   ICON_SMALL2         2
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
               ; GCL_HICON           (-14)
               h_icon := DllCall( "GetClassLong", "uint", wid, "int", -14 )
               
               if ( ! h_icon )
               {
                  ; GCL_HICONSM         (-34)
                  h_icon := DllCall( "GetClassLong", "uint", wid, "int", -34 )
                  
                  if ( ! h_icon )
                  {
                     ; IDI_APPLICATION     32512
                     h_icon := DllCall( "LoadIcon", "uint", 0, "uint", 32512 )
                  }
               }
            }
         }
      }

      ;STM_SETIMAGE        0x0172
      ;   IMAGE_ICON          1
      SendMessage, 0x172, 1, h_icon, Static1, ahk_id %hw_this%
      
      pause
   }
}
return

GuiClose:
ExitApp

ShowNext:
   pause, Off
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
	name_size := 255
	VarSetCapacity(fpath, name_size, 0)
;	result := DllCall("GetFullPathNameA", "Str", name, "UInt", name_size, "Str", fpath, "Str", 0)
	result := DllCall("GetLongPathNameA", "Str", name, "Str", fpath, "UInt", name_size)
	if (ErrorLevel or result = 0)
		MsgBox, [GetLongPath] failed
	return fpath
}

GetModuleFileNameEx( p_pid )
{
/*
   if A_OSVersion in WIN_95,WIN_98,WIN_ME
   {
      MsgBox, This Windows version (%A_OSVersion%) is not supported.
      return
   }

   /*
      #define PROCESS_VM_OPERATION      (0x0008) 
      #define PROCESS_VM_READ           (0x0010)
      #define PROCESS_QUERY_INFORMATION (0x0400) 
   */
    if A_OSVersion in WIN_95,WIN_98,WIN_ME
	{
;	   result := DllCall("GetModuleFileNameA", "UInt", h_process, "Str", name, "UInt", name_size)
	name_size := 255
	VarSetCapacity(name, name_size, 0)
	name := GetProcessName(p_pid)
;	VarSetCapacity(fpath, name_size, 0)
; 	result := DllCall("GetFullPathNameA", "Str", name, "UInt", name_size, "Str", fpath, "Str", 0)
	return name
	}
   h_process := DllCall("kernel32.dll\OpenProcess", "UInt", 0x8|0x10|0x400, "Int", False, "UInt", p_pid)
   if (ErrorLevel or h_process = 0)
   {
      MsgBox, [OpenProcess] failed
      return
   }
   
   name_size := 255
   VarSetCapacity(name, name_size, 0)
 
	   result := DllCall( "psapi.dll\GetModuleFileNameExA", "uint", h_process, "uint", 0, "str", name, "uint", name_size )
   if (ErrorLevel or result = 0)
      MsgBox, [GetModuleFileNameExA] failed`nh_process=%h_process%`nErrorLevel=%ErrorLevel%`nresult=%result%`nfpath=%fpath%
   
   DllCall("CloseHandle", h_process)
   
   return name
}
