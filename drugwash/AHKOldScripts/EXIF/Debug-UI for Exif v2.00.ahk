; Debug-UI for EXIF() Dump-Table v2.00 - By SKAN      |   CD: 01-Jun-2010 / LM 10-Jun-2010
; ________________________________________________________________________________________

#Singleinstance, Force
SetBatchLines -1
SetWorkingDir, %A_ScriptDir%
#Include EXIF.ahk

Gui, Margin, 0, 0
Gui, Color, 454546 ; FFFAF2

Gui, Font, S9 Bold, Tahoma
Gui, Add, ListView, x0 y0 w220 h650 Icon -Multi +LV0x8000 -E0x200 hWndhLV cFFB446
                +0x108 Background111111 AltSubmit vLV gLVroutine, Image|ImagePath

Gui, Font, S9 Normal, Lucida Console
Gui, Add, Edit, x+0 yp+5 w710 hp-10 -E0x200 +ReadOnly vExifData hWndhED cCCCCCC
SendMessage, ( EM_SETMARGINS:=0xD3 ), 1, 10,, ahk_id %hED%

Gui, Font, S9, Arial
Gui, Add, StatusBar,, % "`tWait..."
SB_SetParts( 55,55,110, 640 ),  SetTitleBarIcon()
Gui, Show, AutoSize, Debug-UI >> EXIF() Dump-Table v2.00 - By SKAN

GdiPlus( "Startup" ) ; - - - - - - - - - - - - - - - - - - - - - - - - -  GDI Plus Startup

; Obtain a temporary bitmap that will be displayed in leiu of missing thumbnails
FileRead, NoImage, Sample-Photos\NoImage.gif
tBM := GdiPlus_hBitmapFromBuffer( NoImage, VarSetCapacity( NoImage) )

; Create an ImageList and attach it to ListView
ImageListID := IL_CreateEx( 100, 10, 160, 120 )
LV_SetImageList( ImageListID )

GuiControl, -Redraw, LV ; - - - - - - - - - - - - - - - - - Turn-off ListView Update

Loop, Sample-Photos\*.jpg
  {
    SplitPath,A_LoopFileLongPath,,,,Image

    EXIF( A_LoopFileLongPath, Thumb:=True )

    If   nSz := VarSetCapacity( Thumb )
         hBM := GdiPlus_hBitmapFromBuffer( Thumb, nSz )

    ImgIdx0 := IL_AddEx( ImageListID, nSz ? hBM : tBM ),     Gdi_DeleteObject( hBM )

    LV_Add( "Icon" ImgIdx0+1, Image, A_LoopFileLongPath )

    Mod( A_Index, 20 ) ? : SB_SetText( "`t" A_Index, 2 )
  }

GuiControl, +Redraw, LV  ; - - - - - - - - - - - - - - - - - Turn-on ListView Update

LV_Modify( 1, "Select Focus" ), SB_SetText( "`t" LV_GetCount(),2 )
SB_SetText( "`tPID: " DllCall("GetCurrentProcessId"), 5 )

GdiPlus( "Shutdown" ) ; - - - - - - - - - - - - - - - - - - - - - - - -  GDI Plus Shutdown

;                                                                     :: HOTKEYS CONFIG ::
HotKey, IfWinActive, Debug-UI >> EXIF() ahk_class AutoHotkeyGUI
Loop 7
  Hotkey, F%A_Index%, SortTable  ; Function Keys 1 thru 7 will sort ExifTable Cols 1-7
HotKey, F9, TagSearch            ; Click on a ExifTable row & F9 will take you to Tag spec
HotKey, F10, ExifTool            ; Call ExifTool for Text OutPut
HotKey, F11, ExifTool            ; Call ExifTool for HEXDATA in 'HTML' output
HotKey, F12, GuiClose            ; ExitApp
HotKey, IfWinActive

Return ;                                                 // end of auto-execute section //
;_________________________________________________________________________________________

GuiClose:
 ExitApp
Return

