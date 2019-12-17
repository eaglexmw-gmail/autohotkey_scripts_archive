#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

IconFiles=
(
http://dl.dropbox.com/u/6428211/Sample/ImageList/Icons/1306310755.ico
http://dl.dropbox.com/u/6428211/Sample/ImageList/Icons/1306310798.ico
http://dl.dropbox.com/u/6428211/Sample/ImageList/Icons/1306310806.ico
http://dl.dropbox.com/u/6428211/Sample/ImageList/Icons/1306310865.ico
http://dl.dropbox.com/u/6428211/Sample/ImageList/Icons/1306310888.ico
http://dl.dropbox.com/u/6428211/Sample/ImageList/Icons/1306378426.ico
)

; Download samples of 96x124 icons
Loop, Parse, IconFiles, `n
 UrlDownloadToFile, % A_LoopField, % SubStr( A_LoopField, -13 )


Wid  := 96                  ; Standard width for all images
Hei  := 124                 ; Standard height for all images
ILC_COLOR32 := 0x20         ; This flag is required as we are about to store 32bit Bitmaps
Init := 6                   ; Initial count of images. We are going to add 6 Images.

; ImageList_Create()        www.msdn.microsoft.com/en-us/library/bb761522

himl := DllCall( "ImageList_Create", Int,Wid, Int,Hei, UInt,ILC_COLOR32, Int,Init, Int,1 )


LR_LOADFROMFILE := 0x10, IMAGE_ICON := 1

Loop, *.ico
{

;  LoadImage()              www.msdn.microsoft.com/en-us/library/ms648045

   hIcon := DllCall( "LoadImage", Int,0, Str,A_LoopFileName
                    , Int,IMAGE_ICON          ; Source image is an ICON
                    , Int,0, Int,0            ; use Original Width & Height
                    , UInt,LR_LOADFROMFILE )

;  ImageList_ReplaceIcon()  www.msdn.microsoft.com/en-us/library/bb775215

   DllCall( "ImageList_ReplaceIcon", UInt,hIml, Int,-1, UInt,hIcon )
;  Note >> Calling ImageList_ReplaceIcon() with -1 will append the Icon to ImageList
}

; Now the ImageList contains 6 images equally sized at 96x124

; Let's save it!!

IML_Save( "test.iml", himl )

Return                                                 ; // end of auto-execute section //

; Copy/Paste IML_Save() below

#include IML.ahk
