#Persistent
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
IfNotExist, nip.bmp, UrlDownloadToFile
                   , http://www.autohotkey.net/~Skan/Sample/ImageList/nip.bmp, nip.bmp

himl := DllCall( "ImageList_LoadImage"  ( A_IsUnicode ? "W" : "A" ), UInt,0, Str,"nip.bmp"
                                          , UInt,16, UInt,1, Int,-1, UInt,0, UInt,0x2010 )
Loop {
 I := SubStr( "0" A_Index, -1 )
 IL_SetTNicon( himl, i )
 Sleep 250
}
; Copy/Paste IL_SetTNicon() below

#include TNI.ahk
