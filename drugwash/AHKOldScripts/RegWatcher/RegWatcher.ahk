; RegWatcher by Tertius
; http://www.autohotkey.com/forum/viewtopic.php?t=34226

#NoEnv
#Persistent
OnExit, ExitRout

SetBatchLines, -1
DetectHiddenWindows, On
WinMinimize, %A_ScriptFullPath% - AutoHotkey v
WinHide, %A_ScriptFullPath% - AutoHotkey v
DetectHiddenWindows, Off

If( A_OSType = "WIN32_NT" && A_OSVersion != "WIN_NT4" ) {
HKEY_CLASSES_ROOT = 0x80000000
HKEY_CURRENT_USER = 0x80000001
HKEY_LOCAL_MACHINE = 0x80000002
HKEY_USERS = 0x80000003
HKEY_CURRENT_CONFIG = 0x80000005

KEY_NOTIFY = 0x0010 ; Required to request change notifications for a registry key or for subkeys of a registry key.

REG_NOTIFY_CHANGE_NAME = 0x00000001 ; Notify the caller if a subkey is added or deleted.
REG_NOTIFY_CHANGE_ATTRIBUTES = 0x00000002 ; Notify the caller of changes to the attributes of the key, such as the security descriptor information.
REG_NOTIFY_CHANGE_LAST_SET = 0x00000004 ; Notify the caller of changes to a value of the key. This can include adding or deleting a value, or changing an existing value.
REG_NOTIFY_CHANGE_SECURITY = 0x00000008 ; Notify the caller of changes to the security descriptor of the key.
THREAD_PRIORITY_ABOVE_NORMAL = 1 ; Priority 1 point above the priority class.
THREAD_PRIORITY_BELOW_NORMAL = -1 ; Priority 1 point below the priority class.
THREAD_PRIORITY_HIGHEST = 2 ; Priority 2 points above the priority class.
THREAD_PRIORITY_IDLE = -15 ; Base priority of 1 for IDLE_PRIORITY_CLASS, BELOW_NORMAL_PRIORITY_CLASS, NORMAL_PRIORITY_CLASS, ABOVE_NORMAL_PRIORITY_CLASS, or HIGH_PRIORITY_CLASS processes, and a base priority of 16 for REALTIME_PRIORITY_CLASS processes.
THREAD_PRIORITY_LOWEST = -2 ; Priority 2 points below the priority class.
THREAD_PRIORITY_NORMAL = 0 ; Normal priority for the priority class.
THREAD_PRIORITY_TIME_CRITICAL = 15 ; Base priority of 15 for IDLE_PRIORITY_CLASS, BELOW_NORMAL_PRIORITY_CLASS, NORMAL_PRIORITY_CLASS, ABOVE_NORMAL_PRIORITY_CLASS, or HIGH_PRIORITY_CLASS processes, and a base priority of 31 for REALTIME_PRIORITY_CLASS processes.

   RegRoot:= HKEY_CURRENT_USER . "|" . HKEY_CURRENT_USER . "|" . HKEY_CURRENT_USER
;   Only Registry Keys can be specified, NOT values
   regsubkeystring=Control Panel\Mouse|Control Panel\KeyBoard|Software\Microsoft\Windows\CurrentVersion\Run
   bWatchSubtree=%FALSE%|%FALSE%|%FALSE% ; FALSE means don't watch subkeys, TRUE means watch subkeys as well
   ; dwNotifyFilter can be a one or more of the following REG_NOTIFY_CHANGE_NAME, REG_NOTIFY_CHANGE_ATTRIBUTES, REG_NOTIFY_CHANGE_LAST_SET, REG_NOTIFY_CHANGE_SECURITY
   ; to combine use the | "OR" operator, so for example to be notified for key name and value changes use REG_NOTIFY_CHANGE_NAME | REG_NOTIFY_CHANGE_LAST_SET
   dwNotifyFilter:= REG_NOTIFY_CHANGE_LAST_SET . "|" . REG_NOTIFY_CHANGE_LAST_SET . "|" . REG_NOTIFY_CHANGE_LAST_SET
   ThreadPriority=%THREAD_PRIORITY_ABOVE_NORMAL%|%THREAD_PRIORITY_ABOVE_NORMAL%|%THREAD_PRIORITY_ABOVE_NORMAL%
   StringSplit, RegRoot, RegRoot, |
   StringSplit, regsubkeystring, regsubkeystring, |
   StringSplit, bWatchSubtree, bWatchSubtree, |
   StringSplit, dwNotifyFilter, dwNotifyFilter, |
   StringSplit, ThreadPriority, ThreadPriority, |
   SetTimer, SeperThread, -100
}

