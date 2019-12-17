; USB Vendor ID
; by Drugwash
; version 1.0
; released 3 Oct 2008
; displays the list of USB vendor IDs
; as found in the usb.if file at
; http://www.usb.org/developers/tools/comp_dump
; the 'information' icon used for this script
; was originally a PNG in the silk pack v0.1.3
; at http://www.famfamfam.com

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
start:
width := 340		; dropdown list's width
Gui, Add, Text, x10 y5, Vendor ID code:
Gui, Add, DropDownList, xp yp+14 w%width% vcode grefreshC R10 AltSubmit
Gui, Add, Text, xp yp+22, Vendor name:
Gui, Add, DropDownList, xp yp+14 w%width% vvendor grefreshV R10 Sort
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
Gui, Show, w360 h100, USB Vendor ID
return

refreshC:
Gui Submit, NoHide
GuiControl, Choose, vendor, % line%code%_2
Gui Submit, NoHide
return

refreshV:
Gui Submit, NoHide
Loop, %count%
	if (vendor = line%A_Index%_2 )
		{
		GuiControl, Choose, code, % line%A_Index%_1
		break
		}
Gui Submit, NoHide
return

down:
	Run, http://www.usb.org/developers/tools/comp_dump,, UseErrorLevel, brw
	if ErrorLevel
		MsgBox, 21, Error!, Error downloading file.
		IfMsgBox Retry
			Goto down
return

GuiClose:
ExitApp
