;   ___ __  __ _      __     ___
;  |_ _|  \/  | |     \ \   / (_) _____      _____ _ __    Suresh Kumar.A.N  aka  SKAN
;   | || |\/| | |      \ \ / /| |/ _ \ \ /\ / / _ \ '__|     arian.suresh@gmail.com
;   | || |  | | |___    \ V / | |  __/\ V  V /  __/ |           IML Viewer v1.00
;  |___|_|  |_|_____|    \_/  |_|\___| \_/\_/ \___|_|    CD: 24-May-2011 LM:25-May-2011
;
;  A viewer tool for saved ImageLists [ www.autohotkey.com/forum/viewtopic.php?t=72282 ]
;
;      Use hotkey 'Control + O' (or click on  Statusbar) to FileSelect .iml file.
;      You may also drag-drop to GUI ( or script ) or pass filename as parameter.
;      This is a multi-instance app.  To Close all open instances with one click,
;      keep 'Control button' down while clicking the [x] Close button on any GUI.
;_______________________________________________________________________________________

#SingleInstance, Off
SetWorkingDir, %A_ScriptDir%
SetBatchLines -1

#NoTrayIcon
Menu, Tray, UseErrorLevel
Menu, Tray, Icon, urlmon.dll, 1

Gui +Resize
Gui, Margin, 0, 0
Gui, Font, S9, Arial

DllCall( "msvcrt\s" (A_IsUnicode ? "w": "" ) "printf",Str,WBG:="      ", Str,"%06X",UInt
         , DllCall("ws2_32\ntohl", UInt,DllCall( "GetSysColor", UInt,15 ), UInt ) >> 8 )

Gui, Add, ListView, w360 h325 Icon +0x100 -E0x200  C225599 Background%WBG% vLVC hwndhLVC

Gui, Add, StatusBar, hwndhSB gSelectIML, % "`tv1.0 by SKAN"
SB_SetParts( 150 ), SB_SetText( "Use Ctrl+O to Open file", 2 )
ControlGetPos, ,,, SBH,, ahk_id %hSB%

Gui, Show,, IML Viewer

Loop %1%
 If FileExist( IMLFile := A_LoopFileLongPath )
  GoSub, LoadIML
Return ;                                               // end of auto-execute section //


#IfWinActive IML Viewer ahk_class AutoHotkeyGUI
  ^o::GoSub, SelectIML
#IfWinActive 


GuiDropFiles:
SelectIML:
  Gui +OwnDialogs
  IfEqual,A_ThisLabel,GuiDropFiles, SetEnv,IMLFile,%A_GuiEvent%
  Else FileSelectFile, IMLFile,, %A_ScriptDir%\%IMLF%,Select save ImageList, *.iml
  IfNotExist, %IMLFile%, Return
LoadIML:
  SplitPath,IMLFile,IMLF,,FileExt
  IfNotEqual,FileExt,IML, Return
  LV_Delete(),  SB_SetText( IMLFile,2 )
  Gui, Show,, IML Viewer [ %IMLF% ]
  If ! himl := IML_Load( IMLFile )  {
    SB_SetText( "`tFile Open Error", 1 )
    Return
} IL_Destroy( LV_SetImageList( himl,0 ) )
  Loop % ILCount := DllCall( "ImageList_GetImageCount", UInt,himl )
    LV_Add( "Icon" A_Index, A_Index-1 )
  DllCall( "ImageList_GetIconSize", UInt,himl, IntP,IW, IntP,IH )
  SB_SetText( A_Tab ILCount " Images ( " IW "x" IH " )", 1 )
Return


GuiSize:
  GuiW := A_GuiWidth, GuiH := A_GuiHeight-SBH
  SetTimer, GuiSizeEx, -30
  Return
GuiSizeEx:
  GuiControl, MoveDraw, LVC, x0 y0 w%GuiW%  h%GuiH%
  WinSet, Redraw, , ahk_id %hSB%
Return


GuiEscape:
GuiClose:
  If ! GetKeyState( "LControl" ) {
    ExitApp
  }  Else {
    WinGet, ID, List, IML Viewer ahk_class AutoHotkeyGUI
    Loop %ID%
      PostMessage, 0x111, 65405, 0,, % "ahk_id" ID%A_Index%
  }


IML_Load( File ) {             ; by SKAN  www.autohotkey.com/forum/viewtopic.php?t=72282
 If ( hF := DllCall( "CreateFile", Str,File, UInt,0x80000000, UInt,3  ;  CD: 24-May-2011
                    , Int,0, UInt,3, Int,0, Int,0 ) ) < 1             ;  LM: 25-May-2011
 || ( nSiz := DllCall( "GetFileSize", UInt,hF, Int,0, UInt ) ) < 1
  Return ( ErrorLevel := 1 ) >> 64,  DllCall( "CloseHandle",UInt,hF )
 hData := DllCall("GlobalAlloc", UInt,2, UInt,nSiz )
 pData := DllCall("GlobalLock",  UInt,hData )
 DllCall( "_lread", UInt,hF, UInt,pData, UInt,nSiz )
 DllCall( "GlobalUnlock", UInt,hData ), DllCall( "CloseHandle",UInt,hF )
 DllCall( "ole32\CreateStreamOnHGlobal", UInt,hData, Int,True, UIntP,pStream )
 himl := DllCall( "ImageList_Read", UInt,pStream )
 DllCall( NumGet( NumGet( 1*pStream ) + 8 ), UInt,pStream ),
 DllCall( "GlobalFree", UInt,hData )
Return himl
}