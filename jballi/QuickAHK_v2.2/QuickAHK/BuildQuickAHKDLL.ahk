;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   ;
;                                                                                        ;
;          Title        :  Script to Automate creation of Resource only DLL              ;
;          Author       :  SKAN - Suresh Kumar A N ( arian.suresh@gmail.com )            ;
;          Date         :  Created: 21-May-2008   |   Last Modified: 01-Jun-2008         ;
;                                                                                        ;
;          Forum link   :  http://www.autohotkey.com/forum/viewtopic.php?t=30228         ;
;          This file    :  http://www.autohotkey.net/~Skan/Scripts/RoD/ROD-Ex.ahk        ;
;          
;           Minor modifications by jballi to customize this script for the
;           QuickAHK project.
;                                                                                        ;
;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   ;

#SingleInstance, Force      
SetBatchLines, -1        
SetWorkingDir, %A_ScriptDir%


;[===========]
;[  Confirm  ]
;[===========]
MsgBox
    ,49     ;-- 49 = 1 (OK/Cancel buttons) + 48 ("!" icon)
    ,Confirm Build,
       (ltrim join`s
        This script will create 'QuickAHK.dll', a resource DLL created from
        icon files in the '_Resource' folder.  %A_Space%
        `n`nPress OK to continue.  %A_Space%
       )

IfMsgBox Cancel
    return


;----------------------------------------------------------------------------------------- 
; *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  CONFIGURATION SECTION
;-----------------------------------------------------------------------------------------

ResFolder     := A_WorkingDir . "\_Resource"          ; The folder where resources reside
FileSizeLimit := ( 1024*1024*16 )                     ; 16 MB limit for a single resource
; The following target resource file will be placed/created in script's working folder

ResourceFile:="QuickAHK.dll"

IxIcoN := 1000                                        ;  Ordinal Counter for RT_ICON
IxIcoG := 5000                                        ;  Ordinal Counter for RT_ICON_GROUP
IxBitM := 6000                                        ;  Ordinal Counter for RT_BITMAP
IxRDat := 9000                                        ;  Ordinal Counter for RT_RCDATA 

;-----------------------------------------------------------------------------------------
; *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *
;-----------------------------------------------------------------------------------------


Loop, %ResFolder%\*.*,0,1                             ; Prepare a list of resource files
  {
      If ( InStr(FileExist(A_LoopFileFullPath),"H" ) )
         Continue 
      If A_LoopFileExt in EXE,DLL,CUR,ANI,ICL,BAK
         Continue

      FileGetSize, FileSize, %A_LoopFileLongPath%
      IfGreater, FileSize, %FileSizeLimit%, Continue
     
      ResFiles .= ( A_Index=1 ? "" : "`n" ) . SubStr( A_LoopFileExt "   ",1,3 )
               .  "|" A_LoopFileLongPath  
  }

IfEqual,ResFiles,, Return                           ; no files .. no joy!                              
Sort, ResFiles, D`n                                 ; Sort file list in alphabetical order  

If (ResourceFile="AutoHotkeySC.bin")
  {
     SplitPath,A_AhkPath,,A_AhkDir
     FileCopy, %A_AhkDir%\Compiler\AutoHotkeySC.bin, %A_WorkingDir%\AutoHotkeySC.bin, 1
     MsgBox, % Errorlevel
     IfNotExist, %A_WorkingDir%\AutoHotkeySC.bin, SetEnv,ResourceFile,resource.dll
  }
IfNotEqual,ResourceFile,AutoHotkeySC.bin,SetEnv,ResourceFile, % CreateDLL(ResourceFile) 

FileIO16_Init()  ; Requires  http://www.autohotkey.net/~Skan/wrapper/FileIO16/FileIO16.ahk

hUpdate := DllCall( "BeginUpdateResourceA", Str,ResourceFile, Int,0 )
Loop, Parse, ResFiles, `n
     {
        StringSplit, fPart, A_LoopField, |
        Ext := fPart1, SourceFile := fPart2
    
        If ( Ext = "ICO" )
             GoSub,RT_ICON
        Else  
        If ( Ext = "BMP" )
             GoSub,RT_BITMAP

        Else GoSub,RT_RCDATA
     }
DllCall( "EndUpdateResourceA", UInt,hUpdate, Int,0 )

; ----------------------------------------------------------------------------------------

Return ;                                           * *  end of auto-execute section * *
;_________________________________________________________________________________________
;   ----------------------------------------------------------------------------------- 



RT_BITMAP:
  FileGetSize, nSize, %SourceFile%
  cbData := FileReadEx( SourceFile, lpData, nSize-14, 14  )    ; skipping first 14 bytes
  DllCall( "UpdateResourceA", UInt,hUpdate
                            , UInt,2                           ; RT_BITMAP := 2           
                            , UInt,IxBitM
                            , UInt,0x0409                      ; LANG_NEUTRAL := 0
                            , UInt,&lpData, UInt,cbData )
  IxBitM += 1