Return


ExitRout:

If( A_OSType = "WIN32_NT" && A_OSVersion != "WIN_NT4" ) {
   If HProcess
      DllCall("CloseHandle", Int, HProcess)
   Loop, %regsubkeystring0%
   {
      If hkey%A_Index%
         DllCall("Advapi32.dll\RegCloseKey", UINT, hkey%A_Index%, "UINT")
      If hModule%A_Index%
         DllCall("FreeLibrary", "UInt", hModule%A_Index%)
      If HndThread%A_Index%
      {
         DllCall("TerminateThread", UInt, HndThread%A_Index%, UInt, 0)
         DllCall("CloseHandle", UInt, HndThread%A_Index%)
      }
      If RegWatchAddress%A_Index%
         DllCall("GlobalFree", UInt, RegWatchAddress%A_Index%)
   }
}   


ExitApp


SeperThread:

CPU=1
PROCESS_SET_INFORMATION=0x200
PROCESS_QUERY_INFORMATION=0x400
Process, Exist
If!(CPID := ErrorLevel) {
   MsgBox, Error Getting PID of Current AutoHotkey Process.  Script Will Abort.
   ExitApp
}
If!(HProcess := DllCall("OpenProcess", Int, PROCESS_SET_INFORMATION | PROCESS_QUERY_INFORMATION, Int, 0, Int, CPID)) {
   MsgBox, Unable to Retrieve Handle for Current AutoHotkey Process.  Aborting Script.
   ExitApp
}
If!(DllCall("SetProcessAffinityMask", Int, HProcess, Int, CPU)) {
   MsgBox, Unable to Set Affinity for Current AutoHotkey Process.  Aborting Script.
   ExitApp
}

If(DllCall("CloseHandle", Int, HProcess))
   HProcess=
