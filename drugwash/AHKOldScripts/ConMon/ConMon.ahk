

#include StdoutToVar.ahk
#NoEnv
#SingleInstance Off
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 1

Menu, Tray, NoStandard
;Menu, Tray, Add, Help!, HelpOpen
Menu, Tray, Add, Exit, GuiClose
OnExit, PreExit

TotalTests=0
TotalTimeOuts=0
Periods=0




;;;;;;;;;input;;;;;;;;;;;;;;;;;;;;;;;;;;;
Gui 1: add, edit, x5 y5 W90 limit15 vIpAddress
Gui 1: add, text, x100 y10, IP address
Gui 1: add, DateTime,1 x190 y5 w90 vStopTime, hh:mm tt
Gui 1: add, text, x285 y10, Stop Time
Gui 1: add, text, x5 y35, Account info/notes:
Gui 1: add, Checkbox, x190 y35 checked gPopCheckBox vPopup, Notify when down?
Gui 1: add, edit, x5 y50 r6 w330 vMessage
Gui 1: add, checkbox, x5 y144 vLog gfilebox, -
Gui 1: add, edit, x30 y141 w210 vFilePath -WantReturn disabled, Log to file?
Gui 1: add, button, x245 y140 disabled gBrowse, Browse
;;;;;;OK button;;;;;;;;;;;;;;;;;;;;
Gui 1: Add, Button, x305 y140 Default gExecute, GO!
Gui 1: show,, PingPop

return   ;end of auto execution





;;;;;;;;;when you click OK;;;;;;;;;;;;
Execute:
  Gui 1: Submit ; Save the control's val to the assoc var w/o losing the GUI window      ;saves all vars

Menu, Tray, Tip, Testing in progress %IpAddress%   


;;;;;;Gui2;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Gui 2: add, edit, w300 r(StrLen(String)) readonly, %IpAddress% is now timing out!`n%Message%
Gui 2: add, button, gGui2clear, Ok
;Menu, Tray, delete, About?
Menu, Tray, delete, Exit
Menu, Tray, Add, Show Notes, ShowNotes
Menu, Tray, Add, About?, AboutOpen
Menu, Tray, Add, Exit, GuiClose
;;;;;;Gui2;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



FormatTime, Midnight, %StopTime%, HHmm
If Midnight <= %A_Hour%%A_Min%
{
   outputdebug, crossing midnight! %CheckTime% < %A_Hour%%A_Min%
   Tomorrow += 1, Days
   FormatTime, CheckTime, %Tomorrow%, MMddyyyy%Midnight%
}
Else
   FormatTime, CheckTime, %StopTime%, MMddyyyyHHmm
If Log
{
   If (SubStr(FilePath, 1, 3) = "...")
   {
      StringTrimLeft, FilePath, FilePath, 3
      LogPath = %A_WorkingDir%%FilePath%
   }
   Else
      LogPath = %FilePath%


   StringSplit, PathArray, LogPath, `\
   Shave := StrLen(PathArray%PathArray0%)
   StringTrimRight, LogDir, LogPath, %Shave%
   
   outputdebug, logdir = %logdir%
   outputdebug, logpath = %logpath%
   IfNotExist, %LogDir%
   {
      FileCreateDir, %LogDir%
      outputdebug, creating %LogDir%
   }

   Loop
   {
      ifNotExist, %LogPath%
         break
      ifExist, %LogPath%
      {
         StringGetPos, dotpos, logpath, `., R
         PathLength := StrLen(logpath)
         StringTrimLeft, AfterDot, LogPath, %dotpos%
         if A_Index > 1
            dotpos := dotpos - 3
         PathLength := PathLength-dotpos
         StringTrimRight, LogPath, LogPath, %PathLength%
         LogPath = %LogPath%(%A_Index%)%AfterDot%
      }
   }
   
   outputdebug, %Logpath%

   FormatTime, ReadTime, %StopTime%, MM/dd/yyyy @ hh:mm tt

   FileAppend,
   (
~~~~~~~~~tesing beginning %A_DDDD% %A_MMMM% %A_DD%, %A_YYYY% to IP address %IpAddress%~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~Scheduled stop time is %ReadTime%~~~~~~~~~~~~~~~~~~~~~~~
%Message%
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`n
   ), %LogPath%
Menu, Tray, delete, About?
Menu, Tray, delete, Exit
Menu, Tray, Add, Show Log, ShowLog
Menu, Tray, Add, About?, AboutOpen
Menu, Tray, Add, Exit, GuiClose
}


outputdebug, %checkTime%
Gosub, PingAway
return


Gui2Clear:
Gui 2: Hide
return




PopCheckBox:
Gui 1: submit, NoHide
If Popup
{
   GuiControl, Enable, Log
   If Logstate
      GuiControl,, Log, 1
   If !Logstate
      GuiControl,, Log, 0
}
If !Popup
{
   Logstate = %Log%
   GuiControl,, Log, 1
   GuiControl, Disable, Log
}
GoSub, filebox
return

