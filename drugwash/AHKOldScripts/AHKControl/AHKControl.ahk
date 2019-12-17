; by Lexikos http://www.autohotkey.com/forum/viewtopic.php?t=28623
; Command line to run when a script directory is selected from an Edit menu.
BrowseAction = explorer.exe /select,$SCRIPT_PATH
;BrowseAction = explorer.exe $SCRIPT_DIR

; Command line to run when a file is selected from an Edit menu.
EditAction = edit $SCRIPT_PATH


#SingleInstance force
#NoEnv
#NoTrayIcon

; Detect hidden script windows.
DetectHiddenWindows, On

Menu, Root, Add ; create menu so we can add it (once) to the tray menu.

; Desired icon size. If specified, icons are resized automatically as necessary.
IconSize = 16

; Define WM_COMMAND codes used by ScriptCommand.
Cmd_Open    = 65300
;-
Cmd_Reload  = 65400
Cmd_Edit    = 65401
Cmd_Pause   = 65403
Cmd_Suspend = 65404
;-
Cmd_ViewLines      = 65406
Cmd_ViewVariables  = 65407
Cmd_ViewHotkeys    = 65408
Cmd_ViewKeyHistory = 65409
;-
Cmd_Exit    = 65405

Process, Exist
this_id := WinExist("ahk_class AutoHotkey ahk_pid " . ErrorLevel)

return


;^!#q::
^2::
Exit:
    if Script_Count > 1
    {
        MsgBox, 3, Exiting AHKControl, Close all AutoHotkey scripts?
        ifMsgBox, Cancel
            return
        ifMsgBox, Yes
            Loop, %Script_Count%
                if (Script_%A_Index% != this_id)
                    WinClose, % "ahk_id " Script_%A_Index%
    }
    ExitApp

;#q::
^1::
    RebuildMenu()
    KeyWait, LWin
    ;Menu, Root, Show
    MI_ShowMenu("Root")
    return


ScriptOpen:
    id := %A_ThisMenu%
    WinShow, ahk_id %id%
return

ScriptEdit:
    id := %A_ThisMenu%
    if GetKeyState("Shift") || !OpenIncludesMenu(id)
        EditScriptFile(GetFileToEdit(id))
return

ScriptKill:
    id := %A_ThisMenu%
    WinGet, id, PID, ahk_id %id%
    Run, taskkill /PID %id% /F
return

ScriptCommand:
    ; Get the window ID associated with this menu.
    id := %A_ThisMenu%
    cmd := RegExReplace(A_ThisMenuItem, "[^\w#@$?\[\]]") ; strip invalid chars
    cmd := Cmd_%cmd%
    PostMessage, 0x111, %cmd%, , , ahk_id %id% ; WM_COMMAND
return

ScriptShowTrayMenuDirect:
    ShowScriptTrayMenu(Script_%A_ThisMenuItemPos%_nMsg, Script_%A_ThisMenuItemPos%_uID, Script_%A_ThisMenuItemPos%_hWnd)
return
ScriptShowTrayMenu:
    ShowScriptTrayMenu(%A_ThisMenu%_nMsg, %A_ThisMenu%_uID, %A_ThisMenu%_hWnd)
return

ShowScriptTrayMenu(nMsg, uID, hWnd)
{
    ifWinNotExist, ahk_id %hWnd% ; set LFW
        return
    PostMessage, nMsg, uID, 0x204, , ahk_id %hWnd% ; WM_RBUTTONDOWN
    PostMessage, nMsg, uID, 0x205, , ahk_id %hWnd% ; WM_RBUTTONUP
}

GetFileToEdit(id)
{
    WinGetTitle, title, ahk_id %id%
    if ! RegExMatch(title, ".*?(?= - AutoHotkey v)", script_path)
    {   ; Compiled scripts omit " - AutoHotkey vVERSION".
        if SubStr(title,-3) = ".exe"
            script_path := SubStr(title,1,-3) . "ahk"
    }
    ifExist, %script_path%
        return script_path
}

EditScriptFile(script_path)
{
    global EditAction
    if EditAction !=
    {
        StringReplace, action, EditAction, $SCRIPT_PATH, %script_path%
        Run, %action%,, UseErrorLevel
        if ErrorLevel != ERROR
            return
    }
    Run, edit %script_path%,, UseErrorLevel
    if ErrorLevel = ERROR
        Run, notepad.exe "%script_path%"
}

