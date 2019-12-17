!c::
DetectHiddenWindows, On
IfWinExist ahk_class EasyWinAPI
	Send #c
else
	Send ^c
return

