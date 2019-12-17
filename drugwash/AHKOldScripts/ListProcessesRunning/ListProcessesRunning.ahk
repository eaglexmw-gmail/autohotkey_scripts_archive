
; ListAllProcesses 1.1
; by Decarlo

^#!p::
^!p::

SetBatchLines -1
Process, Priority,, H   ; High
DetectHiddenWindows, on
SetFormat, Float, 0.3

ExeWin=
ExeSrv=
processList=
winList=

startListProc=%A_TickCount%
Process, exist, system
processList=%processList%%ErrorLevel%`tSystem`r`n`r`n
Process, Exist,      ; needs Ahk 1.0.36+
processList=%processList%%ErrorLevel%`tAutoHotkey.exe`r`n
WinGet, Win#, List
Loop %Win#%
{
   winListItem := win#%A_Index%
   winList = %winList%%winListItem%`r`n   ; get id's of windows
}
Sort, winList, U
Loop, parse, WinList, `n, `r         ; get pid's matching windows
{
   WinGet, PID, PID, ahk_id %A_LoopField%
   PIDList = %PIDList%%PID%`r`n
}
Sort, PIDList, NU
Loop, parse, PIDList, `n, `r
{
   if A_LoopField =
      CONTINUE
   WinGet, processName, ProcessName, ahk_pid %A_LoopField%
   processList=%processList%%A_LoopField%`t%processName%`r`n
}
StringReplace, processList, processList, `r`n      ; delete blank lines
Sort, processList, N
Loop, %windir%\system32\*.exe         ; find system32 folder executables
   ExeWin=%ExeWin%%A_LoopFileName%`r`n
Loop, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Services, 1, 1   ; find system services
{
   if A_LoopRegName=ImagePath
   {
      RegRead, itemExe ;, HKEY_LOCAL_MACHINE, %A_LoopRegSubKey%, ImagePath
      ifInString, itemExe, .exe
      {
         StringGetPos, posImage, itemExe, .exe
         StringLen, itemExeLength, itemExe
         offsetExe:=itemExeLength-posImage
         StringGetPos, posSlash, itemExe, \, R, offsetExe
         StringMid, imageExe, itemExe, % posSlash+2, % posImage-posSlash+3
         ExeSrv=%ExeSrv%%imageExe%`r`n
      }
   }
}
Sort, ExeWin, U
Sort, ExeSrv, U
Exe=%ExeWin%%ExeSrv%
Sort, Exe, U
Loop, Parse, Exe, `n, `r      ; check active Prog, sys folder executables
{
   Process, exist, %A_LoopField%
   If ErrorLevel <> 0
      processList=%processList%%ErrorLevel%`t%A_LoopField%`r`n
}
Sort, processList, N
Loop, Parse, processList, %A_Tab%`n, `r      ; remove semi-duplicates (blank name field)
{
   ;msgbox %A_LoopField%
   if A_LoopField is not integer
      Continue
   if A_LoopField <> %A_LoopFieldPrev%
   {
      A_LoopFieldPrev = %A_LoopField%
      Continue
   }
   StringReplace, processList, processList, %A_LoopField%`r`n ;, ReplaceText
   A_LoopFieldPrev = %A_LoopField%
}
timeListProc:=(A_TickCount-startListProc)/1000
Sort, processList, NU
; alternatively, use: ifInString, processList, <processToCheck> , for further operations
Run, Notepad,,, NPid
WinWait, ahk_pid %Npid%
WinSetTitle, ahk_pid %Npid%,, Process List
WinActivate
WinWaitActive,,, 5
if ErrorLevel=1
   Msgbox, The target Notepad window did not respond.
ControlSetText, Edit1, Process Checker: running processes`r`n`r`n0`tSystem Idle Process`r`n%processList%----------`r`n`r`nThe following executables which might not have associated windows`, were checked.`r`nThis program does not detect any other non-window processes.`r`nThis program does not detect additional PID's which share identical process names.`r`n`r`nSystem services:`r`n`r`n%ExeSrv%`r`nSystem32 folder processes:`r`n`r`n%ExeWin%`r`n, ahk_pid %NPid%
Process, Priority,, N      ; Normal
msgbox, 4096, note, Done`n`n%timeListProc% sec, 1.2

return
