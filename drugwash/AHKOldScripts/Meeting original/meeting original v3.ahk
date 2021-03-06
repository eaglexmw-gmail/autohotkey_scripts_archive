
Rosie =
nn =

;This script is meant to generate a set of GUIs to create a seriatim, or a log of speakers, for the purposes of transcription.  One speaker per line,and only use letters, numbers, spaces, and periods. Lines beginning with $ are where the positions of each speaker are stored and are automatically generated by moving/resizing the GUIs to resemble a diagram of the room the speakers are located, and then pressing the Save_Config button.  You may then re-use the same speaker list and the "Apply_Config" button to immediately restore the same floor plan. 

;Lines beginning with a pipe symbol (|) are comment lines and are ignored by the script. It is not recommended that you save many comments in the speaker list however. 

;This version is my latest little time-wasting project, a combination of this project with another I have been using as a learning tool here at AHK forums etc.  It is TRC, or Total Recorder Controller.  The basic idea here is to create a seriatim, and essentially link it to the actual recording application.  You must have total recorder installed to use it.  For testing purposes if you like you can just download an evaluation copy.  Each line on the speaker list creates a gui.  When the one button on each gui is pressed, a variable is created which holds the current time in the recording.  When the goto or gotoplay buttons are pressed, you advance backward through these bookmarks and alternately play them back in TR.  The Resume button restarts the recording after doing so. 

;When the Ctrl- button is held down while pressng a GUI button, an alternate string is sent.

;Pls. try it and report bugs at

;  http://www.autohotkey.com/forum/viewtopic.php?t=45037&start=0&postdays=0&postorder=asc&highlight=


FileSelectFile,Gizmo,,,Select a seriatim file for this event`, or press ESCAPE to create one,*.txt

If Gizmo =
Gizmo = %A_MM%-%A_DD%.txt
Else

;MsgBox,You will need to turn on `"append mode under `"Record`/Play`" on the toolbar menu`, and you will also need to select `"show sound image`" either `"in panel`" or `"in separate window.`"  It is presumed that you have a working knowledge of Total Recorder prior to using this.  If so`, now would be a good time to start the recording.  If not`, you should exit this program and go learn your way around TR before trying this.

IfWinExist,ahk_class TotalRecorderWndClass
WinActivate,ahk_class TotalRecorderWndClass

FileSelectFile,Gomi,,,Select a Speaker list for this event`, or press ESCAPE to create one,*.txt

   If Gomi = ;User has selected a blank template

{
   Gomi = %A_Desktop%\00Speakerlist%A_MM%%A_DD%%A_Hour%%A_Min%.txt


;   Msgbox,%Gomi% is your speaker list.  Start by changing the examples to your actual speakers.  You may add as many as you wish.  Make them one name per line only. Numbers and Letters only`, no commas`,colons`, semicolons or any other funny business.  Periods are allowed. You may always revise the list and restart the program again too. Pls. note that one called `"table`" has no button and can be shaped and resized to resemble oh, say, a table.  You may create buttonless GUIs for this purpose by prefixing their name with the `"`@`" symbol.

   FileAppend,Speaker 1`r`nSpeaker 2 `r`nSpeaker 3 `r`nSpeaker 4 `r`n@Table,%Gomi% ;Creates a generic speaker list


   Msgbox,0,Press Ctrl-C to copy filepath to your clipboard and then press OK to restart,%Gomi%
   Exitapp
}

else

SplitPath,Gomi,Omig

Topper = 1

Gui, Add, Button, x0 y10 w80 h30 , Record
Gui,Margin,0,0
Gui, Add, Button, x0 y189 w40 h30 , <<
Gui, Add, Button, x40 y189 w40 h30 , <
Gui, Add, Button, x80 y189 w40 h30 , >
Gui, Add, Button, x120 y189 w40 h30 , >>
Gui, Add, Button, x0 y160 w80 h30 , Bookmark
Gui, Add, Button, x0 y100 w80 h30 , Goto
Gui, Add, Button, x80 y100 w80 h30 , Goto_play
Gui, Add, Button, x80 y10 w80 h30 , Resume
Gui, Add, Button, x0 y130 w80 h30 , View_log
Gui, Add, Button, x80 y160 w80 h30 , Query
Gui, Add, Button, x0 y40 w80 h30 , Q
Gui, Add, Button, x80 y40 w80 h30 , A
Gui, Add, Button, x0 y70 w80 h30 , Save_Config
Gui, Add, Button, x80 y130 w80 h30 , Speakerlist
Gui, Add, Button, x80 y70 w80 h30 , Apply_Config
Gui, Add, Button, x0 y220 w80 h30 , Reload
Gui, Add, Button, x80 y220 w80 h30 ,Toggle_TR
Gui,+AlwaysOnTop
; Generated using SmartGUI Creator 4.0
Gui,Show,x0 y0, TRC

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
   Gui,%Topper%:+Resize -MaximizeBox +ToolWindow +AlwaysonTop
   Gui, %Topper%:Font, S%Kramer% ;,MS Sans Serif
   Gui,%Topper%:-SysMenu
   Gui,%Topper%:Margin,0,0
   IfInString,Boy,@
     {
        StringReplace,Boy,Boy,@,
        Gui, %Topper%:Font, S%Kramer% ;,MS Sans Serif
      Gui,%Topper%:Add,Text,,%Boy%
        Gui,%Topper%:Show,x200 y0,%Boy%
        M%Topper% = %Boy%
        Continue
     }
   Gui,%Topper%:Font,S%Kramer% ;,MS Sans Serif
   Gui,%Topper%:Add,Button, gButtonSpeaker ,%Boy%
   Gui,%Topper%:Show,x200 y0,%Boy%
   M%Topper% = %Boy%
}

