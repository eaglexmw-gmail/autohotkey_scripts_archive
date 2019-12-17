OnMessage(0x4e,"WM_NOTIFY") ;Will make LinkClick and ToolTipClose possible
OnMessage(0x404,"AHK_NotifyTrayIcon") ;Will pop up the ToolTip when you click on Tray Icon
OnExit, ExitApp
#NoEnv
#SingleInstance Force

Restart:
ToolTip(99,"Please click on a link:`n`n"
      . "<a>My Favorite Websites</a>`n`n"
      . "<a>ToolTip Examples</a>`n`n"
      . "<a notepad.exe >Notepad</a>`n"
      . "<a explorer.exe >Explorer</a>`n"
      . "<a calc.exe >Calculator</a>`n"
      . "`n<a>Hide ToolTip</a>`n  - To show this ToolTip again click onto Tray Icon"
      . "`n<a>ExitApp</a>`n"
      , "Welcome to ToolTip Control"
      , "L1 H1 O1 C1 T220 BLime FBlue I" . GetAssociatedIcon(A_ProgramFiles . "\Internet Explorer\iexplore.exe")
      . " P99 X" A_ScreenWidth . " Y" . A_ScreenHeight)
Return

My_Favorite_Websites:
ToolTip(98,"<a http://www.autohotkey.com >AutoHotkey</a> - <a http://de.autohotkey.com>DE</a>"
      . " - <a http://autohotkey.free.fr/docs/>FR</a> - <a http://www.autohotkey.it/>IT</a>"
      . " - <a http://www.script-coding.info/AutoHotkeyTranslation.html>RU</a>"
      . " - <a http://lukewarm.s101.xrea.com/>JP</a>"
      . " - <a http://lukewarm.s101.xrea.com/>GR</a>"
      . " - <a http://www.autohotkey.com/docs/Tutorial-Portuguese.html>PT</a>"
      . " - <a http://cafe.naver.com/AutoHotKey>KR</a>"
      . " - <a http://forum.ahkbbs.cn/bbs.php>CN</a>"
      . "`n<a http://www.google.com>Google</a> - <a http://www.maps.google.com>Maps</a>`n"
      . "<a http://social.msdn.microsoft.com/Search/en-US/?Refinement=86&Query=>MSDN</a>`n"
      , "My Websites"
      , "L1 O1 C1 BSilver FBlue I" . GetAssociatedIcon(A_ProgramFiles . "\Internet Explorer\iexplore.exe")
      . " P99")
Return

ToolTip_Examples:
ToolTip(97, "<a>Message Box ToolTip</a>`n"
      . "<a>Change ToolTip</a>`n"
      . "<a>ToolTip Loop #1</a>`n"
      . "<a>ToolTip Loop #2</a>`n"
      . "<a>ToolTip Loop #3</a>`n`nClose to return to previous ToolTip"
      , "ToolTip Examples"
      , "L1 O1 C1 BYellow FBlue I" . GetAssociatedIcon(A_ProgramFiles . "\Internet Explorer\iexplore.exe")
      . " P99")
Return

99ToolTip:
If InStr(link:=ErrorLevel,"http://")
   Run iexplore.exe %link%
else if IsLabel(link:=RegExReplace(link,"[^\w\.]","_"))
   SetTimer % link,-150
else if link
{
   Run % link
   SetTimer, Restart, -100
}
Return

98ToolTip:
Run iexplore.exe %ErrorLevel%
Return

97ToolTip:
IsLabel(ErrorLevel:=RegExReplace(ErrorLevel,"[^\w]","_"))
   SetTimer % ErrorLevel,-100
Return

99ToolTipClose:
MsgBox,262148,Closing ToolTip..., ToolTip is about to close`nClick no to disable ToolTip`n -You can show it again by clicking onto the Tray Icon`nDo you want to exit script?
IfMsgBox Yes
   ExitApp
Return

97ToolTipClose:
98ToolTipClose:
SetTimer, Restart, -100
Return

WM_NOTIFY(wParam, lParam, msg, hWnd){
   ToolTip("",lParam,"")
}

AHK_NotifyTrayIcon(wParam, lParam) {
   If (lparam = 0x201 or lparam = 0x202)
      SetTimer, Restart, -250
}


Hide_ToolTip:
ToolTip(99)
Return
Execute:
Run %ErrorLevel%.exe
SetTimer, Restart, -100
Return

ExitApp:
Loop, Parse, #_hIcons, |
      If A_LoopField
         DllCall("DestroyIcon",UInt,%A_LoopField%)
ExitApp
Return

ToolTip_Loop__1:
ToolTip(100,"`nJust an example ToolTip following mouse movements"
   ,"This ToolTip will be destroyed in " . 4 . " Seconds","o1 I" . GetAssociatedIcon(A_AhkPath) . " B0000FF FFFFFFF")
Start:=A_TickCount
end=
While, end < 10
{
   ToolTip(100,"In this example text and Title are updated continuously.`nTickCount:" . A_TickCount,"This ToolTip will be destroyed in " .  11 - Round(end:=(A_TickCount-Start)/1000) . " Seconds","I" . GetAssociatedIcon(A_AhkPath))
}
ToolTip(100)
Return
ToolTip_Loop__2:
end=
ToolTip(100,"In this example only position is tracked.","This ToolTip will be destroyed in 10 Seconds","D10 I" . GetAssociatedIcon(A_AhkPath) . " B0000FF FFFFFFF")
ToolTip(100)
Return

ToolTip_Loop__3:
end=
ToolTip(100,"`nHere only title is being changed"
   ,"This ToolTip will be destroyed in 10 Seconds","I" . GetAssociatedIcon(A_AhkPath) . " B0000FF FFFFFFF")
Start:=A_TickCount
While, end < 10
{
   ToolTip(100,"","This ToolTip will be destroyed in " .  11 - Round(end:=(A_TickCount-Start)/1000) . " Seconds","I" . GetAssociatedIcon(A_AhkPath))
}
ToolTip(100)
Return

Message_Box_Tooltip:
SetTimer,proceed, -200
MsgBox,4,Test,Hallo,`nPoint onto yes or no
proceed:
hwnd:=WinExist("Test ahk_class #32770")
ToolTip(101,"Click here to accept and proceed.","Here you see an example how to assign a ToolTip to MsgBox controls","I1 B00FF00 AButton1 P" . hwnd)
ToolTip(101,"Click here to refuse and proceed","","AButton2 P" . hwnd)
IfWinExist Test ahk_class #32770
{
   WinWaitClose, Test ahk_class #32770
   Return
}
ToolTip(101)
Return

Change_ToolTip:
Gui, Add,Button,,Point your mouse cursor here
Gui,+LastFound
ToolTip(1,"Test deleting and creating same Tooltip","TEST","Abutton1 P" . WinExist())
Gui,Show
Sleep, 5000
ToolTip(1)
Gui,Destroy
Sleep, 1000
Gui, Add,Button,,Move your mouse cursor a little
Gui,+LastFound
ToolTip(1,"Test deleting and creating same Tooltip`nTooltips were destroyed and recreated.","New Tooltip with different text and title.","Abutton1 P" . WinExist())
Gui,Show
Sleep, 5000
Gui,Destroy
ToolTip(1)
Return

#include Tooltip advanced 10.ahk
