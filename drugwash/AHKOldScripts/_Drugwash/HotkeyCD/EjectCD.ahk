;EjectCD.ahk
; Ejects all CD drives, or add the drives to eject to the command line.
;  Example: EjectCD.exe DEF
;Skrommel @2006

#SingleInstance,Force
HotKey, >^PgUp, cd_eject		; Eject
HotKey, >^PgDown, cd_close	; Close
list=%1%
If 0=0
  DriveGet,list,List,CDROM
return
cd_eject:
Loop,Parse,list
  Drive,Eject,%A_LoopField%:
return
cd_close:
Loop,Parse,list
  Drive,Eject,%A_LoopField%:,1
