#Persistent
SetWorkingDir, %A_ScriptDir%
IFNotExist, Anim1.bmp, URLDownloadToFile
                   , http://www.autohotkey.net/~Skan/Sample/ImageList/Anim1.bmp, Anim1.bmp
himl := DllCall( "ImageList_LoadImage" ( A_IsUnicode ? "W" : "A" ), Int,0, Str,"Anim1.bmp"
                                          , UInt,16, UInt,1, Int,-1, UInt,0, UInt,0x2010 )
SetTimer, AnimateTNIcon, 100
Return

AnimateTNIcon:
 IL_SetTNicon( himl, I:=I>=39||I<0 ? 0:I+1 )
Return

; Copy/Paste IL_SetTNicon() below

#include TNI.ahk
