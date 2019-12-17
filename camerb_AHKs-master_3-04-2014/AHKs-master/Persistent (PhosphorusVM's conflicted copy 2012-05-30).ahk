#Persistent
SetTimer, Persist, 500
return

Persist:
SetTitleMatchMode, 1


;{{{ temporary things (processes to kill)
;if (A_ComputerName = "PHOSPHORUS")
   ;ProcessClose("pidgin.exe")
if (A_ComputerName = "BAUSTIAN12")
   ProcessClose("CLCL.exe")
;}}}

;{{{debugging how long it takes for an iteration through the #Persistent stuff
;if NOT timer
;{
   ;AddToTrace("restarted script", A_ScriptName, "grey line")
   ;maxTotalTime := 0
   ;timer:=starttimer()
;}
;totaltime:=elapsedtime(timer)
;if (totalTime > maxTotalTime)
;{
   ;maxTotalTime := totalTime
   ;addtotrace("Max time it took for one iteration:", maxTotalTime, CurrentTime("hyphenated"), A_ComputerName)
;}
;timer:=starttimer()
;}}}

;{{{Middle of the night unit tests, backups, and reload script
if (A_Hour==3 AND A_Min==2)
{
   SpiffyMute()

   debug("reloading script")
   SleepSeconds(10)

   ;let's try for something that is a bit stiffer
   ;Run, ForceReloadAll.exe

   ;lets close all ahks as gently as possible
   CloseAllAhks()
}
if (A_Hour==3 AND A_Min==5)
{
   RunAhk("NightlyAhks.ahk")
   SleepMinutes(2)
}
;}}}

;{{{Send Jira Status Workmorrow for the Tea Meeting Minutes
;if (A_ComputerName="PHOSPHORUS")
;{
;   if A_WDay BETWEEN 2 AND 6
;   {
;      if (A_Hour=13 AND A_Min=30 AND A_Sec=0)
;      {
;         RunAhk("JiraWorkmorrow.ahk", "reminder")
;         SleepSeconds(2)
;      }
;      if (A_Hour=14 AND A_Min=0 AND A_Sec=0)
;      {
;         RunAhk("JiraWorkmorrow.ahk")
;         SleepSeconds(2)
;      }
;   }
;}
;}}}

;{{{Send Morning AHK Status Briefing
if (A_Hour=6 AND A_Min=0 AND A_Sec=0)
{
   if ( A_ComputerName == LeadComputer() )
   {
      RunAhk("MorningStatus.ahk", "SendMessage")
      SleepSeconds(2)
   }
}
;}}}

;{{{Try refreshing mint each hour on vm
if (A_Min=15 AND A_Sec=0 AND A_Hour<>3 AND A_Hour<>4)
{
   if (A_ComputerName="PHOSPHORUSVM")
   {
      RunAhkAndBabysit("MintTouch.ahk")
      SleepSeconds(2)
   }
}
;}}}

;{{{Download carset for nr2003 just before the race FIXME
;hmm, maybe I will never run a NR2003 race again. Not sure.
;if (A_WDay=5 AND A_Hour=18 AND A_Min=0 AND A_Sec=0)
;{
   ;if (A_ComputerName="baustian-09pc-OLD")
   ;{
      ;RunAhkAndBabysit("SaveNR2003cars.ahk")
      ;SleepSeconds(2)
   ;}
;}
;}}}

;{{{Routine email reminders
if (A_Hour=11 AND A_Min=05 AND A_Sec=0)
{
   if (A_ComputerName="PHOSPHORUS")
      if A_WDay BETWEEN 2 AND 6
      {
         ThreadedMsgbox("Time for lunch")
         SleepSeconds(2)
      }
}

if (A_Hour=11 AND A_Min=15 AND A_Sec=0)
{
   if (A_ComputerName="PHOSPHORUS")
      if A_WDay BETWEEN 2 AND 6
      {
         ThreadedMsgbox("Really now, it is time for lunch!")
         SleepSeconds(2)
      }
}

;if (A_Hour=08 AND A_Min=01)
;{
   ;if (A_ComputerName="PHOSPHORUS")
      ;RunAhk("EpmsTimecardReminder.ahk")
;}
;if (A_Hour=10 AND A_Min=01)
;{
   ;if (A_ComputerName="PHOSPHORUS")
      ;RunAhk("EpmsTimecardReminder.ahk")
;}

if (A_Hour=13 AND A_Min=0 AND A_Sec=0)
{
   if (A_ComputerName="PHOSPHORUS")
   {
      sendEmail("Read yer Bible", "Message sent by bot", "", "melindabaustian@gmail.com")
      SleepSeconds(2)
   }
}

if (A_Hour=15 AND A_Min=15 AND A_Sec=0)
{
   if (A_ComputerName="PHOSPHORUS")
      if A_WDay BETWEEN 2 AND 6
      {
         sendEmail("Snacktime", "Message sent by bot")
         SleepSeconds(2)
      }
}

;if (A_Hour=13 AND A_Min=30 AND A_Sec=0)
;{
;   if (A_ComputerName="PHOSPHORUS")
;      if A_WDay BETWEEN 2 AND 6
;         sendEmail("Update your jira tasks (completed and workmorrow)", "http://jira.mitsi.com`n`nMessage sent by bot")
;}

;if (A_WDay=5 AND A_Hour=10 AND A_Min=22 AND A_Sec=0)
;{
   ;if (A_ComputerName="PHOSPHORUS")
      ;sendEmail("Fantasy Nascar", "http://fantasygames.nascar.com/streak`n`nMake your fantasy picks", "", "cameronbaustian@gmail.com;melindabaustian@gmail.com")
;}

if (A_WDay=5 AND A_Hour=10 AND A_Min=0 AND A_Sec=0)
{
   if (A_ComputerName="PHOSPHORUS")
      sendEmail("Check if Melinda is coming to lunch", "Message sent by bot")
}

if (A_WDay=6 AND A_Hour=10 AND A_Min=0 AND A_Sec=0)
{
   if (A_ComputerName="PHOSPHORUS")
      sendEmail("Mitsi Donut Day", "Message sent by bot")
}

if (A_DD=17 A_Hour=7 AND A_Min=59 AND A_Sec=0)
{
   if (A_ComputerName="PHOSPHORUS")
   {
      sendEmail("Bill reminder", "Cameron Mastercard`n`nMessage sent by bot")
      SleepSeconds(2)
   }
}
if (A_DD=07 A_Hour=7 AND A_Min=59 AND A_Sec=0)
{
   if (A_ComputerName="PHOSPHORUS")
   {
      sendEmail("Bill reminder", "Melinda Mastercard`n`nMessage sent by bot")
      SleepSeconds(2)
   }
}
if (A_DD=08 A_Hour=7 AND A_Min=59 AND A_Sec=0)
{
   if (A_ComputerName="PHOSPHORUS")
   {
      sendEmail("Bill reminder", "Time Warner Cable`n`nMessage sent by bot")
      SleepSeconds(2)
   }
}
if (A_DD=11 A_Hour=7 AND A_Min=59 AND A_Sec=0)
{
   if (A_ComputerName="PHOSPHORUS")
   {
      sendEmail("Bill reminder", "City of Garland Electric`n`nMessage sent by bot")
      SleepSeconds(2)
   }
}
if (A_DD=25 A_Hour=7 AND A_Min=59 AND A_Sec=0)
{
   if (A_ComputerName="PHOSPHORUS")
   {
      sendEmail("Bill reminder", "Chase Freedom Credit (Routine Bills Card)`n`nMessage sent by bot")
      SleepSeconds(2)
   }
}
;}}}

;{{{Check weather and put it on the remote widget
if (Mod(A_Min, 15)==0 && A_Sec==0)
{
   if (A_ComputerName="PHOSPHORUS")
   {
      Run, UpdateRemoteWidget.ahk
      sleepseconds(2)
   }
}
;}}}

;{{{Monitor FF4 RAM usage
;if (Mod(A_Min, 15)==0 && A_Sec==35)
;{
   ;if (A_ComputerName="PHOSPHORUS")
   ;{
      ;time:=currenttime("hyphenated")
      ;pid:=getpid("firefox.exe")
      ;ram:=GetRamUsage(pid)
      ;cpu:=GetCpuUsage(pid)
      ;csvLine := ConcatWithSep(",", time, pid, ram, cpu)
      ;FileAppendLine(csvLine, "gitExempt/phosFFstats.csv")
      ;sleepseconds(2)
   ;}
;}
;}}}

;{{{Reload AHK site using anonymouse for work compy (No longer in use)
;SetTitleMatchMode, Slow
;WinGetText, winText, A
;WinGetActiveTitle, winTitle

;IfWinActive, ahk_class Chrome_WidgetWin_0
;{
   ;;if RegExMatch(winText, "(autohotkey.com|autohotkey.net/~crazyfirex/all.html)")
   ;if RegExMatch(winText, "autohotkey\.com")
   ;{
      ;if NOT InStr(winText, "anonymouse.org")
      ;{
         ;RegExMatch(winText, "www.autohotkey.*", url)
         ;newurl=anonymouse.org/cgi-bin/anon-www.cgi/http://%url%
         ;Send, !d
         ;Send, !a
         ;SendViaClipboard(newurl)
         ;Send, {enter}
         ;Sleep, 10000
      ;}
   ;}
;}

;SetTitleMatchMode, Fast
;}}}

;{{{Check to see if we scheduled an ahk from the cloud
if (Mod(A_Sec, 5)==0)
{
   if (A_ComputerName="baustian-09pc-OLD")
   {
      ghetto:=SexPanther()
      BotGmailUrl=https://cameronbaustianbot:%ghetto%@gmail.google.com/gmail/feed/atom

      gmailPage:=urldownloadtovar(BotGmailUrl)
      RegExMatch(gmailPage, "<fullcount>(\d+)</fullcount>", gmailPage)
      RegExMatch(gmailPage, "\d+", number)

      if (number == 0 || number == "")
         number:=""

      if (number)
      {
         RunAhkAndBabysit("ProcessBotEmails.ahk")
         SleepSeconds(20)
         ;maybe we should sleep more like 60 secs
      }
   }
}
;}}}

;{{{Run scheduled AHKs
if (Mod(A_Sec, 2)==0)
{
   asapAhk=%A_WorkingDir%\scheduled\%A_ComputerName%\asap.ahk
   asapTxt=%A_WorkingDir%\scheduled\%A_ComputerName%\asap.txt
   lock=%A_WorkingDir%\scheduled\%A_ComputerName%\InProgress.lock
   deleteLock=%A_WorkingDir%\scheduled\%A_ComputerName%\DeleteLock.now

   bothAsaps=%asapAhk%,%asapTxt%
   Loop, parse, bothAsaps, CSV
   {
      if FileExist(A_LoopField)
      {
         time:=CurrentTime("hyphenated")
         newFileName=%A_WorkingDir%\scheduled\%A_ComputerName%\%time%.ahk
         FileMove(A_LoopField, newFileName)
      }
   }


   if FileExist(deletelock)
   {
      FileDelete(lock)
      FileDelete(deletelock)
   }

   if NOT FileExist(lock)
   {
      ;check if time to run an ahk
      asapAhk=%A_WorkingDir%\scheduled\%A_ComputerName%\asap.ahk
      asapTxt=%A_WorkingDir%\scheduled\%A_ComputerName%\asap.txt
      if FileExist(asapTxt)
         FileMove(asapTxt, asapAhk, "overwrite")

      ;TODO put all this crap into another ahk, so that persistent doesn't halt while we're babysitting other ahks
      Loop, %A_WorkingDir%\scheduled\%A_ComputerName%\*.ahk
      {
         filedate := A_LoopFileName
         filedate := RegExReplace(filedate, "\.ahk$")
         filedate := DeformatTime(filedate)

         ;check to make sure filedate is a number and is 14 long
         if ( strlen(filedate) != 14 )
            continue
         if NOT filedate is integer
            continue
         if NOT CurrentlyAfter(filedate)
            continue

         ;debug(filedate)

         compilingPath=%A_WorkingDir%\scheduled\%A_ComputerName%\Compiling\%A_LoopFileName%
         errorsPath   =%A_WorkingDir%\scheduled\%A_ComputerName%\Errors\%A_LoopFileName%
         runningPath  =%A_WorkingDir%\scheduled\%A_ComputerName%\Running\%A_LoopFileName%
         finishedPath =%A_WorkingDir%\scheduled\%A_ComputerName%\Finished\%A_LoopFileName%

         ;debug(compilingPath)
         FileMove(A_LoopFileFullPath, compilingPath)
         FileAppend("`n#include FcnLib.ahk", compilingPath)

         ;TODO write a testCompile function
         ;if errorsCompiling
         ;{
            ;FileMove(A_LoopFileFullPath, errorsPath)
            ;continue
         ;}

         ;Prep for run (tell him that after he's done running, he's got to move himself to the finished folder)
         FileMove(compilingPath, runningPath)
         lastLine=`nFileMove("%runningPath%", "%finishedPath%")
         FileAppend(lastLine, runningPath)

         ;Run that sucka!
         RunAhk(runningPath)
      }
   }
}
;}}}

;{{{ Run Queued Functions (queued in a variable)
;run every time through the loop (500 ms), or maybe we should wait longer, like 5 seconds
;if queue is empty, length 0, do nothing
;Run the next item in the queue, then bail out
    ; (we need to keep going so that we can monitor things like windows that pop up
;Maybe I should put the AHKs into an ini variable, put a tick count on them, and then
if ( Mod(A_Sec, 2) == 0 )
{
   ;TODO if this has already run this second, then bail

   ;TODO move this to an AssignGlobals() func
   G_null := "ZZZ-NULL-ZZZ"

   if G_VariableQueuedFunctions
   {
      Loop, parse, G_VariableQueuedFunctions, `n
      {
         LineToRun := A_LoopField

         needle=^(%LineToRun%)(`n)?
         G_VariableQueuedFunctions := RegExReplace(G_VariableQueuedFunctions, needle)

         ;parse the sucker
         Loop, parse, LineToRun, CSV
         {
            i := A_Index - 1
            Param%i% := A_LoopField
            numberOfParams := i
         }
         FuncToRun := Param0

         ;FIXME
         ;FuncToRun := LineToRun

         ;run the sucker, with the correct number of params
         if (numberOfParams == 0)
            %FuncToRun%()
         else if (numberOfParams == 1)
            %FuncToRun%(param1)
         else if (numberOfParams == 2)
            %FuncToRun%(param1, param2)
         else if (numberOfParams == 3)
            %FuncToRun%(param1, param2, param3)
         else if (numberOfParams == 4)
            %FuncToRun%(param1, param2, param3, param4)
         else if (numberOfParams == 5)
            %FuncToRun%(param1, param2, param3, param4, param5)
         else if (numberOfParams == 6)
            %FuncToRun%(param1, param2, param3, param4, param5, param6)
         else if (numberOfParams == 7)
            %FuncToRun%(param1, param2, param3, param4, param5, param6, param7)
         else if (numberOfParams == 8)
            %FuncToRun%(param1, param2, param3, param4, param5, param6, param7, param8)
         else if (numberOfParams == 9)
            %FuncToRun%(param1, param2, param3, param4, param5, param6, param7, param8, param9)
         else if (numberOfParams == 10)
            %FuncToRun%(param1, param2, param3, param4, param5, param6, param7, param8, param9, param10)
         else if (numberOfParams == 11)
            %FuncToRun%(param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11)
         else if (numberOfParams == 12)
            %FuncToRun%(param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12)
         else if (numberOfParams == 13)
            %FuncToRun%(param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12, param13)
         else if (numberOfParams == 14)
            %FuncToRun%(param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12, param13, param14)
         else if (numberOfParams == 15)
            %FuncToRun%(param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12, param13, param14, param15)

         ;bail out and do other things, Variable Queued Functions are not a priority
         break
      }
   }
}

;Schedule something for testing
if NEVER
if (A_ComputerName = "PHOSPHORUS" and A_Sec=54)
{
   ScheduleVariableQueuedFunction("debug")
   ScheduleVariableQueuedFunction("debug", "hi mom")
   ScheduleVariableQueuedFunction("debug", "hi mom", 1, 2, 3)
   ScheduleVariableQueuedFunction("addtotrace", "hi")
   ScheduleVariableQueuedFunction("debug", "hi mom", 1, 2, 3, 4, 5)
}

;show scheduled ahks for debugging
;if (A_ComputerName = "PHOSPHORUS" and A_Sec=54)
;{
   ;AddToTrace(G_VariableQueuedFunctions)
   ;SleepSeconds(1.1)
;}
;}}}

;{{{ Close unwanted windows, new ways, but not one-liners
if ForceWinFocusIfExist("Microsoft Windows")
{
   if SimpleImageSearch("images/win7/doYouWantToScanAndFixFlashDrive.bmp")
      ClickIfImageSearch("images/win7/continueWithoutScanning.bmp", "control")
}
;}}}

;{{{ new ways to close unwanted windows

;note that this is the body of the traytip, not the title
CloseTrayTip("Automatic Updates is turned off")
CloseTrayTip("A new version of Java is ready to be installed.")
CloseTrayTip("There are unused icons on your desktop")
CloseTrayTip("Click here to have Windows automatically keep your computer")

if ForceWinFocusIfExist("Microsoft SQL Server Management Studio Recovered Files")
   ClickButton("&Do Not Recover")
;}}}

;{{{ Miscellaneous stuff, done the new way
if (Mod(A_Sec, 5)==0)
{
   CustomTitleMatchMode("Contains")
   IfWinActive, Gmail
   {
      ClickIfImageSearch("images\gmail\ReconnectWidget7.bmp",  "Control")
      ClickIfImageSearch("images\gmail\ReconnectWidgetXP.bmp", "Control")
      ;ClickIfImageSearch("images\gmail\ReconnectWidgetXP2.bmp", "Control")
   }
   CustomTitleMatchMode("Default")
}
;}}}

;{{{ move network usage notification to a less annoying spot
thewintitle=NetWorx Notification ahk_class TTimedMessageForm
IfWinExist, %thewintitle%
{
   WinMove, 3564, 0
}
thewintitle=NetWorx (All Connections) ahk_class TGraphForm
IfWinExist, %thewintitle%
{
   WinMove, 3689, 960
}
;}}}

;{{{ kill processes that are of the devil
Process, Close, newreleaseversion70700.exe
Process, Close, DivXUpdate.exe
;}}}

;{{{ Old legacy stuff for closing unwanted windows
;N64 emulator error
WinClose, Access Violation, While processing graphics data an exception occurred

SetTitleMatchMode 2

;Descriptive messages (most of these are error messages)
WinClose, Error, An instance of Pidgin is already running
WinClose, WinSplit message, Impossible to install hooks
WinClose, VMware Player, The virtual machine is busy
WinClose, VMware Player, internal error
WinClose, Google Chrome, The program can't start because nspr4.dll is missing from your computer
WinClose, Search and Replace, Error opening

IfWinExist, TGitCache, error
   if ForceWinFocusIfExist("TGitCache")
      Send, !x

;tortoisegit crashed
IfWinExist, TortoiseGit status cache
{
   WinActivate
   Sleep, 10
   Send, {ENTER}
   Sleep, 500
}

IfWinExist, Find and Run Robot ahk_class TMessageForm, OK
{
   WinActivate
   SaveScreenshot("FARR-MessageThatWeClosed")
   Sleep, 10
   Send, {ENTER}
   Sleep, 500
}

;This is for foobar at work
;IfWinExist, Playback error
   ;WinClose

IfWinActive, Disconnect Terminal Services Session ahk_class #32770
{
   ;Disconnect RDP automatically
   Send, {ENTER}

   ;Kill Astaro if we just disconnected from RDP on the VPN
   Process, Close, openvpn-gui.exe
}

IfWinActive, , This will disconnect your Remote Desktop Services session
   Send, {ENTER}

;IfWinActive, Remote Desktop Connection, Do you want to connect despite these certificate errors?
   ;Send, !y
IfWinExist, Remote Desktop Connection, Do you want to connect despite these certificate errors?
{
   WinActivate
   Sleep, 100
   Send, !y
}

;FF4 has fewer prompts now
;IfWinExist, Firefox Add-on Updates ahk_class MozillaDialogClass
;{
   ;;ForceWinFocus("Firefox Add-on Updates ahk_class MozillaDialogClass")
   ;;Sleep, 10
   ;;SendInput, !i

   ;;FIXME this should work!!!
   ;ControlSend, MozillaWindowClass1, !i, Firefox Add-on Updates ahk_class MozillaDialogClass
   ;Sleep, 100
   ;errord("nolog", "just attempted to prod along firefox update window: did it work?", A_LineNumber, A_ScriptName)
   ;SleepSeconds(60)
;}

IfWinExist, Connection to server argon.lan.mitsi.com lost. ahk_class #32770, Close server browser? If you abort, the object browser will not show accurate data.
   ControlClick, &Yes

IfWinExist, Security Warning ahk_class #32770, Do you want to view only the webpage content that was delivered securely?
   ControlClick, &No

IfWinExist, EF Commander Free, Do you want to quit the Commander
   ControlClick, &Yes

CustomTitleMatchMode("Contains")
WinClose, pgAdmin III ahk_class #32770, server closed the connection unexpectedly
CustomTitleMatchMode("Default")
   ;ControlClick, OK

;This is for accidentally opened .js files
WinClose, Windows Script Host, 'Ext' is undefined

;Come on, i already know my Win XP isn't pirated
WinClose, Windows Genuine Advantage Notifications - Installation Wizard

;Close error that sometimes comes up from Adobe Acrobat
WinClose, Fatal Error, Acrobat failed to connect to a DDE server.

;Temporary solution, close the pestering dialog since i'm using the trial
IfWinActive, Balsamiq Mockups For Desktop - * New Mockup ahk_class ApolloRuntimeContentWindow
   ClickIfImageSearch("images\balsamiq\TrialDialog.bmp")

;Annoying Popups
titleofwin = Popular ScreenSavers!!
SetTitleMatchMode 2
IfWinExist, %titleofwin%
   WinClose

;Pesky pop up for netflix... but don't close the main site!
;WinClose, Netflix - Google Chrome
;check window dimensions
;>>>>>>>>>>( Window Title & Class )<<<<<<<<<<<
;Netflix - Google Chrome
;ahk_class Chrome_WidgetWin_0

;>>>>>>>>>>>>( Mouse Position )<<<<<<<<<<<<<
;On Screen:	641, 429  (less often used)
;In Active Window:	161, 54

;>>>>>>>>>( Now Under Mouse Cursor )<<<<<<<<
;ClassNN:	Chrome_RenderWidgetHostHWND1
;Text:	Netflix
;Color:	0xE7DFE7  (Blue=E7 Green=DF Red=E7)

;>>>>>>>>>>( Active Window Position )<<<<<<<<<<
;left: 480     top: 375     width: 730     height: 355

;>>>>>>>>>>>( Status Bar Text )<<<<<<<<<<

;>>>>>>>>>>>( Visible Window Text )<<<<<<<<<<<
;Netflix
;Netflix

;>>>>>>>>>>>( Hidden Window Text )<<<<<<<<<<<

;>>>>( TitleMatchMode=slow Visible Text )<<<<
;http://cdn.optmd.com/V2/62428/196130/index.html?g=Af////8=&r=www.foodnetwork.com/recipes/rachael-ray/halibut-fish-tacos-with-guacamole-sauce-recipe/index.html

;>>>>( TitleMatchMode=slow Hidden Text )<<<<

;}}}

;{{{ Close windows that have been open for a while (they are "abandoned")
;dangit... this isn't used anymore since we switched to Git
;TODO perhaps this approach can be used for telling last.fm to resume listening
SetTitleMatchMode, RegEx
IfWinExist .* - (Update|Commit) - TortoiseSVN Finished! ahk_class #32770
{
   if (TimeToExitWindow=="")
   {
      ;the window just showed up
      WinGet, windowHwndId, ID
      TimeToExitWindow:=CurrentTimePlus(60)
   }
   else if (CurrentlyAfter(TimeToExitWindow))
   {
      ;we are now going to close the window and reset vars
      WinClose, ahk_id %windowHwndId%
      TimeToExitWindow:=""
   }
}
;}}}

;{{{ Watch for error messages from AHKs with syntax errors (and log them)
IfWinExist, %filename%, (The program will exit|The previous version will remain in effect)
{
   textFromTheWindow := WinGetText()
   ControlClick, OK, %filename%
   errord("silent yellow line", A_ThisFunc, filename, "AHK file had an error...", textFromTheWindow, "... end of error msg")
   ;return "error"
}
;}}}

;{{{ Keep Last.fm music running
if (Mod(A_Sec, 30)==0)
{
   lastFmWindow=Last.fm - Opera ahk_class OperaWindowClass

   CustomTitleMatchMode("RegEx")
   DetectHiddenWindows, On

   IfWinExist, %lastFmWindow%
   {
      ;now := CurrentTime()
      ;futureTimeCheckLastFmWindow := AddDatetime(now, 1, "minutes")
      titletext := WinGetTitle(lastFmWindow)

      if (OldTitleTextFromLastFmWindow == titleText)
      {
         if CurrentlyAfter(futureTimeCheckLastFmWindow)
         {
            ;refresh lastfm window
            ;WinShow, %lastFmWindow%
            RunAhk("PlayPauseMusic.ahk", "resumeLastFm")
            now := CurrentTime()
            futureTimeCheckLastFmWindow := AddDatetime(now, 8, "minutes")
            ;WinHide, %lastFmWindow%
         }
      }
      else
      {
         ;debug("new track")
         OldTitleTextFromLastFmWindow:=titleText
         now := CurrentTime()
         futureTimeCheckLastFmWindow := AddDatetime(now, 8, "minutes")
      }
   }
   else
   {
      OldTitleTextFromLastFmWindow:=""
      futureTimeCheckLastFmWindow:=""
   }
}

DetectHiddenWindows, Off
CustomTitleMatchMode("Default")
;}}}

;{{{ TransferTo - Check to see if there are files that need to be moved out of the dropbox
;TODO put all this crap into another ahk, so that persistent doesn't halt while we're babysitting other ahks
Loop, C:\My Dropbox\AHKs\gitExempt\transferTo\%A_ComputerName%\*.*, 2, 0
{
   localPath=C:\DataExchange\ReceivedFrom
   Sleep, 100
   iniFile = %A_LoopFileFullPath%.ini
   IniRead, DirSize, %iniFile%, TransferTo-Info, DirSize
   IniRead, DirName, %iniFile%, TransferTo-Info, DirName
   IniRead, FromComputer, %iniFile%, TransferTo-Info, FromComputer
   IniRead, DateStamp, %iniFile%, TransferTo-Info, DateStamp
   ;debug("hi dirsize", dirsize)
   if (DirSize == "ERROR")
   {
      ;errord("The INI did not contain the required values")
      ;ExitApp
      continue
   }

   if ( DirSize <> DirGetSize(A_LoopFileFullPath) )
   {
      ;errord("The folder was not the same size as specified in the ini")
      ;ExitApp
      continue
   }
   DestinationFolder = %LocalPath%\%FromComputer%\%DateStamp%\
   DestinationFolder .= GetFolderName(DirName)
   FileCreateDir, %DestinationFolder%
   FileCopyDir, %A_LoopFileFullPath%, %DestinationFolder%, 1
   ;debug(A_LoopFileFullPath, DestinationFolder)
   if ( DirSize <> DirGetSize(DestinationFolder) )
   {
      errord("there must have been an error during the copy, dir size is incorrect")
      ExitApp
   }
   FileRemoveDir, %A_LoopFileFullPath%, 1
   FileDelete, %iniFile%
   Sleep, 5000
}
;}}}

;{{{ Ensure VM firefly bot is running, and not crashed
if (A_ComputerName = "BAUSTIANVM" and Mod(A_Sec, 5)==0)
{
   if NOT ProcessExist("Baretail.exe")
   {
      RunProgram("C:\Dropbox\Programs\Baretail\Baretail.exe")
      SleepSeconds(5)
   }

   ;checkin
   FireflyCheckin("Babysitter", "Watching")

   if NOT IsAhkCurrentlyRunning("FireflyFeesBot")
   {
      RunAhk("C:\Dropbox\AHKs\FireflyFeesBot.ahk")
      SleepSeconds(5)
   }
   if NOT IsAhkCurrentlyRunning("FireflyBotHelper")
   {
      RunAhk("C:\Dropbox\AHKs\FireflyBotHelper.ahk")
      SleepSeconds(5)
   }

   ;if bot or helper haven't said hi within a certain period of time, kill them and restart them
   VerifyFireflyCheckin("Bot")
   VerifyFireflyCheckin("Helper")
   Sleep, 1200
}

;getting some info about the AHK processes that are running currently
;if (A_ComputerName = "BAUSTIANVM" and A_Sec=42)
;{
   ;addToTrace("time marker (tick tock) grey line")
   ;;HowManyAhksAreRunning()
   ;;HowManyAhksAreRunning(A_ScriptName)
   ;SleepSeconds(1)
;}

;delete dropbox cruft on VM
;TODO move this to the variable queued AHKs
if (A_ComputerName = "BAUSTIANVM" and A_Min=0 and A_Sec=42)
{
   RunAhk("DeleteDropboxCruft.ahk")
}

;TODO move this to the variable queued AHKs
if (A_ComputerName = "PHOSPHORUS" and A_Sec=32)
{
   Run, fireflyCreateViewableInis.ahk
   SleepSeconds(1.1)
}
;}}}

;{{{ Count the number of fees that need to be added by the firefly bot
if (A_ComputerName = "BAUSTIAN12" and A_Sec == 48)
{
   if IsVmRunning()
      Run, fireflyCountFeesNotYetAdded.ahk
   else
      FileCreate("VM is not running", "C:\Dropbox\Public\fireflyFees.txt")
   Sleep, 1000
}
;}}}

;{{{ Continual backups

;Set all the variables for backing up FireflyScorecards
myConfig := GetPath("MyConfig.ini")
if (A_ComputerName = "BAUSTIAN12" and Mod(A_Min, 5)==0)
   G_FireflyScorecardXLS := IniRead(myConfig, "FireflyScorecard", "WorkingExcelFile")

;archive firefly scorecard for Mel
datestamp := CurrentTime("hyphendate")
ArchivePath=C:\Dropbox\Melinda\Firefly\archive-scorecards\%datestamp%
if (A_ComputerName = "BAUSTIAN12" and Mod(A_Sec, 5)==0)
   BackupFile(G_FireflyScorecardXLS, ArchivePath)

;archive import reports for EPMS
if (A_ComputerName = "PHOSPHORUS" and Mod(A_Sec, 5)==0)
{
   BackupFile("C:\code\report.txt",                    "C:\import_files\archive\importReports\")  ;importer reports
   BackupFile("C:\code\epms\script\epms_workbench.pl", "C:\import_files\archive\epms_workbench\") ;workbench
}
;}}}

;{{{ Heck yeah, race reminders
url := GetUrlBar("firefox")
if ( ProcessExist("iRacingSim.exe") OR InStr(url, "iracing.com") )
{
   DingIfScheduled(0, 59)
   DingIfScheduled(1, 59)
   DingIfScheduled(2, 59)
   DingIfScheduled(3, 59)
   DingIfScheduled(4, 59)
   DingIfScheduled(5, 59)
   DingIfScheduled(6, 59)
   DingIfScheduled(7, 59)
   DingIfScheduled(8, 59)
   DingIfScheduled(9, 59)
   DingIfScheduled(10, 59)
   DingIfScheduled(11, 59)
   DingIfScheduled(12, 59)
   DingIfScheduled(13, 59)
   DingIfScheduled(14, 59)
   DingIfScheduled(15, 59)
   DingIfScheduled(16, 59)
   DingIfScheduled(17, 59)
   DingIfScheduled(18, 59)
   DingIfScheduled(19, 59)
   DingIfScheduled(20, 59)
   DingIfScheduled(21, 59)
   DingIfScheduled(22, 59)
   DingIfScheduled(23, 59)

   DingIfScheduled(0, 29)
   DingIfScheduled(2, 29)
   DingIfScheduled(4, 29)
   DingIfScheduled(6, 29)
   DingIfScheduled(8, 29)
   DingIfScheduled(10, 29)
   DingIfScheduled(12, 29)
   DingIfScheduled(14, 29)
   DingIfScheduled(16, 29)
   DingIfScheduled(18, 29)
   DingIfScheduled(20, 29)
   DingIfScheduled(22, 29)
}
;}}}


;end of Persist subroutine
return

;{{{ functions of things that should only be used here in the Persistent file

;DOES NOT SUPPORT LINE BREAKS
ScheduleVariableQueuedFunction(functionName, param1="ZZZ-NULL-ZZZ", param2="ZZZ-NULL-ZZZ", param3="ZZZ-NULL-ZZZ", param4="ZZZ-NULL-ZZZ", param5="ZZZ-NULL-ZZZ", param6="ZZZ-NULL-ZZZ", param7="ZZZ-NULL-ZZZ", param8="ZZZ-NULL-ZZZ", param9="ZZZ-NULL-ZZZ", param10="ZZZ-NULL-ZZZ", param11="ZZZ-NULL-ZZZ", param12="ZZZ-NULL-ZZZ", param13="ZZZ-NULL-ZZZ", param14="ZZZ-NULL-ZZZ", param15="ZZZ-NULL-ZZZ")
{
   global G_VariableQueuedFunctions
   global G_null

   if NOT functionName
      errord("tried to schedule a blank function name")

   ;figure out what the scheduled item will look like
   ;ODO  csv-style!
   ;ODO multi-param!
   ItemToSchedule := functionName
   Loop, 15
   {
      thisParam := param%A_Index%
      if ( thisParam == G_null )
         break

      ItemToSchedule .= ","
      ItemToSchedule .= Format4Csv(thisParam)
   }

   ;already scheduled
   if InStr(G_VariableQueuedFunctions, ItemToSchedule)
      return

   ;go ahead and schedule the sucker!
   if G_VariableQueuedFunctions
      G_VariableQueuedFunctions .= "`n"
   G_VariableQueuedFunctions .= ItemToSchedule
}

;is there a better name for this function?
;BackupFileImmediatelyOnChange() ????
BackupFile(fileToBackup, archiveDir)
{
   archiveDir := EnsureEndsWith(archiveDir, "\")
   if NOT FileExist(fileToBackup) ;die with silent error, maybe?
      return
   EnsureDirExists(archiveDir)
   if NOT FileDirExist(archiveDir)
      return

   if FileGetSize(fileToBackup)
   {
      FileGetTime, timestamp, %fileToBackup%
      timestamp := FormatTime(timestamp, "yyyy-MM-dd_HH-mm-ss")

      archiveFile=%archiveDir%%timestamp%.txt
      if NOT FileExist(archiveFile)
         FileCopy(fileToBackup, archiveFile)
   }
}

;WRITEME
BackupFolder(folderToBackup, archiveDir)
{
}

;if bot or helper haven't said hi within a certain period of time, kill them and restart them
VerifyFireflyCheckin(whoIsCheckingIn)
{
   CheckinInterval := 2*60*1000
   FailedCheckinTime := CurrentTime() - 600
   CurrentTick := A_TickCount
   FailedTickCheckinTime := CurrentTick - CheckinInterval
   FailedCheckinLower := CurrentTick - CheckinInterval
   FailedCheckinUpper := CurrentTick + CheckinInterval

   iniFolder:=GetPath("FireflyCheckinIniFolder")

   ;(changed on 2012-05-10) REMOVEMESOON
   ;lastCheckin:=IniFolderRead(iniFolder, "Check-In", whoIsCheckingIn)

   lastTickCheckin := iniFolderRead(iniFolder, "TickCheckin", whoIsCheckingIn)

   if (lastTickCheckin < FailedTickCheckinTime)
   {
      ;(this may not be able to save on the vm)
      ;SaveScreenshot("killing-firefly-vm-bot")
      SaveScreenshot2()
      debugmsg:="killing unresponsive vm-ahk (faint orange line) "
      debugmsg .= whoIsCheckingIn
      iniPP(debugmsg)
      addtotrace(debugmsg)
      HowManyAhksAreRunning()

      WinActivate, Program Manager
      MouseMove, 720, 944, 20
      MouseMove, 1080, 944, 80
      MouseMove, 1280, 944, 80

      Run, ForceReloadAll.exe  ;just gives a lot of dead tray icons

      ;Reload
      ;Sleep, 5000
      ;(changed on 2012-05-01)
      Reload()

      ExitApp
   }
}

Ding(times=1)
{
   SoundPlay, %A_WinDir%\Media\ding.wav
   Sleep, 100
   if (times == 2)
      SoundPlay, %A_WinDir%\Media\ding.wav
   Sleep, 5000
}

DingIfScheduled(hour2, min2)
{
   hour1 := hour2
   min1 := min2 - 4

   ;check time
   ;play sound
   if (A_Hour=hour1 AND A_Min=min1)
   {
      Ding()
      SleepMinutes(1)
   }
   if (A_Hour=hour2 AND A_Min=min2)
   {
      Ding(2)
      SleepMinutes(1)
   }
}

;all I needed was the iniFolder lib
;and the ghetto methods of debugging how many ahks were running
;also needed the number
#include Firefly-FcnLib.ahk
;}}}
