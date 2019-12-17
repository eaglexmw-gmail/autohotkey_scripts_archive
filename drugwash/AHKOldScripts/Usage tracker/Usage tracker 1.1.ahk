; http://www.autohotkey.com/forum/viewtopic.php?t=41379

A_SysDir := (A_OSType = "WIN32_NT") ? "32":""
A_SysDir := A_WinDir . "\System" . A_SysDir
Menu, Tray, Icon, %A_SysDir%\shell32.dll, 25	; used to be 44
Menu, Tray, NoStandard
Menu, Tray, Add, Exit, closeall

SetTimer, CheckTime, 60000 ; updates every 1 minute

CheckTime:
   FormatTime, thedate,,dd-MM-yyyy
   IniRead, ActiveTime, track.txt, %thedate%, active, 0
   IniRead, IdleTime, track.txt, %thedate%, idle, 0

;   If (A_TimeIdle<180000)
   If (A_TimeIdlePhysical<60000)
      ActiveTime++
   Else
      IdleTime++
   
   TotalTime := IdleTime + ActiveTime

   IniWrite, %ActiveTime%, track.txt, %thedate%, active
   IniWrite, %IdleTime%, track.txt, %thedate%, idle
   IniWrite, %TotalTime% , track.txt, %thedate%, total

Return

FormatMinutes(NumberOfMinutes)  ; Convert mins to hh:mm
{
   Time := 19990101 ; *Midnight* of an arbitrary date
   Time += %NumberOfMinutes%,minutes
   FormatTime, mmss, %time%, H 'h' mm 'min'
   Return mmss
}

F6::
   Gui, Add, Text, w150 Center, % "Active Time: " FormatMinutes(ActiveTime) "`nIdle Time: " FormatMinutes(IdleTime) "`nTotal: " FormatMinutes(TotalTime)
   Gui, -SysMenu
   
   Gui, Show
   Keywait,F6, D
   Keywait,F6
   Gui, Destroy
Return

closeall:
   ExitApp
