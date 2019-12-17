/*  * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    Disclaimer:

    I do not foresee any risk in running this script but
    you may run this file "ONLY" at your own risk. 

    * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

File Name   : Button_Clock_WIN9X.ahk

Download    : http://file.autohotkey.net/goyyah/Tips-N-Tricks/TaskBar/Button_Clock_WIN9X.ahk
Icon        : http://file.autohotkey.net/goyyah/Tips-N-Tricks/TaskBar/Clock.ico
SnapShot    : http://file.autohotkey.net/goyyah/Tips-N-Tricks/TaskBar/Snapshot1.gif
Post        : http://www.autohotkey.com/forum/viewtopic.php?p=54863#54863

Main Title  : Taskbar Enhancement Utility
Sub Title   : Start Button Clock for Windows 98

Description :  A "Button Clock" in lieu of "Windows Start Button"

               This script hides the "Start Button" and adds a new Button and keeps updating the 
               "Button Caption" with a Time String - periodically - effectively making it a clock.
               
Note        :  This script will work fine with standard settings in Windows 98 SE & may require
               modifications to suit a different theme.
          
Author      : A.N.Suresh Kumar aka "Goyyah"
Email       : arian.suresh@gmail.com

Created     : 2006-03-28
Modified    : 2006-03-30

Scripted in : AutoHotkey Version 1.0.42.06 , www.autohotkey.com 

*/

#Persistent
#SingleInstance, Ignore

IfNotExist, Clock.ico
  URLDownloadToFile
  , http://file.autohotkey.net/goyyah/Tips-N-Tricks/TaskBar/Clock.ico
  , Clock.ico

IfExist, Clock.ico
  Menu, Tray, Icon, Clock.ico
Menu, Tray, Tip, Start Button Clock for Windows 98

Control, Hide, , Button1, ahk_class Shell_TrayWnd
OnExit, Exitt  ; and restore the Start Button

cTime := A_Now
FormatTime,Time,,HH:mm:ss

Option1=0x8000 ; BS_FLAT:  Specifies that the button is two-dimensional.
               ; Does not use the default shading to create a 3-D image.

Gui, +ToolWindow -Caption           
Gui, +Lastfound                     
GUI_ID := WinExist()                
WinGet, TaskBar_ID, ID, ahk_class Shell_TrayWnd
DllCall("SetParent", "uint", GUI_ID, "uint", Taskbar_ID)

Gui, Margin,0,0
Gui, Font, S10 Bold , Arial
Gui, Add,Button, w64 h23 %Option1% gStartM vTime, % Time
Gui, Show,x0 y1 AutoSize, Start Button Clock - By Goyyah

SetTimer, UpdateButtonTime, 10

Return

; ----------------------------------------------------------------------------------------

UpdateButtonTime:

  If cTime = %A_Now%
     exit
  else
     cTime := A_Now

  SetTimer, UpdateButtonTime, OFF
  FormatTime,Time,,HH:mm:ss
  GuiControl,,Time , %Time%
  SetTimer, UpdateButtonTime, 10
Return


StartM:
  Send ^{ESCAPE}
return


Exitt:
  Gui,Destroy
  Control, Show, ,Button1, ahk_class Shell_TrayWnd
  ExitApp  
Return