; IconEx v0.9 by SKAN ( arian.suresh@gmail.com )  ||   Created/Last Modified : 13-May-2008

#SingleInstance, Force
SetWorkingDir %A_ScriptDir%  
SetBatchLines, -1

Folder := A_WinDir, FileCount := 0, IGCount := 0
IfNotExist, % ( Deff := A_ScriptDir "\~Icons" ), FileCreateDir, %Deff% 
CallB  := RegisterCallback( "EnumResNameProc" ) 
 
EnumResNameProc( hModule, lpszType, lpszName, lParam ) { 
 Global IconGroups, IGCount 
 IconGroups .= ( ( IconGroups!="" ) ? "|" : "" ) . lpszName , IGCount:=IGCount+1  
 Return True 
} 

Gui, Font, S10 Bold, Courier New
Gui, Add, Text, x7 y7 w769 h20 0x4 +Border gSelectFolder
Gui, Add, Text, xp+6 yp w666 h20 cFEFEFA 0x200 BackgroundTrans vFolder, %Folder%
Gui,Font, s8 Normal, Tahoma
Gui, Add, ListView, x7 y+5 h350 w235 -Theme -E0x200 +0x4 +0x8 +Border vLVR gLVR  
                   +BackGroundFFFFFA c444466, Resource File|Icons|IG
LV_ModifyCol( 1 ,"170" ), LV_ModifyCol( 2, "42 Integer" ), LV_ModifyCol( 3, "0" )
Gui, Add, ListView, x+0 yp h350 w533 -Theme +Icon -E0x200 +0x100 
                   +BackGroundFFFFFC cBB2222 Border vLVI gLVI hwndLVC2 
Gui, Add, Text, x7 y+74 w1 h1
Loop 12 {
   Gui, Add, Text,x+0 yp-64 0x1203 w64 h64 vI%A_Index% hWndIcon%A_Index% gCreateSimpleIcon
   Gui, Add, Text, xp  yp+64 0x1201 w64 h16 vIconT%A_Index%, -
}  Gui,Font
Gui, Add, StatusBar, vSB gSelectFile
SB_SetParts( 50 )
Gui, Show, w782, IconEx - v0.9
GoSub, UpdateResourceList
Return                                                 ; // end of auto-execute section //

UpdateResourceList:
 GuiControlGet, Folder
 Gui, ListView, LVI
 LV_Delete()
 Gui, ListView, LVR
 LV_Delete(), , SB_SetText( "  Loading files.. Please wait" , 2 )
 Loop, %Folder%\*.*  {
  If A_LoopFileExt Not in EXE,DLL,CPL
     Continue
  hModule := DllCall( "LoadLibraryEx", Str,A_LoopFileLongPath, UInt,0, UInt,0x2 )
  IfEqual,hModule,0,Continue
  IGCount:=0, IconGroups := "", FileCount:=FileCount+1
  DllCall("EnumResourceNamesA", UInt,hModule, UInt,(RT_GROUP_ICON:=14), UInt,CallB,UInt,0)
  DllCall( "FreeLibrary", UInt,hModule )
  IfEqual,IGCount,0, Continue
  FileName := DllCall( "CharUpperA", Str,A_LoopFileName, Str )
  LV_ADD( "", FileName, IGCount, IconGroups )
  SB_SetText( "`t" FileCount, 1 ), 
} SB_SetText( "  Done!" , 2 ) 
Return

