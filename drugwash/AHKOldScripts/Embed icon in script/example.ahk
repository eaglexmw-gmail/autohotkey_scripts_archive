; http://www.autohotkey.com/forum/viewtopic.php?p=244453#244453

#NoTrayIcon
MsgN := DllCall( "RegisterWindowMessage", Str,"TaskbarCreated" )
OnMessage( MsgN, "WM_TASKBAR_CREATED" )

IconDataHex =
( join
2800000010000000200000000100040000000000C000000000000000000000000000000000000000C6080800CE
101000CE181800D6212100D6292900E13F3F00E7525200EF5A5A00EF636300F76B6B00F7737300FF7B7B00FFC6
C600FFCEC600FFDEDE00FFFFFF00CCCCCCCCCCCCCCCCC00000000000000CC11111111111111CC22222CFFE2222
2CC33333CFFE33333CC44444CFFE44444CC55555CFFE55555CC55555CFFE55555CC55555CFFE55555CC66666CF
FE66666CC77777777777777CC88888CFFC88888CC99999CFFC99999CCAAAAAAAAAAAAAACCBBBBBBBBBBBBBBCCC
CCCCCCCCCCCCCC0000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000
)
VarSetCapacity( IconData,( nSize:=StrLen(IconDataHex)//2) )
Loop %nSize% ; MCode by Laszlo Hars: http://www.autohotkey.com/forum/viewtopic.php?t=21172
  NumPut( "0x" . SubStr(IconDataHex,2*A_Index-1,2), IconData, A_Index-1, "Char" )
IconDataHex := ""            ; contents needed no more
hICon := DllCall( "CreateIconFromResourceEx", UInt,&IconData
                , UInt,nSize, Int,1, UInt,196608, Int,16, Int,16, UInt,0 )

; Thanks Chris : http://www.autohotkey.com/forum/viewtopic.php?p=69461#69461
Gui +LastFound               ; Set our GUI as LastFound window ( affects next two lines )
SendMessage, ( WM_SETICON:=0x80 ), 0, hIcon  ; Set the Titlebar Icon
SendMessage, ( WM_SETICON:=0x80 ), 1, hIcon  ; Set the Alt-Tab icon

; Creating NOTIFYICONDATA : http://msdn.microsoft.com/en-us/library/aa930660.aspx
; Thanks Lexikos : http://www.autohotkey.com/forum/viewtopic.php?p=162175#162175
PID := DllCall("GetCurrentProcessId"), VarSetCapacity( NID,444,0 ), NumPut( 444,NID )
DetectHiddenWindows, On
NumPut( WinExist( A_ScriptFullPath " ahk_class AutoHotkey ahk_pid " PID),NID,4 )
DetectHiddenWindows, Off
NumPut( 1028,NID,8 ), NumPut( 2,NID,12 ), NumPut( hIcon,NID,20 )
Menu, Tray, Icon                                           ;   Shows the default Tray icon
DllCall( "shell32\Shell_NotifyIcon", UInt,0x1, UInt,&NID ) ; and we immediately modify it.
Gui, Show, w640 h480
Return

GuiClose:
 ExitApp
 
Return

WM_TASKBAR_CREATED() {
 Global NID
 WinWait ahk_class Shell_TrayWnd
 DllCall( "shell32\Shell_NotifyIcon", UInt,0x1, UInt,&NID )
}
