; Miranda Plug-in Checker by Drugwash
; performs a thorough analysis on a Miranda IM setup
;*****************************************
appname = Miranda Plug-in Checker	; application name
version = 0.0.2.2					; version number
release = October 25, 2008			; release date
type = internal					; release type (internal / public)
iconlocal = mpc.ico					; external icon for uncompiled script
debug = 0						; debug switch (1 = active)
; *****************************************
msg = Failed to find a valid Miranda IM installation. Possible reasons:`n`t1. Wrong path for %appname%`n`t2. Incomplete/corrupt Miranda IM setup`n`nPlease check that Miranda IM is correctly installed and`n %appname% is placed in its main folder`n(or in plugins folder), then relaunch %appname%.`n`n`tThis application will now exit.
msg1 = Cannot find the 'plugins' subfolder
msg2 = Cannot find the main executable (miranda32.exe)
msg3 = Attention: running %appname% in -WhIM mode may take a very long time,`nsince it's scanning all local, mapped and networked drives for the presence of miranda32.exe.`n`nAre you sure you want to perform this task?
; ********** CHECK FOR PARAMETERS *********
if 0 = 1
	{
param = %1%
	param := RegExReplace(param, "[^a-zA-Z]*")
	StringLower, param, param
MsgBox, %param%
	If param in whim,whereismiranda
	MsgBox, 65, Warning, %msg3%
		IfMsgBox Cancel
			ExitApp
	}
; *****************************************
Mexe = miranda32.exe
;mirver := "0.8.0.22"
mirver := 524310
; ****** CHECK CORRECT MIRANDA SETUP ******
SplitPath, A_ScriptFullPath,, path,,, drive
StringRight, plg, path, 7
StringLower, plg, plg
StringTrimRight, path1, path, 7	; if in plugins, should yield C:\Program FIles\Miranda\ or similar
;MsgBox, current path (path)=%path%`nplugins folder (plg)=%plg%`nlower path (path1)=%path1%
p0 := path1 . Mexe
p1 := path . "\*.dll"
p2 := path . "\Plugins"
p3 := path . "\" . Mexe
p4 := path . "\plugins\*.dll"
if plg in plugins
	{
	ifExist %p0%
		path := p1
	else
		goto error
	}
