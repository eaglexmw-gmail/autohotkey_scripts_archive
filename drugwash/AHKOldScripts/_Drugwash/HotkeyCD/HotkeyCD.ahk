; HotkeyCD.ahk
; Ejects/closes all CD drives
; Drugwash @2008
; version 1.1

#SingleInstance, Force
;#NoTrayIcon
;HotKey, >^PgDn, cd_eject	; Eject
;HotKey, >^PgUp, cd_close	; Close
HotKey, >^End, cd_eject	; Eject
HotKey, >^Home, cd_close	; Close
;list=%1%
;If 0=0
	DriveGet, list, List, CDROM
return

cd_eject:
text = EJECT CD
param =
goto exec

cd_close:
text = CLOSE CD
param = 1
goto exec

exec:
	Progress,B2 ZH0 FM32 CTFF00FF CW0,,%text%,,Tahoma
	SetTimer, prOff, 2000
	Sleep 5
	Loop, Parse, list
	Drive, Eject, %A_LoopField%:, %param%
return

prOff:
SetTimer, prOff, off
Progress, Off
return
