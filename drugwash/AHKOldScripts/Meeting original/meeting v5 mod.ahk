; http://www.autohotkey.com/forum/viewtopic.php?p=274999#274999
; modified by Drugwash June 15 2009
;This script is meant to generate a set of GUIs to create a seriatim, or a log of speakers, for the purposes of transcription.  One speaker per line,and only use letters, numbers, spaces, and periods. Lines beginning with $ are where the positions of each speaker are stored and are automatically generated by moving/resizing the GUIs to resemble a diagram of the room the speakers are located, and then pressing the Save_Config button.  You may then re-use the same speaker list and the "Apply_Config" button to immediately restore the same floor plan. 

;Lines beginning with a pipe symbol (|) are comment lines and are ignored by the script. It is not recommended that you save many comments in the speaker list however. 

;This version is my latest little time-wasting project, a combination of this project with another I have been using as a learning tool here at AHK forums etc.  It is TRC, or Total Recorder Controller.  The basic idea here is to create a seriatim, and essentially link it to the actual recording application.  You must have total recorder installed to use it.  For testing purposes if you like you can just download an evaluation copy.  Each line on the speaker list creates a gui.  When the one button on each gui is pressed, a variable is created which holds the current time in the recording.  When the goto or gotoplay buttons are pressed, you advance backward through these bookmarks and alternately play them back in TR.  The Resume button restarts the recording after doing so. 

;When the Ctrl- button is held down while pressng a GUI button, an alternate string is sent.

;Pls. try it and report bugs at

