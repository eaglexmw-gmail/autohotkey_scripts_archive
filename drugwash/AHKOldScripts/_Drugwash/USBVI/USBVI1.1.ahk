; USB Vendor ID by Drugwash
;displays the list of USB vendor IDs
; as found in the usb.if file at
; http://www.usb.org/developers/tools/comp_dump
; the 'information' icon used for this script
; was originally a PNG in the silk pack v0.1.3
; at http://www.famfamfam.com
;*****************************************
version = 1.1				; version number
release = October 11, 2008	; release date
type = internal			; release type (internal / public)
iconlocal = information.ico	; external icon for uncompiled script
debug = 0				; debug switch (1 = active)
;*****************************************
selfile:
if FileExist("usb.if")
	{
	input := A_WorkingDir . "\usb.if"
	goto start
	}
else
MsgBox, 67, Attention, This application requires the file usb.if.`nDo you want to download it now?`n`n'Yes' to download`n'No' if it's already on the HDD`n'Cancel' to exit
IfMsgBox Cancel
	Goto GuiClose
else
	IfMsgBox Yes
		gosub down
	FileSelectFile, input, 3, %A_WorkingDir%\usb.if, Please select the location of usb.if:, USB vendor list (usb.if)
	if ErrorLevel
		{
		MsgBox, 8245, Error, No file selected.,
		ifMsgBox Cancel
			Goto GuiClose
		else
			Goto selfile
		}
;*****************************************
start:
width := 350		; dropdown list's width
wg := width + 20	; GUI width
Gui, Add, Text, x10 y5, Vendor ID code:
Gui, Add, Text, x+3 yp cRed vdID Hidden, COPIED TO CLIPBOARD
Gui, Add, DropDownList, x10 yp+14 w%width% vcode grefreshC R10 AltSubmit
Gui, Add, Text, xp yp+22, Vendor name:
Gui, Add, Text, x+3 yp cRed vdname Hidden, COPIED TO CLIPBOARD
Gui, Add, DropDownList, x10 yp+14 w%width% vvendor grefreshV R10 Sort
Gui, Add, Button, xp y+10 w60, Copy &ID
Gui, Add, Button, x+5 yp w80, Copy &name
Gui, Add, Button, x+40 yp w60, &About
Gui, Add, Button, x+45 yp w60, E&xit
;Gui, Add, Text, xp yp+22 w%width% vven, % line%code%_2
;Gui, Add, Text, xp yp+14 w%width% vdebg1, %dbg%
Loop, Read, %input%
	{
	StringSplit, line%A_Index%_, A_LoopReadLine, |
	line%A_Index%_1 := "VEN_" . line%A_Index%_1
	GuiControl,, code, % line%A_Index%_1
	GuiControl,, vendor, % line%A_Index%_2
	count++
	}
GuiControl, Choose, code, 1
gosub refreshC
Gui, Show, w%wg% h120, USB Vendor ID
return
;*****************************************
refreshC:
Gui Submit, NoHide
GuiControl, Choose, vendor, % line%code%_2
name := % line%code%_2
Gui Submit, NoHide
return
;*****************************************
refreshV:
Gui Submit, NoHide
Loop, %count%
	if (vendor = line%A_Index%_2 )
		{
		GuiControl, Choose, code, % line%A_Index%_1
		venID := % line%A_Index%_1
		break
		}
Gui Submit, NoHide
return
;*****************************************
down:
	Run, http://www.usb.org/developers/tools/comp_dump,, UseErrorLevel, brw
	if ErrorLevel
		MsgBox, 21, Error!, Error downloading file.
		IfMsgBox Retry
			Goto down
return
;*****************************************
ButtonCopyID:
gosub dispoff
gosub refreshV
if debug
	MsgBox, name=%name%, venID=%venID%
clipboard := venID
control = dID
GuiControl, Show, %control%
SetTimer, dispoff, 4000
return
;*****************************************
ButtonCopyname:
gosub dispoff
gosub refreshC
if debug
	MsgBox, name=%name%, venID=%venID%
clipboard := name
control = dname
GuiControl, Show, %control%
SetTimer, dispoff, 4000
return
;*****************************************
dispoff:
SetTimer, dispoff, off
GuiControl, Hide, %control%
return
;*****************************************
ButtonAbout:
Gui 1:+Disabled
Gui, 1:Hide
Gui, 2:+owner1 -MinimizeBox
if ! A_IsCompiled
	Gui, 2:Add, Picture, x69 y10 w32 h-1, %iconlocal%
else
	Gui, 2:Add, Picture, x69 y10 w32 h-1 Icon1, %A_ScriptName%
Gui, 2:Font, Bold
Gui, 2:Add, Text, x5 y+10 w160 Center, USB VendorID v%version%
Gui, 2:Font
Gui, 2:Add, Text, xp y+2 wp Center, by Drugwash
Gui, 2:Add, Text, xp y+2 wp Center gmail0 cBlue, drugwash@gmail.com
Gui, 2:Add, Text, xp y+10 wp Center, Released %release%
Gui, 2:Add, Text, xp y+2 wp Center, (%type% version)
Gui, 2:Add, Text, xp y+10 wp Center, This product is open-source,
Gui, 2:Add, Text, xp y+2 wp Center, developed in AutoHotkey
Gui, 2:Font,CBlue Underline
Gui, 2:Add, Text, xp y+2 wp Center glink0,  http://www.autohotkey.com
Gui, 2:Font
Gui, 2:Add, Text, xp y+5 wp Center, Icon from the Silk package at
Gui, 2:Font,CBlue Underline
Gui, 2:Add, Text, xp y+2 wp Center glink1,  http://www.famfamfam.com
Gui, 2:Font
Gui, 2:Add, Button, xp+40 y+20 w80 gdismiss Default, &OK
Gui, 2:Show,, About USB VendorID
hCurs := DllCall("LoadCursor", "UInt", NULL, "Int", 32649, "UInt") ;IDC_HAND
OnMessage(0x200, "WM_MOUSEMOVE")
return

dismiss:
Gui, 1:-Disabled
Gui, 2:Destroy
Gui, 1:Show
IfWinNotExist, VolOSD options
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
;*****************************************
ButtonExit:
GuiClose:
ExitApp

WM_MOUSEMOVE(wParam, lParam)
{
Global hCurs
MouseGetPos,,, winid, ctrl
if ctrl in Static4,Static9,Static11
	DllCall("SetCursor", "UInt", hCurs)
}
