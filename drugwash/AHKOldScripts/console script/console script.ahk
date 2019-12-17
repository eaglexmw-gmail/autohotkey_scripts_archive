;Init the console
Console_Init()
Console_Write("Autohotkey Command Line Application Test`n")
Console_Write("----------------------------------------`n")
Console_Write("`n")
Console_Write("Welcome " . A_UserName . ". The Current Time is: " . A_Hour . ":" . A_Min . "`n")
Console_Write("What would you like to do today?`n")
ToDo := Console_GetUserInput()
Console_Write("Today you want to " . ToDo . ".`n")

Loop, 5
   {
   Console_Write("Exiting in " . 6 - A_Index . " seconds.`n")
   Sleep, 1000
   }
   
ExitApp

Console_Init(){
   if !(Process_GetModuleFileNameEx(Process_GetCurrentParentProcessID()) = COMSPEC)
      {
      ;MsgBox % "Parent process is not '" . GetFileName(COMSPEC) . "'. The script will now be restarted.`nParent process name : " . Process_GetProcessName(Process_GetCurrentParentProcessID()) . "`nShould be: " . GetFileName(COMSPEC)
      If A_IsCompiled
         Run %comspec% /c ""%A_ScriptFullPath%"", , Hide
      else
         Run %comspec% /c ""%A_AhkPath%" "%A_ScriptFullPath%"", , Hide
      ExitApp
      }
   DllCall("AllocConsole")
   }

Console_Write(txt){
   FileAppend, %txt%, con
   }

Console_GetUserInput(){
   FileReadLine, l, con, 1
   return l
   }
   
GetFileName(pFile){
Loop %pFile%
   Return A_LoopFileName
   }

; ProcessInfo.ahk - Function library to retrieve various application process informations:
; - Script's own process identifier
; - Parent process ID of a process (the caller application)
; - Process name by process ID (filename without path)
; - Thread count by process ID (number of threads created by process)
; - Full filename by process ID (GetModuleFileNameEx() function)
;
; Tested with AutoHotkey 1.0.46.10
;
; Created by HuBa
; Contact: http://www.autohotkey.com/forum/profile.php?mode=viewprofile&u=4693
;
; Portions of the script are based upon the GetProcessList() function by wOxxOm
; (http://www.autohotkey.com/forum/viewtopic.php?p=65983#65983)

Process_GetCurrentProcessID(){
  Return DllCall("GetCurrentProcessId")  ; http://msdn2.microsoft.com/ms683180.aspx
}

Process_GetCurrentParentProcessID(){
  Return Process_GetParentProcessID(Process_GetCurrentProcessID())
}

Process_GetProcessName(ProcessID){
  Return Process_GetProcessInformation(ProcessID, "Str", 260, 36)  ; TCHAR szExeFile[MAX_PATH]
}

Process_GetParentProcessID(ProcessID){
  Return Process_GetProcessInformation(ProcessID, "UInt *", 4, 24)  ; DWORD th32ParentProcessID
}

Process_GetProcessThreadCount(ProcessID){
  Return Process_GetProcessInformation(ProcessID, "UInt *", 4, 20)  ; DWORD cntThreads
}

Process_GetProcessInformation(ProcessID, CallVariableType, VariableCapacity, DataOffset){
  hSnapshot := DLLCall("CreateToolhelp32Snapshot", "UInt", 2, "UInt", 0)  ; TH32CS_SNAPPROCESS = 2
  if (hSnapshot >= 0)
  {
    VarSetCapacity(PE32, 304, 0)  ; PROCESSENTRY32 structure -> http://msdn2.microsoft.com/ms684839.aspx
    DllCall("ntdll.dll\RtlFillMemoryUlong", "UInt", &PE32, "UInt", 4, "UInt", 304)  ; Set dwSize
    VarSetCapacity(th32ProcessID, 4, 0)
    if (DllCall("Process32First", "UInt", hSnapshot, "UInt", &PE32))  ; http://msdn2.microsoft.com/ms684834.aspx
      Loop
      {
        DllCall("RtlMoveMemory", "UInt *", th32ProcessID, "UInt", &PE32 + 8, "UInt", 4)  ; http://msdn2.microsoft.com/ms803004.aspx
        if (ProcessID = th32ProcessID)
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

Process_GetModuleFileNameEx(ProcessID)  ; modified version of shimanov's function
{
  if A_OSVersion in WIN_95, WIN_98, WIN_ME
    Return Process_GetProcessName(ProcessID)
 
  ; #define PROCESS_VM_READ           (0x0010)
  ; #define PROCESS_QUERY_INFORMATION (0x0400)
  hProcess := DllCall( "OpenProcess", "UInt", 0x10|0x400, "Int", False, "UInt", ProcessID)
  if (ErrorLevel or hProcess = 0)
    Return
  FileNameSize := 260
  VarSetCapacity(ModuleFileName, FileNameSize, 0)
  CallResult := DllCall("Psapi.dll\GetModuleFileNameExA", "UInt", hProcess, "UInt", 0, "Str", ModuleFileName, "UInt", FileNameSize)
  DllCall("CloseHandle", hProcess)
  Return ModuleFileName
}
