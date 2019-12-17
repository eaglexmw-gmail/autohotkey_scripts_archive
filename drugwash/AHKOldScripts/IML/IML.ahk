;   ___  __  __  _
;  |_ _||  \/  || |           A collection of standalone functions to Save/Load ImageLists
;   | | | |\/| || |                     by SKAN - Suresh Kumar A N, arian.suresh@gmail.com
;   | | | |  | || |___               Topic: www.autohotkey.com/forum/viewtopic.php?t=72282
;  |___||_|  |_||_____|                                Wrapper Last Updated : 11 June 2011
;
;  Functions  : IML_Save() / IML_Load() / IML_LoadRes() / IML_SaveAsBMP()
;  IML Viewer : www.autohotkey.net/~Skan/Scripts/IMLViewer/IMLViewer.zip
;_________________________________________________________________________________________


IML_Save( File, himl ) {         ; by SKAN  www.autohotkey.com/forum/viewtopic.php?t=72282
 SplitPath, File,,,Ext
 Off := ( Ext = "BMP" ) ? 28 : 0
 DllCall( "ole32\CreateStreamOnHGlobal", UInt,0, Int,1, UIntP,pStream ) ;  CD: 24-May-2011
 DllCall( "ImageList_Write", UInt,himl, UInt,pStream )                  ;  LM: 03-Jun-2011
 DllCall( "ole32\GetHGlobalFromStream", UInt,pStream, UIntP,hData )
 pData := DllCall( "GlobalLock", UInt,hData )
 nSize := DllCall( "GlobalSize", UInt,hData )
 If ( hF := DllCall( "CreateFile", Str,File, UInt,0x40000000, UInt,2
                    , Int,0, UInt,2, Int,0, Int,0 ) ) > 0
   Bytes := DllCall( "_lwrite", UInt,hF, UInt,pData+Off, UInt,nSize-Off )
         ,  DllCall( "CloseHandle",UInt,hF )
 DllCall( "GlobalUnlock", UInt,hData )
 DllCall( NumGet( NumGet( 1*pStream ) + 8 ), UInt,pStream )
 DllCall( "GlobalFree",   UInt,hData )
Return Bytes > 0 ? Bytes : 0
}


IML_Load( File ) {               ; by SKAN  www.autohotkey.com/forum/viewtopic.php?t=72282
 If ( hF := DllCall( "CreateFile", Str,File, UInt,0x80000000, UInt,3    ;  CD: 24-May-2011
                    , Int,0, UInt,3, Int,0, Int,0 ) ) < 1               ;  LM: 25-May-2011
 || ( nSiz := DllCall( "GetFileSize", UInt,hF, Int,0, UInt ) ) < 1
  Return ( ErrorLevel := 1 ) >> 64,  DllCall( "CloseHandle",UInt,hF )
 hData := DllCall("GlobalAlloc", UInt,2, UInt,nSiz )
 pData := DllCall("GlobalLock",  UInt,hData )
 DllCall( "_lread", UInt,hF, UInt,pData, UInt,nSiz )
 DllCall( "GlobalUnlock", UInt,hData ), DllCall( "CloseHandle",UInt,hF )
 DllCall( "ole32\CreateStreamOnHGlobal", UInt,hData, Int,True, UIntP,pStream )
 himl := DllCall( "ImageList_Read", UInt,pStream )
 DllCall( NumGet( NumGet( 1*pStream ) + 8 ), UInt,pStream )
 DllCall( "GlobalFree", UInt,hData )
Return himl
}


IML_LoadRes( File, Ord="" ) {    ; by SKAN  www.autohotkey.com/forum/viewtopic.php?t=72282
 IfNotExist, %File%, Return ( ErrorLevel := 1 ) >> 64                   ;  CD: 24-May-2011
 If ! hMod := DllCall( "GetModuleHandle", Str,File, UInt )
 If ! hMod := DllCall( "LoadLibraryEx", Str,File, Int,0, UInt,0x2, UInt )
   Return ( ErrorLevel := 2 ) >> 64
 hRes  := DllCall( "FindResource",  UInt,hMod, UInt,Ord, UInt,10 )
 hDat  := DllCall( "LoadResource",  UInt,hMod, UInt,hRes )
 pDat  := DllCall( "LockResource",  UInt,hDat )
 nSiz  := DllCall( "SizeofResource",UInt,hMod, UInt,hRes )
 IfLess,nSiz,1, Return ( ErrorLevel := 3 ) >> 64
 hData := DllCall("GlobalAlloc", UInt,2, UInt,nSiz )
 pData := DllCall("GlobalLock",  UInt,hData )
 DllCall( "RtlMoveMemory", UInt,pData, UInt,pDat, UInt,nSiz )
 DllCall( "GlobalUnlock", UInt,hData ), DllCall( "FreeLibrary", UInt,hMod )
 DllCall( "ole32\CreateStreamOnHGlobal", UInt,hData, Int,True, UIntP,pStream )
 himl := DllCall( "ImageList_Read", UInt,pStream )
 DllCall( NumGet( NumGet( 1*pStream ) + 8 ), UInt,pStream )
 DllCall( "GlobalFree", UInt,hData )
Return himl
}


IML_SaveAsBMP( File, himl, Alpha=1 ) { ; by SKAN
 ; Topic: www.autohotkey.com/forum/viewtopic.php?t=72282 | CD:09-Jun-2011 / LM:11-Jun-2011
 DllCall( "ImageList_GetIconSize", UInt,himl, IntP,W, IntP,TH )
 TW := W * ( Imgs := DllCall( "ImageList_GetImageCount", UInt,himl ) )
 hBM := DllCall( "CopyImage", UInt,DllCall( "CreateBitmap", Int,TW, Int,TH, UInt,1, UInt
                 ,Alpha ? 32 : 24, UInt,0 ), UInt,0, Int,0, Int,0, UInt,0x2000|0x8, UInt )
 DllCall( "SelectObject", UInt,Hdc := DllCall("CreateCompatibleDC",Int,0), UInt,hBM )
 Loop % ( Imgs + ( X:=0 ) )
  DllCall( "ImageList_Draw", UInt,himl, Int,A_Index-1,UInt,Hdc,Int,X,Int,0,Int,0 ), X:=X+W
 DllCall( "DeleteDC", UInt,Hdc )
 DllCall( "GetObject", UInt,hBM, Int,VarSetCapacity( DIB,84,0 ), UInt,&DIB )
 Numput( VarSetCapacity(BFH,14,0)+40, Numput((NumGet(DIB,44)+54),Numput(0x4D42,BFH)-2)+4 )
 If ( hF := DllCall( "CreateFile", Str,File,UInt,2**30,UInt,2,Int,0,UInt,2,Int64,0 ) ) > 0
   DllCall( "WriteFile", UInt,hF, UInt,&BFH,    UInt,14, IntP,0,Int,0 ) ; BITMAPFILEHEADER
 , DllCall( "WriteFile", UInt,hF, UInt,&DIB+24, UInt,40, IntP,0,Int,0 ) ; BITMAPINFOHEADER
 , DllCall( "WriteFile", UInt,hF, UInt,NumGet(DIB,20), UInt,NumGet(DIB,44), IntP,0,Int,0 )
 , DllCall( "CloseHandle", UInt,hF )
Return hBM
}
