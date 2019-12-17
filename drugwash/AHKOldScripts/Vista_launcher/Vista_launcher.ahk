#SingleInstance
;#NoTrayIcon
debug := 1

if A_OSType != WIN32_WINDOWS
	ver := 1
Loop, %ProgramFiles%\*.exe, 0, 1
{
If (A_LoopFileName = "firefox.exe")
	path1 = %A_LoopFileLongPath%
If (A_LoopFileName = "iexplore.exe")
	path2 = %A_LoopFileLongPath%
If (A_LoopFileName = "ccleaner.exe")
	path3 = %A_LoopFileLongPath%
}

;Gui +ToolWindow
Gui +AlwaysOnTop
Gui, Add, Tab, x5 y5 w300 h240 , Main|Games|System|Help

Gui, Tab, Main
Gui, Add, Button, x33 y40 w100 h30 , Explorer
Gui, Add, Button, x33 y80 w100 h30 Disabled, FireFox
Gui, Add, Button, x33 y120 w100 h30 Disabled, Internet Explorer
Gui, Add, Button, x33 y160 w100 h30 Disabled, CCleaner
Gui, Add, Button, x165 y40 w100 h30 , Media Player
Gui, Add, Button, x165 y80 w100 h30 , MyDocuments
Gui, Add, Button, x165 y120 w100 h30 , Desktop
Gui, Add, Button, x165 y160 w100 h30 , Programs

Gui, Tab, Games
Gui, Add, Button, x33 y40 w100 h30 , Spider Solitaire
Gui, Add, Button, x33 y80 w100 h30 , Solitaire
Gui, Add, Button, x33 y120 w100 h30 , Freecell
Gui, Add, Button, x33 y160 w100 h30 , Hearts
Gui, Add, Button, x165 y40 w100 h30 , Minesweeper
Gui, Add, Button, x165 y80 w100 h30 , Mahjong
Gui, Add, Button, x165 y120 w100 h30 , Chess
Gui, Add, Button, x165 y160 w100 h30 , Inkball

Gui, Tab, System
Gui, Add, Button, x33 y40 w100 h30 , Display Properties
Gui, Add, Button, x33 y80 w100 h30 , Time/Date
Gui, Add, Button, x33 y120 w100 h30 , Control Panel
Gui, Add, Button, x33 y160 w100 h30 , TaskMgr
Gui, Add, Button, x165 y40 w100 h30 , MultiLaunch
Gui, Add, Button, x165 y80 w100 h30 , Logoff
Gui, Add, Button, x165 y120 w100 h30 , Restart
Gui, Add, Button, x165 y160 w100 h30 , Shutdown

gui, tab
Gui, Add, DateTime, vMyDateTime x7 y225 w296 h18, %A_Space%%A_Space%%A_Space%%A_Space%%A_Space%%A_Space%%A_Space%%A_Space%%A_DDD%, %A_MMM% %A_DD%, %A_YYYY%                                     %A_Hour%:%A_Min%
Gui, Add, Button, x5 y207 w298 h18, Tasks

Gui, Tab, Help
Gui, Add, Text, x33 y35 w250 h20, To Show Launcher:        Middle Mouse Button
Gui, Add, Text, x33 y60 w250 h20, To show using Keys:       Ctrl+Z
Gui, Add, Text, x33 y85 w250 h20, To change volume:         Ctrl+Wheel up/down
Gui, Add, Text, x33 y110 w250 h20, To Cycle Active Tasks:    Alt+left/right Mouse Button
Gui, Add, Text, x33 y135 w250 h20, To Hide All Windows:       Alt+Space 
Gui, Add, Text, x33 y160 w250 h20, To show hidden windows:   Alt+X

If path1
	GuiControl, Enable, FireFox
If path2
	GuiControl, Enable, Internet Explorer
If path3
	GuiControl, Enable, CCleaner

;Gui, hide
Gui, show
SetTimer,  RefreshD, 1000
Return

RefreshD:
GuiControl, text, MyDateTime, %A_Space%%A_Space%%A_Space%%A_Space%%A_Space%%A_Space%%A_Space%%A_Space%%A_DDD%, %A_MMM% %A_DD%, %A_YYYY%                                     %A_Hour%:%A_Min%
return

GuiClose:
WinHide ;ExitApp
Return

ButtonTasks:
Menu,alttab,add
Menu,alttab,deleteall
;get windows list
Winget, ids, list, , , Program Manager
Loop, %ids%
   {
      id:=ids%A_Index%
      Wingettitle, title, ahk_id %id%
      ;exclude docks window and not needed ones
      If title not contains %A_ScriptName%
;      If title not contains KCmenu Vista.exe
;      If title not contains KCmenu Vista.ahk
      If title not contains Start
      If title not contains dock
         if(title!="")
            Menu,alttab,add, %title%,selTask
   }