Return                                       ; Increment the Ordinal counter for RT_BITMAP



RT_RCDATA:
  FileGetSize, nSize, %SourceFile%
  cbData := FileReadEx( SourceFile, lpData, nSize, 0 )   

  DllCall( "UpdateResourceA", UInt,hUpdate
                            , UInt,10                          ; RT_RCDATA := 10
                            , UInt,IxRDat
                            , UInt,0x0409                      ; LANG_NEUTRAL := 0
                            , UInt,&lpData, UInt,cbData )

  IxRDat += 1                                ; Increment the Ordinal counter for RT_RCDATA
Return



RT_ICON:
  hFile := FOpen( SourceFile, F_READ )                     ; Open ICO file
  FRead( hFile, IconHdr, 6 )                               ; Read header. First 6 bytes
  IconCount := NumGet( IconHdr,4, "UShort" )               ; Extract Icon Count for Header
  
  ; Create empty ICONGROUPDATA structure to hold RT_GROUP_ICON data 
  ; Header requires 6 bytes + GRPICONDIRENTRY is 14 bytes for each Icon
  VarSetCapacity( IconGroupData, ( ICGS := 6+(IconCount*14 ) ) )
  
  MemCopy( &IconHdr, &IconGroupData, 6 ) ; Copy header into ICONGROUPDATA structure 
  pICGD := &IconGroupData + 6            ; Increment the pointer to ICONGROUPDATA


  /*

  GRPICONDIRENTRY in a resource is much similar to ICONDIRENTRY of .ICO except:
    - GRPICONDIRENTRY is 14 bytes long the last two bytes contain RT_ICON ordinal
    - ICONDIRENTRY is 16 bytes long and last four bytes would contain file offset to data

  Therefore to add a .ICO as ICON resource:
    - Read .ICO and translate ICONDIRENTRY into GRPICONDIRENTRY
    - Read and Update each ICONIMAGE as a seperate RT_ICON Ordinal
    - Update ICONGROUPDATA ( Header + array of GRPICONDIRENTRY ) as a single RT_GROUP_ICON
     
  */     
  

  Loop %IconCount% 
   {
     FRead( hFile,ICGD,16 )              ; Read ICONDIRENTRY of .ICO into ICGD
     IDS := NumGet( ICGD,08 )            ; Get IconData Size from ICONDIRENTRY 
     IDO := NumGet( ICGD,12 )            ; Get IconData Offset from ICONDIRENTRY
     NumPut( IxIcoN,ICGD,12 )            ; Put RT_ICON ordinal into ICONDIRENTRY
     MemCopy( &ICGD, pICGD, 14 )         ; Copy ICONDIRENTRY into ICONGROUPDATA
     pICGD += 14                         ; Increment the pointer to ICONGROUPDATA
     
     CPF := FSeek( hFile, 0, F_CPF )     ; save the current position of file pointer 
     FSeek( hFile, IDO, F_BOF )          ; Seek IconData offset from beginning of file
     FRead( hFile, ICD, IDS )            ; Read ICONIMAGE into ICD 
     FSeek( hFile, CPF, F_BOF )          ; move the file pointer to the previous position

     ; The following adds ICONIMAGE as RT_ICON in resource
     DllCall( "UpdateResourceA", UInt,hUpdate
                               , UInt,3                        ; RT_ICON := 3           
                               , UInt,IxIcoN
                               , UInt,0x0409                   ; LANG_NEUTRAL := 0
                               , UInt,&ICD, UInt,IDS )
     IxIcoN += 1                         ; Increment the Ordinal counter for RT_ICON
   }  

  FClose( hFile )                        ; Close the .ICO file
  
  ; The following adds GRPICONDIRENTRY as RT_GROUP_ICON in resource
  DllCall( "UpdateResourceA", UInt,hUpdate
                            , UInt,14                          ; RT_GROUP_ICON := 14           
                            , UInt,IxIcoG 
                            , UInt,0x0409                      ; LANG_NEUTRAL := 0
                            , UInt,&IconGroupData, UInt,ICGS )
                               
  IxIcoG += 1                          ; Increment the Ordinal counter for RT_GROUP_ICON
