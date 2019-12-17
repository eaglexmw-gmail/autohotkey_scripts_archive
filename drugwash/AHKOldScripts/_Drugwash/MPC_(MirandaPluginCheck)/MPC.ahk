mirver := 524310
debug :=
Loop, *.dll
{
VarSetCapacity(LOADED_IMAGE, 48, 0)
VarSetCapacity(LOADED_IMAGE_ModuleName, 255, 0)
module := A_LoopFileName
map := DllCall("imagehlp.dll\MapAndLoad", "str", module, "str", 0, "UInt", &LOADED_IMAGE, "UChar", 1, "UChar", 1, "Int")	; OK
if ! map
	if A_LastError
		MsgBox, Error mapping %A_LastError%

ModuleName := NumGet(LOADED_IMAGE, 0, "UInt")
;DllCall("kernel32.dll\lstrcpy", "UInt *", LOADED_IMAGE_ModuleName, "UInt *", ModuleName, UInt)
doName := DllCall("kernel32.dll\lstrcpy", "UInt*", LOADED_IMAGE_ModuleName, "UInt*", ModuleName, UInt)
if ! doName
	if A_LastError
		MsgBox, Error copying name %A_LastError%
name := DllCall("kernel32.dll\MulDiv", "int*", ModuleName, "int", 1, "int", 1, "str")
LOADED_IMAGE_hFile := NumGet(LOADED_IMAGE, 4, "UInt")
LOADED_IMAGE_MappedAddress := NumGet(NumGet(LOADED_IMAGE, 8, "UInt"), 0, "UInt")
LOADED_IMAGE_FileHeader := NumGet(NumGet(LOADED_IMAGE, 12, "UInt"), 0, "UInt")
LOADED_IMAGE_LastRvaSection := NumGet(NumGet(LOADED_IMAGE, 16, "UInt"), 0, "UInt")
LOADED_IMAGE_NumberOfSections := NumGet(LOADED_IMAGE, 20, "UInt")
LOADED_IMAGE_Sections := NumGet(NumGet(LOADED_IMAGE, 24, "UInt"), 0, "UInt")
LOADED_IMAGE_Characteristics := NumGet(LOADED_IMAGE, 28, "UInt")
LOADED_IMAGE_fSystemImage := NumGet(LOADED_IMAGE, 32, "UChar")
LOADED_IMAGE_fDOSImage := NumGet(LOADED_IMAGE, 33, "UChar")
LOADED_IMAGE_fReadOnly := NumGet(LOADED_IMAGE, 34, "UChar")
LOADED_IMAGE_Version := NumGet(LOADED_IMAGE, 35, "UChar")
LOADED_IMAGE_Links := NumGet(LOADED_IMAGE, 36, "DOUBLE")
LOADED_IMAGE_SizeOfImage := NumGet(LOADED_IMAGE, 44, "UInt")

hModule := LOADED_IMAGE_hFile
load := DllCall("GetProcAddress", "UInt", hModule, "Str", "Load")
info  := DllCall("GetProcAddress", "UInt", hModule, "Str", "MirandaPluginInfo")
infoex := DllCall("GetProcAddress", "UInt", hModule, "Str", "MirandaPluginInfoEx")
inter := DllCall("GetProcAddress", "UInt", hModule, "Str", "MirandaPluginInterfaces")
unload := DllCall("GetProcAddress", "UInt", hModule, "Str", "Unload")
isplug := ( load && ( info || ( infoex && inter )) && unload )  ? "" : "not"
/*
if ! load
		{
		MsgBox,This is %isplug% a Miranda plug-in!
DllCall("imagehlp.dll\UnMapAndLoad", "UInt", &LOADED_IMAGE)	; OK
		Continue
		}
*/
if !infoex
	st := DllCall(module . "\MirandaPluginInfo", "UInt", mirver, "cdecl UInt")
else
	st := DllCall(module . "\MirandaPluginInfoEx", "UInt", mirver, "cdecl UInt")
codebase := st + &(LOADED_IMAGE_MappedAddress + 0x3C + 0x100) + &(LOADED_IMAGE_MappedAddress + 0x3C + 0x110)

MsgBox,
(
codebase = %codebase%

load:`t%load%
info:`t%info%
infoex:`t%infoex%
inter:`t%inter%
unload:`t%unload%

ModuleName:`t%LOADED_IMAGE_ModuleName% %name%
hFile:`t`t%LOADED_IMAGE_hFile%
MappedAddress:`t%LOADED_IMAGE_MappedAddress%
FileHeader:`t%LOADED_IMAGE_FileHeader%
LastRvaSection:`t%LOADED_IMAGE_LastRvaSection%
NumberOfSections:`t%LOADED_IMAGE_NumberOfSections%
Sections:`t`t%LOADED_IMAGE_Sections%
Characteristics:`t%LOADED_IMAGE_Characteristics%
fSystemImage:`t%LOADED_IMAGE_fSystemImage%
fDOSImage:`t%LOADED_IMAGE_fDOSImage%
fReadOnly:`t%LOADED_IMAGE_fReadOnly%
Version:`t`t%LOADED_IMAGE_Version%
Links:`t`t%LOADED_IMAGE_Links%
SizeOfImage:`t%LOADED_IMAGE_SizeOfImage%
)

unmap := DllCall("imagehlp.dll\UnMapAndLoad", "UInt", &LOADED_IMAGE)	; OK
if ! unmap
	if A_LastError
		MsgBox, Error unmapping %A_LastError%
}
return

GuiClose:
ExitApp
