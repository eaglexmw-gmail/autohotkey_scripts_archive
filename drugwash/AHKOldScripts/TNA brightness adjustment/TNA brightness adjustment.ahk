/* _   _   _     _   _   _   _   _   _   _   _   _   _     _   _   _   _   _   _   _   _
  / \ / \ / \   / \ / \ / \ / \ / \ / \ / \ / \ / \ / \   / \ / \ / \ / \ / \ / \ / \ / \
 ( T | N | A ) ( B | R | I | G | H | T | N | E | S | S ) ( A | D | J | U | S | T | E | R )
  \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 TNA Brightness Adjuster - Control Screen Brightness with mouse scroll wheel on Tray Icon.
 
 Author A.N.Suresh Kumar a.k.a SKAN ( arian.suresh@gmail.com ), Last Modified: 27-Mar-2012
 Thanks to Sean : www.autohotkey.com/forum/viewtopic.php?p=197904#197904
 Forum Topic : www.autohotkey.com/forum/viewtopic.php?t=84280

 ImageList : www.autohotkey.net/~Skan/Sample/ImageList/nipb.bmp
             www.goo.gl/3h1JO ( Dropbox )
             www.i.imgur.com/vZPW0.png
*/

#SingleInstance, Force
SetWorkingDir %A_ScriptDir% 
Menu, Tray, NoStandard
Menu, Tray, Add, Brightest, Preset
Menu, Tray, Add, Brighter,  Preset
Menu, Tray, Add, Normal,    Preset
Menu, Tray, Add, Darker,    Preset
Menu, Tray, Add, Darkest,   Preset
Menu, Tray, Add
Menu, Tray, Add, Default,   Preset
Menu, Tray, Add, Exit,  QuitScript
Menu, Tray, Default, Default

Br := 96    ;   Brightness Range: 0 - 255 where 0=darkest, 255=Brightest and 128 is Normal

IfNotExist, nipb.bmp
UrlDownloadToFile, http://www.autohotkey.net/~Skan/Sample/ImageList/nipb.bmp, nipb.bmp
IfNotExist, nipb.bmp, ExitApp

himl := DllCall( "ImageList_LoadImage" ( A_IsUnicode ? "W" : "A" )
      , UInt,0, Str,"nipb.bmp", UInt,16, UInt,1, Int,-1, UInt,0, UInt,0x2010 )

DisplaySetBrightness( Br ), OnMessage( 0x404,"AHK_NOTIFYICON" )
OnMessage( DllCall( "RegisterWindowMessage",Str,"TaskbarCreated" ), "WM_TASKBAR_CREATED" )
IL_SetTNIcon( himl, Round(Br/255*100) )
OnExit, QuitScript
Return ;                                                 // End of Auto-Execute Section //

#IfWinExist TNA Brightness Adjuster ahk_class AutoHotkeyGUI
 WheelUp::  AdjustBrightness( +1 )
^WheelUp::  AdjustBrightness( +1 )
 WheelDown::AdjustBrightness( -1 )
^WheelDown::AdjustBrightness( -1 )
#IfWinActive

Preset:
 IfEqual,A_ThisMenuItem, Brightest,   SetEnv, pBr, 192
 IfEqual,A_ThisMenuItem, Brighter,    SetEnv, pBr, 160
 IfEqual,A_ThisMenuItem, Normal,      SetEnv, pBr, 128
 IfEqual,A_ThisMenuItem, Darker,      SetEnv, pBr,  96
 IfEqual,A_ThisMenuItem, Darkest,     SetEnv, pBr,  64
 IfEqual,A_ThisMenuItem, Default,     SetEnv, pBr, %Br%
 DisplaySetBrightness( pBr ),  IL_SetTNicon( himl, Round(pBr/255*100) )
Return

QuitScript:
 OnExit
 ExitApp, % DisplaySetBrightness( 128 )
Return

SetTNAIcon:
 WinWait ahk_class Shell_TrayWnd
 cBr := DisplayGetBrightness(),  IL_SetTNicon( himl, Round(cBr/255*100) )
Return

MonitorMouseLeave:
 MouseGetPos,,,, hCtrl, 2
 WinGetTitle, Title, ahk_id %hCtrl%
 If ( Title <> "Notification Area" ) {
   SetTimer, MonitorMouseLeave, Off
   Gui, 1:Destroy
   Tooltip
 }
Return

AdjustBrightness( V=0 ) {
 Global himl
 V  := ( GetKeyState("MButton") && V > 0 ) ? V + 9
    :  ( GetKeyState("MButton") && V < 0 ) ? V - 9 : V
 Br := ( Br := DisplayGetBrightness() + V ) > 255 ? 255 : Br < 0 ? 0 : Br
 DisplaySetBrightness( Br ),  IL_SetTNicon( himl,  Prc := Round(Br/255*100) )
 ToolTip, % GetKeyState( "LControl" ) ? Prc "% [" Br "]" : ""
}

DisplaySetBrightness( Br=128 ) {
 Loop, % VarSetCapacity( GR,1536 ) / 6
   NumPut( ( n := (Br+128)*(A_Index-1)) > 65535 ? 65535 : n, GR, 2*(A_Index-1), "UShort" )
 DllCall( "RtlMoveMemory", UInt,&GR+512,  UInt,&GR, UInt,512 )
 DllCall( "RtlMoveMemory", UInt,&GR+1024, UInt,&GR, UInt,512 )
Return DllCall( "SetDeviceGammaRamp", UInt,hDC := DllCall( "GetDC", UInt,0 ), UInt,&GR )
     , DllCall( "ReleaseDC", UInt,0, UInt,hDC )
}

DisplayGetBrightness( ByRef GR="" ) {
 VarSetCapacity( GR,1536,0 )
 DllCall( "GetDeviceGammaRamp", UInt,hDC := DllCall( "GetDC", UInt,0 ), UInt,&GR )
 Return NumGet( GR, 2, "UShort" ) - 128,  DllCall( "ReleaseDC", UInt,0, UInt,hDC )
}

IL_SetTNicon( himl=0, i=0 ) {     ; Set TNA-Icon from ImageList - By SKAN | CD:24-Jun-2011
 Static NID ; Altered version!   Original @ www.autohotkey.com/forum/viewtopic.php?t=72282
 IfLess,himl,1, Return,VarSetCapacity( NID,0 )
 If ! VarSetCapacity( NID )
  NumPut( 0x2|0x4, NumPut( 1028, NumPut( DllCall( "FindWindow", Str,"AutoHotkey"
  , Str, A_ScriptFullPath ( A_IsCompiled ? "" : " - AutoHotkey v" A_AhkVersion ) )
  , NumPut( VarSetCapacity( NID,444,0 ),NID ) ) ) )
 NumPut( hIcon := DllCall( "ImageList_GetIcon", UInt,himl, int,i, int,0 ), NID, 20 )
Return DllCall( "shell32\Shell_NotifyIcon", UInt,0x1, UInt,&NID )
     , DllCall( "DestroyIcon", UInt,hIcon )
}

AHK_NOTIFYICON( wParam, lParam, Msg, hWnd ) { ; Thanks to Lexikos
  If ! ( WinExist( "TNA Brightness Adjuster ahk_class AutoHotkeyGUI" ) ) {
   Gui, 1:+ToolWindow
   Gui, 1:Show, x0 y0 w0 h0 NA, TNA Brightness Adjuster
   SetTimer, MonitorMouseLeave, 50
}}

WM_TASKBAR_CREATED() {
 SetTimer, SetTNAIcon, -1
} ;                                                                    // End of Script //