LVRoutine:
 If ( InStr(A_GuiEvent,"I",1 ) && InStr( ErrorLevel,"S",1 ) ) {
   LV_GetText( File, Row:=A_EventInfo, 2 )
   SB_SetText( "`t" Row ), SB_SetText( "  " File,4 )

   QPX( True ), ExifData := EXIF( File ), TimeTaken := QPX( False )

   SB_SetText( "`tSpeed: " Round( TimeTaken,3) "s",3 )
   GuiControl,, ExifData, %ExifData%
 }
If ( A_GuiEvent="DoubleClick" )
 Runwait, Rundll32.exe %A_Windir%\system32\shimgvw.dll`,ImageView_Fullscreen %File%
Return

ExifTool:
 SoundBeep, 555, 66
 LV_GetText( File, LV_GetNext(), 2 )

 If ( A_ThisHotkey="F11" )
       param=exiftool.exe -htmlDump0 "%file%" > exiftool.htm
 Else  param=exiftool.exe "%file%" > exiftool.txt

 SetWorkingDir, %A_ScriptDir%\exiftool

 runwait cmd.exe /c "%Param%",, Hide UseErrorLevel
 If ! ErrorLevel
   Run % ( A_ThisHotkey="F8" ) ? "exiftool.htm" : "exiftool.txt" ,, Max

 SetWorkingDir, %A_ScriptDir%
 SoundBeep, 777, 88
 Return

SortTable:
 GuiControlGet, ExifData
 GuiControl,, ExifData, % SortTable( ExifData,  SubStr( A_ThisHotkey, 0 ) )
Return

SortTable( ExifData, Field=0 ) {
 Static F1=1, F2=6, F3=35, F4=43, F5=51, F6=58, F7=64
 Header := SubStr( ExifData,1,96),  ExifData := SubStr( ExifData,97 ),  Pos := F%Field%
 Sort, ExifData, D`n P%Pos%
Return Header . ExifData
}