;  http://www.autohotkey.com/forum/viewtopic.php?t=45037&start=0&postdays=0&postorder=asc&highlight=
;*******************************************************************************************
SetTitleMatchMode 2 ; otherwise it doesn't detect the window
SetTitleMatchMode Fast
SetWorkingDir := A_ScriptDir
Gui, 99:Add, GroupBox, x8 y1 w378 h260 , Settings
Gui, 99:Add, Text, x16 y15 w300 h20 +0x200, Select your preferred text editor:
Gui, 99:Add, Edit, x16 y37 w300 h20 +0x200 vmyeditor, Notepad
Gui, 99:Add, Button, x318 y37 w60 h20 gselectedit, Browse
Gui, 99:Add, Text, x16 y59 w180 h20 +0x200, Hotkey for editor's 'Refresh' function:
Gui, 99:Add, Hotkey, x199 y59 w65 h20 vehk1, 
Gui, 99:Add, Hotkey, x266 y59 w50 h20 vehk2, 
Gui, 99:Add, Hotkey, x318 y59 w60 h20 vehk3, 
Gui, 99:Add, Text, x16 y81 w300 h20 +0x200, Select seriatim file for this event (leave blank to create new):
Gui, 99:Add, Edit, x16 y103 w300 h20 vGizmo, 
Gui, 99:Add, Button, x318 y103 w60 h20 gselectser, Browse
Gui, 99:Add, Text, x16 y125 w300 h20 +0x200, Select storage path for seriatim file (leave blank for app folder):
Gui, 99:Add, Edit, x16 y147 w300 h20 vfilepath, 
Gui, 99:Add, Button, x318 y147 w60 h20 gselfilepath, Browse
Gui, 99:Add, Text, x16 y169 w300 h20 +0x200, Select speaker list for this event (leave blank to create new):
Gui, 99:Add, Edit, x16 y191 w300 h20 vGomi, 
Gui, 99:Add, Button, x318 y191 w60 h20 gselectspk, Browse
Gui, 99:Add, Text, x16 y213 w300 h20 +0x200, Select storage path for speaker list (leave blank for app folder):
Gui, 99:Add, Edit, x16 y235 w300 h20 vspkpath, 
Gui, 99:Add, Button, x318 y235 w60 h20 gselspkpath, Browse
Gui, 99:Add, Text, x16 y267 w180 h30 +Center +Border +Border, Place for name && version,`npicture logo, etc.
Gui, 99:Add, Button, x206 y267 w110 h30 , &Run
Gui, 99:Add, Button, x318 y267 w60 h30 , E&xit
Gui, 99:+OwnDialogs
Gui, 99:Show, x350 y160 h305 w395, Settings
Return

selectedit:
FileSelectFile, myeditor, 3,, Select your preferred text editor (leave blank for default):, Application (*.exe)
IfNotExist, %myeditor%
	myeditor = Notepad
GuiControl,99:, myeditor, %myeditor%
return

selectser:
FileSelectFile, Gizmo, 3,, Select seriatim file for this event (leave blank to create new):, Text file (*.txt)
IfNotExist, %Gizmo%
	Gizmo = %A_MM%-%A_DD%.txt
GuiControl,99:, Gizmo, %Gizmo%
return

selectspk:
FileSelectFile, Gomi, 3,, Select speaker list for this event (leave blank to create new):, Text file (*.txt)
IfNotExist, %Gomi%
	{
	neededit=1
	Gomi = 00Speakerlist%A_MM%%A_DD%%A_Hour%%A_Min%.txt
	FileAppend,Speaker 1`r`nSpeaker 2 `r`nSpeaker 3 `r`nSpeaker 4 `r`n@Table,%Gomi% ;Creates a generic speaker list
	}
GuiControl,99:, Gomi, %Gomi%
return

selfilepath:
FileSelectFolder, filepath, *%A_WorkingDir%, 3, Select storage path for seriatim file (leave blank for app folder):
IfNotExist, %filepath%
	filepath := A_WorkingDir
filepath := RegExReplace(filepath, "\\$")
GuiControl,99:, filepath, %filepath%
return

selspkpath:
FileSelectFolder, spkpath, *%A_WorkingDir%, 3, Select storage path for speaker list (leave blank for app folder):
IfNotExist, %spkpath%
	spkpath := A_WorkingDir
spkpath := RegExReplace(spkpath, "\\$")
GuiControl,99:, spkpath, %spkpath%
return

99ButtonExit:
99GuiClose:
ExitApp

99ButtonRun:
Gui, 99:-OwnDialogs
Gui, 99:Submit ; needs double-check for filename/path errors
IfNotExist, %Gizmo%
	Gizmo = %A_MM%-%A_DD%.txt
IfNotExist, %Gomi%
	{
	neededit=1
	Gomi = 00Speakerlist%A_MM%%A_DD%%A_Hour%%A_Min%.txt
	FileAppend,Speaker 1`r`nSpeaker 2 `r`nSpeaker 3 `r`nSpeaker 4 `r`n@Table,%Gomi% ;Creates a generic speaker list
	}
IfNotExist, %myeditor%
	myeditor = Notepad

refresh := (ehk1 ? "{" ehk1 "}" : "") . (ehk2 ? "{" ehk2 "}" : "") . (ehk3 ? "{" ehk3 "}" : "")
Loop, %Gizmo%
	FileMove, %Gizmo%, filepath "\" A_LoopFileName
Loop, %Gomi%
	FileMove, %Gomi%, spkpath "\"  A_LoopFileName
Rosie =
nn =
grip=15 ; width of blue grip to the right of the speaker labels
if neededit
	{
	Msgbox,%Gomi% is your speaker list.  Start by changing the examples to your actual speakers.  You may add as many as you wish.  Make them one name per line only. Numbers and Letters only`, no commas`,colons`, semicolons or any other funny business.  Periods are allowed. You may always revise the list and restart the program again too. Pls. note that one called `"table`" has no button and can be shaped and resized to resemble oh, say, a table.  You may create buttonless GUIs for this purpose by prefixing their name with the `"`@`" symbol.
	RunWait, %myeditor% %Gomi%
	Sleep, 1000	; allow the OS to save the file properly
	}