Menu,alttab,show
Return

selTask:
WinActivate, %A_ThisMenuItem%
return

ButtonExplorer:
Run, explorer.exe C:\Program Files
gui, hide
Return

ButtonFirefox:
;Run, c:\program files\mozilla firefox\firefox.exe
Run, %path1%
gui, hide
Return

ButtonInternetExplorer:
;Run, c:\program files\internet explorer\iexplore.exe
Run, %path2%
gui, hide
Return

ButtonCCleaner:
;Run, C:\Program Files\CCleaner\ccleaner.exe
Run, %path3%
gui, hide
Return

ButtonMediaPlayer:
Run, C:\Program Files\Windows Media Player\wmplayer.exe
gui, hide
Return

ButtonDesktop:
Run, explorer %A_Desktop%
gui, hide
Return

ButtonMyDocuments:
Run, explorer %A_MyDocuments%
gui, hide
Return

ButtonPrograms:
Run, explorer %A_Programs%
gui, hide
Return

ButtonDisplayProperties:
if ver
	Run, %windir%\system32\control.exe desktop
else
	Run, desk.cpl
gui, hide
Return

ButtonControlPanel:
Run, control.exe
gui, hide
Return

ButtonSpiderSolitaire:
Run, %ProgramFiles%\Microsoft Games\SpiderSolitaire\SpiderSolitaire.exe
gui, hide
Return

ButtonFreeCell:
Run, %ProgramFiles%\Microsoft Games\FreeCell\FreeCell.exe
gui, hide
Return

ButtonHearts:
Run, %ProgramFiles%\Microsoft Games\Hearts\Hearts.exe
gui, hide
Return

ButtonMahjong:
Run, %ProgramFiles%\Microsoft Games\Mahjong\Mahjong.exe
gui, hide
Return

ButtonMinesweeper:
Run, %ProgramFiles%\Microsoft Games\Minesweeper\Minesweeper.exe
gui, hide
Return

ButtonSolitaire:
Run, %ProgramFiles%\Microsoft Games\Solitaire\Solitaire.exe
gui, hide
Return

ButtonChess:
Run, %ProgramFiles%\Microsoft Games\chess\chess.exe
gui, hide
Return

ButtonInkball:
Run, %ProgramFiles%\Microsoft Games\inkball\InkBall.exe
gui, hide
Return

ButtonMultiLaunch:
Run, C:\Program Files\Windows Live\Messenger\msnmsgr.exe
Run, C:\Program Files\Yahoo!\Messenger\YahooMessenger.exe
gui, hide
Return

ButtonTime/Date:
Run, timedate.cpl
gui, hide
Return

ButtonLogoff:
Shutdown, 0
Return

ButtonRestart:
Shutdown, 2
Return

ButtonShutdown:
Shutdown, 9
Return

ButtonTaskmgr:
if ver
	Run, taskmgr.exe
else
	Run, taskman.exe
gui, hide
Return

Mbutton::Gui, show
^LButton::Gui, show
LCtrl & Z::Gui, show
^Z::Gui, show

LAlt & Rbutton::Send, !{ESC}
LAlt & Lbutton::Send, !+{ESC}

;volume control
#MaxThreadsPerHotkey 2
#MaxThreadsBuffer On
LCtrl & wheeldown::
LCtrl & wheelup::
volctrl:
IfWinNotExist, Volume Mixer
Run sndvol.exe
IfWinNotActive, Volume Mixer
WinActivate, Volume Mixer
Hotkey, LCtrl & wheeldown, voldown
Hotkey, LCtrl & wheelup, volup
KeyWait, Control
Sleep 400
WinClose Volume Mixer
Hotkey, LCtrl & wheeldown, volctrl
Hotkey, LCtrl & wheelup, volctrl
return
voldown:
Send {Volume_down}
;SoundPlay, *-1
return
volup:
Send {Volume_up}
;SoundPlay, *-1
return
#MaxThreadsBuffer Off
#MaxThreadsPerHotkey 1

;Boss Key
LAlt & space::
      WinGet, id, list,,, Program Manager
      Loop, %id%
      {
         StringTrimRight, this_id, id%a_index%, 0
         WinGetTitle, title, ahk_id %this_id%
         WinGetClass, class, ahk_id %this_id%
         WinHide, ahk_id %this_id%
         HWins = %HWins%||%this_id%
       }
      Return
   
LAlt & X::
      Loop, Parse, HWins, ||
         WinShow, ahk_id %A_LoopField%
      Return
