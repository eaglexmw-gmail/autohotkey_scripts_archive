SendU_Init()
Hotkey, #F12, _SendU_Change_Dynamic_Mode
Hotkey, #F11, _SendU_Toggle_Clipboard_Restore_Mode
return

#q::
	; Send Information Separator Four (In Total Commander: goto to the root directory)
	SendCh( 0x1c )
return

#s::
	; Send with dynamic mode. Very easy. :)
	; Is this O with double acute (O")?
	; Try other modes (Win+F12)!
	SendU(0x150) ; O"
	SendU(0x151) ; o"
return


#Include SendU.ahk
