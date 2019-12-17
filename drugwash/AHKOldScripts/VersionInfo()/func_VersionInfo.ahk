; by SKAN http://www.autohotkey.com/forum/viewtopic.php?p=233188#233188

FileGetVersionInfo( peFile="", StringFileInfo="" ) {
 FSz := DllCall( "Version\GetFileVersionInfoSizeA",Str,peFile,UInt,0 )
 IfLess, FSz,1, Return -1
 VarSetCapacity( FVI, FSz, 0 ), VarSetCapacity( Trans,8 )
 DllCall( "Version\GetFileVersionInfoA", Str,peFile, Int,0, Int,FSz, UInt,&FVI )
 If ! DllCall( "Version\VerQueryValueA", UInt,&FVI, Str,"\VarFileInfo\Translation"
                                       , UIntP,Translation, UInt,0 )
   Return -2
 If ! DllCall( "msvcrt.dll\sprintf", Str,Trans, Str,"%08X", UInt,NumGet(Translation+0) )
   Return -4
 subBlock := "\StringFileInfo\" SubStr(Trans,-3) SubStr(Trans,1,4) "\" StringFileInfo
 If ! DllCall( "Version\VerQueryValueA", UInt,&FVI, Str,SubBlock, UIntP,InfoPtr, UInt,0 )
   Return
 VarSetCapacity( Info, DllCall( "lstrlen", UInt,InfoPtr ) )
 DllCall( "lstrcpy", Str,Info, UInt,InfoPtr )
Return Info
}
/*
SetBatchLines -1
Loop, %A_WinDir%\System\*.??l
  Files .= "|" A_LoopFileLongPath
Files := A_AhkPath . Files

Loop, Parse, Files, |
  MsgBox, 0, % (PeFile:=A_LoopField)
  , % "FileDescription      `t:`t" FileGetVersionInfo( PeFile, "FileDescription"  ) "`n"
    . "FileVersion          `t:`t" FileGetVersionInfo( PeFile, "FileVersion"      ) "`n"
    . "InternalName         `t:`t" FileGetVersionInfo( PeFile, "InternalName"     ) "`n"
    . "LegalCopyright       `t:`t" FileGetVersionInfo( PeFile, "LegalCopyright"   ) "`n"
    . "OriginalFilename     `t:`t" FileGetVersionInfo( PeFile, "OriginalFilename" ) "`n"
    . "ProductName          `t:`t" FileGetVersionInfo( PeFile, "ProductName"      ) "`n"
    . "ProductVersion       `t:`t" FileGetVersionInfo( PeFile, "ProductVersion"   ) "`n`n`n"
    . "CompanyName          `t:`t" FileGetVersionInfo( PeFile, "CompanyName"      ) "`n"
    . "PrivateBuild         `t:`t" FileGetVersionInfo( PeFile, "PrivateBuild"     ) "`n"
    . "SpecialBuild         `t:`t" FileGetVersionInfo( PeFile, "SpecialBuild"     ) "`n"
    . "LegalTrademarks      `t:`t" FileGetVersionInfo( PeFile, "LegalTrademarks"  ) "`n"
ExitApp
*/