TagSearch:
 GuiControlGet, ClassNN, Focus
 IfNotEqual,ClassNN,Edit1, Return
 SendMessage, EM_LINEINDEX := 0xBB, -1, 0,, ahk_id %hED%
 hTag := SubStr( ExifData, ((ErrorLevel//96)*96)+1, 4 ),      op := "site:awaresystems.be"
 Run, http://www.google.com/search?hl=en&q=allintitle:0x%hTag%+%op%&btnI=I'm+Feeling+Lucky
Return

SetTitleBarIcon() {
 IconDataHex =
 ( Join LTrim
  2800000010000000200000000100040000000000C00000000000000000000000000000000000000000000000
  0000320000004A003E3E5C00000071003D3D63005A5A7E0000008900000098000000AC000000D0000000F400
  9292D4008E8EF200B3B3EA00FDFDFE00008888888888880000877741111118000088CFFFFFF348000088EEFF
  FFE888000089FC11999999000089FF11999999000089FF2111118900008AFFFFFF518A00008AAFFFFFDAAA00
  008AFF12AAAAAA00008AFF19AAAAAA00008AFD9921129A00008BEEFFFF622A00008BDFFFFFFDBB00008BBBBB
  BBBBBB000000000000000000C0030000C0030000C0030000C0030000C0030000C0030000C0030000C0030000
  C0030000C0030000C0030000C0030000C0030000C0030000C0030000FFFF0000
 )
 VarSetCapacity( IconData,( nSize:=StrLen(IconDataHex)//2) )
 Loop %nSize% ; MCode by Laszlo Hars: www.autohotkey.com/forum/viewtopic.php?t=21172
   NumPut( "0x" . SubStr(IconDataHex,2*A_Index-1,2), IconData, A_Index-1, "Char" )
 hICon := DllCall( "CreateIconFromResourceEx", UInt,&IconData
                   , UInt,0, Int,1, UInt,196608, Int,16, Int,16, UInt,0 )
 ; Thanks Chris : www.autohotkey.com/forum/viewtopic.php?p=69461#69461
 Gui +LastFound               ; Set our GUI as LastFound window ( affects next two lines )
 SendMessage, ( WM_SETICON:=0x80 ), 0, hIcon  ; Set the Titlebar Icon
 SendMessage, ( WM_SETICON:=0x80 ), 1, hIcon  ; Set the Alt-Tab icon
}

;-----------------------------------------------------------------------------------------
;                                                                          Other Functions
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

QPX( N=0 ) {       ;  Wrapper for  QueryPerformanceCounter()by SKAN  | CD: 06/Dec/2009
 Static F,A,Q,P,X  ;  www.autohotkey.com/forum/viewtopic.php?t=52083 | LM: 10/Dec/2009
 If ( N && !P )
    Return  DllCall("QueryPerformanceFrequency",Int64P,F) + (X:=A:=0)
          + DllCall("QueryPerformanceCounter",Int64P,P)
 DllCall("QueryPerformanceCounter",Int64P,Q), A:=A+Q-P, P:=Q, X:=X+1
Return ( N && X=N ) ? (X:=X-1)<<64 : ( N=0 && (R:=A/X/F) ) ? ( R + (A:=P:=X:=0) ) : 1
}

;-----------------------------------------------------------------------------------------
;                                                              ImageList Wrapper Functions
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

IL_CreateEx( IniCount, GrowCount, W, H, F=0x20 ) {     ; Creates and returns 'ImageListID'
Return DllCall( "ImageList_Create", Int,W, Int,H, UInt,F, Int,IniCount, Int,GrowCount )
}

IL_AddEx( ImageListID, hBM, hMask=0 ) {                ; Adds a GDI Bitmap to ImageList
Return DllCall( "ImageList_Add", UInt,ImageListID, UInt,hBM, UInt,hMask )
}

;-----------------------------------------------------------------------------------------
;                                                        GDI and GDIPLUS Wrapper Functions
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

GdiPlus( Comm="Startup" ) {
 Static pToken, hMod
  If ( Comm="Startup" ) {
    If ! DllCall( "GetModuleHandle", Str,"gdiplus.dll" )
         hMod := DllCall( "LoadLibrary", Str,"gdiplus.dll" )
    DllCall( "LoadLibrary", Str,"gdiplus" ), VarSetCapacity( si,16,0 ), NumPut( 1,si )
    Res := DllCall( "gdiplus\GdiplusStartup", UIntP,pToken, UInt,&si, UInt,0 )
  } Else {
  Res := DllCall( "gdiplus\GdiplusShutdown", UInt,pToken )
  If hMod
     DllCall( "FreeLibrary", UInt,hMod ),DllCall( "FreeLibrary", UInt,hMod ), hMod := 0
  }
Return ! Res
}

GdiPlus_hBitmapFromBuffer( ByRef Buffer, nSize, ByRef W="", ByRef H="" ) {
; Original code by Sean www.autohotkey.com/forum/viewtopic.php?p=147029#147029
  hData := DllCall("GlobalAlloc", UInt,2, UInt, nSize )
  pData := DllCall("GlobalLock",  UInt,hData )
  DllCall( "RtlMoveMemory", UInt,pData, UInt,&Buffer, UInt,nSize )
  DllCall( "GlobalUnlock", UInt,hData )
  DllCall( "ole32\CreateStreamOnHGlobal", UInt,hData, Int,True, UIntP,pStream )
  DllCall( "gdiplus\GdipCreateBitmapFromStream", UInt,pStream, UIntP,pBitmap )
  DllCall( "gdiplus\GdipCreateHBITMAPFromBitmap", UInt,pBitmap, UIntP,hBitmap, UInt,8 )
  DllCall( "gdiplus\GdipGetImageWidth" , UInt, pBitmap, UIntP,W )
  DllCall( "gdiplus\GdipGetImageHeight", UInt, pBitmap, UIntP,H )
  DllCall( "gdiplus\GdipDisposeImage", UInt,pBitmap )
  DllCall( NumGet( NumGet(1*pStream)+8 ), UInt,pStream ) ; IStream::Release ?!
Return hBitmap
}

Gdi_DeleteObject( hObj ) {
 Return !! DllCall( "GDI32\DeleteObject", UInt,hObj )
}