; * Folder Spy v0.97 *   by Skan  || Created : 14-Apr-2007  /// LastModified : 06-Sep-2007
; http://www.autohotkey.com/forum/viewtopic.php?t=22862

#Persistent
SetBatchLines, -1
Process, Priority,, High
OnExit, ShutApp
Menu, Tray, Icon, Shell32.dll, 4
Menu, Tray, Tip , FolderSpy

WatchFolder  := A_Temp . "orary Internet Files"
WatchSubDirs := True

Loop %WatchFolder%, 1
      WatchFolder := A_LoopFileLongPath
DllCall( "shlwapi\PathAddBackslashA", UInt,&Watchfolder )

CBA_ReadDir := RegisterCallback("ReadDirectoryChanges")

; FILE_NOTIFY_INFORMATION : http://msdn2.microsoft.com/en-us/library/aa364391.aspx

SizeOf_FNI := ( 64KB := 1024 * 64 )
VarSetCapacity( FILE_NOTIFY_INFORMATION, SizeOf_FNI, 0 )
PointerFNI := &FILE_NOTIFY_INFORMATION

Gui, Margin, 5, 5
Gui, Add, Edit     , x5   w574 h22 +ReadOnly vWatchFolder, %WatchFolder%
Gui, Add, Button   , x+5  w25  h22 gSelectFolder vBrowseButton, ...
Gui, Add, CheckBox , x+20      h22 vWatchSubDirs Checked 0x20, Sub Folders
Gui, Add, ListView , x5   w700 h480 +Grid vSpyLV
                   , Time|Event|File/Folder Name|Size-KB|TimeStamp [Mod]|Attrib
Gui, Add, Button   , x550  w64  h22 +Default vClear gClearListView, Clear
Gui, Add, Button   , x+10  w64  h22 +Default vStartStop gStartStop, Start

LV_ModifyCol( 1, "54" )
LV_ModifyCol( 2, "75  Center " )
LV_ModifyCol( 3, "327        " )
LV_ModifyCol( 4, "55  Integer" )
LV_ModifyCol( 5, "120        " )
LV_ModifyCol( 6, "46         " )

Gui, Add, StatusBar
SB_SetParts( 100, 500 )
GuiControl, Focus, StartStop
Gui, Show, , FolderSpy v0.96

;:   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
Return ;                                                  [| End of Auto-execute section |]
;:   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -


WatchFolder:

  GuiControlGet, WatchFolder
  GuiControlGet, WatchSubDirs

  ; CreateFile: http://msdn2.microsoft.com/en-us/library/aa914735.aspx

  hDir := DllCall( "CreateFile"
                 , Str  , WatchFolder
                 , UInt , ( FILE_LIST_DIRECTORY := 0x1 )
                 , UInt , ( FILE_SHARE_READ     := 0x1 )
                        | ( FILE_SHARE_WRITE    := 0x2 )
                        | ( FILE_SHARE_DELETE   := 0x4 )
                 , UInt , 0
                 , UInt , ( OPEN_EXISTING := 0x3 )
                 , UInt , ( FILE_FLAG_BACKUP_SEMANTICS := 0x2000000  )
                        | ( FILE_FLAG_OVERLAPPED       := 0x40000000 )
                 , UInt , 0 )

  Loop {

  nReadLen  := 0
  hThreadId := 0

  ; CreateThread   : http://msdn2.microsoft.com/en-us/library/ms682453.aspx

  hThread   := DllCall( "CreateThread", UInt,0, UInt,0, UInt,CBA_ReadDir
                       , UInt,0, UInt,0, UIntP,hThreadId )
         Loop {
                If nReadLen
                            {
                              GoSub, Decode_FILE_NOTIFY_INFORMATION
                              Break
                            }
                If !Watch
                    Break
                Sleep 100
              }

  ; TerminateThread : http://msdn2.microsoft.com/en-us/library/ms686717.aspx
  ; CloseHandle     : http://msdn2.microsoft.com/en-us/library/ms724211.aspx

  DllCall( "TerminateThread", UInt,hThread, UInt,0 )
  DllCall( "CloseHandle", UInt,hThread ) 

  If !Watch
      Break
}

Return

;:   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -

SelectFolder:

 FileSelectFolder, SelFolder, *%WatchFolder%, , Select Watch Folder
 If ( SelFolder = "" )
      Return

 Loop %SelFolder%, 1
    WatchFolder := A_LoopFileLongPath
 DllCall( "shlwapi\PathAddBackslashA", UInt,&Watchfolder )

 GuiControl,, WatchFolder, %WatchFolder%
 GuiControl, Focus, StartStop

 DllCall( "CloseHandle", UInt,hThread )
 SetTimer, StartStop, -1

