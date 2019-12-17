Gui, Add, DDL, w134 R5 hwndCBOX2 AltSubmit gUpdateGradient vGradientType
     , Vertical Linear|Horizontal Linear|Sunburst||Horizontal Bi-Linear|Vertical Bi-Linear
Gui, Add, Edit, x+5 w55 hp Center Uppercase Limit6 vColor1, ABCDEF
Gui, Add, Edit, x+5 w55 hp Center Uppercase Limit6 vColor2, 123456
Gui, Add, Picture, x10 y+5 w256 h256 0x120E hwndcHwnd
Gui, Show,, CreateGradientBitmap()
Gui, Add, Button, +Default gUpdateGradient

UpdateGradient:
 Gui, Submit, NoHide
 DllCall( "DeleteObject", UInt,hBMP )
 hBMP := GDI_CreateGradientBitmap( GradientType, Color1, Color2, 256, 256 )
 DllCall( "SendMessage", UInt,cHwnd, UInt,0x172, UInt,0, UInt,hBMP ) ; STM_SETIMAGE

Return                                                 ; // end of auto-execute section //

GDI_CreateGradientBitmap( G=3, C1="ABCDEF", C2="123456", W=256, H=256 ) {
 ; Thanks to HotkeyIt : www.autohotkey.com/forum/viewtopic.php?t=37376
 ; This post : www.autohotkey.com/forum/viewtopic.php?p=425387#425387
 D := ( G := G<1||G>5 ? 3:G ) < 3 ? 2 : 3,  SZ := D*D*4,  VarSetCapacity( B$,40+SZ,0 )
 ; Init BITMAPINFOHEADER ( 40 Bytes )
 NumPut(SZ,NumPut(0x180001,NumPut(D,NumPut(D,NumPut(40,B$))))+4), C1:="0x" C1, C2:="0x" C2
 ; Dynamic BITMAP Data
 _ := G=1 ? NumPut(C1,NumPut(C1,NumPut(C2,NumPut(C2,&B$+40)-1)+1)-1) : G=2 ? NumPut(C2
 ,NumPut(C1,NumPut(C2,NumPut(C1,&B$+40)-1)+1)-1) : G=3 ? NumPut(C2,NumPut(C2,NumPut(C2
 ,NumPut(C2,NumPut(C1,NumPut(C2,NumPut(C2,NumPut(C2,NumPut(C2,&B$+40)-1)-1)+2)-1)-1)+2)-1)
 -1):G=4 ? NumPut(C2,NumPut(C1,NumPut(C2,NumPut(C2,NumPut(C1,NumPut(C2,NumPut(C2,NumPut(C1
 ,NumPut(C2,&B$+40)-1)-1)+2)-1)-1)+2)-1)-1) :G=5 ? NumPut(C2,NumPut(C2,NumPut(C2,NumPut(C1
 ,NumPut(C1,NumPut(C1,NumPut(C2,NumPut(C2,NumPut(C2,&B$+40)-1)-1)+2)-1)-1)+2)-1)-1) : 0
 ; Obtain GDI Bitmap
 hBM := DllCall( "CreateDIBitmap", UInt, hDC := DllCall( "GetDC", UInt,cHwnd   ), UInt,&B$
      , Int,6, UInt,&B$+40, UInt,&B$, UInt,1 ), DllCall( "ReleaseDC", UInt,hDC )
 ; Obtain Resized GDI Bitmap / Obtain a copy with DIB section
 hBM := DllCall( "CopyImage", UInt,hBM, UInt,0, Int,W, Int,H, UInt,0x8, UInt )
 Return DllCall( "CopyImage", UInt,hBM, UInt,0, Int,0, Int,0, UInt,0x2000|0x8, UInt )
}

/*

The following five files were created in imaging software and used as reference in writing
CreateGradientBitmap().

Vertical Linear.bmp ( 2x2 24bpp, 70 Bytes )
BITMAPFILEHEADER: 424D460000000000000036000000
BITMAPINFOHEADER: 28000000020000000200000001001800000000001000000000000000000000000000000000000000
BITMAP Data     : 563412 563412 0000 EFCDAB EFCDAB 0000

Horizontal Linear.bmp ( 2x2 24bpp, 70 Bytes )
BITMAPFILEHEADER: 424D460000000000000036000000
BITMAPINFOHEADER: 28000000020000000200000001001800000000001000000000000000000000000000000000000000
BITMAP Data     : EFCDAB 563412 0000 EFCDAB 563412 0000

Sunburst.bmp ( 3x3 24bpp, 90 Bytes )
BITMAPFILEHEADER: 424D5A0000000000000036000000
BITMAPINFOHEADER: 28000000030000000300000001001800000000002400000000000000000000000000000000000000
BITMAP Data     : 563412 563412 563412 000000 563412 EFCDAB 563412 000000 563412 563412 563412 000000

Horizontal Bi-Linear.bmp ( 3x3 24bpp, 90 Bytes )
BITMAPFILEHEADER: 424D460000000000000036000000
BITMAPINFOHEADER: 28000000030000000300000001001800000000002400000000000000000000000000000000000000
BITMAP Data     : 563412 EFCDAB 563412 000000 563412 EFCDAB 563412 000000 563412 EFCDAB 563412 000000

Vertical Bi-Linear.bmp ( 3x3 24bpp, 90 Bytes )
BITMAPFILEHEADER: 424D460000000000000036000000
BITMAPINFOHEADER: 28000000030000000300000001001800000000002400000000000000000000000000000000000000
BITMAP Data     : 563412 563412 563412 000000 EFCDAB EFCDAB EFCDAB 000000 563412 563412 563412 000000

Note1 : BITMAPFILEHEADER is not required for CreateDIBitmap() and hence omitted from code.
Note2 : Reference for .bmp file format : www.fortunecity.com/skyscraper/windows/364/bmpffrmt.html
