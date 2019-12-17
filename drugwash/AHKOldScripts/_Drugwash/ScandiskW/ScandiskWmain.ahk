; ScanDiskW 32-bit GUI by Drugwash
; provides a 32-bit UI for the standard Windows Scandisk
;*****************************************
appname = ScanDiskW32	; application name
version = 0.3				; version number
release = October 23, 2008	; release date
type = internal			; release type (internal / public)
iconlocal = cd.ico			; external icon for uncompiled script
debug = 0				; debug switch (1 = active)
; *****************************************
; ******* Detect drives *********
DriveGet, List, List
	Loop, Parse, List
	{
	alldrives++
	drv%A_Index% := A_LoopField . ":"
	DriveGet, typ%A_Index%, Type, % drv%A_Index%
	if typ%A_Index% not in CDROM,RAMDisk,Unknown
		valid++
	if drv%A_Index% not in A:,B:
		{
		DriveGet, lbl%A_Index%, Label, % drv%A_Index%
		DriveGet, fs%A_Index%, FS, % drv%A_Index%
		DriveGet, cap%A_Index%, Cap, % drv%A_Index%
		DriveSpaceFree, free%A_Index%, % drv%A_Index%
		DriveGet, ser%A_Index%, Serial, % drv%A_Index%
		}
	}