MsgBox,You will need to turn on `"append mode under `"Record`/Play`" on the toolbar menu`, and you will also need to select `"show sound image`" either `"in panel`" or `"in separate window.`"  It is presumed that you have a working knowledge of Total Recorder prior to using this.  If so`, now would be a good time to start the recording.  If not`, you should exit this program and go learn your way around TR before trying this.

IfWinExist,ahk_class TotalRecorderWndClass
WinActivate,ahk_class TotalRecorderWndClass
;*******************************************************************************************
SplitPath,Gomi,Omig

Topper = 1
Gui, 1:Add, Button, x0 y10 w80 h30 , Record
Gui, 1:Margin, 0, 0
Gui, 1:Add, Button, x0 y189 w40 h30 , <<
Gui, 1:Add, Button, x40 y189 w40 h30 , <
Gui, 1:Add, Button, x80 y189 w40 h30 , >
Gui, 1:Add, Button, x120 y189 w40 h30 , >>
Gui, 1:Add, Button, x0 y160 w80 h30 , Bookmark
Gui, 1:Add, Button, x0 y100 w80 h30 , Goto
Gui, 1:Add, Button, x80 y100 w80 h30 , Goto_play
Gui, 1:Add, Button, x80 y10 w80 h30 , Resume
Gui, 1:Add, Button, x0 y130 w80 h30 , View_log
Gui, 1:Add, Button, x80 y160 w80 h30 , Query
Gui, 1:Add, Button, x0 y40 w80 h30 , Q
Gui, 1:Add, Button, x80 y40 w80 h30 , A
Gui, 1:Add, Button, x0 y70 w80 h30 , Save_Config
Gui, 1:Add, Button, x80 y130 w80 h30 , Speakerlist
Gui, 1:Add, Button, x80 y70 w80 h30 , Apply_Config
Gui, 1:Add, Button, x0 y220 w80 h30 , Reload
Gui, 1:Add, Button, x80 y220 w80 h30 ,Toggle_TR
Gui, 1:+AlwaysOnTop
; Generated using SmartGUI Creator 4.0
Gui, 1:Show,x0 y0, TRC
Gui, 1:+Default

M%Topper% = TRC

Loop
{
   FileReadLine,Boy,%Gomi%,%A_Index%
   If Errorlevel
   Break
   IfInString,Boy,|
   Continue
   IfInString,Boy,$
   Break
   If Boy =
   Continue
   IfInString,Boy,`&
      {
      StringReplace,Boy,Boy,`&,,All
      Kramer = %Boy%
      Continue
      }
   Topper++
   Goy = %Boy%
   Boy = %Goy%
   Gui,%Topper%:+Resize -MaximizeBox +ToolWindow +AlwaysonTop +MinSize50x16 -Caption
   Gui, %Topper%:Font, S%Kramer% ;,MS Sans Serif
   Gui,%Topper%:-SysMenu
   Gui,%Topper%:Margin,0,0
   IfInString,Boy,@
     {
        StringReplace,Boy,Boy,@,
        Gui, %Topper%:Font, S%Kramer% ;,MS Sans Serif
	Gui, %Topper%:+LabelTable +MinSize50x40
	Gui, %Topper%:Add, Picture, w50 h50 gmoveit, tbl.bmp
 	Gui, %Topper%:Add,Text, x1 y1 cWhite BackgroundTrans Center,%Boy%
	Gui, %Topper%:Show,x200 y0,%Boy%
        M%Topper% = %Boy%
        Continue
     }
   Gui, %Topper%:+LabelSpkr
   Gui, %Topper%:Font,S%Kramer% ;,MS Sans Serif
   Gui, %Topper%:Add,Button, x0 y0 gButtonSpeaker ,%Boy%
   Gui, %Topper%:Add, Picture, x+1 yp w%grip% hp gmoveit, spk.bmp
   Gui, %Topper%:Show,x200 y0,%Boy%
   M%Topper% = %Boy%
}

FileAppend,`r`n`[Script started %A_MM%-%A_DD%-%A_Hour%:%A_Min%:%A_Sec%`]`r`n,%Gizmo%

; If not using Notepad++ you will want to delete or change these lines.  They are mostly for testing purposes.

;Run %A_ProgramFiles%\Notepad++\notepad++.exe %A_ScriptFullPath%
; Why open the speaker list again, once it's already been edited ?!
;Run %myeditor% %Gomi%

; If not using Notepad++ you will want to change the viewer to notepad or your preferred text viewer in the following line.

Run %myeditor% %Gizmo%

;IfWinExist,Total Recorder Spectrum Analyzer
;WinSet,AlwaysOnTop,On,Total Recorder Spectrum Analyzer

Return

TableSize:
GuiControl, %A_Gui%:MoveDraw, Static1, x0, y0, w%A_GuiWidth%, h%A_GuiHeight%
GuiControl, %A_Gui%:MoveDraw, Static2, x0, y0, w%A_GuiWidth%
return

SpkrSize:
nx := A_GuiWidth-grip
GuiControl, %A_Gui%:MoveDraw, Static1, x%nx%, y0, w%grip%, h%A_GuiHeight%
GuiControl, %A_Gui%:MoveDraw, Button1, x0, y0, w%nx% , h%A_GuiHeight%
return

moveit:
PostMessage, 0xA1, 2,,, A ; this allows dragging a window by any spot ;-)
return

ButtonSpeaker:

If A_Gui = 1
{
Gosub Button%Speaker%
Sleep,50
Goto Scrapple
}
Else

GetKeyState,ByA,Ctrl
If ByA = D
{
 ControlGetText,Timex,Static8,ahk_class TotalRecorderWndClass
 FormatTime, timey,, HH:mm:ss
 FileAppend, `r`n`[%Timex%-%timey%`]%A_Tab%%A_Tab%BY%A_Space%,%Gizmo%
 FileAppend,% M%A_Gui% ":",%Gizmo%
}

Else
{
 ControlGetText,Timex,Static8,ahk_class TotalRecorderWndClass
 FormatTime, timey,, HH:mm:ss
 FileAppend, `r`n`[%Timex%-%timey%`],%Gizmo%
 FileAppend,% M%A_Gui%,%Gizmo%
 FileAppend,:*.%A_Space%, %Gizmo%
}
 Rosie++
 R%Rosie% := Timex
 Pinky = %Rosie%
 Goto Scrapple
 
^+#Escape::ExitApp

;-----------------------------------------------------

ButtonSave_Config:

Loop,Read,%Gomi%,deleme.txt
{
   If A_LoopReadLine =
   Continue
   StringReplace,FancyPants,A_LoopReadLine,`n,,All
   StringReplace,FancyPants,FancyPants,`r,,All
   StringReplace,FancyPants,FancyPants,`,,``,,All
   IfInString,FancyPants,$
   Continue
   FileAppend,%FancyPants%`r`n
}
Loop,Read,%Gomi%,deleme.txt
{
   If A_LoopReadLine =
   Continue
   IfInString,A_LoopReadLine,|
   Continue
   IfInString,A_LoopReadLine,$
   Continue
   IfInString,A_LoopReadLine,`&
   Continue
   Autotrim,On
   FancyPants = %A_LoopReadLine%
   StringReplace,FancyPants,FancyPants,@,,All
   WinGetPos,xx,yy,ww,hh,%FancyPants%
   FileAppend,$%FancyPants%`,%xx%`,%yy%`,%ww%`,%hh%`r`n
}
WinGetPos,xx,yy,ww,hh,TRC
FileAppend,$TRC`,%xx%`,%yy%`,%ww%`,%hh%`r`n,deleme.txt

WinGetPos,xx,yy,ww,hh,ahk_class TotalRecorderWndClass
FileAppend,$ahk_class TotalRecorderWndClass`,%xx%`,%yy%`,%ww%`,%hh%`r`n,deleme.txt

FileMove,deleme.txt,%Gomi%,1
FileAppend,`r`n,%Gomi%

Return

ButtonApply_Config: ;;This reads all lines containing "$" and moves the GUIs to those positions. 
Loop
{
   FileReadLine,Troy,%Gomi%,%A_Index%
      If Troy =
   Break
   IfInString,Troy,$
      {
      StringSplit,aa,Troy,`,,$
      WinMove,%aa1%,,%aa2%,%aa3%,%aa4%,%aa5%
      }
}
Return
;-----------------------------------------------------

;TRC stuff follows

;-----------------------------------------------------
Pause::Suspend
;-----------------------------------------------------

ButtonQuery:
ControlGetText,Timex,Static8,ahk_class TotalRecorderWndClass
FormatTime, timey,, HH:mm:ss
stringtolog = `n[%Timex%-%timey%-00QUERY`]
goto commonsub

ButtonQ:
ControlGetText,Timex,Static8,ahk_class TotalRecorderWndClass
FormatTime, timey,, HH:mm:ss
stringtolog = `n[%Timex%-%timey%`]Q*.%A_Space%
goto commonsub