else
	{
	ifExist %p2%
		{
		ifExist %p3%
			{
			path := p4
			}
		else
			goto error
		}
	else
		{
;		MsgBox, path %path%`np0 %p0%`np1 %p1%`np2 %p2%`np3 %p3%`np4 %p4%
		goto error
		}
	}
; *****************************************

/*
; the struct is made of pointers to the real addresses
; , "UShort", size, "Str", name, "UInt", version, "Str", details, "Str", author, "Str", mail, "Str", copy, "Str", web, "Int", trans, "Int", builtin, "Str", uuid
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
*/

; ***************** GUI *******************
Menu, Tray, Icon, .\icons\MPC.ico
Gui, Add, ListView, w550 h200 AltSubmit ReadOnly NoSortHdr Checked -LV0x10 gshowinfo vlist, | |Plug-in|Name|Version|Active|0.8+
GuiControl, -Redraw, list
Gui, Add, Groupbox, x10 y+10 w550 h180, Details
Gui, Add, Text, x15 yp+15 h40 w60 Right, Description:
Gui, Add, Text, x80 yp hp w470 vdesc, %desc%
Gui, Add, Text, x15 y+2 h20 w60 Right, Author(s):
Gui, Add, Text, x80 yp hp w470 vauth, %auth%
Gui, Add, Text, x15 y+2 h20 w60 Right, Copyright:
Gui, Add, Text, x80 yp h20 w470 vcopy, %copy%
Gui, Add, Text, x15 y+2 w60 Right, Contact:
Gui, Add, Text, x80 yp w470 vmail, %mail%
Gui, Add, Text, x15 y+2 w60 Right, Download:
Gui, Font, CBlue Underline
Gui, Add, Text, x80 yp w470 vweb, %web%
Gui, Font
Gui, Add, Text, x15 y+2 w60 Right, MUUID:
Gui, Add, Text, x80 yp w470 vuuid, %uuid%
Gui, Add, Picture, x15 y+8 w16 h-1 Hidden vci0, %A_WorkingDir%\icons\comico0.ico
Gui, Add, Picture, xp yp w16 h-1 Hidden vci1, %A_WorkingDir%\icons\comico1.ico
Gui, Add, Picture, xp yp w16 h-1 Hidden vci2, %A_WorkingDir%\icons\comico2.ico
Gui, Font, W700
Gui, Add, Text, x35 yp+2 w520 vcomp, %comp%
Gui, Font, Norm
Gui, Add, Picture, x10 y400 w16 h-1, %A_WorkingDir%\icons\fansi.ico
Gui, Add, Text, x+2 yp+2, = ANSI`,
Gui, Add, Picture, x+5 y400 w16 h-1, %A_WorkingDir%\icons\funicode.ico
Gui, Add, Text, x+2 yp+2, = Unicode`,
Gui, Add, Picture, x+5 y400 w16 h-1, %A_WorkingDir%\icons\fboth.ico
Gui, Add, Text, x+2 yp+2, = 2in1`,
Gui, Add, Picture, x+5 y400 w16 h-1, %A_WorkingDir%\icons\fbad.ico
Gui, Add, Text, x+2 yp+2, = Not plug-in
Gui, Add, Button, x10 y420 w50 h25, Update
Gui, Add, Button, x+5 yp w60 hp, Clean-up
Gui, Add, Button, x+10 yp w50 hp, Test
Gui, Add, Button, x+260 yp wp hp, About
Gui, Add, Button, x+5 yp wp+10 hp, Exit
icons := IL_Create(5)
LV_SetImageList(icons)
IL_Add(icons, ".\icons\fbad.ico")
IL_Add(icons, ".\icons\fansi.ico")
IL_Add(icons, ".\icons\funicode.ico")
IL_Add(icons, ".\icons\fboth.ico")
; *****************************************
cmp0 := "not "
cmp1 =
cmp2 =
bck0 = however
bck1 = not
bck2 = also

Loop, %path%
{
module := A_LoopFileLongPath
Smodule := A_LoopFileName
hModule := DllCall("LoadLibrary", "str", module)
load := DllCall("GetProcAddress", "UInt", hModule, "Str", "Load")
info  := DllCall("GetProcAddress", "UInt", hModule, "Str", "MirandaPluginInfo")
infoex := DllCall("GetProcAddress", "UInt", hModule, "Str", "MirandaPluginInfoEx")
inter := DllCall("GetProcAddress", "UInt", hModule, "Str", "MirandaPluginInterfaces")
unload := DllCall("GetProcAddress", "UInt", hModule, "Str", "Unload")
isplug := ( load && ( info || ( infoex && inter )) && unload )  ? 1 : 0
if !infoex
	{
	VarSetCapacity(MIRPLINF, 40, 0)
	MIRPLINF := DllCall(module . "\MirandaPluginInfo", "UInt", mirver, cdecl)
	err1 := ErrorLevel
	}
else
	{
	VarSetCapacity(MIRPLINF, 56, 0)
	MIRPLINF := DllCall(module . "\MirandaPluginInfoEx", "UInt", mirver, cdecl)
	err1 := ErrorLevel
;	DllCall(module . "\MirandaPluginInterfaces", "cdecl Str") ;? "OK" : "failed"
	err2 := ErrorLevel
	}

comp := 1
if info && ! infoex
	comp := 0
else if info && infoex
	comp := 2
ex := infoex ? "Ex" : ""
start := infoex ? infoex : info
addr := NumGet(MIRPLINF+0, 0, "UInt")
off :=
gosub clearvar
;VarSetCapacity(MUUID, 16)
Loop, 11
	{
	addr%A_Index%a := NumGet(MIRPLINF+0, off, "UInt")	; good
	off += 4
	}
if infoex
	{
	addr12a := NumGet(MIRPLINF+0, 44, "UShort")
	addr13a := NumGet(MIRPLINF+0, 46, "UShort")
	off := 48
	pos := 14
	Loop, 8
		{
		addr%pos%a := NumGet(MIRPLINF+0, off, "UChar")
		pos += 1
		off += 1
		}
	}
else
	addr11a :=

Msize := addr1a				; struct size (addr1 is struct length, we leave it alone)
Mname := GETSTR(addr2a)		; name
PLUGIN_MAKE_VERSION(addr3a)	; addr3 is decoded as version number
Mdetails := GETSTR(addr4a)		; details
Mauthor := GETSTR(addr5a)		; author
Mmail := GETSTR(addr6a)		; e-mail
Mcopy := GETSTR(addr7a)		; copyright
Mweb := GETSTR(addr8a)		; web address
Mtrans := addr9a				; transient
Mbuiltin := addr10a				; built-in replacement
Loop, 11
	{
	t := 10 + A_Index
	MKHEX(addr%t%a)
	a%A_Index% := addr%t%a
	}
Muuid := "{" . a1 . ", " . a2 . ", " . a3 . ", {" . a4 . ", " . addr15a . ", " . addr16a . ", " . addr17a . ", " . addr18a . ", " . addr19a . ", " . addr20a . ", " . addr21a . "}}"
/*
MsgBox,
(
• MIRPLINF pointer is %MIRPLINF%
• Load located at %load%
• PluginInfo%ex% at %start%, length %addr%
• Unload located at %unload%
• Function call returned %err1% (%err2%).
• The %module% plug-in is %comp%0.8+ compatible !
• It is %back% backwards compatible with 0.7 and older!

MirandaPluginInfo%ex% struct:
size: %Msize% bytes
name: %Mname%
version: %Mversion%
details: %Mdetails%
author: %Mauthor%
e-mail: %Mmail%
copyright: %Mcopy%
web address: %Mweb%
transient: %Mtrans%
replaces built-in: %Mbuiltin%
MUUID: %Muuid%
)
*/
DllCall("FreeLibrary", "UInt", hModule)
if ! comp
	cver = No
else if comp = 1
	cver = Yes
else
	cver = All
if isplug
	{
	ico := Mtrans ? 3 : 2
	ansi := Mtrans ? "U" : "A"
	LV_Add("Icon" . ico, "", ansi, Smodule, Mname, Mversion, "N/A", cver)
	if cver = 1
	Muuid :=
	}
else
	{
	ico = 1
	ansi := "?"
	cver := "--"
	last := LV_Add("Icon" . ico, "", ansi, Smodule, Mname, Mversion, "N/A", cver)
	LV_Modify(last, "Check")
	Muuid :=
	Mdetails = %module% either is not a Miranda plug-in or has compatibility issues`. Please click 'Test' for a thorough testing of this module`.
	}
d%A_Index% := Mdetails
h%A_Index% := Mauthor
m%A_Index% := Mmail
c%A_Index% := Mcopy
w%A_Index% := Mweb
t%A_Index% := Mtrans ? "Unicode (or 2in1)" : "ANSI"
r%A_Index% := Mbuiltin
u%A_Index% := Muuid
k%A_Index% := comp
pg%A_Index% := isplug
gosub log
gosub clearvar
}
LV_ModifyCol(1, "AutoHdr")
LV_ModifyCol(2, "AutoHdr")
LV_ModifyCol(3, "AutoHdr")
LV_ModifyCol(4, "AutoHdr")
LV_ModifyCol(5, "AutoHdr")
LV_ModifyCol(6, "AutoHdr")
LV_ModifyCol(7, "AutoHdr")
Gui, Show, w570 h450, Miranda Plug-in Checker %version%
GuiControl, +Redraw, list
return

error:
MsgBox, 48, %appname% Error, %msg%
ButtonExit:
GuiClose:
ExitApp

; **************** VARS RESET *****************
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

; *************** DISPLAY DETAILS ****************
showinfo:
if A_EventInfo in %row%,0
	return
row := A_EventInfo
action := A_GuiEvent
GuiControl,, desc, % d%row%
GuiControl,, auth, % h%row%
GuiControl,, copy, % c%row%
GuiControl,, mail, % m%row%
GuiControl,, web, % w%row%
GuiControl,, uuid, % u%row%
nmb := k%row%
cmp := cmp%nmb%
bck := bck%nmb%
GuiControl, Hide, ci0
GuiControl, Hide, ci1
GuiControl, Hide, ci2
GuiControl,, comp,
if pg%row% = 0
	return
GuiControl, Show, ci%nmb%
GuiControl,, comp, This plug-in is %cmp%0.8+ compatible. It is %bck% backwards compatible with 0.7 and older.
return

; *************** LOGGING *****************
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

; *************** HEX CONVERSION *****************
MKHEX(ByRef val)
{
SetFormat, Integer, Hex
	val += 0
SetFormat, Integer, D
}

; *************** STRING GRAB *****************
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

; *************** VERSION *****************
PLUGIN_MAKE_VERSION(make)
{
;(((((DWORD)(a))&0xFF)<<24)|((((DWORD)(b))&0xFF)<<16)|((((DWORD)(c))&0xFF)<<8)|(((DWORD)(d))&0xFF))
Global Mversion
Va := (make>>24 & 0xFF)
Vb := (make>>16 & 0xFF)
Vc := (make>>8 & 0xFF)
Vd := (make & 0xFF)
;MsgBox  %make% %Va%, %Vb%, %Vc%, %Vd%
Mversion := Va . "." . Vb . "." . Vc . "." . Vd
return Mversion
}

;#Include, %A_ScriptDir%\ahkstructlib2.ahk
