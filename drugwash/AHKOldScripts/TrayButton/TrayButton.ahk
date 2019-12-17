#Persistent
#SingleInstance, Ignore
#NoTrayIcon

Control, Hide, , Button1, ahk_class Shell_TrayWnd
OnExit, Exitt 

Gui, +ToolWindow -Caption           
Gui, +Lastfound                     
GUI_ID := WinExist()               
WinGet, TaskBar_ID, ID, ahk_class Shell_TrayWnd
DllCall("SetParent", "uint", GUI_ID, "uint", Taskbar_ID)

Gui, Margin,0,0
Gui, Font, S12 Bold, Times New Roman
Gui, Add,Button, w45 h30 gStartM, Start
Gui, Font, S8 Bold, Arial
Gui, Add,Button, x+0 w63 h30 gQuickM, My Menu
Gui, Show,x0 y0 AutoSize

Return

StartM:
Send ^{ESCAPE}
return

QuickM:
Menu,Tray,Show
return

Exitt:
  Gui,Destroy
  Control, Show, , Button1, ahk_class Shell_TrayWnd
  ExitApp 
Return
