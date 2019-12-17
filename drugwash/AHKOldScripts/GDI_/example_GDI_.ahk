tBMP := GDI_CreateGradientBitmap( 3, "DAFCDC", "1C8431", 256, 256 )
hBMP := GDI_CropBitmap( tBMP, 128, 128, 128, 128 )
DllCall( "DeleteObject", UInt,tBMP )

Gui +ToolWindow
Gui, Add, Picture, w256 h256 0x20E hwndcHwnd2
Gui, Add, Picture, w128 h128 0x20E hwndcHwnd
DllCall( "SendMessage", UInt,cHwnd2, UInt,0x172, UInt,0, UInt,tBMP ) ; STM_SETIMAGE
DllCall( "SendMessage", UInt,cHwnd, UInt,0x172, UInt,0, UInt,hBMP ) ; STM_SETIMAGE
Gui, Font, S90 Bold, Arial Black
Gui, Add, Text, xp yp wp hp c005900 BackgroundTrans 0x201, H
Gui, Add, Text, xp-3 yp-3 wp hp cF8FCF8 BackgroundTrans 0x201, H
Gui, Show,, % " Diagonal Gradient"
WinWaitActive, % " Diagonal Gradient"
cBM := GDI_cHDCtoBitmap( cHwnd )
GDI_SaveBitmap( cBM, "ahk.bmp" )
DllCall( "DeleteObject", UInt,cBM )
Return


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

GDI_CropBitmap( hbm, x, y, w, h ) {                               ; By SKAN LM:28-Jun-2010
 ; This post : www.autohotkey.com/forum/viewtopic.php?p=425387#425387
 hdcSrc  := DllCall( "CreateCompatibleDC", UInt,0 )
 hdcDst  := DllCall( "CreateCompatibleDC", UInt,0 )
 VarSetCapacity( bm,24,0 ) ; BITMAP Structure
 DllCall( "GetObject", UInt,hbm, UInt,24, UInt,&bm )
 hbmOld  := DllCall( "SelectObject", UInt,hdcSrc, UInt,hbm )
 hbmNew  := DllCall( "CreateBitmap", Int,w, Int,h, UInt,NumGet( bm,16,"UShort" )
                    , UInt,NumGet( bm,18,"UShort" ), Int,0 )
 hbmOld2 := DllCall( "SelectObject", UInt,hdcDst, UInt,hbmNew )
 DllCall( "BitBlt", UInt,hdcDst, Int,0, Int,0, Int,w, Int,h
                  , UInt,hdcSrc, Int,x, Int,y, UInt,0x00CC0020 )
 DllCall( "SelectObject", UInt,hdcSrc, UInt,hbmOld )
 DllCall( "DeleteDC",  UInt,hdcSrc ),   DllCall( "DeleteDC",  UInt,hdcDst )
Return DllCall( "CopyImage", UInt,hbmNew, UInt,0, Int,0, Int,0, UInt,0x2008, UInt )
}

GDI_cHDCtoBitmap( hwnd )   {  ; By SKAN  www.autohotkey.com/forum/viewtopic.php?t=35242
 ControlGetPos,,,W,H,, ahk_id %hwnd%
 tDC := DllCall( "CreateCompatibleDC", UInt,0 )
 hBM := DllCall( "CopyImage", UInt,DllCall( "CreateBitmap", Int,W, Int,H, UInt,1, UInt,24
                            , UInt,0 ), UInt,0, Int,0, Int,0, UInt,0x2008, UInt )
 oBM := DllCall( "SelectObject", UInt,tDC, UInt,hBM ), hDC := DllCall( "GetDC", Int,hwnd )
 DllCall( "BitBlt",  UInt,tDC, Int64,0, Int,W, Int,H, UInt,hDC, Int64,0, UInt,0x00CC0020 )
 DllCall( "ReleaseDC", UInt,0, UInt,hDC ),   DllCall( "SelectObject", UInt,tDC, UInt,oBM )
 Return hBM, DllCall( "DeleteDC", UInt,tDC )
}

GDI_SaveBitmap( hBM, File ) {  ; By SKAN    www.autohotkey.com/forum/viewtopic.php?t=35242
 DllCall( "GetObject", Int,hBM, Int,VarSetCapacity($,84), UInt,NumPut(0,$,40,"Short")-42 )
 Numput( VarSetCapacity(BFH,14,0)+40, Numput((NumGet($,44)+54),Numput(0x4D42,BFH)-2)+4 )
 If ( hF := DllCall( "CreateFile", Str,File,UInt,2**30,UInt,2,Int,0,UInt,2,Int64,0 ) ) > 0
   DllCall( "WriteFile", UInt,hF, UInt,&BFH,  UInt,14, IntP,0,Int,0 ) ; BITMAPFILEHEADER
 , DllCall( "WriteFile", UInt,hF, UInt,&$+24, UInt,40, IntP,0,Int,0 ) ; BITMAPINFOHEADER
 , DllCall( "WriteFile", UInt,hF, UInt,NumGet($,20), UInt,NumGet($,44), UIntP,BW, Int,0 )
 , DllCall( "CloseHandle", UInt,hF )
Return BW ? 54+BW : 0
}