FileAppend,`r`n`[Script started %A_MM%-%A_DD%-%A_Hour%:%A_Min%:%A_Sec%`]`r`n,%Gizmo%

; If not using Notepad++ you will want to delete or change these lines.  They are mostly for testing purposes.

Run %A_ProgramFiles%\Notepad++\notepad++.exe %A_ScriptFullPath%
Run %A_ProgramFiles%\Notepad++\notepad++.exe %Gomi%

; If not using Notepad++ you will want to change the viewer to notepad or your preferred text viewer in the following line.

Run %A_ProgramFiles%\Notepad++\notepad++.exe %Gizmo%

Return



ButtonSpeaker:

If A_Gui = 1
{
Gosub Button%Speaker%
Sleep,50
WinActivate,ahk_class Notepad++
Return
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
 WinActivate,ahk_class Notepad++
 return
 
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
   StringReplace,FancyPants,A_LoopReadLine,@,,All
   WinGetPos,xx,yy,ww,hh,%FancyPants%
   FileAppend,$%FancyPants%`,%xx%`,%yy%`,%ww%`,%hh%`r`n
}
WinGetPos,xx,yy,ww,hh,TRC
FileAppend,$TRC`,%xx%`,%yy%`,%ww%`,%hh%`r`n,deleme.txt
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
Rosie++
ControlGetText,Timex,Static8,ahk_class TotalRecorderWndClass
FormatTime, timey,, HH:mm:ss
FileAppend, `n[%Timex%-%timey%-00QUERY`],%Gizmo%
R%Rosie% := Timex
Pinky = %Rosie%
WinActivate,ahk_class Notepad++
Return

ButtonQ:
Rosie++
ControlGetText,Timex,Static8,ahk_class TotalRecorderWndClass
FormatTime, timey,, HH:mm:ss
FileAppend, `n[%Timex%-%timey%`]Q*.%A_Space%,%Gizmo%
R%Rosie% := Timex
Pinky = %Rosie%
WinActivate,ahk_class Notepad++
Return

ButtonA:
Rosie++
ControlGetText,Timex,Static8,ahk_class TotalRecorderWndClass
FormatTime, timey,, HH:mm:ss
FileAppend, `n[%Timex%-%timey%`]A*.%A_Space%,%Gizmo%
R%Rosie% := Timex
Pinky = %Rosie%
WinActivate,ahk_class Notepad++
Return

ButtonBookmark:
Rosie++
ControlGetText,Timex,Static8,ahk_class TotalRecorderWndClass
FormatTime, timey,, HH:mm:ss
FileAppend, *.%A_Space%[%Timex%-%timey%--00Marker`],%Gizmo%
R%Rosie% := Timex
Pinky = %Rosie%
WinActivate,ahk_class Notepad++
Return

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
Rnn := R%Pinky%
ControlClick,Button19,ahk_class TotalRecorderWndClass
Sleep,100
ControlClick,ToolBarWindow324,ahk_class TotalRecorderWndClass
WinWaitActive,Jump to time
ControlSetText,Edit1,%Rnn%,Jump to time
Sleep,200
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
IfWinNotExist,%gizmo% - Notepad
{
Run Notepad  %Gizmo%
WinWaitActive,%Gizmo% - Notepad
ControlSend,,^{End},%Gizmo% - Notepad
Return
}
Else
WinKill,%Gizmo% - Notepad
Return

ButtonSpeakerlist:
IfWinNotExist,%Omig% - Notepad
{
Run Notepad %Gomi%
WinWaitActive,%Omig% - Notepad
ControlSend,,^{End},%Omig% - Notepad
Return
}
Else
WinKill,%Omig% - Notepad
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
WinActivate,ahk_class Notepad++
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
   WinActivate,ahk_class Notepad++
   If Abby > 1
   Abby = 0
   }
Return