Loop, %regsubkeystring0%
{
   If !(RegWatchAddress%A_Index% := RegisterCallback("RegWatch" . A_Index))
      Continue
   If !(DllCall("VirtualProtect", UInt, RegWatchAddress%A_Index%, UInt, 22, UInt, 0x40, UIntP, 0)) {
      ; On DEP Enabled Systems that don't have the executeable responsible for running this DEP Exception enabled this failed attempt will result in the program crashing
      RegWatchAddress%A_Index% := DllCall("GlobalFree", UInt, RegWatchAddress%A_Index%)
      Continue
   }
   If !(VarSetCapacity(Num%A_Index%, 4, 0)) {
      RegWatchAddress%A_Index% := DllCall("GlobalFree", UInt, RegWatchAddress%A_Index%)
      Continue
   }
   NumPut(A_Index, Num%A_Index%, 0, "UInt")
   HandThreadID%A_Index%=0
   If (HndThread%A_Index% := dllCall("CreateThread", UInt, 0, UInt, 0, UInt, RegWatchAddress%A_Index%, UInt, &Num%A_Index%, UInt, 0, UIntP, HandThreadID%A_Index%)) {
      ; Note setting thread priority is relative to the processes priority unless critical is specified
      ; The below works, however only those who KNOW they NEED the following should uncomment this because without changing the main thread's priority to at least equal to or greater than this thread's one will hang the app when attempting to exit it
      ;If !(dllcall("SetThreadPriority", UINT, HndThread%A_Index%, INT, ThreadPriority%A_Index%))
      ;   MsgBox, % "Error Changing Thread Priority for Thread with Registry Key " . (RegRoot%A_Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%A_Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%A_Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%A_Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%A_Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG") . (regsubkeystring%A_Index% ? "\" . regsubkeystring%A_Index% : "")
      
   }
   Else {
      RegWatchAddress%A_Index% := DllCall("GlobalFree", UInt, RegWatchAddress%A_Index%)
      Continue
   }
}

Return


RegWatch1(Index) {
Local   ReturnValue
   Critical
   Index := NumGet(Index+0, 0, "UINT")
   If !(VarSetCapacity(hkey%Index%, 4, 0)) {
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "No Such Variable hkey" . Index
      Return
   }
   If !(hModule%Index% := DllCall("LoadLibrary", "str", "Advapi32.dll")) {
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "Unable to Load Dll Advapi32 for Registry Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG") . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "")
      Return
   }
   If(dllcall("Advapi32.dll\RegOpenKeyExA", UINT, RegRoot%Index%, Str, regsubkeystring%Index%, UINT, 0, UINT, KEY_NOTIFY, UINTP, hKey%Index%)) {
      If(DllCall("FreeLibrary", "UInt", hModule%Index%))
         hModule%Index%=
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "Invalid Key or Insufficient Rights for Opening Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG") . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "")
      Return
   }
   Critical, Off
   ReturnValue := dllcall("Advapi32.dll\RegNotifyChangeKeyValue", UINT, hKey%Index%, INT, bWatchSubtree%Index%, UINT, dwNotifyFilter%Index%, UINT, 0, INT, 0, "UINT")
   Critical
Begin_RegWatch1:
   If !ReturnValue
   {
      MsgBox, % "Something Has Changed in/with Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG")   . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "") . (bWatchSubtree%Index% = TRUE ? " or One of its Subkeys" : "")
      ; Your Code Goes Here
      Critical, Off
      ReturnValue := dllcall("Advapi32.dll\RegNotifyChangeKeyValue", UINT, hKey%Index%, INT, bWatchSubtree%Index%, UINT, dwNotifyFilter%Index%, UINT, 0, INT, 0, "UINT")
      Critical
      GoTo Begin_RegWatch%Index%
   }
   Else {
      hkey%Index% := DllCall("Advapi32.dll\RegCloseKey", UINT, hkey%Index%, "UINT")
      If(DllCall("FreeLibrary", "UInt", hModule%Index%))
         hModule%Index%=
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "Unable to Register for Registry Notification Events for Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG") . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "")
      Return
   }
}


RegWatch2(Index) {
Local   ReturnValue
   Critical
   Index := NumGet(Index+0, 0, "UINT")
   If !(VarSetCapacity(hkey%Index%, 4, 0)) {
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "No Such Variable hkey" . Index
      Return
   }
   If !(hModule%Index% := DllCall("LoadLibrary", "str", "Advapi32.dll")) {
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "Unable to Load Dll Advapi32 for Registry Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG") . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "")
      Return
   }
   If(dllcall("Advapi32.dll\RegOpenKeyExA", UINT, RegRoot%Index%, Str, regsubkeystring%Index%, UINT, 0, UINT, KEY_NOTIFY, UINTP, hKey%Index%)) {
      If(DllCall("FreeLibrary", "UInt", hModule%Index%))
         hModule%Index%=
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "Invalid Key or Insufficient Rights for Opening Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG") . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "")
      Return
   }
   Critical, Off
   ReturnValue := dllcall("Advapi32.dll\RegNotifyChangeKeyValue", UINT, hKey%Index%, INT, bWatchSubtree%Index%, UINT, dwNotifyFilter%Index%, UINT, 0, INT, 0, "UINT")
   Critical
