SetWorkingDir, %A_ScriptDir%
IfNotExist, shil.dll ; 11.5 KiB, UPX Compressed!!  virustotal.com result: www.goo.gl/HmUX8
    URLDownloadToFile, http://www.autohotkey.net/~Skan/Sample/ImageList/shil.dll, shil.dll

hIns := DllCall( "LoadLibrary", Str,"shil.dll" ),               BackgroundTrans := True
himl := DllCall( "ImageList_LoadImage" ( A_IsUnicode ? "W" : "A" ), UInt,hIns, UInt,6001
          , UInt,272, UInt,0, Int,BackgroundTrans ? 0xFF000000 : -1, UInt,0, UInt,0x2000 )
DllCall( "ImageList_SetBkColor", UInt,himl, UInt,DllCall( "GetSysColor", Int,15 ) )
DllCall( "FreeLibrary", UInt,hIns )

Gui, Add, Picture, w272 h60 hwndhStatic1
hDC := DllCall( "GetDC", UInt,hStatic1 )
Gui, Show,, Animation with ImageList_Draw()
SetTimer, UpdateAnimation, 75
Return ;                                                 // End of auto-execute section //

UpdateAnimation: ;  The computation rotates I from 0 thru 35 to access 31 images from list
 If ( I := I>=35||I<0 ? 0 : I+1 ) < 31
  DllCall( "ImageList_Draw", UInt,himl, Int,I, UInt,hDC, Int,0, Int,0, Int,0 )
Return