ButtonA:
ControlGetText,Timex,Static8,ahk_class TotalRecorderWndClass
FormatTime, timey,, HH:mm:ss
stringtolog = `n[%Timex%-%timey%`]A*.%A_Space%
goto commonsub

ButtonBookmark:
ControlGetText,Timex,Static8,ahk_class TotalRecorderWndClass
FormatTime, timey,, HH:mm:ss
; shouldn't this have a newline prepended ??? I added one, just in case
stringtolog = `n*.%A_Space%[%Timex%-%timey%--00Marker`]
commonsub:
Rosie++
FileAppend, %stringtolog%,%Gizmo%
R%Rosie% := Timex
Pinky = %Rosie%
Goto Scrapple

ButtonRecord:
;nn = 1
;Rosie++
Disney = 1
ControlGetText,Timex,Static8,ahk_class TotalRecorderWndClass
ControlClick,Button14,ahk_class TotalRecorderWndClass
R%Rosie% = %Timex%
;FormatTime, timey,, HH:mm:ss
FileAppend, `r`n`[Recording Begin %Timex%-%timey%`],%Gizmo%
ControlClick,Button20,ahk_class TotalRecorderWndClass
;Pinky = %Rosie%
WinSet,AlwaysOnTop,Off,ahk_class TotalRecorderWndClass
Return

