; http://www.autohotkey.com/forum/viewtopic.php?t=27780&postdays=0&postorder=asc&start=30

#singleinstance force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
;SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
settitlematchmode 2
SetKeyDelay, 10
;Menu, TRAY, Icon, AHKFileControl.ico

 CtrlDown := GetKeyState("Ctrl", "P")
 CapsDown := GetKeyState("CapsLock", "P")
 ;msgbox, Ctrl key state: %CtrlDown%`nCaps key state: %CapsDown%.

 if (CtrlDown = 0 AND CapsDown = 0)
   runPortable("AutoHotkey\AutoHotkey.exe")
 else if (CtrlDown = 1 AND CapsDown = 0)
  runPortable("Notepad+\notepad++.exe")
  else if (CtrlDown = 0 AND CapsDown = 1)
 {
  gosub, CompileAHK
 }
 exitapp
return


CompileAHK:
SplitPath, 1, , sourceDir, , sourceNameNoExt
 
  IfExist, %sourceNameNoExt%.exe
  {
   filedelete, %sourceNameNoExt%.exe
   if errorlevel <> 0
   {
    TrayTip, AHKFileControl, Could not delete %sourceNameNoExt%.exe, , 3
    sleep, 3000
    TrayTip
    exitapp
   }
  }
 
  IfExist, %sourceNameNoExt%.ico
  {
   IfExist, %sourceNameNoExt%.password
   {
    ;msgbox, Found icon and password files.`nCommand:"%command%"
    FileReadLine, sourcePassword, %sourceNameNoExt%.pass, 1
    command = /in "%1%" /out "%sourceDir%\%sourceNameNoExt%.exe" /icon "%sourceDir%\%sourceNameNoExt%.ico" /pass "%sourcePassword%"
    TrayText = Compiled %sourceNameNoExt%.ahk`nParameters: Icon and password.
   }
   else
   {
    ;msgbox, Found icon file only.`nCommand:"%command%"
    command = /in "%1%" /out "%sourceDir%\%sourceNameNoExt%.exe" /icon "%sourceDir%\%sourceNameNoExt%.ico"
    TrayText = Compiled %sourceNameNoExt%.ahk`nParameters: Icon.
   }
  }
  else
  {
   ;msgbox, Plain compile.`nCommand:"%command%"
   command = /in "%1%" /out "%sourceDir%\%sourceNameNoExt%.exe"
   TrayText = Compiled %sourceNameNoExt%.ahk
  }
 
 
  aPath := RP(A_ScriptDir,1,"AutoHotkey\Compiler\Ahk2Exe.exe")
  aCommand = "%aPath%" %command%
  run, %aCommand%
  CapsState := GetKeyState("CapsLock", "T")
  KeyWait, Capslock 
  if CapsState = 1
   SetCapsLockState, off
  if CapsState = 0
   SetCapsLockState, on
  gosub, waitExists
  TrayTip, AHKFileControl, %TrayText%, , 1 
  sleep, 3500
  traytip
return



waitExists:
 StartTime := A_Now
 DurationWait := ""
 
 loop,
 {
  DurationWait := A_Now - StartTime
 
  IfExist, %sourceNameNoExt%.exe
   break
 
  if DurationWait > 3
   {
    TrayTip, AHKFileControl, Error compiling!, , 3
    sleep, 3500
    traytip
    exitapp
   }
   
  sleep, 500
 }
return








runPortable(rPath)
{
 global 1
 aPath := RP(A_ScriptDir,1,rPath)
 run, "%apath%" "%1%"
}


RP(WorkDir,LevelsToCut,FileName)
{
   StringSplit, WDLevel, WorkDir, \ ; get number of levels from workdir

   If (LevelsToCut >= WDLevel0)
      Return ("Illegal number of levels set to build relative path")

   LevelsToCut := WDLevel0-LevelsToCut ; cut off req. # of sublevels from workdir path
   Loop, %LevelsToCut%
      RelativePath .= WDLevel%A_Index% . "\" ; create 'relative path' (from surviving levels)
   Return (RelativePath . FileName)
}