filebox:
Gui 1: submit, NoHide
if Log
{
   GuiControl, enable, FilePath
   GuiControl, enable, Browse
   GuiControl, text, FilePath, ...\Logs\%A_MM%%A_DD%%A_Hour%%A_Min%.log
}
if !Log
{
   GuiControl, disable, FilePath
   GuiControl, disable, Browse
   GuiControl, text, FilePath, Log to File?
}
return

Browse:
FileSelectFile, SelectLog, S 24, %A_WorkingDir%\logs\%A_MM%%A_DD%%A_Hour%%A_Min%.log,,*.log
GuiControl, text, FilePath, %SelectLog%
return



;___________________________end of Gui and autoexec_____________________________








PingAway:
outputdebug, %IpAddress%, %CheckTime%
breakout = 0
TOtime =       ;time that pings stopped
ReplyTime =
sCmd = ping %IpAddress% -n 1
CheckForThis = Reply from %IPAddress%

loop
{
;outputdebug, checking %CheckTime% vs %A_MM%%A_DD%%A_YYYY%%A_Hour%%A_Min%
If CheckTime < %A_MM%%A_DD%%A_YYYY%%A_Hour%%A_Min%
{
   GoSub, Wrapup
   break
}


sOutput := StdoutToVar_CreateProcess(sCmd) ; Create the console app without creating a console window


TotalTests++

Loop, parse, sOutput, `n, `r
{
   ifEqual A_Index, 4
   {
      outputdebug, checking if %CheckForThis% is in %A_LoopField%
      IfNotInString, A_LoopField, %CheckForThis%
      {
         outputdebug, %CheckForThis% is NOT in %A_LoopField%
         TotalTimeOuts++
         breakout++
         If Breakout = 1
            TOtime = %A_Hour%:%A_Min%:%A_Sec%
      }
      Else If Breakout
      {
         outputdebug, %CheckForThis% is in %A_LoopField% and breakout = 1+
         Periods++
         ReplyTime =  %A_Hour%:%A_Min%:%A_Sec%
         fileappend, %A_MM%/%A_DD%: %IPAddress% timed out from %TOtime% to %ReplyTime%`n,%LogPath%
         TOtime =
         breakout = 0
      }
   }
;outputdebug, TOtime = %TOtime%, ReplyTime = %ReplyTime%
}

sOutput := ""

if (breakout = 5) && (Popup = 1)
   {
   Gui 2: show, autosize
   }
sleep 1000
}
return


Wrapup:
If breakout
{
   fileappend, %A_MM%/%A_DD%: %IPAddress% timed out at %TOtime% and did not recover.  Test ended at %A_Hour%:%A_Min%:%A_Sec%.`n,%LogPath%
}
Received := TotalTests-TotalTimeOuts
PrecLoss := (TotalTimeOuts/TotalTests) * 100
PrecLoss := Round(PrecLoss, 2)


If Log
{
   FileAppend,
   (
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Summary report:
%IPAddress% timed out a total of %TotalTimeOuts% time(s) over %Periods% Period(s) of time.


Ping statistics for %IPAddress%:
    Packets: Sent = %TotalTests%, Received = %Received%, Lost = %TotalTimeOuts% (%PrecLoss%`% loss)
   ), %LogPath%

MsgBox, 4,,Would you like to view the log file for tests on %IPAddress%?,60
IfMsgBox, Yes
   Run, %LogPath%
}


Else If PopUp
{
   Msgbox, Ping statistics for %IPAddress%:`n  Packets: Sent = %TotalTests%, Received = %Received%, Lost = %TotalTimeOuts% (%PrecLoss%`% loss)
}
return


ShowNotes:
MsgBox,,Notes,%Message%
return


ShowLog:
Run, %LogPath%
Return

AboutOpen:
MsgBox,
(
Copyright © 2007 Jonathan Schmidt
This program is provided "as is" and there is no warranty of any kind.
For support Please email jds-ahk@bluefx.com.
Any patent on this software must be licensed for everyone's free use or not licensed at all.
)
return



GuiClose:
ExitApp
return

PreExit:
Received := TotalTests-TotalTimeOuts
PrecLoss := (TotalTimeOuts/TotalTests) * 100
PrecLoss := Round(PrecLoss, 2)
If CheckTime > %A_MM%%A_DD%%A_YYYY%%A_Hour%%A_Min%
{
FileAppend,
   (
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TEST TERMINATED PREMATURELY!!! PROGRAM WAS CLOSED BEFORE TEST ENDED!

Summary report:
%IPAddress% timed out a total of %TotalTimeOuts% time(s) over %Periods% Period(s) of time.

Ping statistics for %IPAddress%:
    Packets: Sent = %TotalTests%, Received = %Received%, Lost = %TotalTimeOuts% (%PrecLoss%`% loss)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TEST TERMINATED PREMATURELY!!! PROGRAM WAS CLOSED BEFORE TEST ENDED!
   ), %LogPath%
}
ExitApp
return
