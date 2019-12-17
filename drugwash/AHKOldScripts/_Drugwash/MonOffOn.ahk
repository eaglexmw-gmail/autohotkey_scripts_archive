; Shutdown other monitor when watching fullscreen video
; Drugwash 31Oct2008

/*
Visual Basic:

Option Explicit
Private Declare Function SendMessage Lib _
"user32" Alias "SendMessageA" (ByVal hWnd As Long, _
ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As Any) As Long


Const SC_MONITORPOWER = &HF170
Public Const MONITOR_ON = -1&
Public Const MONITOR_OFF = 2&
Const WM_SYSCOMMAND = &H112

'Turn Monitor on:
'SendMessage Me.hWnd, WM_SYSCOMMAND, SC_MONITORPOWER, MONITOR_ON
'
'Turn Monitor off:
'SendMessage Me.hWnd, WM_SYSCOMMAND, SC_MONITORPOWER, MONITOR_OFF

C++

HWND hwnd = GetForegroundWindow();
SendMessage(hwnd, WM_SYSCOMMAND, SC_MONITORPOWER, 2);

Because SendMessage takes a HWND as the first parameter, it didn't like the HMONITOR.
An HWND to any window on the screen will do.
*/
HotKey, ^F9, Moff
HotKey, ^F10, Mon
return

Moff:
;MsgBox, CTRL+F9 worked
;SendMessage, 0x112, 0xF170, 1,, Program Manager
SendMessage, 0x112, 0xF170, 1,, A
return

Mon:
;MsgBox, CTRL+F10 worked
SendMessage, 0x112, 0xF170, -1,, A
SendMessage, 0x112, 0xF170, -1,, Program Manager
return