Begin_RegWatch2:
   If !ReturnValue
   {
      MsgBox, % "Something Has Changed in/with Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG")   . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "") . (bWatchSubtree%Index% = TRUE ? " or One of its Subkeys" : "")
      ; Your Code Goes Here
      Critical, Off
      ReturnValue := dllcall("Advapi32.dll\RegNotifyChangeKeyValue", UINT, hKey%Index%, INT, bWatchSubtree%Index%, UINT, dwNotifyFilter%Index%, UINT, 0, INT, 0, "UINT")
      Critical
      GoTo Begin_RegWatch%Index%
   }
   Else {
      hkey%Index% := DllCall("Advapi32.dll\RegCloseKey", UINT, hkey%Index%, "UINT")
      If(DllCall("FreeLibrary", "UInt", hModule%Index%))
         hModule%Index%=
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "Unable to Register for Registry Notification Events for Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG") . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "")
      Return
   }
}


RegWatch3(Index) {
Local   ReturnValue
   Critical
   Index := NumGet(Index+0, 0, "UINT")
   If !(VarSetCapacity(hkey%Index%, 4, 0)) {
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "No Such Variable hkey" . Index
      Return
   }
   If !(hModule%Index% := DllCall("LoadLibrary", "str", "Advapi32.dll")) {
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "Unable to Load Dll Advapi32 for Registry Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG") . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "")
      Return
   }
   If(dllcall("Advapi32.dll\RegOpenKeyExA", UINT, RegRoot%Index%, Str, regsubkeystring%Index%, UINT, 0, UINT, KEY_NOTIFY, UINTP, hKey%Index%)) {
      If(DllCall("FreeLibrary", "UInt", hModule%Index%))
         hModule%Index%=
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "Invalid Key or Insufficient Rights for Opening Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG") . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "")
      Return
   }
   Critical, Off
   ReturnValue := dllcall("Advapi32.dll\RegNotifyChangeKeyValue", UINT, hKey%Index%, INT, bWatchSubtree%Index%, UINT, dwNotifyFilter%Index%, UINT, 0, INT, 0, "UINT")
   Critical
Begin_RegWatch3:
   If !ReturnValue
   {
      MsgBox, % "Something Has Changed in/with Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG")   . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "") . (bWatchSubtree%Index% = TRUE ? " or One of its Subkeys" : "")
      ; Your Code Goes Here
      Critical, Off
      ReturnValue := dllcall("Advapi32.dll\RegNotifyChangeKeyValue", UINT, hKey%Index%, INT, bWatchSubtree%Index%, UINT, dwNotifyFilter%Index%, UINT, 0, INT, 0, "UINT")
      Critical
      GoTo Begin_RegWatch%Index%
   }
   Else {
      hkey%Index% := DllCall("Advapi32.dll\RegCloseKey", UINT, hkey%Index%, "UINT")
      If(DllCall("FreeLibrary", "UInt", hModule%Index%))
         hModule%Index%=
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "Unable to Register for Registry Notification Events for Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG") . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "")
      Return
   }
}


RegWatch4(Index) {
Local   ReturnValue
   Critical
   Index := NumGet(Index+0, 0, "UINT")
   If !(VarSetCapacity(hkey%Index%, 4, 0)) {
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "No Such Variable hkey" . Index
      Return
   }
   If !(hModule%Index% := DllCall("LoadLibrary", "str", "Advapi32.dll")) {
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "Unable to Load Dll Advapi32 for Registry Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG") . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "")
      Return
   }
   If(dllcall("Advapi32.dll\RegOpenKeyExA", UINT, RegRoot%Index%, Str, regsubkeystring%Index%, UINT, 0, UINT, KEY_NOTIFY, UINTP, hKey%Index%)) {
      If(DllCall("FreeLibrary", "UInt", hModule%Index%))
         hModule%Index%=
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "Invalid Key or Insufficient Rights for Opening Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG") . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "")
      Return
   }
   Critical, Off
   ReturnValue := dllcall("Advapi32.dll\RegNotifyChangeKeyValue", UINT, hKey%Index%, INT, bWatchSubtree%Index%, UINT, dwNotifyFilter%Index%, UINT, 0, INT, 0, "UINT")
   Critical
