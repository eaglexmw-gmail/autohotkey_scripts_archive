; by SKAN http://www.autohotkey.com/forum/viewtopic.php?p=271247#271247
SetTimer, AutoFadeMsgBox, -3500
MsgBox, 260, Auto-Fade, This Msgbox will fade out after 3.5 seconds, 4
SetTimer, AutoFadeMsgBox, Off
Return

AutoFadeMsgBox:
 DllCall( "AnimateWindow", UInt,WinExist("Auto-Fade ahk_class #32770"), Int,500, UInt,0x90000 )
Return
