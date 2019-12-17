; ScanDiskW GUI by Drugwash
; provides a 32-bit UI for the standard Windows Scandisk
;*****************************************
appname = ScanDiskW GUI	; application name
version = 0.2				; version number
release = October 21, 2008	; release date
type = internal			; release type (internal / public)
iconlocal = cd.ico			; external icon for uncompiled script
debug = 0				; debug switch (1 = active)
;*****************************************

Menu, Tray, Icon, %iconlocal%, 1
Gui, Add, Pic, x16 y8 w32 h-1, %iconlocal%
Gui, Font, s16
Gui, Add, Text, x67 y15 w180 h20, ScanDisk 32-bit GUI
Gui, Font, s8
Gui, Add, Text, x17 y49 w229 h16, Select the dri&ve(s) you want to check for errors:
Gui, Add, ListBox, x17 y67 w230 h134,
Gui, Add, GroupBox, x254 y48 w193 h153, Type of test
Gui, Add, Radio, x261 y67 w75 h21 vst Checked gstandard, Stan&dard
Gui, Add, Radio, x261 y108 w76 h18 vth gthorough, &Thorough
Gui, Add, Text, x277 y88 w164 h16, (checks files && folders for errors)
Gui, Add, Text, x277 y128 w166 h17, (Standard test + disk surface scan)
Gui, Add, Button, x306 y158 w92 h30 vBopt Disabled, &Options...
Gui, Add, Checkbox, x257 y208 w140 h19 vaf Checked, Automatically &fix errors
Gui, Add, Checkbox, x17 y207 w210 h20 vss Checked, Su&ppress screensaver while scanning
Gui, Add, GroupBox, x16 y230 w430 h78, Progress
Gui, Add, Button, x16 y318 w100 h30, &Start
Gui, Add, Button, x16 y318 w100 h30 Hidden, St&op
Gui, Add, Button, x126 y318 w100 h30, &Close
Gui, Add, Button, x346 y318 w100 h30, &Advanced
Gui, Add, Button, x346 y8 w100 h30, A&bout
Gui, Show, x466 y230 h353 w462, %appname%
Return


ButtonOptions...:
Gui, 3:Add, Text, x7 y6 w171 h44, ScanDisk will use the following settings when scanning the surface of your disk for errors:
Gui, 3:Add, GroupBox, x7 y51 w169 h91, Areas of the disk to scan
Gui, 3:Add, Radio, x15 y68 w151 h23, System &and data areas
Gui, 3:Add, Radio, x15 y90 w152 h23, &System area only
Gui, 3:Add, Radio, x15 y113 w152 h21, &Data area only
Gui, 3:Add, Checkbox, x16 y146 w151 h24, Do not perform &write-testing
Gui, 3:Add, Checkbox, x17 y170 w149 h30, Do not repair bad sectors in &hidden and system files
Gui, 3:Add, Button, x16 y201 w71 h27 goptout, OK
Gui, 3:Add, Button, x97 y202 w72 h26 gCopt, Cancel
Gui, 3:Show, x351 y254 h233 w184, Surface Scan Options
return

ButtonAdvanced:
Gui, 2:Add, GroupBox, x7 y7 w169 h76, Display summary
Gui, 2:Add, Radio, x16 y22 w150 h20, &Always
Gui, 2:Add, Radio, x17 y42 w149 h19, N&ever
Gui, 2:Add, Radio, x17 y61 w150 h18, &Only if errors found
Gui, 2:Add, GroupBox, x6 y90 w171 h82, Log file
Gui, 2:Add, Radio, x16 y105 w152 h19, &Replace log
Gui, 2:Add, Radio, x17 y124 w151 h19, A&ppend to log
Gui, 2:Add, Radio, x17 y143 w151 h19, &No log
Gui, 2:Add, GroupBox, x7 y180 w170 h78, Cross-linked files
Gui, 2:Add, Radio, x16 y197 w151 h21, &Delete
Gui, 2:Add, Radio, x16 y218 w149 h18, Make &copies
Gui, 2:Add, Radio, x17 y236 w150 h18, I&gnore
Gui, 2:Add, GroupBox, x186 y8 w161 h74, Lost file fragments
Gui, 2:Add, Radio, x196 y26 w141 h21, &Free
Gui, 2:Add, Radio, x197 y48 w140 h19, Con&vert to files
Gui, 2:Add, GroupBox, x186 y90 w161 h83, Check files for
Gui, 2:Add, Checkbox, x195 y105 w143 h20, Invalid file na&mes
Gui, 2:Add, Checkbox, x196 y125 w142 h20, Invalid dates and &times
Gui, 2:Add, Checkbox, x196 y145 w142 h18, D&uplicate names
Gui, 2:Add, Checkbox, x196 y178 w141 h27, Check &host drive first
Gui, 2:Add, Checkbox, x197 y208 w139 h31, Report M&S-DOS mode name length errors
Gui, 2:Add, Button, x186 y263 w81 h26 gadvout, OK
Gui, 2:Add, Button, x274 y263 w74 h26 gCadv, Cancel
Gui, 2:Show, x416 y283 h296 w358, ScanDisk Advanced Options
Return

ButtonStart:
GuiControl, Hide, &Start
GuiControl, Show, St&op
GuiControl, Disable, &Close
GuiControl, Disable, &Advanced
GuiControl, Disable, ss
GuiControl, Disable, af
GuiControl, Disable, st
GuiControl, Disable, th
GuiControl, Disable, Bopt
busy = 1
;Run, ScandskW.exe
MsgBox, Now we're running scandskw.exe
normal:
busy = 0
GuiControl, Show, &Start
GuiControl, Hide, St&op
GuiControl, Enable, &Close
GuiControl, Enable, &Advanced
GuiControl, Enable, ss
GuiControl, Enable, af
GuiControl, Enable, st
GuiControl, Enable, th
if thS
	GuiControl, Enable, Bopt
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
ExitApp

optout:
Copt:
Gui, 3:Destroy
return

advout:
Cadv:
Gui, 2:Destroy
return

standard:
GuiControl, Disable, Bopt
thS = 0
return

thorough:
GuiControl, Enable, Bopt
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
	if wind in About ScanDiskW GUI
		DllCall("SetCursor", "UInt", hCurs)
}
