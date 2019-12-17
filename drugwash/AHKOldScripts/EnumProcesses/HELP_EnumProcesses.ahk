; Example #4: Retrieves a list of running processes via DllCall then shows them in a MsgBox.

d = `n  ; string separator
s := 4096  ; size of buffers and arrays (4 KB)

Process, Exist  ; sets ErrorLevel to the PID of this running script
; Get the handle of this script with PROCESS_QUERY_INFORMATION (0x0400)
h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ErrorLevel)
; Open an adjustable access token with this process (TOKEN_ADJUST_PRIVILEGES = 32)
DllCall("Advapi32.dll\OpenProcessToken", "UInt", h, "UInt", 32, "UIntP", t)
VarSetCapacity(ti, 16, 0)  ; structure of privileges
NumPut(1, ti, 0, 4)  ; one entry in the privileges array...
; Retrieves the locally unique identifier of the debug privilege:
DllCall("Advapi32.dll\LookupPrivilegeValueA", "UInt", 0, "Str", "SeDebugPrivilege", "UIntP", luid)
NumPut(luid, ti, 4, 8)
NumPut(2, ti, 12, 4)  ; enable this privilege: SE_PRIVILEGE_ENABLED = 2
; Update the privileges of this process with the new access token:
DllCall("Advapi32.dll\AdjustTokenPrivileges", "UInt", t, "Int", false, "UInt", &ti, "UInt", 0, "UInt", 0, "UInt", 0)
DllCall("CloseHandle", "UInt", h)  ; close this process handle to save memory

hModule := DllCall("LoadLibrary", "Str", "Psapi.dll")  ; increase performance by preloading the libaray
s := VarSetCapacity(a, s)  ; an array that receives the list of process identifiers:
DllCall("Psapi.dll\EnumProcesses", "UInt", &a, "UInt", s, "UIntP", r)
Loop, % r // 4  ; parse array for identifiers as DWORDs (32 bits):
{
   id := NumGet(a, A_Index * 4)
   ; Open process with: PROCESS_VM_READ (0x0010) | PROCESS_QUERY_INFORMATION (0x0400)
   h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id)
   VarSetCapacity(n, s, 0)  ; a buffer that receives the base name of the module:
   e := DllCall("Psapi.dll\GetModuleBaseNameA", "UInt", h, "UInt", 0, "Str", n, "Char", s)
   DllCall("CloseHandle", "UInt", h)  ; close process handle to save memory
   If n  ; if image is not null add to list:
      l = %l%%n%%d%
}
DllCall("FreeLibrary", "UInt", hModule)  ; unload the library to free memory
; Remove the first and last items in the list (possibly ASCII signitures)
StringMid, l, l, InStr(l, d) + 1, InStr(l, d, false, 0) - 2 - InStr(l, d)
StringReplace, l, l, %d%, %d%, UseErrorLevel  ; gets the number of processes
Sort, l, C  ; uncomment this line to sort the list alphabetically
MsgBox, 0, %ErrorLevel% Processes, %l%
