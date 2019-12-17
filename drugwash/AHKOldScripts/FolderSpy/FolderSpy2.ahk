; by HotkeyIt  http://www.autohotkey.com/forum/viewtopic.php?p=235344#235344

#Persistent
SetBatchLines, -1
Process, Priority,, High
OnExit, ShutApp
Menu, Tray, Icon, Shell32.dll, 4
Menu, Tray, Tip , FolderSpy
DebugBIF()			; aded for debug purposes by Drugwash
WatchFolder  := A_Temp . "orary Internet Files"
WatchSubDirs := True
debug=1				; aded for debug purposes by Drugwash
VarSetCapacity(FindData, 318, 0)
Loop %WatchFolder%, 1
      WatchFolder := A_LoopFileLongPath
if !debug
	fixpath(WatchFolder)
;DllCall( "shlwapi\PathAddBackslashA", UInt,&Watchfolder )
CBA_ReadDir := RegisterCallback("ReadDirectoryChanges")

; FILE_NOTIFY_INFORMATION : http://msdn2.microsoft.com/en-us/library/aa364391.aspx

SizeOf_FNI := ( 64KB := 1024 * 64 )
; VarSetCapacity( FILE_NOTIFY_INFORMATION, SizeOf_FNI, 0 )
; PointerFNI := &FILE_NOTIFY_INFORMATION

Gui, Margin, 5, 5
Gui, Add, Edit     , x5   w574 h18 +ReadOnly vWatchFolder1, %WatchFolder%
Gui, Add, Button   , x+5  w25  h18 gSelectFolder vBrowseButton1, ...
Gui, Add, Text     , x+40                                      , S
Gui, Add, Edit     , x5   w574 h18 +ReadOnly vWatchFolder2,
Gui, Add, Button   , x+5  w25  h18 gSelectFolder vBrowseButton2, ...
Gui, Add, Text     , x+40                                      , U
Gui, Add, Edit     , x5   w574 h18 +ReadOnly vWatchFolder3,
Gui, Add, Button   , x+5  w25  h18 gSelectFolder vBrowseButton3, ...
Gui, Add, Text     , x+40                                      , B
Gui, Add, Edit     , x5   w574 h18 +ReadOnly vWatchFolder4,
Gui, Add, Button   , x+5  w25  h18 gSelectFolder vBrowseButton4, ...
Gui, Add, CheckBox , x+22      h18 vWatchSubDirs Checked 0x20,
Gui, Add, Edit     , x5   w574 h18 +ReadOnly vWatchFolder5,
Gui, Add, Button   , x+5  w25  h18 gSelectFolder vBrowseButton5, ...
Gui, Add, Text     , x+40                                      , F
Gui, Add, Edit     , x5   w574 h18 +ReadOnly vWatchFolder6,
Gui, Add, Button   , x+5  w25  h18 gSelectFolder vBrowseButton6, ...
Gui, Add, Text     , x+40                                      , O
Gui, Add, Edit     , x5   w574 h18 +ReadOnly vWatchFolder7,
Gui, Add, Button   , x+5  w25  h18 gSelectFolder vBrowseButton7, ...
Gui, Add, Text     , x+40                                      , L
Gui, Add, Edit     , x5   w574 h18 +ReadOnly vWatchFolder8,
Gui, Add, Button   , x+5  w25  h18 gSelectFolder vBrowseButton8, ...
Gui, Add, Text     , x+40                                      , D
Gui, Add, Edit     , x5   w574 h18 +ReadOnly vWatchFolder9,
Gui, Add, Button   , x+5  w25  h18 gSelectFolder vBrowseButton9, ...
Gui, Add, Text     , x+40                                      , E
Gui, Add, Edit     , x5   w574 h18 +ReadOnly vWatchFolder10,
Gui, Add, Button   , x+5  w25  h18 gSelectFolder vBrowseButton10, ...
Gui, Add, Text     , x+40                                      , R
Gui, Add, Edit     , x5   w574 h18 +ReadOnly vWatchFolder11,
Gui, Add, Button   , x+5  w25  h18 gSelectFolder vBrowseButton11, ...
Gui, Add, Text     , x+40                                      , S
Gui, Add, Edit     , x5   w574 h18 +ReadOnly vWatchFolder12,
Gui, Add, Button   , x+5  w25  h18 gSelectFolder vBrowseButton12, ...
Gui, Add, Button   , x+5       h18 gDeleteSelection vDeleteSelection, DELETE ALL