LVR:
 RowNo := A_EventInfo
 Gui, ListView, LVR
 LV_GetText( File, RowNo,1 ), LV_GetText( IGC, RowNo,2 ), LV_GetText( IG, RowNo,3 )
 If GetKeyState( "LControl", "P" ) {
     IfGreater,RowNo,0,SetTimer, ExtractIconRes, -1
     Return
 }  Gui, ListView, LVI
 LV_Delete()
 ImageListID ? IL_Destroy( ImageListID ) :
 ImageListID := IL_Create( 10,10,1 ), LV_SetImageList(ImageListID)
 Loop, %IGC%
    IL_Add(ImageListID, Folder "\" File, A_Index )
 Loop, Parse, IG, |
    LV_Add("Icon" . A_Index, A_LoopField )
 Gui, ListView, LVR
Return

LVI:
 RowNo := A_EventInfo
 Gui, ListView, LVI
 LV_GetText( IconGroup, RowNo,1 )
 If GetKeyState( "LControl", "P" ) {
     IfGreater,RowNo,0,SetTimer, ExtractIcon, -1
     Return
} hMod := DllCall( "LoadLibraryEx", Str,Folder "\" File, UInt,0, UInt,0x2 )
  Buff := GetResource( hMod, IconGroup, (RT_GROUP_ICON:=14), nSize, hResData ) 
  Icos := NumGet( Buff+4, 0, "UShort" ), Buff:=Buff+6 

  Loop, %Icos% { 
      W   := NumGet( Buff+0,0,"UChar" ),   H   := NumGet( Buff+0,1,"UChar" )
      BPP := NumGet( Buff+0,6,"UShort"),   nID := NumGet( Buff+0,12,"UShort")
      IfEqual,W,0,Continue
      Buff+=14
      IconD  := GetResource( hMod, nID, (RT_ICON:=3), nSize, hResData )
      hIcon  := DllCall( "CreateIconFromResourceEx", UInt,IconD, UInt,BPP, Int,1 
                        , UInt, 0x00030000, Int,W, Int,H, UInt,(LR_SHARED := 0x8000) )
      SendMessage, ( STM_SETIMAGE:=0x172 ), 0x1, hIcon,, % "ahk_id " Icon%A_Index% 
      DllCall( "FreeResource", UInt,hResData ) 
      GuiControl,,IconT%A_Index%, % W "x" H "-" BPP "b"  
} Loop % 12-Icos {
      Ix := Icos+A_Index
      GuiControl,,IconT%Ix%, -      
      SendMessage, ( STM_SETIMAGE:=0x172 ), 0x1, 0,, % "ahk_id " Icon%Ix%
} DllCall( "FreeResource", UInt,hResData ), DllCall( "FreeLibrary", UInt,hModule )
Return

GetResource( hModule, rName, rType, ByRef nSize, ByRef hResData ) { 
 hResource := DllCall( "FindResource", UInt,hModule, UInt,rName, UInt,rType ) 
 nSize     := DllCall( "SizeofResource", UInt,hModule, UInt,hResource ) 
 hResData  := DllCall( "LoadResource", UInt,hModule, UInt,hResource ) 
 Return DllCall( "LockResource", UInt, hResData ) 
}

ExtractIconRes:
 TargetFolder := A_ScriptDir "\" File "\"
 MsgBox, 262145, Extract Icon Resources from %File% ?
           , %IGC% Icons will be extracted to`n`n%TargetFolder% 
 IfMsgBox, Cancel, Return
 IfNotExist, %TargetFolder%, FileCreateDir, %TargetFolder% 
 hModule := DllCall( "LoadLibraryEx", Str,Folder "\" File, UInt,0, UInt,0x2 )
 
 Loop, Parse, IG, | 
 { 
   FileN := SubStr( "000" A_Index, -3 ) "-" SubStr( "00000" A_LoopField, -4 ) ".ico"
   SB_SetText( (FileN := TargetFolder . FileN), 2 ), IconGroup := A_LoopField
   GoSub, WriteIcon
 } 
 DllCall( "FreeLibrary", UInt,hModule ), SB_SetText( IGC " Icons extracted!", 2 )
 DllCall( "Sleep", UInt,1000 ), SB_SetText( TargetFolder, 2 )
Return

ExtractIcon:
 TargetFolder := A_ScriptDir "\" File "\"
 FileN := TargetFolder "IG" SubStr( "-00000" IconGroup, -4 ) ".ICO"  
 MsgBox, 262145, Extract Icon Group %IconGroup% from %File% ?
           , Icon will be created as`n`n%FileN% 
 IfMsgBox, Cancel, Return
 IfNotExist, %TargetFolder%, FileCreateDir, %TargetFolder% 
 hModule := DllCall( "LoadLibraryEx", Str,Folder "\" File, UInt,0, UInt,0x2 )
 GoSub, WriteIcon
 DllCall( "FreeLibrary", UInt,hModule ), SB_SetText( FileN, 2 )
Return

WriteIcon:
 hFile := DllCall( "_lcreat", Str,FileN, UInt,0 )
 sBuff := GetResource( hModule, IconGroup, (RT_GROUP_ICON:=14), nSize, hResData ) 
 Icons := NumGet( sBuff+0, 4, "UShort" ) 
 tSize := nSize+( Icons*2 ), VarSetCapacity( tmpBuff,tSize, 0 ), tBuff := &tmpBuff 
 CopyData( sBuff, tBuff, 6  ),   sBuff:=sBuff+06,  tBuff:=tBuff+06 
 Loop %Icons% 
      CopyData( sBuff, tBuff, 14  ),  sBuff:=sBuff+14,  tBuff:=tBuff+16 
 DllCall( "FreeResource", UInt,hResData ) 
 DllCall( "_lwrite", UInt,hFile, Str,tmpBuff, UInt,tSize ) 
 EOF := DllCall( "_llseek", UInt,hFile, UInt,-0, UInt,2 ) 
 VarSetCapacity( tmpBuff, 0 ) 
 DataOffset := DllCall( "_llseek", UInt,hFile, UInt,18, UInt,0 ) 

 Loop %Icons% {
   VarSetCapacity( Data,4,0 ) 
   DllCall( "_lread", UInt,hFile, Str,Data, UInt,2 ), 
   nID := NumGet( Data, 0, "UShort" ) 
   DllCall( "_llseek", UInt,hFile, UInt,-2, UInt,1 ) 
   NumPut( EOF, Data ),  DllCall( "_lwrite", UInt,hFile, Str,Data, UInt,4 ) 
   DataOffset := DllCall( "_llseek", UInt,hFile, UInt,0, UInt,1 ) 
   sBuff := GetResource( hModule, nID, (RT_ICON:=3), nSize, hResData )    
   DllCall( "_llseek", UInt,hFile, UInt,0, UInt,2 )          
   DllCall( "_lwrite", UInt,hFile, UInt,sBuff, UInt,nSize ) 
   DllCall( "FreeResource", UInt,hResData ) 
   EOF := DllCall( "_llseek", UInt,hFile, UInt,-0, UInt,2 ) 
   DataOffset := DllCall( "_llseek", UInt,hFile, UInt,DataOffset+12, UInt,0 ) 
}  DllCall( "_lclose", UInt,hFile ) 
Return

CreateSimpleIcon:
 StringTrimLeft,FNo,A_GuiControl,1
 GuiControlGet, IconT%fNo%
 If ( (IconT := IconT%fNo%) = "-" )
    Return
 FileN := Deff "\" File " [" SubStr("0000" IconGroup, -4 ) 
        . "-" SubStr( "0" FNo,-1) . "][ " IconT "].ICO"
 If ! GetKeyState( "LControl", "P" )
      MsgBox, 262145, Extract Icon %fno% from IconGroup %IconGroup% of %File% ?
                    , Icon will be created as %FileN% 
 IfMsgBox, Cancel, Return
 hModule := DllCall( "LoadLibraryEx", Str,Folder "\" File, UInt,0, UInt,0x2 )
 Buffer := GetResource( hModule, IconGroup, (RT_GROUP_ICON:=14), nSize, hResData )
 tBuff := Buffer+6+((Fno-1)*14), nID := Numget( tBuff+0, 12, "Ushort" )
 VarSetCapacity(Z,10,0), NumPut(1,Z,2,"UChar"), NumPut(1,Z,4,"UChar" ),NumPut(22,Z,6)
 SBuff := GetResource( hModule, nID, (RT_ICON:=3), nSize, hResData )
 hFile := DllCall( "_lcreat", Str,FileN, UInt,0 )
 DllCall( "_lwrite", UInt,hFile, Str,Z, UInt,6 )
 DllCall( "_lwrite", UInt,hFile, UInt,tbuff, UInt,12 ) 
 DllCall( "_lwrite", UInt,hFile, UInt,&Z+6, UInt,4 )
 DllCall( "FreeResource", UInt,hResData )
 Buff := GetResource( hModule, nID, (RT_ICON:=3), nSize, hResData )
 DllCall( "_lwrite", UInt,hFile, UInt,Buff, UInt,nSize )
 DllCall( "_lclose", UInt,hFile ) 
 DllCall( "FreeResource", UInt,hResData ),  DllCall( "FreeLibrary", UInt,hModule )
 SB_SetText( FileN, 2 )
Return

SelectFile:
 StatusBarGetText, SB, 2, A
 IfExist, %SB%, Run, %COMSPEC% /c "Explorer /select`, %SB%",,Hide
Return

SelectFolder:
 FileSelectFolder, nFolder, *%Folder%, , Select a Resource Folder
 IfEqual,nFolder,,Return
 GuiControl,,Folder, %nFolder%
 GoSub, UpdateResourceList
Return

CopyData( SPtr, TPtr, nSize ) { 
 Return DllCall( "RtlMoveMemory", UInt,TPtr, UInt,SPtr, UInt,nSize ) 
}    
GuiClose:
 ExitApp