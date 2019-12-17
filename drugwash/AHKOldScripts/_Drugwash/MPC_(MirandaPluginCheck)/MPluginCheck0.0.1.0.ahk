;mirver := "0.8.0.22"
mirver := 524310
debug :=
VarSetCapacity(MIRPLINF, 56)
VarSetCapacity(_MUUID, 16)

StructCreate("_MUUID"
, "Muuid1		as UInt"
, "Muuid2		as UShort"
, "Muuid3		as UShort"
, "Muuid4		as UChar"
, "Muuid5		as UChar"
, "Muuid6		as UChar"
, "Muuid7		as UChar"
, "Muuid8		as UChar"
, "Muuid9		as UChar"
, "Muuid10	as UChar"
, "Muuid11	as UChar")

/*
; the struct is made of pointers to the real addresses
; , "UShort", size, "Str", name, "UInt", version, "Str", details, "Str", author, "Str", mail, "Str", copy, "Str", web, "Int", trans, "Int", builtin, "Str", uuid

StructCreate("MIRPLINF"
, "Msize		as Int"
, "Mname		as Str" pointer
, "Mversion	as dword"
, "Mdetails	as Str" pointer
, "Mauthor	as Str" pointer
, "Mmail		as Str" pointer
, "Mcopy		as Str" pointer
, "Mweb		as Str" pointer
, "Mtrans		as byte"
, "Mbuiltin		as Int"
, "Muuid		as Str") structure
*/

StructCreate("MIRPLINFOLD"
, "Msize		as UInt"
, "Mname		as UInt"
, "Mversion	as UInt"
, "Mdetails	as UInt"
, "Mauthor	as UInt"
, "Mmail		as UInt"
, "Mcopy		as UInt"
, "Mweb		as UInt"
, "Mtrans		as UInt"
, "Mbuiltin		as UInt")
/*
StructCreate("MIRPLINF"
, "Msize		as UInt"
, "Mname		as UInt"
, "Mversion	as UInt"
, "Mdetails	as UInt"
, "Mauthor	as UInt"
, "Mmail		as UInt"
, "Mcopy		as UInt"
, "Mweb		as UInt"
, "Mtrans		as UInt"
, "Mbuiltin		as UInt"
, "Muuid1		as UInt"
, "Muuid2		as UShort"
, "Muuid3		as UShort"
, "Muuid4		as UChar"
, "Muuid5		as UChar"
, "Muuid6		as UChar"
, "Muuid7		as UChar"
, "Muuid8		as UChar"
, "Muuid9		as UChar"
, "Muuid10	as UChar"
, "Muuid11	as UChar")
*/
; , "Muuid		as UInt")

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
;	MIRPLINF := DllCall(module . "\MirandaPluginInfo", "UInt", mirver, "cdecl Str" Msize)
	MIRPLINF := DllCall(module . "\MirandaPluginInfo", "UInt", mirver, "cdecl UInt *")
;	DllCall(module . "\MirandaPluginInfo", "UInt", mirver, "cdecl UInt")
	err1 := ErrorLevel
	}
else
	{
;	MIRPLINF := DllCall(module . "\MirandaPluginInfoEx", "UInt", mirver, "cdecl Str" Msize)
;	DllCall(module . "\MirandaPluginInfoEx", "UInt", mirver, "cdecl Str" MIRPLINF)
	MIRPLINF := DllCall(module . "\MirandaPluginInfoEx", "UInt", mirver, "cdecl UIntP")
	err1 := ErrorLevel
	DllCall(module . "\MirandaPluginInterfaces", "cdecl Str") ;? "OK" : "failed"
	err2 := ErrorLevel
	}
;Struct?("MIRPLINF")

comp := infoex ? "" : "not "
ex := infoex ? "Ex" : ""
start := infoex ? infoex : info
/*
off :=
Loop, 10
	{
	addr%A_Index% := NumGet(&MIRPLINF, off, "UInt")
	off += 4
	}
*/
addr := NumGet(start+0, 1, "UInt")
off :=
Loop, 11
	{
	addr%A_Index%a := NumGet(addr+0, off, "UInt")
	off += 4
	}
if infoex
	{
	addr12a := NumGet(addr+0, 44, "UShort")
	addr13a := NumGet(addr+0, 46, "UShort")
	off := 48
	pos := 14
	Loop, 8
		{
		addr%pos%a := NumGet(addr+0, off, "UChar")
		pos += 1
		off += 1
		}
	}
else
	addr11a :=

PLUGIN_MAKE_VERSION(addr3a)
/*
SetFormat, integer, hex
load += 0
start += 0
unload += 0
addr1 += 0
addr2 += 0
addr3 += 0
addr4 += 0
addr5 += 0
addr6 += 0
addr7 += 0
addr8 += 0
addr9 += 0
addr10 += 0
addr11 += 0
addr12 += 0
addr13 += 0
addr14 += 0
addr15 += 0
addr16 += 0
addr17 += 0
addr18 += 0
addr19 += 0
addr20 += 0
addr21 += 0

SetFormat, integer, DEC
*/
; addr1 is struct length, we leave it alone
Msize := addr1a		; struct size
;Loop, 256
;	Mname := Mname . Chr(NumGet(&addr2a, A_Index, "UChar"))	; name
;Mname := NumGet(addr2a, 0, "Str")	; name
Mname := DllCall("msvcrt.dll\memmove", "UInt", addr2a, "UChar", 255)
if ErrorLevel
MsgBox, Error %ErrorLevel%
;DllCall("RtlCopyMemory", UIntP, &Mname, UIntP, &addr2a, UChar, 255)
; addr3 is decoded as version number
;Mdetails := NumGet(&addr4a, 0, "UChar")	; details
Mdetails := DllCall("msvcrt.dll\strcpy", "UInt", addr4a)
if ErrorLevel
MsgBox, Error %ErrorLevel%
Mauthor := NumGet(addr5a, 0, "UChar")	; author
Mmail := NumGet(addr6a, 0, "UChar")	; e-mail
Mcopy := NumGet(addr7a, 0, "UChar")	; copyright
Mweb := NumGet(addr8a, 0, "UChar")	; web address
Mtrans := addr9a	; transient
Mbuiltin := addr10a	; built-in replacement

MsgBox,
(
• The %module% plug-in is %comp%0.8+ compatible !
• MIRPLINF is %MIRPLINF%
• Load located at %load%
• PluginInfo%ex% struct located at %addr%, called from %start%
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

/*
size: %MIRPLINF?Msize% bytes
name: %MIRPLINF?Mname%
version: %Va%.%Vb%.%Vc%.%Vd%
details: %MIRPLINF?Mdetails%
author: %MIRPLINF?Mauthor%
e-mail: %MIRPLINF?Mmail%
copyright: %MIRPLINF?Mcopy%
web address: %MIRPLINF?Mweb%
transient: %MIRPLINF?Mtrans%
replaces built-in: %MIRPLINF?Mbuiltin%
MUUID: %MIRPLINF?Muuid%
*/

DllCall("FreeLibrary", "UInt", hModule)
gosub log
gosub clearvar
}

GuiClose:
ExitApp

#Include, %A_ScriptDir%\ahkstructlib2.ahk

clearvar:
Msize :=
Mname :=
Mdetails :=
Mauthor :=
Mmail :=
Mcopy :=
Mweb :=
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
