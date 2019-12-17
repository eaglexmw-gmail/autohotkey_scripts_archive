mirver := 524310
Loop *.dll
{
VarSetCapacity(info, 512, 0)
module := A_LoopFileName
FileRead, info, m512 %module%
peheader := NumGet(info, 60, "UInt")
codebase := NumGet(info, peheader + 44, "UInt")
section := NumGet(info, peheader + 60, "UInt")
imagebase := NumGet(info, peheader + 52, "UInt")
offset := codebase + section
hModule := DllCall("LoadLibrary", "str", module)
load := DllCall("GetProcAddress", "UInt", hModule, "Str", "Load")
info  := DllCall("GetProcAddress", "UInt", hModule, "Str", "MirandaPluginInfo")
infoex := DllCall("GetProcAddress", "UInt", hModule, "Str", "MirandaPluginInfoEx")
inter := DllCall("GetProcAddress", "UInt", hModule, "Str", "MirandaPluginInterfaces")
unload := DllCall("GetProcAddress", "UInt", hModule, "Str", "Unload")
isplug := ( load && ( info || ( infoex && inter )) && unload )  ? "" : "not"
if ! load
		{
		MsgBox,This is %isplug% a Miranda plug-in!
		DllCall("FreeLibrary", "UInt", hModule)
		Continue
		}
if !infoex
	{
	VarSetCapacity(PLUGININFO, 40, 0)
	NumPut(40, PLUGININFO, 0, "UInt")
	PLUGININFO := DllCall(module . "\MirandaPluginInfo", "UInt", mirver, "cdecl UInt*")
	err1 := ErrorLevel
	}
else
	{
	VarSetCapacity(PLUGININFO, 56, 0)
	NumPut(56, PLUGININFO, 0, "UInt")
	PLUGININFO := DllCall(module . "\MirandaPluginInfoEx", "UInt", mirver, "cdecl UInt*")
	err1 := ErrorLevel
;	DllCall(module . "\MirandaPluginInterfaces", "cdecl Str")
;	err2 := ErrorLevel
	}
start := infoex ? infoex : info
addr := NumGet(start+0, 1, "UInt")
Loop, 10
	addr%A_Index% := NumGet(addr+0, (A_Index-1)*4, "UInt")
Loop, 256
	{
;	name := name . Chr(NumGet(&addr2, A_Index-1, "UChar"))
	name := name . Chr(NumGet(419585108, A_Index-1, "UChar"))
	}

MsgBox,
(
%module%, codebase=%codebase%, section=%section%, imagebase=%imagebase%
Error: %err1% (%err2%)
%addr1%
%name% %addr2%
%addr3%
%addr4%
%addr5%
%addr6%
%addr7%
%addr8%
%addr9%
%addr10%
)
name :=
details :=
}

GuiClose:
ExitApp

