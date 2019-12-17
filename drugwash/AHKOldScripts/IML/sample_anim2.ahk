SetWorkingDir, %A_ScriptDir%
IfNotExist, neil2.dll ; 48 KiB, UPX Compressed!!   virustotal.com result: www.goo.gl/s50mX
  URLDownloadToFile, http://www.autohotkey.net/~Skan/Sample/ImageList/neil2.dll, neil2.dll
                     
hIns := DllCall( "LoadLibrary", Str,"neil2.dll" ),               BackgroundTrans := True
himl := DllCall( "ImageList_LoadImage" ( A_IsUnicode ? "W" : "A" ), UInt,hIns, UInt,6000
          , UInt,270, UInt,0, Int,BackgroundTrans ? 0xFF000000 : -1, UInt,0, UInt,0x2000 )
DllCall( "ImageList_SetBkColor", UInt,himl, UInt,DllCall( "GetSysColor", Int,15 ) )
DllCall( "FreeLibrary", UInt,hIns )

Gui, Add, Picture, w270 h60 hwndhStatic1 0x3
hDC := DllCall( "GetDC", UInt,hStatic1 )
Gui, Show,, Animation with ImageList_Draw()
SetTimer, UpdateAnimation, 100
Return ;                                                 // End of auto-execute section //

UpdateAnimation: ;  The computation rotates I from 0 thru 74 to access 75 images from list
 DllCall( "ImageList_Draw", UInt,himl, Int,I:=I>=74||I<0 ? 0:I+1, UInt,hDC,Int64,0,Int,0 )
Return
