; BCM_SETIMAGELIST := 0x1602

IfNotExist, bil.bmp, URLDownloadToFile
 , http://www.autohotkey.net/~Skan/Sample/ImageList/bil.bmp, bil.bmp
 
; ImageList_LoadImage()      ; www.msdn.microsoft.com/en-us/library/bb761557
himl := DllCall( "ImageList_LoadImage"  ( A_IsUnicode ? "W" : "A" ), UInt,0, Str,"bil.bmp"
                                       , UInt,16, UInt,1, Int,-1, UInt,0, UInt,0x2010 )

; BUTTON_IMAGELIST Structure : www.msdn.microsoft.com/en-us/library/bb775953
VarSetCapacity( BIL, 24, 0 ), NumPut( himl, BIL )                   ;

; Button-Image margins: Left / Top / Right / Bottom
NumPut( 5, BIL, 4 ),   NumPut( 0, BIL, 8 ),   NumPut( 0, BIL,12 ),   NumPut( 0, BIL,16 )


Gui, +ToolWindow
Gui, Font, S10, Calibri

Gui, Add, Button, w120 h25 hwndErrorLevel,               Button 1
 SendMessage, 0x1602, 0, &BIL,, ahk_id %Errorlevel%

Gui, Add, Button, wp hp hwndErrorlevel,                  Button 2
 SendMessage, 0x1602, 0, &BIL,, ahk_id %Errorlevel%

Gui, Add, Button, wp hp hwndErrorlevel ,                 Button 3
 SendMessage, 0x1602, 0, &BIL,, ahk_id %Errorlevel%

Gui, Add, Button, wp hp hwndErrorlevel ,                 Button 4
 SendMessage, 0x1602, 0, &BIL,, ahk_id %Errorlevel%

Gui, Add, Button, wp hp Disabled hwndErrorlevel,         Button 5
 SendMessage, 0x1602, 0, &BIL,, ahk_id %Errorlevel%

Gui, Show,, % " LED Buttons"

include IML.ahk
