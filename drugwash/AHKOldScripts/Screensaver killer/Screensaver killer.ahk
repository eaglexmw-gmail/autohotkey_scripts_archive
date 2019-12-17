; by SKAN http://www.autohotkey.com/forum/viewtopic.php?p=271708#271708
DebugBIF()
Process, Priority,, High
Gui +LastFound
hWnd := WinExist()
DllCall( "RegisterShellHookWindow", UInt,hWnd )
MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
OnMessage( MsgNum, "ShellMessage" )
Return

ShellMessage( wParam,lParam ) {
  If ( wParam = 1 ) ;  HSHELL_WINDOWCREATED := 1
     {
       WinGet, PN, ProcessName, ahk_id %lParam%
       If ( SubStr(PN,-3) = ".scr" )
          SetTimer, ScreenSaverHandler, -1
     }
}

ScreenSaverHandler:
 Send {Esc}                    ; Cancel ScreenSaver
 MsgBox, ScreenSaver was detected and cancelled immediately
Return
