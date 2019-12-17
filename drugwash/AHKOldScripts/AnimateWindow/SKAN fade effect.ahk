IfNotExist, asplash1.gif
 URLDownloadToFile
 , http://autohotkey.net/goyyah/CrazyScripts/SlideShow/asplash1.gif
 , asplash1.gif

Gui, Margin, 0,0
Gui +LastFound
GUI_ID:=WinExist()
Gui, -Caption +AlwaysOnTop +Border
Gui, Add, Picture, , asplash1.gif
Gui,Show, AutoSize Hide, Animated Splash Window - Demo
msgbox, GUI_ID: %GUI_ID%
DllCall("AnimateWindow","UInt",GUI_ID,"Int",1500,"UInt","0xa0000")
Sleep 3000
;DllCall("AnimateWindow","UInt",GUI_ID,"Int",500,"UInt","0x90000")
DllCall("AnimateWindow","UInt",GUI_ID,"Int",1500,"UInt",0x10000)
ExitApp
