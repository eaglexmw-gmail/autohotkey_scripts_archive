/*
LoadIconfromRES() : Loads and returns handle of an Icon from Resource file.
The following demonstrates retrieval of RT_ICON_GROUP: 512 from Shell32.DLL

LoadIconFromRES() DEMO by SKAN     ||| Created: 12-05-2008 ||| Last Modified: 12-05-2008
*/

#SingleInstance, Force
SetWorkingDir %A_ScriptDir%

Icons := "48x48-4|32x32-4|16x16-4|48x48-8|32x32-8|16x16-8|48x48-32|32x32-32|16x16-32"
Gui, Add, DDL, w130 Choose1 R5 Sort -Theme vSel gSelect, %Icons%
Gui, Add, Text, w130 h130 Border 0x203 hwndIcon1
Gui, Show, w150, Icon
Return

Select:
 GuiControlGet, Sel
 StringSplit, P, Sel,-
 hIcon := LoadIconFromRes( "Shell32.dll", 64, P1, P2  )
 SendMessage, ( STM_SETIMAGE:=0x172 ), ( IMAGE_ICON:=0x1 ), hIcon,, ahk_id %Icon1%
Return

LoadIconFromRES( ResFile, ResName, WxH, BPP ) {
 hModule := DllCall( "GetModuleHandle", Str,ResFile )
 Buffer  := GetResource( hModule, ResName, (RT_GROUP_ICON:=14), nSize, hResData )
 IfEqual,Buffer,0, Return,0
 StringSplit, D, WxH, x 
 Icons := NumGet( Buffer+4, 0, "UShort" ), Buffer := Buffer+6

 Loop, %Icons%
   {
      If ( NumGet( Buffer+0,0,"UChar" ) = D1 && NumGet( Buffer+0,1,"UChar" ) = D2 
        && NumGet( Buffer+0,6,"UShort" ) = BPP ) 
         { 
           nID := NumGet( Buffer+0,12,"UShort" )
           Break                    
         } 
      Buffer := Buffer+14
    } 

 DllCall( "FreeResource", UInt,hResData ) 
 IfEqual,nID,, Return,0    
 Buffer := GetResource( hModule, nID, (RT_ICON:=3), nSize, hResData )
 hIcon  := DllCall( "CreateIconFromResourceEx", UInt,Buffer, UInt,BPP, Int,1
                  , UInt, 0x00030000, Int,W, Int,H, UInt,(LR_SHARED := 0x8000) )
 DllCall( "FreeResource", UInt,hResData )
 Return hIcon
}

GetResource( hModule, rName, rType, ByRef nSize, ByRef hResData ) { 
 hResource := DllCall( "FindResource", UInt,hModule, UInt,rName, UInt,rType ) 
 nSize     := DllCall( "SizeofResource", UInt,hModule, UInt,hResource ) 
 hResData  := DllCall( "LoadResource", UInt,hModule, UInt,hResource ) 
 Return DllCall( "LockResource", UInt, hResData ) 
}