OpenIncludesMenu(id, require_multiple_scripts=true)
{
    global BrowseAction, EditAction
    static action, SCRIPT_DIR, SCRIPT_PATH
    
    SCRIPT_PATH := GetFileToEdit(id)
    if !(includes := ListIncludes(SCRIPT_PATH))
        return false
    
    ; Don't open the menu if only one script file would be in it.
    if (require_multiple_scripts && !InStr(includes, "|"))
        return false
    
    SplitPath, SCRIPT_PATH,, script_dir
    
    Menu, Includes, Add, %script_dir%, OpenScriptDir
    Menu, Includes, Add

    script_dir .= "\"
    
    Loop, Parse, includes, |
    {
        path := A_LoopField
        if (SubStr(path,1,StrLen(script_dir)) = script_dir)
            path := SubStr(path, StrLen(script_dir)+1)
        path := ((A_Index<10) ? "&" : "") A_Index ". " path
        Menu, Includes, Add, %path%, OpenIncludeFile
    }

    Menu, Includes, Show
    Menu, Includes, DeleteAll
    
    return true

OpenScriptDir:
    action := BrowseAction
    StringReplace, action, action, $SCRIPT_PATH, %SCRIPT_PATH%
    StringReplace, action, action, $SCRIPT_DIR, %SCRIPT_DIR%
    Run, %action%
return

OpenIncludeFile:
    SCRIPT_PATH := SubStr(A_ThisMenuItem,InStr(A_ThisMenuItem, ".")+2)
    if (SubStr(SCRIPT_PATH,2,1) != ":")
        SCRIPT_PATH := SCRIPT_DIR . SCRIPT_PATH
    EditScriptFile(SCRIPT_PATH)
return
}


RebuildMenu()
{
    local h_Root, i, id, pid, title, pos, hasTrayIcon, filename
        , h_icon, h_bitmap, width, height, new_bitmap, h_menu, ext
    
    Loop, Parse, BitmapsToCleanUp, `,
        DllCall("DeleteObject", "uint", A_LoopField)
    Loop, Parse, IconsToCleanUp, `,
        DllCall("DestroyIcon", "uint", A_LoopField)
    BitmapsToCleanUp =
    IconsToCleanUp =
    
    Menu, Root, DeleteAll
    
    ; Get handle to menu, for use with SetMenuItemBitmap().
    h_Root := MI_GetMenuHandle("Root")
    
    ; List all AutoHotkey main windows.
    WinGet, ahk_list, List, ahk_class AutoHotkey
    
    i = 1
    Loop, %ahk_list%
    {
        id := ahk_list%A_Index%
        if !WinExist("ahk_id " . id) ; set LFW for convenience
            continue

        ; Delete previous script sub-menu.
        if Script_%i% && Script_%i%_HasMenu
            Menu, Script_%i%, DeleteAll

        Script_%i% = %id%
    
        WinGet, pid, PID
        WinGetTitle, filename
        filename := RegExReplace(filename, " - AutoHotkey v[\d\.]+$")

        hasTrayIcon := GetTrayIconInfo(pid
            , Script_%i%_hWnd
            , Script_%i%_uID
            , Script_%i%_nMsg
            , h_icon
            , title)
        
        if !hasTrayicon || title=""
            SplitPath, filename, title
        
        StringReplace, title, title, &, &&, All
        
        ; AHK_RETURN_PID is a legacy message used to get the script's process ID.
        ; Since it is a user message, Vista UAC blocks the message if the script
        ; is elevated and AHKControl is not. Note the A_OSVersion may not be
        ; accurate if AutoHotkey is running in a compatibility mode.
        ErrorLevel =
        if A_OSVersion = WIN_VISTA
            SendMessage, 1029,,,, ahk_id %id%
        
        if Script_%i%_HasMenu := (ErrorLevel != "FAIL")
        {
            ;
            ; Build sub-menu
            ;
    
            if hasTrayIcon
            {
                Menu, Script_%i%, Add, Tray& Menu       , ScriptShowTrayMenu
                Menu, Script_%i%, Add
            }
            
            SplitPath, filename,,, ext
            
            Menu, Script_%i%, Add, &Open                , ScriptOpen
            Menu, Script_%i%, Add, &Reload              , ScriptCommand
            if (ext != "exe") || FileExist(SubStr(filename,1,-4) ".ahk")
                Menu, Script_%i%, Add, &Edit            , ScriptEdit
            Menu, Script_%i%, Add, &Pause               , ScriptCommand
            Menu, Script_%i%, Add, &Suspend             , ScriptCommand
            if (ext != "exe") {
                Menu, Script_%i%, Add
                Menu, Script_%i%, Add, View &Lines      , ScriptCommand
                Menu, Script_%i%, Add, View &Variables  , ScriptCommand
                Menu, Script_%i%, Add, View &Hotkeys    , ScriptCommand
                Menu, Script_%i%, Add, View Key &History, ScriptCommand
            }
            Menu, Script_%i%, Add
            Menu, Script_%i%, Add, E&xit                , ScriptCommand
            Menu, Script_%i%, Add, K&ill                , ScriptKill
        
            ; Add sub-menu to root menu.
            Menu, Root, Add, &%i%. %title%, :Script_%i%
        }
        else ; ErrorLevel = FAIL
        {
            if !hasTrayIcon
            {
                i += 1
                continue
            }
            ; AHKControl will be unable to command this script, so hook the
            ; menu item directly to the script's tray menu if it has one.
            Menu, Root, Add, &%i%. %title%, ScriptShowTrayMenuDirect
        }
        
        ; Set menu item icon
        if h_icon
        {
            MI_SetMenuItemIcon(h_Root, i, h_icon, 1, IconSize, h_bitmap, h_usedicon)
            if (h_usedicon && h_usedicon != h_icon)
                IconsToCleanUp .= (IconsToCleanUp ? "," : "") . h_usedicon
            if (h_bitmap)
                BitmapsToCleanUp .= (BitmapsToCleanUp ? "," : "") . h_bitmap
        }
        i += 1
    }
    
    Script_Count := i-1
    
    Menu, Root, Add
    Menu, Root, Add, E&xit, Exit

    ; Give E&xit an appropriate icon.
    VarSetCapacity(mii,48,0), NumPut(48,mii), NumPut(0x80,mii,4), NumPut(8,mii,44)
    DllCall("SetMenuItemInfo","uint",h_Root,"uint",i,"uint",1,"uint",&mii)
    
    MI_SetMenuStyle(h_Root, 0x04000000) ; MNS_CHECKORBMP
}