ButtonGoto_Play:
WinSet,AlwaysOnTop,On,ahk_class TotalRecorderWndClass
If Disney <>
{
WinActivate,Total Recorder
Rosie++
ControlGetText,Timex,Static8,ahk_class TotalRecorderWndClass
R%Rosie% := Timex
FileAppend, `r`n[Recording Paused %Timex%-%timey%`],%Gizmo%
}
Gosub, Backup
Sleep,50
ControlClick,Button16,ahk_class TotalRecorderWndClass
Disney =
Return

ButtonGoto:
WinSet,AlwaysOnTop,On,ahk_class TotalRecorderWndClass
If Disney <>
{
WinActivate,Total Recorder
Rosie++
ControlGetText,Timex,Static8,ahk_class TotalRecorderWndClass
R%Rosie% := Timex
FileAppend, `r`n[Recording Paused %Timex%-%timey%`],%Gizmo%
Pinky = %Rosie%
}
Gosub, Backup
Disney =
Return

Backup:
Pinky--
if Pinky < 0
	return	; otherwise it throws an error
Rnn := R%Pinky%
ControlClick,Button19,ahk_class TotalRecorderWndClass
Sleep,50
ControlClick,ToolBarWindow324,ahk_class TotalRecorderWndClass
WinWaitActive,Jump to time
Sleep,50
ControlSetText,Edit1,%Rnn%,Jump to time
Sleep,50
ControlClick,Button3,Jump to time
Sleep,30
If Pinky = 1
{
Msgbox,,2,Out of bookmarks!,.5
Pinky = %Rosie%
}
Return

JumpBox:
^+j::
ControlClick,ToolBarWindow324,ahk_class TotalRecorderWndClass
Return

ButtonView_log:
SetTitleMatchMode,1
IfWinNotExist,%Gizmo%
{
Run %myeditor% %Gizmo%
WinWaitActive,%Gizmo%
ControlSend,,^{End},%Gizmo%
Return
}
Else
WinKill,%Gizmo%
Return

ButtonSpeakerlist:
IfWinNotExist,%Omig%
{
Run %myeditor% %Gomi%
WinWaitActive,%Omig%
ControlSend,,^{End},%Omig%
Return
}
Else
WinKill,%Omig%
Return


ButtonResume:
nn = 1
Disney = 1
ControlClick,Button14,ahk_class TotalRecorderWndClass
Sleep,10
ControlGetText,Timex,Static8,ahk_class TotalRecorderWndClass
R%Rosie% := Timex
FileAppend, `r`n[Recording Resume %Timex%-%timey%`],%Gizmo%
ControlClick,Button20,ahk_class TotalRecorderWndClass
WinSet,AlwaysOnTop,Off,ahk_class TotalRecorderWndClass
Gosub,Scrapple
Return

^#c:: ;;This sends highlighted text to the TR jumpbox and presses OK
Send,^c
Bubba := Clipboard
ControlClick,Button19,ahk_class TotalRecorderWndClass
Sleep,300
ControlClick,ToolBarWindow324,ahk_class TotalRecorderWndClass
WinWaitActive,Jump to time
ControlSetText,Edit1,%Bubba%,Jump to time
ControlClick,Button3,Jump to time
Return

Button<<:
ControlClick,Button11,ahk_class TotalRecorderWndClass
Return

Button<:
ControlClick,Button12,ahk_class TotalRecorderWndClass
Return

Button>:
ControlClick,Button13,ahk_class TotalRecorderWndClass
Return

Button>>:
ControlClick,Button14,ahk_class TotalRecorderWndClass
Return


ButtonReload:
^+#Backspace:
Reload
Return

ButtonToggle_TR:
^+#t::  ;;toggle TR to front and back
Abby++
If Abby = 1
   {
   WinSet,AlwaysOnTop,ON,ahk_class TotalRecorderWndClass
   WinActivate,ahk_class TotalRecorderWndClass
   Return
   }
Else
   {
   WinSet,AlwaysOnTop,Off,ahk_class TotalRecorderWndClass
   WinActivate,ahk_class TotalRecorderWndClass
   Gosub,Scrapple
   If Abby > 1
   Abby = 0
   }
Return

Scrapple:
^#!9::
IfWinNotExist,%Gizmo%
{
Run %myeditor% %Gizmo%
WinWaitActive,%Gizmo%
ControlSend,,^{End},%Gizmo%
Return
}
Else if refresh
	{
	WinActivate, %Gizmo%
	WinWaitActive, %Gizmo%
	SendInput %refresh%
	}
Else
{
WinKill,%Gizmo%
Run %myeditor% %Gizmo%
}
WinWaitActive,%Gizmo%
ControlSend,,^{End}, %Gizmo%
Return
