; by Drugwash 2011-2012
; AHK screws up certain bytes when saving a variable to file
; this is a replacement for AHK's built-in function FileAppend
; var is a variable (buffer) name or a buffer's address

FileCreate(name, ByRef var="", sz="")
{
hFile := DllCall("CreateFile", "Str", name, "UInt", 0x40000000, "UInt", 1, "UInt", 0, "UInt", 4, "UInt", 0, "UInt", 0)
if var is integer
	DllCall("WriteFile", "UInt", hFile, "UInt", var, "UInt", sz, "UIntP", realLen, "UInt", 0)
else if (var <> "")
	DllCall("WriteFile", "UInt", hFile, "UInt", &var, "UInt", (sz ? sz : StrLen(var)), "UIntP", realLen, "UInt", 0)
DllCall("CloseHandle", "UInt", hFile)
return (sz==realLen)
}
