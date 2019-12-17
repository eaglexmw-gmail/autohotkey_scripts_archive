#SingleInstance force
   Gui, +LastFound
   hGui := WinExist()+0


   HLink_Add(hGui, 10,  10,  200, 20, "MyNotify", "Click <a href=""http://www.Google.com"">here</a> to go to Google" )
   HLink_Add(hGui, 10,  40,  250, 20, "MyNotify", "Click <a href=""http://www.Yahoo.com"">on this link</a> to go to Yahoo")
   HLink_Add(hGui, 10,  170, 100, 20, "MyNotify", "<a href=""About"">About HLink</a>")
   HLink_Add(hGui, 110, 170, 100, 20, "MyNotify", "<a href=""http://www.autohotkey.com/forum/topic19508.html"">Forum</a>")

   HLink_Add(hGui, 10, 60, 100, 20, "MyNotify")

   Gui, Show, w300 h200
return

MyNotify:
	if HLink_link = About
		 MsgBox 64, ,% HLink_About()
	else Run %HLink_link%
return

#include HLink.ahk