Gui, Add, ListView , x5   w700 h380 +Grid vSpyLV
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
Gui, Show, , FolderSpy v0.97X

;:   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
Return ;                                                  [| End of Auto-execute section |]
;:   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -


WatchFolder:

  ReadDirectoryChanges()

Return

;:   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
DeleteSelection:
If Watch
 Gosub, StartStop
Loop 12
 GuiControl,,WatchFolder%A_Index%
Return

SelectFolder:
    FileSelectFolder, SelFolder, *%WatchFolder%, 2, Select Watch Folder
   If ( SelFolder = "" )
   {
      GuiControl,,% "WatchFolder" . SubStr(A_GuiControl, 13)
      Return
    }
   If !(StrLen(SelFolder) = 3 and SubStr(SelFolder, 0) = "\")
   {
      Loop %SelFolder%, 1
      WatchFolder := A_LoopFileLongPath
if !debug
	fixpath(WatchFolder)
;      DllCall( "shlwapi\PathAddBackslashA", UInt,&Watchfolder )
   }
   else
      WatchFolder := SelFolder
   GuiControl,,% "WatchFolder" . SubStr(A_GuiControl, 13), %WatchFolder%
   GuiControl, Focus, StartStop
    SelFolder =
   If ( Watch )
    BeginWatchingDirectory(WatchFolder, WatchSubDirs)
Return

;:   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -

StartStop:

Watch := !Watch
  If ( Watch ) {
                DirIdx= 0
                Loop 12
                {
                  GuiControlGet, WatchFolder, , WatchFolder%A_Index%
                  If (WatchFolder != "")
                  {
                    BeginWatchingDirectory(WatchFolder, WatchSubDirs)
                  }
                }
            GuiControl,, StartStop, Stop   
            SetTimer, WatchFolder, 20
}  Else      {
            Loop %DirIdx%
            {
               Dir%A_Index%         =
               Dir%A_Index%Path     =
               Dir%A_Index%Subdirs  =
               Dir%A_Index%FNI      =
               Dir%A_Index%Overlapped=
               DllCall( "CloseHandle", UInt,Dir%A_Index% )
               DllCall( "CloseHandle", UInt,NumGet(Dir%A_Index%Overlapped, 16) ) 
            }
            DirIdx= 0
            SetTimer, WatchFolder, Off
            GuiControl,, StartStop, Start
  }

Return

;:   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -

BeginWatchingDirectory(WatchFolder, WatchSubDirs=true)
{
    local hDir, hEvent
   
    Loop %DirIdx%
   {
      If InStr(WatchFolder, Dir%A_Index%Path)
      {
         If (WatchSubDirs and Dir%A_Index%Subdirs)
            Return
         else if (WatchSubDirs and !Dir%A_Index%Subdirs)
         {
            DllCall( "CloseHandle", UInt,Dir%A_Index% )
            DllCall( "CloseHandle", UInt,NumGet(Dir%A_Index%Overlapped, 16) )
            #__RE_BEGINN_WATHING_DIR_ := DirIdx
            DirIdx := A_Index
         }
         Else
            Return
      }
      else if InStr(Dir%A_Index%Path, WatchFolder)
      {
         If (WatchSubDirs)
         {
            DllCall( "CloseHandle", UInt,Dir%A_Index% )
            DllCall( "CloseHandle", UInt,NumGet(Dir%A_Index%Overlapped, 16) )
            #__RE_BEGINN_WATHING_DIR_ := DirIdx
            DirIdx := A_Index
         }
      }
   }
   If !#__RE_BEGINN_WATHING_DIR_
    DirIdx += 1
    ; CreateFile: http://msdn2.microsoft.com/en-us/library/aa914735.aspx
if debug
	{
	msgbox, WatchFolder path in line %A_LineNumber%:`n%WatchFolder%
	hDir := DllCall( "FindFirstFile", Str, WatchFolder, UInt, &FindData)
	}
else
	{
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
	}

if debug
	msgbox, CreateFile in line %A_LineNumber%, handle hDir: %hDir%   
    Dir%DirIdx%         := hDir
    Dir%DirIdx%Path     := WatchFolder
    Dir%DirIdx%Subdirs  := WatchSubDirs
    VarSetCapacity( Dir%DirIdx%FNI, SizeOf_FNI )
    VarSetCapacity( Dir%DirIdx%Overlapped, 20, 0 )
    hEvent := DllCall( "CreateEvent", UInt,0, Int,true, Int,false, UInt,0 )
if debug
	msgbox, CreateEvent in line %A_LineNumber%, handle hEvent: %hEvent%   
    NumPut( hEvent, Dir%DirIdx%Overlapped, 16 )
   
    ; Maintain array of event handles to wait on.
    if ( VarSetCapacity(DirEvents) < DirIdx*4 )
    {   ; Expand by 16 directories (64 bytes) at a time.
        VarSetCapacity(DirEvents, DirIdx*4 + 60)
        ; Copy all previous event handles.
        Loop %DirIdx%
        {
              NumPut( NumGet( Dir%A_Index%Overlapped, 16 ), DirEvents, A_Index*4-4 )
      }
    }
    NumPut( hEvent, DirEvents, DirIdx*4-4 )
   
    debugret := DllCall( "ReadDirectoryChangesW"  ; http://msdn2.microsoft.com/en-us/library/aa365465.aspx
                , UInt , hDir
                , UInt , &Dir%DirIdx%FNI
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
                , UInt , 0
                , UInt , &Dir%DirIdx%Overlapped
                , UInt , 0  )
if debug
	msgbox, ReadDirectoryChangesW in line %A_LineNumber% returned`n%debugret%
    If #__RE_BEGINN_WATHING_DIR_
   {
      DirIdx := #__RE_BEGINN_WATHING_DIR_
      #__RE_BEGINN_WATHING_DIR_ =
   }
}

; Handles one directory at a time.
; Returns non-zero if a change was detected.
; Returns zero if it timed out or a window message was received.
ReadDirectoryChanges(Timeout=-1)
{
    local hDir, r
    ; Wait for any event object to be signaled or a window message to be received.
    r := DllCall("MsgWaitForMultipleObjectsEx", UInt, DirIdx, UInt, &DirEvents
                                            , UInt, Timeout, UInt, 0x4FF, UInt, 0x6)
;if debug
;	msgbox, MsgWaitForMultipleObjectsEx in line %A_LineNumber% returned`n%r%
    if (r >= 0 && r < DirIdx) ; WAIT_OBJECT_*
    {
        r += 1
        ; At least one event object was signaled. Decode the FNI for this event.
        ; If more than one event object was signaled, this func must be called again.
        WatchFolder := Dir%r%Path
        PointerFNI := &Dir%r%FNI
        nReadLen := 0
        debugret := DllCall( "GetOverlappedResult", UInt, hDir
                    , UInt, &Dir%r%Overlapped, UIntP, nReadLen, Int, true )
if debug
	msgbox, GetOverlappedResult in line %A_LineNumber% returned`n%debugret%
        gosub Decode_FILE_NOTIFY_INFORMATION

        ; Reset the event and call ReadDirectoryChangesW in async mode again.
        debugret := DllCall( "ResetEvent", UInt,NumGet( Dir%r%Overlapped, 16 ) )
if debug
	msgbox, ResetEvent in line %A_LineNumber% returned`n%debugret%
        DllCall( "ReadDirectoryChangesW"
                , UInt , Dir%r%
                , UInt , &Dir%r%FNI
                , UInt , SizeOf_FNI
                , UInt , Dir%r%WatchSubDirs
                , UInt , ( FILE_NOTIFY_CHANGE_FILE_NAME   := 0x1   )
                       | ( FILE_NOTIFY_CHANGE_DIR_NAME    := 0x2   )
                       | ( FILE_NOTIFY_CHANGE_ATTRIBUTES  := 0x4   )
                       | ( FILE_NOTIFY_CHANGE_SIZE        := 0x8   )
                       | ( FILE_NOTIFY_CHANGE_LAST_WRITE  := 0x10  )
                       | ( FILE_NOTIFY_CHANGE_LAST_ACCESS := 0x20  )
                       | ( FILE_NOTIFY_CHANGE_CREATION    := 0x40  )
                       | ( FILE_NOTIFY_CHANGE_SECURITY    := 0x100 )
                , UInt , 0
                , UInt , &Dir%r%Overlapped
                , UInt , 0  )
        return r
    }
    return 0
}

;:   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -


Decode_FILE_NOTIFY_INFORMATION:

;   PointerFNI := &FILE_NOTIFY_INFORMATION

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
if debug
	{
    DllCall( "unicows\WideCharToMultiByte", UInt,0, UInt,0, UInt,FileNamePtr, UInt
           , FileNameLen,  Str,FileNameANSI, UInt,FileNameLen, UInt,0, UInt,0 )
msgbox, FileNameANSI in line %A_LineNumber%: <%FileNameANSI%>
	}
else
	{
   DllCall( "WideCharToMultiByte", UInt,0, UInt,0, UInt,FileNamePtr, UInt
           , FileNameLen,  Str,FileNameANSI, UInt,FileNameLen, UInt,0, UInt,0 )
	}
    File := SubStr( FileNameANSI, 1, FileNameLen/2 )
if debug
    FullPath := WatchFolder "\" File
else
    FullPath := WatchFolder . File
    FileGetAttrib, Attr, %FullPath%
    FormatTime, Time  , %A_Now%, HH:mm:ss

    If ( FileExist( FullPath ) = "" )
     {
       LV_Insert( 1, "", Time, Event, FullPath )
       Sb_SetText( "`t" LV_GetCount() )
     }
    Else if ( FileExist( FullPath ) = "D" )
    Loop, %FullPath%, 2
     {
       FormatTime, TStamp, %A_LoopFileTimeModified%, yyyy-MM-dd  HH:mm:ss
       LV_Insert( 1, "", Time, Event, RegExReplace(FullPath, "\\\\", "\\"), A_LoopFileSizeKB, TStamp, A_LoopFileAttrib )
       Sb_SetText( "`t" LV_GetCount() )
     }
    Else
    Loop %FullPath%
     {
       FormatTime, TStamp, %A_LoopFileTimeModified%, yyyy-MM-dd  HH:mm:ss
       LV_Insert( 1, "", Time, Event, RegExReplace(FullPath, "\\\\", "\\"), A_LoopFileSizeKB, TStamp, A_LoopFileAttrib )
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

  Loop %DirIdx%
  {
     ToolTip % "Canceling watching " Dir%A_Index%Path
     Dir%A_Index%         =
     Dir%A_Index%Path     =
     Dir%A_Index%Subdirs  =
     Dir%A_Index%FNI      =
     Dir%A_Index%Overlapped=
     DllCall( "CloseHandle", UInt,Dir%A_Index% )
     DllCall( "CloseHandle", UInt,NumGet(Dir%A_Index%Overlapped, 16) ) 
  }
if debug
	DllCall("FindClose", UInt, hDir)
  ExitApp

Return

;:   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -

ClearListView:

 LV_Delete() , Sb_SetText("")

Return

;:   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
fixpath(ByRef thispath)
{
source := thispath
wf := StrLen(source)
VarSetCapacity(dest, wf + 1, 32)
DllCall("msvcrt\strcpy", UInt, &dest, UInt, &source, cdecl)
if debug
	msgbox, After string copy:`n%dest%
DllCall( "shlwapi\PathAddBackslashA", UInt,&dest )
if debug
	msgbox, initial path: %source%`nlength: %wf%`npath: •%dest%•`nError: %ErrorLevel%
thispath := dest
}