Return

;:   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -

StartStop:

  Watch := !Watch
  If ( Watch ) {
                 GuiControl,Disable, BrowseButton
                 GuiControl,Disable, WatchSubDirs
                 GuiControl,, StartStop, Stop
                 SetTimer, WatchFolder, -1
  }  Else      {
                 GuiControl,Enable, BrowseButton
                 GuiControl,Enable, WatchSubDirs
                 GuiControl,, StartStop, Start
  }

Return

;:   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -

ReadDirectoryChanges() {       ;    http://msdn2.microsoft.com/en-us/library/aa365465.aspx

 Global hDir,PointerFNI, Sizeof_FNI, WatchSubdirs, nReadlen
 Return DllCall( "ReadDirectoryChangesW"
                , UInt , hDir
                , UInt , PointerFNI
                , UInt , SizeOf_FNI
                , UInt , WatchSubDirs
                , UInt , ( FILE_NOTIFY_CHANGE_FILE_NAME   := 0x1   )
                       | ( FILE_NOTIFY_CHANGE_DIR_NAME    := 0x2   )
                       | ( FILE_NOTIFY_CHANGE_ATTRIBUTES  := 0x4   )
                       | ( FILE_NOTIFY_CHANGE_SIZE        := 0x8   )
                       | ( FILE_NOTIFY_CHANGE_LAST_WRITE  := 0x10  )
                       | ( FILE_NOTIFY_CHANGE_LAST_ACCESS := 0x20  )
                       | ( FILE_NOTIFY_CHANGE_CREATION    := 0x40  )
                       | ( FILE_NOTIFY_CHANGE_SECURITY    := 0x100 )
                , UIntP, nReadLen
                , UInt , 0
                , UInt , 0  )
}

;:   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -


Decode_FILE_NOTIFY_INFORMATION:

  PointerFNI := &FILE_NOTIFY_INFORMATION

  Loop {

    NextEntry   := NumGet( PointerFNI + 0  )
    Action      := NumGet( PointerFNI + 4  )
    FileNameLen := NumGet( PointerFNI + 8  )
    FileNamePtr :=       ( PointerFNI + 12 )


    If ( Action = 0x1 )                            ; FILE_ACTION_ADDED   
       Event := "New File"

    If ( Action = 0x2 )                            ; FILE_ACTION_REMOVED 
       Event := "Deleted"

    If ( Action = 0x3 )                            ; FILE_ACTION_MODIFIED 
       Event := "Modified"

    If ( Action = 0x4 )                            ; FILE_ACTION_RENAMED_OLD_NAME
       Event := "Renamed Fm"

    If ( Action = 0x5 )                            ; FILE_ACTION_RENAMED_NEW_NAME
       Event := "Renamed To"

    VarSetCapacity( FileNameANSI, FileNameLen )
    DllCall( "WideCharToMultiByte", UInt,0, UInt,0, UInt,FileNamePtr, UInt
           , FileNameLen,  Str,FileNameANSI, UInt,FileNameLen, UInt,0, UInt,0 )

    File := SubStr( FileNameANSI, 1, FileNameLen/2 )
    FullPath := WatchFolder . File
    FileGetAttrib, Attr, %FullPath%
    FormatTime, Time  , %A_Now%, HH:mm:ss

    If ( FileExist( FullPath ) = "" )
     {
       LV_Insert( 1, "", Time, Event, File )
       Sb_SetText( "`t" LV_GetCount() )
     }
    Else
    Loop %FullPath%
     {
       FormatTime, TStamp, %A_LoopFileTimeModified%, yyyy-MM-dd  HH:mm:ss
       LV_Insert( 1, "", Time, Event, File, A_LoopFileSizeKB, TStamp, A_LoopFileAttrib )
       Sb_SetText( "`t" LV_GetCount() )
     }

    If !NextEntry
       Break
    Else
       PointerFNI := PointerFNI + NextEntry
  }

Return

;:   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -

GuiClose:
ShutApp:

  DllCall( "CloseHandle", UInt,hDir )
  DllCall( "TerminateThread", UInt,hThread, UInt,0 )
  DllCall( "CloseHandle", UInt,hThread )
  ExitApp

Return

;:   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -

ClearListView:

 LV_Delete() , Sb_SetText("")

Return

;:   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