; Adapted from Sean's TrayIcons()
;   http://www.autohotkey.com/forum/topic17314.html
GetTrayIconInfo(TargetPID, ByRef hWnd, ByRef uID, ByRef nMsg, ByRef hIcon, ByRef sTooltip)
{
    TBWnd := GetTrayBarHwnd()
    WinGet, pidTaskbar, PID, ahk_id %TBWnd%

    hProc := DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", pidTaskbar)
    pRB := DllCall("VirtualAllocEx", "Uint", hProc, "Uint", 0, "Uint", 20, "Uint", 0x1000, "Uint", 0x4)

    VarSetCapacity(btn, 20)
    VarSetCapacity(nfo, 24)
    VarSetCapacity(sTooltip, 128)
	VarSetCapacity(wTooltip, 128 * 2)

    SendMessage, 0x418, 0, 0,, ahk_id %TBWnd%  ; TB_BUTTONCOUNT

    IconFound = 0
    uID = 0
    nMsg = 0
    hIcon = 0
    sTooltip =

    Loop, %ErrorLevel%
    {
        SendMessage, 0x417, A_Index - 1, pRB,, ahk_id %TBWnd% ; TB_GETBUTTON

        DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pRB, "Uint", &btn, "Uint", 20, "Uint", 0)

        dwData    := NumGet(btn, 12)
        iString   := NumGet(btn, 16)

        DllCall("ReadProcessMemory", "Uint", hProc, "Uint", dwData, "Uint", &nfo, "Uint", 24, "Uint", 0)

        hWnd  := NumGet(nfo, 0)

        WinGet, pid, PID, ahk_id %hWnd%

        If TargetPID = %pid%
        {
            uID   := NumGet(nfo, 4)
            nMsg  := NumGet(nfo, 8)
            hIcon := NumGet(nfo, 20)
            
            DllCall("ReadProcessMemory", "Uint", hProc, "Uint", iString, "Uint", &wTooltip, "Uint", 128 * 2, "Uint", 0)
			DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "str", wTooltip, "int", -1, "str", sTooltip, "int", 128, "Uint", 0, "Uint", 0)
			
            IconFound = 1
            break
        }
    }

    DllCall("VirtualFreeEx", "Uint", hProc, "Uint", pRB, "Uint", 0, "Uint", 0x8000)
    DllCall("CloseHandle", "Uint", hProc)

    If IconFound = 0
        hWnd = 0

    return IconFound
}
; Based on Sean's GetTrayBar()
;   http://www.autohotkey.com/forum/topic17314.html
GetTrayBarHwnd()
{
    WinGet, ControlList, ControlList, ahk_class Shell_TrayWnd
    RegExMatch(ControlList, "(?<=ToolbarWindow32)\d+(?!.*ToolbarWindow32)", nTB)

    Loop, %nTB%
    {
        ControlGet, hWnd, hWnd,, ToolbarWindow32%A_Index%, ahk_class Shell_TrayWnd
        hParent := DllCall("GetParent", "Uint", hWnd)
        WinGetClass, sClass, ahk_id %hParent%
        If sClass != SysPager
            Continue
        return hWnd
    }

    return 0
}

#include MI 2.21.ahk
#include ListIncludes.ahk
