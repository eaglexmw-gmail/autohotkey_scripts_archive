; Flicker-Free animation with ImageList_Draw() By SKAN   CD: 15-Jun-2011 | LM: 21-Jun-2011
; Post: www.autohotkey.com/forum/viewtopic.php?p=453748#453748
DebugBIF()
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

; Download neil.dll ( 70 KiB ) which contains neil.png ( 69 KiB )
IfNotExist, neil.dll                             ; virustotal.com result: www.goo.gl/l63NI
    URLDownloadToFile, http://www.autohotkey.net/~Skan/Sample/ImageList/neil.dll, neil.dll

; Note: Refer Resource-Only DLL for Dummies www.autohotkey.com/forum/viewtopic.php?t=62180
; Load neil.png from neil.dll into variable 'PNG'
nSize := DllRead( PNG, "neil.dll", "PNG", "NEIL.PNG" )

; Start GDIPlus       Create & obtain a handle to 32bit GDI Bitmap   Shutdown GDIPlus
GDIPlus( "Startup" ), hBM := GDIPlus_hBitmapFromBuffer( PNG,nSize ), GDIPlus( "Shutdown" )

; Note: The fully transparent pixels have been replaced with 'Window Background Color',
;       but is still an alpha bitmap and ImageList_Draw() can detect transparency.

; Create an empty ImageList that can hold 270x60            24bit     75 Images
himl :=  DllCall( "ImageList_Create", Int,270, Int,60, UInt,0x18, Int,75, Int,1 )

; Place the 32-bit GDI Bitmap into 24-bit ImageList to lose the effing transparency!
DllCall( "ImageList_Add", UInt,himl, Uint,hBM, UInt,0 )

VarSetCapacity( PNG,0 ) ; Var PNG is needed no more
GDI_DeleteObject( hBM ) ; Delete the GDI Bitmap

; Phew! All the trouble was in creating the ImageList, while Animating is so simple:

Gui, Add, Picture, w270 h60 hwndhStatic1 0x3
hDC := DllCall( "GetDC", UInt,hStatic1 )
Gui, Show,, Animation with ImageList_Draw()
SetTimer, UpdateAnimation, 100
Return ;                                                 // End of auto-execute section //


UpdateAnimation: ;  The computation rotates I from 0 thru 74 to access 75 images from list
 DllCall( "ImageList_Draw", UInt,himl, Int,I:=I>=74||I<0 ? 0:I+1, UInt,hDC,Int64,0,Int,0 )
Return


DllRead( ByRef Var, Filename, Section, Key ) {          ; Functionality and Parameters are
 VarSetCapacity( Var,64 ), VarSetCapacity( Var,0 )      ; identical to IniRead command ;-)
 If hMod := DllCall( "LoadLibrary", Str,Filename )
  If hRes := DllCall( "FindResource", UInt,hMod, Str,Key, Str,Section )
   If hData := DllCall( "LoadResource", UInt,hMod, UInt,hRes )
    If pData := DllCall( "LockResource", UInt,hData )
 Return VarSetCapacity( Var,nSize := DllCall( "SizeofResource", UInt,hMod, UInt,hRes ),32)
     , DllCall( "RtlMoveMemory", UInt,&Var, UInt,pData, UInt,nSize )
     , DllCall( "FreeLibrary", UInt,hMod )
Return DllCall( "FreeLibrary", UInt,hMod ) >> 32
}

;-----------------------------------------------------------------------------------------
;                                                        GDI and GDIPLUS Wrapper Functions
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

GDIPlus( Comm="Startup" ) {
 Static pToken, hMod
 hMod := hMod ? hMod : DllCall( "LoadLibrary", Str,"gdiplus.dll" )
 If ( Comm="Startup" )
   VarSetCapacity( si,16,0 ), si := Chr(1)
 , Res := DllCall( "gdiplus\GdiplusStartup", UIntP,pToken, UInt,&si, UInt,0 )
 Else Res := DllCall( "gdiplus\GdiplusShutdown", UInt,pToken )
 , hMod := DllCall( "FreeLibrary", UInt,hMod ) >> 64
Return ! Res
}

GDIPlus_hBitmapFromBuffer( ByRef Buffer, nSize ) {   ;  Last Modifed : 21-Jun-2011
; Adapted version by SKAN   www.autohotkey.com/forum/viewtopic.php?p=383863#383863
; Original code by   Sean   www.autohotkey.com/forum/viewtopic.php?p=147029#147029
 hData := DllCall("GlobalAlloc", UInt,2, UInt,nSize )
 pData := DllCall("GlobalLock",  UInt,hData )
 DllCall( "RtlMoveMemory", UInt,pData, UInt,&Buffer, UInt,nSize )
 DllCall( "GlobalUnlock" , UInt,hData )
 DllCall( "ole32\CreateStreamOnHGlobal", UInt,hData, Int,True, UIntP,pStream )
 DllCall( "gdiplus\GdipCreateBitmapFromStream",  UInt,pStream, UIntP,pBitmap )
 DllCall( "gdiplus\GdipCreateHBITMAPFromBitmap", UInt,pBitmap, UIntP,hBitmap, UInt
,DllCall( "ntdll\RtlUlongByteSwap",UInt
;,DllCall("ws2_32\ntohl", UInt
,DllCall( "GetSysColor", Int,15 ) <<8 ) | 0xFF000000 )
 DllCall( "gdiplus\GdipDisposeImage", UInt,pBitmap )
 DllCall( NumGet( NumGet(1*pStream)+8 ), UInt,pStream ) ; IStream::Release
Return hBitmap
}

GDI_DeleteObject( hObj ) {
 Return !! DllCall( "GDI32\DeleteObject", UInt,hObj )
}