if ! valid
	{
	MsgBox, `tAre you kiddin' me?!`n`tWhat should I scan: the RAM or the optical drive(s)?!`n`tBugger!
	ExitApp
	}
; ***************************	
Menu, Tray, Icon, %iconlocal%, 1
Gui, Add, Pic, x15 y8 w32 h-1 vstatico, %iconlocal%
Gui, Font, s16
Gui, Add, Text, x65 y15 w165 h20, %appname% v%version%
Gui, Font, s8
Gui, Add, Text, x15 y49 w230 h16, Select the dri&ve(s) you want to check for errors:
Gui, Add, ListView, x15 y67 w230 h134 vn1 -Hdr ReadOnly Checked, Drive|Label|Cap|Type
Gui, Add, GroupBox, x254 y60 w193 h143, Type of test
Gui, Add, Radio, x261 y78 w75 h21 vn2 Checked gstandard, Stan&dard
Gui, Add, Radio, x261 y118 w76 h18 vn3 gthorough, &Thorough
Gui, Add, Text, x277 y98 w164 h16, (checks files && folders for errors)
Gui, Add, Text, x277 y138 w166 h17, (Standard test + disk surface scan)
Gui, Add, Button, x306 y163 w92 h30 vn4 Disabled, &Options...
Gui, Add, Checkbox, x257 y208 w140 h19 vn5 Checked, Automatically &fix errors
Gui, Add, Checkbox, x15 y207 w210 h20 vn6 Checked, Su&ppress screensaver while scanning
Gui, Add, GroupBox, x15 y230 w430 h60, Progress
Gui, Add, Text, x20 y245 w44 h16 Right, Current :
Gui, Add, Text, x20 y265 w44 h16 Right, Overall :
Gui, Add, Progress, x66 y245 w370 h16 vn7, 0
Gui, Add, Progress, x66 y265 w370 h16 vn8, 0
Gui, Add, Button, x15 y318 w100 h30, &Start
Gui, Add, Button, x15 y318 w100 h30 Hidden, St&op
Gui, Add, Button, x126 y318 w100 h30, &Close
Gui, Add, Button, x346 y318 w100 h30, &Advanced
Gui, Add, Button, x346 y8 w100 h30, A&bout
gosub createList
Gui, Show, x466 y230 h353 w462, %appname%
Return

createList:
icons := IL_Create(5)
LV_SetImageList(icons)
IL_Add(icons, "shell32.dll", 6)		; floppy
IL_Add(icons, "shell32.dll", 8)		; removable
IL_Add(icons, "shell32.dll", 9)		; fixed
IL_Add(icons, "shell32.dll", 10)	; network
IL_Add(icons, "shell32.dll", 12)	; CDROM
Loop, %alldrives%
	{
	typ := typ%A_Index%
	if typ in CDROM,RAMDisk,Unknown
		continue
	drv := drv%A_Index%
	lbl := lbl%A_Index%
	cap := cap%A_Index%
	if cap > 1023
		cap := Round(cap / 1024, 2) . " GB"
	else
		cap := cap . " MB"
	fs := fs%A_Index%
	if typ in Removable
		{
		if drv in A:,B:
			icon := 1
		else
			icon := 2
		}
	else if typ in Fixed
		icon := 3
	else
		icon := 4
	last := LV_Add("Icon" . icon, drv, lbl, cap, fs)
	if SubStr(A_WinDir, 1, 2) = drv
		LV_Modify(last, "Check")
;MsgBox, %drv% %typ% %lbl%
	}
LV_ModifyCol(1, "Auto")
LV_ModifyCol(2, "Auto")
LV_ModifyCol(3, "Auto")
LV_ModifyCol(4, "Auto")
return

ButtonOptions...:
if gui3ID
	Gui, 3:Show
else
	{
Gui, 3:Add, Text, x7 y6 w171 h44, ScanDisk will use the following settings when scanning the surface of your disk for errors:
Gui, 3:Add, GroupBox, x7 y51 w169 h91, Areas of the disk to scan
Gui, 3:Add, Radio, x15 y68 w151 h23 vo1, System &and data areas
Gui, 3:Add, Radio, x15 y90 w152 h23 vo2, &System area only
Gui, 3:Add, Radio, x15 y113 w152 h21 vo3, &Data area only
Gui, 3:Add, Checkbox, x16 y146 w151 h24 vo4, Do not perform &write-testing
Gui, 3:Add, Checkbox, x17 y170 w149 h30 vo5, Do not repair bad sectors in &hidden and system files
Gui, 3:Add, Button, x16 y201 w71 h27 goptout, OK
Gui, 3:Add, Button, x97 y202 w72 h26 gCopt, Cancel
Gui, 3:Show, x351 y254 h233 w184, Surface Scan Options
Gui +LastFound
gui3ID := WinExist()
	}
return

; ************ ADVANCED SETTINGS ***********
ButtonAdvanced:
if gui2ID
	Gui, 2:Show
else
	{
Gui, 2:Add, GroupBox, x7 y7 w169 h76, Display summary
Gui, 2:Add, Radio, x16 y22 w150 h20 va1, &Always
Gui, 2:Add, Radio, x17 y42 w149 h19 va2, N&ever
Gui, 2:Add, Radio, x17 y61 w150 h18 va3, &Only if errors found
Gui, 2:Add, GroupBox, x6 y90 w171 h82, Log file
Gui, 2:Add, Radio, x16 y105 w152 h19 va4, &Replace log
Gui, 2:Add, Radio, x17 y124 w151 h19 va5, A&ppend to log
Gui, 2:Add, Radio, x17 y143 w151 h19 va6, &No log
Gui, 2:Add, GroupBox, x7 y180 w170 h78, Cross-linked files
Gui, 2:Add, Radio, x16 y197 w151 h21 va7, &Delete
Gui, 2:Add, Radio, x16 y218 w149 h18 va8, Make &copies
Gui, 2:Add, Radio, x17 y236 w150 h18 va9, I&gnore
Gui, 2:Add, GroupBox, x186 y8 w161 h74, Lost file fragments
Gui, 2:Add, Radio, x196 y26 w141 h21 va10, &Free
Gui, 2:Add, Radio, x197 y48 w140 h19 va11, Con&vert to files
Gui, 2:Add, GroupBox, x186 y90 w161 h83, Check files for
Gui, 2:Add, Checkbox, x195 y105 w143 h20 va12, Invalid file na&mes
Gui, 2:Add, Checkbox, x196 y125 w142 h20 va13, Invalid dates and &times
Gui, 2:Add, Checkbox, x196 y145 w142 h18 va14 gcfDup, D&uplicate names
Gui, 2:Add, Checkbox, x196 y178 w141 h27 va15, Check &host drive first
Gui, 2:Add, Checkbox, x197 y208 w139 h31 va16, Report M&S-DOS mode name length errors
Gui, 2:Add, Button, x186 y263 w81 h26 gadvout, OK
Gui, 2:Add, Button, x274 y263 w74 h26 gCadv, Cancel
Gui, 2:Show, x416 y283 h296 w358, ScanDisk Advanced Options
Gui +LastFound
gui2ID := WinExist()
	}
Return

cfDup:
Gui, Submit, NoHide
if ! a14
	return
MsgBox, 8260, ScanDisk, Enabling this check may slow ScanDisk down quite a bit`n`ton folders with lots of files in them.`nAre you sure you want to enable the duplicate name check?
ifMsgBox No
	GuiControl,, a14, 0
Gui, Submit, NoHide
return
; *******************************************

ButtonStart:
GuiControl, Hide, &Start
GuiControl, Show, St&op
GuiControl, Disable, &Close
GuiControl, Disable, &Advanced
GuiControl, Disable, n2
GuiControl, Disable, n3
if thS
	GuiControl, Disable, n4
GuiControl, Disable, n5
;GuiControl, Disable, n6
busy = 1
;Run, ScandskW.exe
GuiControl, Hide, statico
Gui +LastFound
gui1ID := WinExist()
h1 := AVI_CreateControl(gui1ID, 15, 8, 32, 32, A_ScriptDir . "\cd3.avi")
If h1 is not integer
	MsgBox %h1%
AVI_Play(h1)
MsgBox, Now we're running scandskw.exe
normal:
busy = 0
AVI_Stop(h1)
AVI_DestroyControl(h1)
GuiControl, Show, statico
GuiControl, Show, &Start
GuiControl, Hide, St&op
GuiControl, Enable, &Close
GuiControl, Enable, &Advanced
GuiControl, Enable, n2
GuiControl, Enable, n3
if thS
	GuiControl, Enable, n4
GuiControl, Enable, n5
;GuiControl, Enable, n6
return

ButtonStop:
MsgBox, 4, Confirm, Are you sure you want to cancel the current scanning operation?
IfMsgBox No
	return
goto normal
return

ButtonClose:
GuiClose:
if busy
	MsgBox, 4, Confirm, Are you sure you want to cancel the current scanning operation?
	IfMsgBox No
		return
Gui, 2:Destroy
Gui, 3:Destroy
ExitApp

optout:
Copt:
Gui, 3:Hide
return

advout:
Cadv:
Gui, 2:Hide
return

standard:
GuiControl, Disable, n4
thS = 0
return

thorough:
GuiControl, Enable, n4
thS = 1
return

ButtonAbout:
Gui 1:+Disabled
Gui, 1:Hide
Gui, 4:+owner1 -MinimizeBox
if ! A_IsCompiled
	Gui, 4:Add, Picture, x69 y10 w32 h-1, %iconlocal%
else
	Gui, 4:Add, Picture, x69 y10 w32 h-1 Icon1, %A_ScriptName%
Gui, 4:Font, Bold
Gui, 4:Add, Text, x5 y+10 w160 Center, %appname% v%version%
Gui, 4:Font
Gui, 4:Add, Text, xp y+2 wp Center, by Drugwash
Gui, 4:Add, Text, xp y+2 wp Center gmail0 cBlue, drugwash@gmail.com
Gui, 4:Add, Text, xp y+10 wp Center, Released %release%
Gui, 4:Add, Text, xp y+2 wp Center, (%type% version)
Gui, 4:Add, Text, xp y+10 wp Center, This product is open-source,
Gui, 4:Add, Text, xp y+2 wp Center, developed in AutoHotkey
Gui, 4:Font,CBlue Underline
Gui, 4:Add, Text, xp y+2 wp Center glink0,  http://www.autohotkey.com
Gui, 4:Font
Gui, 4:Add, Text, xp y+5 wp Center, Icon from the Silk package at
Gui, 4:Font,CBlue Underline
Gui, 4:Add, Text, xp y+2 wp Center glink1,  http://www.famfamfam.com
Gui, 4:Font
Gui, 4:Add, Button, xp+40 y+20 w80 gdismiss Default, &OK
Gui, 4:Show,, About %appname%
hCurs := DllCall("LoadCursor", "UInt", NULL, "Int", 32649, "UInt") ;IDC_HAND
OnMessage(0x200, "WM_MOUSEMOVE")
return

dismiss:
Gui, 1:-Disabled
Gui, 4:Destroy
Gui, 1:Show
IfWinNotExist, %appname%
	{
	OnMessage(0x200,"")
	DllCall("DestroyCursor", "Uint", hCurs)
	}
return

mail0:
Run, mailto:drugwash@gmail.com, UseErrorLevel
return

link0:
Run, http://www.autohotkey.com,, UseErrorLevel
return

link1:
Run, http://www.famfamfam.com,, UseErrorLevel
return

WM_MOUSEMOVE(wParam, lParam)
{
Global hCurs
WinGetTitle, wind
MouseGetPos,,, winid, ctrl
if ctrl in Static4,Static9,Static11
	if wind in About ScanDiskW32
		DllCall("SetCursor", "UInt", hCurs)
}

#include ..\Additional_tools\Control_AVI.ahk