Return

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CreateDLL( file="empty.dll" ) {                       ; Creates an empty DLL sized @ 2.5K

hex := "4D5A9X3U4VFFFFXB8N4KLMFF8BX8TE1FBA0EZB409CD21B8014CCD214175746F486F746B6579205363" 
. "72697074696E67204C616E67756167652C205265736F757263652D6F6E6C7920444C4C2E245045X4C0103L" 
. "REXE210B0103W2U2N2U2U1Q1Y1T2W4U1U4L4T4O2Y3V1W1S1LY1JLS3VCIKV2E64617461U4T1T2U4LP4WC02E" 
. "74657874V11T2T2U6LP2W602E72656C6F63WCT3T2U8LP4W4JL02E737263T2D01V4T2UALP4Z8Y6GGGHI8B44" 
. "2408A3Z1Y10B801VC20CGHIJKZ2VCU53GHIJKND0A" 
VarSetCapacity(Z,512,48),   Nums:="512|256|128|64|32|16|15|14|13|12|11|10|9|8|7|6|5|4|3|2" 
Loop, Parse, Nums, |                                  ;  Uncompressing nulls in hex data 
  StringReplace,hex,hex,% Chr(70+A_Index),% SubStr(Z,1,A_LoopField),All 
; MCode() by Laszlo Hars : http://www.autohotkey.com/forum/viewtopic.php?p=135302#135302
VarSetCapacity( Bin,(cLen:=StrLen(hex)//2)), h:=DllCall("_lcreat",str,file,int,0) 
Loop %cLen% 
  NumPut("0x" SubStr(hex,2*a_index-1,2),Bin,a_index-1,"char") 
b:=DllCall("_lwrite",uint,h,str,Bin,uint,cLen),DllCall("_lclose",uint,h), Bin:="", hex:="" 
Return b ? file : "" 
}
;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -






;;;;;#Include FileIO16.ahk ;      http://www.autohotkey.net/~Skan/wrapper/FileIO16/FileIO16.ahk


; Title        :  File IO - 16bit, wrapper for low-level file access ( ver 1.00 )
; Author       :  SKAN - Suresh Kumar A N ( arian.suresh@gmail.com )
; Date         :  Created: 21-May-2008   |   Last Modified: 23-May-2008   
;
; Forum link   :
; This file    :  http://www.autohotkey.net/~Skan/wrapper/FileIO16/FileIO16.ahk


FileIO16_Init() {
  Global F_READ:=0,F_READWRITE:=2,F_WRITE:=1,F_SHARE_COMPAT:=0,F_SHARE_DENY_NONE:=0x40
       , F_SHARE_DENY_READ :=0x30,F_SHARE_DENY_WRITE:=0x20,F_SHARE_EXCLUSIVE:=0x10
       , F_BOF:=0,F_CPF:=1,F_EOF:=2
       , F_NORMAL:=0, F_READONLY:=1,F_HIDDEN:=2,F_SYSTEM:=4
}


FClose( hfil  ) {
  Return DllCall( "_lclose", UInt,hFil )
}

FCreate( sFile, nAttr ) {
  Return DllCall( "_lcreat", Str,sFile, UInt,nAttr )
}

FOpen( sFile, nAttr ) {
  Return DllCall( "_lopen", Str,sFile, UInt,nAttr )
}

FRead( hFil, byref var, nSize ) {
 Return (VarSetCapacity(var,nSize)+n) DllCall( "_lread", UInt,hFil, Str,var, UInt,nSize )
}

FSeek( hfil, nSize, nOrigin ) {
  Return DllCall( "_llseek", UInt,hFil, UInt,nSize, UInt,nOrigin )
}                             

FWrite( hFil, nPtr, nSize ) {
  Return DllCall( "_lwrite", UInt,hFil, UInt,nPtr, UInt,nSize )
}



FileReadEx( F,ByRef V,B,O=0 )  {   
 by:= (B<0 ? ABS(B-1) : B), VarSetCapacity(V,By,0), H:=DllCall("_lopen",Str,F,UInt,0)
 IfLess,H,1, Return,-1
 DllCall( "_llseek",UInt,H,UInt,( B < 0 ? B : O), UInt,(B < 0 ? 2 : 0) )
 Return DllCall("_lread",UInt,H,Str,V,UInt,by) ( DllCall("_lclose",UInt,H)+n )      
}

FileWriteEx( F,ByRef V,B,O=0 ) {  
 H:=(FileExist(F)="") ? DllCall("_lcreat",Str,F,UInt,0) : DllCall("_lopen",Str,F,UInt,1) 
 IfLess,H,1, Return, -1
 DllCall("_llseek",UInt,H,UInt,( O < 0 ? O+1 : O ), UInt,(O < 0 ? 2 : 0) )
 Return DllCall("_lwrite",UInt,H,Str,V,UInt,B) ( DllCall("_lclose",UInt,H)+n ) 
} 

MemCopy( SPtr, TPtr, nSize ) {
 Return DllCall( "RtlMoveMemory", UInt,TPtr, UInt,SPtr, UInt,nSize )
}
