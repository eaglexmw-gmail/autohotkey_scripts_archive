#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

IfNotExist,hsbmp.bmp
   UrlDownloadToFile, http://dl.dropbox.com/u/6428211/Sample/ImageList/hsbmp.bmp,hsbmp.bmp

himl := DllCall( "ImageList_LoadImage"  ( A_IsUnicode ? "W" : "A" )
                 , UInt,  0           ; HINSTANCE
                 , Str,  "hsbmp.bmp"  ; Bitmap file
                 , UInt, 59           ; The width of each image
                 , UInt,  1           ; The number of images by which the image list grows
                 , UInt, -1           ; CLR_NONE
                 , UInt,  0           ; IMAGE_BITMAP
                 , UInt, 0x2010 )     ; LR_LOADFROMFILE | LR_CREATEDIBSECTION


Gui +ToolWindow
Gui, Margin, 0, 0

Gui, Add, ListView, w330 h300 Icon +0x100 -E0x200  C225599 vLVC hwndhLVC BackgroundE2E2E2
LV_SetImageList( himl,0 )

Loop % DllCall( "ImageList_GetImageCount", UInt,himl )
    LV_Add( "Icon" A_Index, A_Index-1 )

Gui, Show,, Testing hsbmp.bmp

#include IML.ahk
