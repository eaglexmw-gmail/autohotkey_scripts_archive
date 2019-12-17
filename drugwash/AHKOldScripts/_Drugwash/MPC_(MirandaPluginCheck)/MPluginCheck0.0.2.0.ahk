;mirver := "0.8.0.22"
mirver := 524310
debug :=


/*
; the struct is made of pointers to the real addresses
; , "UShort", size, "Str", name, "UInt", version, "Str", details, "Str", author, "Str", mail, "Str", copy, "Str", web, "Int", trans, "Int", builtin, "Str", uuid
*/
StructCreate("BASIC_PLUGIN_INFO"
, "hInst		as UInt"
, "load		as UInt"
, "unload 		as UInt"
, "info		as UInt"
, "infoex		as UInt"
, "inter		as UInt"
, "dbinfo		as UInt"
, "clistlink		as UInt"
, "plugininfo	as UInt"
, "dblink		as UInt")

Loop, *.dll
{
;module := A_LoopFileLongPath
module := A_LoopFileName
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
VarSetCapacity(MIRPLINF, 40, 0)
;	DllCall(module . "\MirandaPluginInfo", "UInt", mirver, "cdecl UInt")
	MIRPLINF := DllCall(module . "\MirandaPluginInfo", "UInt", mirver, cdecl)
	err1 := ErrorLevel
	}
else
	{
VarSetCapacity(MIRPLINF, 56, 0)
;	DllCall(module . "\MirandaPluginInfoEx", "UInt", mirver, "cdecl Str" MIRPLINF)
	MIRPLINF := DllCall(module . "\MirandaPluginInfoEx", "UInt", mirver, cdecl)
	err1 := ErrorLevel
	DllCall(module . "\MirandaPluginInterfaces", "cdecl Str") ;? "OK" : "failed"
	err2 := ErrorLevel
	}

comp := infoex ? "" : "not "
ex := infoex ? "Ex" : ""
start := infoex ? infoex : info
;addr := NumGet(start+0, 1, "UInt")	; bad
addr := NumGet(MIRPLINF+0, 0, "UInt")
off :=
gosub clearvar
VarSetCapacity(MUUID, 16)
Loop, 11
	{
;	addr%A_Index%a := NumGet(addr, off, "UInt")
	addr%A_Index%a := NumGet(MIRPLINF+0, off, "UInt")	; good
	off += 4
	}
if infoex
	{
;	addr12a := NumGet(addr, 44, "UShort")
;	addr13a := NumGet(addr, 46, "UShort")
	addr12a := NumGet(MIRPLINF+0, 44, "UShort")
	addr13a := NumGet(MIRPLINF+0, 46, "UShort")
	off := 48
	pos := 14
	Loop, 8
		{
		addr%pos%a := NumGet(MIRPLINF+0, off, "UChar")
;		addr%pos%a := NumGet(addr, off, "UChar")
		pos += 1
		off += 1
		}
	}
else
	addr11a :=

PLUGIN_MAKE_VERSION(addr3a)

; addr1 is struct length, we leave it alone
Msize := addr1a		; struct size
Mname := GETSTR(addr2a)
; addr3 is decoded as version number
Mdetails := GETSTR(addr4a)	; details
Mauthor := GETSTR(addr5a)	; author
Mmail := GETSTR(addr6a)	; e-mail
Mcopy := GETSTR(addr7a)	; copyright
Mweb := GETSTR(addr8a)	; web address
Mtrans := addr9a	; transient
Mbuiltin := addr10a	; built-in replacement

MsgBox,
(
• The %module% plug-in is %comp%0.8+ compatible !
• MIRPLINF is %MIRPLINF%
• Load located at %load%
• PluginInfo%ex% struct length %addr%, called from %start%
• Unload located at %unload%
%addr1a%
%addr2a%
%addr3a%
%addr4a%
%addr5a%
%addr6a%
%addr7a%
%addr8a%
%addr9a%
%addr10a%
{%addr11a%, %addr12a%, %addr13a%, {%addr14a%, %addr15a%, %addr16a%, %addr17a%, %addr18a%, %addr19a%, %addr20a%, %addr21a%}}


Function call returned %err1%.

MirandaPluginInfo%ex% struct:
size: %Msize% bytes
name: %Mname%
version: %Va%.%Vb%.%Vc%.%Vd%
details: %Mdetails%
author: %Mauthor%
e-mail: %Mmail%
copyright: %Mcopy%
web address: %Mweb%
transient: %Mtrans%
replaces built-in: %Mbuiltin%
MUUID: %Muuid%
)

DllCall("FreeLibrary", "UInt", hModule)
gosub log
gosub clearvar
}

GuiClose:
ExitApp

#Include, %A_ScriptDir%\ahkstructlib2.ahk

clearvar:
Msize :=
VarSetCapacity(Mname, 256, 0)
VarSetCapacity(Mdetails, 1024, 0)
VarSetCapacity(Mauthor, 256, 0)
VarSetCapacity(Mmail, 128, 0)
VarSetCapacity(Mcopy, 1024, 0)
VarSetCapacity(Mweb, 256, 0)
Mtrans :=
Mbuiltin :=
Loop, 21
	addr%A_Index%a :=
return

log:
if ! debug
	return
		FileSelectFile, log, s26, .\Log.txt, Save log as:, text files (Log.txt)
	if log =
	{
		MsgBox, 12336, Error, You haven't selected a name for saving the log.,
		return
	}
	hFile := DllCall("CreateFile", str, log, Uint, 0x40000000, Uint, 0, Uint, 0, Uint, 2, Uint, 0, Uint, 0)
	if not hFile
	{
	    MsgBox Couldn't create "%log%".
	    return
	}
	DllCall("WriteFile", UInt, hFile, str, MIRPLINF, UInt, mystring, UIntP, BytesActuallyWritten, UInt, 0)
	DllCall("CloseHandle", UInt, hFile)
return

GETSTR(addr)
{
Loop, 1024
	{
	t1 := NumGet(addr+0, A_Index - 1, "UChar")
	if ! t1
		break
	val := val . Chr(t1)
	}
Return val
}

PLUGIN_MAKE_VERSION(make)
{
;(((((DWORD)(a))&0xFF)<<24)|((((DWORD)(b))&0xFF)<<16)|((((DWORD)(c))&0xFF)<<8)|(((DWORD)(d))&0xFF))
Global
Va := (make>>24 & 0xFF)
Vb := (make>>16 & 0xFF)
Vc := (make>>8 & 0xFF)
Vd := (make & 0xFF)
;MsgBox  %make% %Va%, %Vb%, %Vc%, %Vd%
return Va, Vb, Vc, Vd
}
