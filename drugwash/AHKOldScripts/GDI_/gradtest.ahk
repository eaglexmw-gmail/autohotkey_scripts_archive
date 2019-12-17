#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
IfNotExist, bkg.bmp
 URLDownloadToFile, http://www.autohotkey.net/~Drugwash/pics/bkg.bmp, bkg.bmp

himl := DllCall( "ImageList_LoadImage"
                , UInt,0, Str,"bkg.bmp", Int,5, Int,1, Int,-1, Int,0, UInt,0x2010 )
Gui, Add, Picture, w132 h132 0xE hwndhStatic1
Gui, Show

Loop % DllCall( "ImageList_GetImageCount", UInt,himl ) {
  hBM := IL_GetBitmap( himl, A_Index-1, 132, 132 )
  oBM := DllCall( "SendMessage", UInt,hStatic1, UInt,0x172, UInt, 0, UInt,hBM )
  DllCall( "DestroyObject", UInt,oBM )
  Sleep 1000
}

Return                                               ; // end of auto-execute section //


IL_GetBitmap( himl, i=0, nw=0, nh=0 ) { ;                       By SKAN  CD: 01-Aug-2011
; Topic/Post : www.autohotkey.com/forum/viewtopic.php?p=461418#461418
 DllCall( "ImageList_GetIconSize", UInt,himl, IntP,cW, IntP,cH )
 tDC := DllCall( "CreateCompatibleDC", Int,0 )
 tBM := DllCall( "CopyImage", UInt,DllCall( "CreateBitmap", Int,cW, Int,cH, UInt,1, UInt
                  ,24, UInt,0 ), UInt,0, Int,0, Int,0, UInt,0x2008, UInt )
 DllCall( "SelectObject", UInt,tDC, UInt,tBM )
 DllCall( "ImageList_Draw", UInt,himl, Int,i, UInt,tDC, Int,0, Int,0, Int,0 )
 DllCall( "DeleteDC", UInt,tDC )
 Return ( nW|nH = 0 )
     ? tBM : DllCall( "CopyImage", UInt,tBM, UInt,0, Int,nW, Int,nH, UInt,0x2008, UInt )
}