Begin_RegWatch4:
   If !ReturnValue
   {
      MsgBox, % "Something Has Changed in/with Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG")   . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "") . (bWatchSubtree%Index% = TRUE ? " or One of its Subkeys" : "")
      ; Your Code Goes Here
      Critical, Off
      ReturnValue := dllcall("Advapi32.dll\RegNotifyChangeKeyValue", UINT, hKey%Index%, INT, bWatchSubtree%Index%, UINT, dwNotifyFilter%Index%, UINT, 0, INT, 0, "UINT")
      Critical
      GoTo Begin_RegWatch%Index%
   }
   Else {
      hkey%Index% := DllCall("Advapi32.dll\RegCloseKey", UINT, hkey%Index%, "UINT")
      If(DllCall("FreeLibrary", "UInt", hModule%Index%))
         hModule%Index%=
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "Unable to Register for Registry Notification Events for Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG") . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "")
      Return
   }
}


RegWatch5(Index) {
Local   ReturnValue
   Critical
   Index := NumGet(Index+0, 0, "UINT")
   If !(VarSetCapacity(hkey%Index%, 4, 0)) {
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "No Such Variable hkey" . Index
      Return
   }
   If !(hModule%Index% := DllCall("LoadLibrary", "str", "Advapi32.dll")) {
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "Unable to Load Dll Advapi32 for Registry Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG") . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "")
      Return
   }
   If(dllcall("Advapi32.dll\RegOpenKeyExA", UINT, RegRoot%Index%, Str, regsubkeystring%Index%, UINT, 0, UINT, KEY_NOTIFY, UINTP, hKey%Index%)) {
      If(DllCall("FreeLibrary", "UInt", hModule%Index%))
         hModule%Index%=
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "Invalid Key or Insufficient Rights for Opening Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG") . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "")
      Return
   }
   Critical, Off
   ReturnValue := dllcall("Advapi32.dll\RegNotifyChangeKeyValue", UINT, hKey%Index%, INT, bWatchSubtree%Index%, UINT, dwNotifyFilter%Index%, UINT, 0, INT, 0, "UINT")
   Critical
Begin_RegWatch5:
   If !ReturnValue
   {
      MsgBox, % "Something Has Changed in/with Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG")   . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "") . (bWatchSubtree%Index% = TRUE ? " or One of its Subkeys" : "")
      ; Your Code Goes Here
      Critical, Off
      ReturnValue := dllcall("Advapi32.dll\RegNotifyChangeKeyValue", UINT, hKey%Index%, INT, bWatchSubtree%Index%, UINT, dwNotifyFilter%Index%, UINT, 0, INT, 0, "UINT")
      Critical
      GoTo Begin_RegWatch%Index%
   }
   Else {
      hkey%Index% := DllCall("Advapi32.dll\RegCloseKey", UINT, hkey%Index%, "UINT")
      If(DllCall("FreeLibrary", "UInt", hModule%Index%))
         hModule%Index%=
      RegWatchAddress%Index% := DllCall("GlobalFree", UInt, RegWatchAddress%Index%)
      If(DllCall("CloseHandle", UInt, HndThread%Index%))
         HndThread%Index%=
      MsgBox, % "Unable to Register for Registry Notification Events for Key " . (RegRoot%Index% = HKEY_CLASSES_ROOT ? "HKEY_CLASSES_ROOT" : RegRoot%Index% = HKEY_CURRENT_USER ? "HKEY_CURRENT_USER" : RegRoot%Index% = HKEY_LOCAL_MACHINE ? "HKEY_LOCAL_MACHINE" : RegRoot%Index% = HKEY_USERS ? "HKEY_USERS" : RegRoot%Index% = HKEY_CURRENT_CONFIG ? "HKEY_CURRENT_CONFIG") . (regsubkeystring%Index% ? "\" . regsubkeystring%Index% : "")
      Return
   }
}
