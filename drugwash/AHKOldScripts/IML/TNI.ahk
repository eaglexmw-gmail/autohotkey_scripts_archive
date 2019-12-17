IL_SetTNicon( himl=0, i=0 ) {     ; Set TNA-Icon from ImageList - By SKAN | CD:24-Jun-2011
 Static NID ;                               www.autohotkey.com/forum/viewtopic.php?t=72282
 IfLess,himl,1, Return,VarSetCapacity( NID,0 )
 If ! VarSetCapacity( NID )
  NumPut( 2, NumPut( 1028, NumPut( DllCall( "FindWindow", Str,"AutoHotkey"
  , Str, A_ScriptFullPath ( A_IsCompiled ? "" : " - AutoHotkey v" A_AhkVersion ) )
  , NumPut( VarSetCapacity( NID,444,0 ),NID ) ) ) )
 NumPut( hIcon := DllCall( "ImageList_GetIcon", UInt,himl, int,i, int,0 ), NID, 20 )
Return DllCall( "shell32\Shell_NotifyIcon", UInt,0x1, UInt,&NID )
     , DllCall( "DestroyIcon", UInt,hIcon )
}
