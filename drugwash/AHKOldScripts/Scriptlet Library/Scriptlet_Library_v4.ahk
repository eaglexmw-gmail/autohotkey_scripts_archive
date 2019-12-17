;Scriptlet Library with TreeView to group the code snippets
;by toralf, original by Rajat
;requires AHK 1.0.44.09
;www.autohotkey.com/forum/topic2510.html

Version = 4
ScriptName = Scriptlet Library %Version%

/*
changes to version 3:
- requires "../Anchor/Anchor_v3.3.ahk" => www.autohotkey.com/forum/topic4348.html
- on RollUp, gui minimized animated to a small bar. very nice :)
- menu option to choose between two gui styles (thanks MsgBox)
- menu options to turn on/off RollUpDown and AlwaysOnTop  (thanks MsgBox)
- changed RollUpDown to work on gui not-active instead of OnMessage(RButton) 
- changed AlwaysOnTop to work without OnMessage(MButton)
- menu option to choose the font and size (thanks MsgBox) 
- menu option to backup the ini (thanks MsgBox)
- improved docking behavior 
changes to version 2:
- complete rewritten
- added tray menu and icon
- tray icon allows to exit script
- treeview to show groups of scriptlets
- easy naming/saving handling, similar to IniFileCreator
- scriplets can change groups easily
- command line parameter "/dock hwnd" to dock GUI to upper left corner of hwnd
- remembers the gui size and position between starts
*/

GroupStartString = <---Group_
ScriptletStartString = <---Start_
ScriptletEndString = <---End_
DefaultGroupName = Misc
DefaultNewGroupName = New Group
DefaultNewScriptletName = Scriptlet
ScriptletNameIndex = 0

;set working dir, in case this script is called from some other script in a different dir 
SetWorkingDir, %A_ScriptDir%

;get ini file name and values
SplitPath, A_ScriptName, , , , OutNameNoExt
IniFile = %OutNameNoExt%.ini
IniRead, Gui1Pos,        %IniFile%, Settings, Gui1Pos,        %A_Space%
IniRead, Gui1W,          %IniFile%, Settings, Gui1W,          %A_Space%
IniRead, Gui1H,          %IniFile%, Settings, Gui1H,          %A_Space%
IniRead, BolResizeTreeH, %IniFile%, Settings, BolResizeTreeH, 0
IniRead, BolRollUpDown,  %IniFile%, Settings, BolRollUpDown,  1
IniRead, BolAlwaysOnTop, %IniFile%, Settings, BolAlwaysOnTop, 0
IniRead, IntGuiStyle,    %IniFile%, Settings, IntGuiStyle,    1
IniRead, StrFontName,    %IniFile%, Settings, StrFontName,    Courier
IniRead, IntFontSize,    %IniFile%, Settings, IntFontSize,    %A_Space%
If IntFontSize
    FontSize = S%IntFontSize%

#SingleInstance force
GoSub, BuildTrayMenu
GoSub, BuildGuiStyle%IntGuiStyle%
GoSub, BuildContextMenu
GroupAdd, GrpGui , ahk_id %Gui1UniqueID%

Loop, %0% {                       ;for each command line parameter
    next := A_Index + 1           ;get next parameters number
    If (%A_Index% = "/dock")      ;check if known command line parameter exists
        param_dock := %next%      ;assign next command line parameter as value
;     Else If (%A_Index% = "/log")
;         param_log := %next%
  }

;when docked to an editor ...
If param_dock {
    Gui, 1:+ToolWindow              ;make library a toolwindow
    GoSub,DockToWindow              ;dock it to the editor upper left corner
    Settimer, DockToWindow, On      ;make sure it stays there
    If !BolAlwaysOnTop              ;enforce AOT
        GoSub, ToggleAlwaysOnTop
    Menu, ContextMenu, Disable, Always On Top
    AOTState := True
    If BolRollUpDown
        RollGuiUp(ScriptName)       ;roll Gui Up when wanted
  }
Return

DockToWindow:
  ;Check if editor window exists 
  EditorVisibleState = 1
  If !WinExist("ahk_id " param_dock){
      DetectHiddenWindows, On
      If !WinExist("ahk_id " param_dock)  ;check if editor window exists minimized
          GoSub, GuiClose                 ;if not close this script
      Else 
          EditorVisibleState = 0     ; WinGet, EditorVisibleState, MinMax  doesn't work on PSPad    
    } 
  ;get editor position
  WinGetPos, EditorX, EditorY, , , ahk_id %param_dock%
  DetectHiddenWindows, Off
  
  ;remove AOT if other window is active
  ID := WinActive("A")
  If (WinActive("A") <> Gui1UniqueID AND WinActive("A") <> param_dock AND AOTState ) {
      Gui, 2: -AlwaysOnTop
      Gui, 1: -AlwaysOnTop
      AOTState := False
      Return
  }Else If ( (WinActive("A") = Gui1UniqueID OR WinActive("A") = param_dock) AND !AOTState)  {
      Gui, 2: +AlwaysOnTop
      Gui, 1: +AlwaysOnTop
      AOTState := True
      Return
    }  
 
  ;reposition bar/gui to upper left corner or hide when editor is minimized 
  If (!EditorVisibleState AND Old_EditorVisibleState <> EditorVisibleState) {
      Gui 2:+LastFoundExist  ;hide small bar when minimized and existing
      IfWinExist
          Gui, 2:Show , Hide     
      Gui, 1:Show , Hide     ;hide gui when minimized
  }Else If (EditorVisibleState AND Old_EditorVisibleState <> EditorVisibleState) {
      If GuiRolledUp
          Gui, 2:Show , NoActivate    ;Show small bar when restored
      Else
          Gui, 1:Show , NoActivate    ;Show gui when restored
  }Else If ( EditorX " " EditorY <> Old_EditorPos ) {
      If GuiRolledUp {
          Gui, 2:Show, x%EditorX% y%EditorY% NoActivate   ;move small bar when rolled up
          Gui, 1:Show, x%EditorX% y%EditorY% Hide         ;and move gui hidden
      }Else{
          Gui, 1:Show, x%EditorX% y%EditorY% NoActivate   ;otherwise move gui
        }
      Old_EditorPos := EditorX " " EditorY
    }
  Old_EditorVisibleState = %EditorVisibleState%
Return

BuildTrayMenu:
  ;location of icon file
  If ( A_OSType = "WIN32_WINDOWS" )  ; Windows 9x
      IconFile = %A_WinDir%\system\shell32.dll
  Else
      IconFile = %A_WinDir%\system32\shell32.dll

  ;tray menu
  Menu, Tray, Icon, %IconFile%, 45   ;icon for taskbar and for process in task manager
  Menu, Tray, Tip, %ScriptName%
  Menu, Tray, NoStandard
  Menu, Tray, Add, Exit, GuiClose
  Menu, Tray, Default, Exit
  Menu, Tray, Click, 1
Return

FileScriptletsIntoGui:
  ;create default group
  Gui, 1: Default
  Group_ID := TV_Add(DefaultGroupName, "", "Sort")
  ListOfGroupNames = `n%DefaultGroupName%`n
  Default_Group_ID := Group_ID
  
  ;read data
  Loop, Read, %IniFile%
    {
      If (InStr(A_LoopReadLine,GroupStartString)=1) {
          ;get group name
          StringTrimLeft, GroupName, A_LoopReadLine, % StrLen(GroupStartString)
          Group_ID := TV_Add(GroupName, "", "Sort")
          ListOfGroupNames = %ListOfGroupNames%%GroupName%`n
      }Else If (InStr(A_LoopReadLine,ScriptletStartString)=1) {
          ;get scriptlet name
          StringTrimLeft, ScriptletName, A_LoopReadLine, % StrLen(ScriptletStartString)
          
          ;add scriptlet
          ID := TV_Add(ScriptletName,Group_ID,"Sort")
          ScriptletInProcess := True
          Scriptlet =
      }Else If (InStr(A_LoopReadLine,ScriptletEndString)=1) {
          ScriptletInProcess := False
          StringTrimRight, Scriptlet, Scriptlet, 1
          %ID%Scriptlet = %Scriptlet%
      }Else If ScriptletInProcess {
          Scriptlet = %Scriptlet%%A_LoopReadLine%`n
        }
    }
  ;check if default group is used
  If !TV_GetChild(Default_Group_ID){
      TV_Delete(Default_Group_ID)
      StringReplace, ListOfGroupNames, ListOfGroupNames, `n%DefaultGroupName%`n, `n
    } 
  
  StringReplace, DdbScriptletInGroup, ListOfGroupNames, `n, |, All
  GuiControl, 1:, DdbScriptletInGroup, %DdbScriptletInGroup%
Return

BuildGuiStyle1:
  Gui, 1:+Resize
  Gui, 1:Add, Button, Section vBtnAddGroup gBtnAddGroup, +
  Gui, 1:Add, Edit,  x+1 ys+1 w200 vEdtGroupName gEdtGroupName Disabled, 
  Gui, 1:Add, Button,  x+1 ys vBtnRemoveGroup gBtnRemoveGroup Disabled, -
  
  Gui, 1:Add, Button, x+40 ys vBtnAddScriptlet gBtnAddScriptlet Disabled, +
  Gui, 1:Add, Edit,  x+1 ys+1 w150 vEdtScriptletName gEdtScriptletName Disabled, 
  Gui, 1:Add, Button,  x+1 ys vBtnRemoveScriptlet gBtnRemoveScriptlet Disabled, -
  Gui, 1:Add, DropDownList, x+40 ys w150 vDdbScriptletInGroup gDdbScriptletInGroup Sort Disabled, 
  
  Gui, 1:Add, Button, ys vBtnCopyToClipboard gBtnCopyToClipboard Disabled, Copy to &Clipboard

  Gui, 1:Add, TreeView, xs Section w250 h500 vTrvScriptlets gTrvScriptlets
  GoSub, FileScriptletsIntoGui
  Gui, 1:Font, %FontSize%, %StrFontName%
  Gui, 1:Add, Edit, ys w500 h500 Multi T8 vEdtScriptletData gEdtScriptletData,
  GoSub, FinishGUI
Return

FinishGUI:
  Gui, 1:Show, %Gui1Pos%, %ScriptName%
  Gui, 1: +LastFound
  Gui1UniqueID := WinExist()
  ;restore old size
  WinMove, ahk_id %Gui1UniqueID%, , , , %Gui1W%, %Gui1H%
  ;select first scriptlet
  TV_Modify(TV_GetChild(TV_GetNext()), "Select")
Return

BuildGuiStyle2:
  Gui, 1:+Resize
  Gui, 1:Margin, 3, 3 
  Gui, 1:Add, Button, w15 Section vBtnAddGroup gBtnAddGroup, +
  Gui, 1:Add, Edit, ys+1 w190 vEdtGroupName gEdtGroupName Disabled, 
  Gui, 1:Add, Button, w15 ys vBtnRemoveGroup gBtnRemoveGroup Disabled, -
  
  Gui, 1:Add, Button, w15 xs Section vBtnAddScriptlet gBtnAddScriptlet Disabled, +
  Gui, 1:Add, Edit, ys+1 w190 vEdtScriptletName gEdtScriptletName Disabled, 
  Gui, 1:Add, Button, w15 ys vBtnRemoveScriptlet gBtnRemoveScriptlet Disabled, -

  Gui, 1:Add, DropDownList, xs Section w127 vDdbScriptletInGroup gDdbScriptletInGroup Sort Disabled, 
  Gui, 1:Add, Button, x+3 ys-1 vBtnCopyToClipboard gBtnCopyToClipboard Disabled, Copy to &Clipboard

  Gui, 1:Add, TreeView, xs w225 h500 vTrvScriptlets gTrvScriptlets
  GoSub, FileScriptletsIntoGui
  Gui, 1:Font, %FontSize%, %StrFontName% 
  Gui, 1:Add, Edit, ym w500 h577 Multi T8 vEdtScriptletData gEdtScriptletData,
  GoSub, FinishGUI
Return

BuildContextMenu:
  ;context menu for right mouse click
  Menu, ContextMenu, Add, BackUp Scriptlets, BackUpScriptlets
  Menu, ContextMenu, Add, Change Font, ChangeFont
  Menu, ContextMenu, Add, Change Font Size, ChangeFontSize
  Menu, ContextMenu, Add, 

  Menu, ContextMenu, Add, Resize TreeView Width, ToggleResizeTreeview
  If BolResizeTreeH
      Menu, ContextMenu, ToggleCheck, Resize TreeView Width
  Menu, ContextMenu, Add, Auto-Roll-Up when not active, ToggleRollUpDown
  If BolRollUpDown
      GoSub, SetRollUpDown
  Menu, ContextMenu, Add, Always On Top, ToggleAlwaysOnTop
  If BolAlwaysOnTop
      Gosub, SetAlwaysOnTop

  Menu, IntGuiStyles, Add, 1 - Open , ChooseIntGuiStyle
  Menu, IntGuiStyles, Add, 2 - Compact, ChooseIntGuiStyle
  If IntGuiStyle = 1
      Menu, IntGuiStyles, ToggleCheck, 1 - Open
  Else
      Menu, IntGuiStyles, ToggleCheck, 2 - Compact

  Menu, ContextMenu, add, Gui Styles, :IntGuiStyles
Return

GuiContextMenu:
   Menu, ContextMenu, Show
return

BackUpScriptlets:
  Gui, 1:+OwnDialogs
  FileSelectFile, SelectedFile, S18, %A_ScriptDir%, Select file to backup scriptlets, Ini file (*.ini)
  If SelectedFile {
      NormalINI = %IniFile%
      IniFile = %SelectedFile%
      GoSub, WriteINIFile
      IniFile = %NormalINI%
    }
Return
ChangeFont:
  Gui, 1:+OwnDialogs
  InputBox, OutVar, Choose Font, Specify an existing font name`nfor the scriptlet window (Default: Courier),,270,130,,,,, %StrFontName%
  If ErrorLevel 
      Return
  StrFontName = %OutVar%
  GoSub, ReRunOrReload
Return
ChangeFontSize:
  Gui, 1:+OwnDialogs
  InputBox, OutVar, Choose Font Size, Specify a font size for`nthe scriptlet window (Default: empty),,250,130,,,,, %IntFontSize%
  If ErrorLevel 
      Return
  IntFontSize = %OutVar%
  GoSub, ReRunOrReload
Return

ToggleResizeTreeview:
  BolResizeTreeH := Not BolResizeTreeH
  GoSub, ReRunOrReload
Return

ChooseIntGuiStyle:
  IntGuiStyle = %A_ThisMenuItemPos%
  GoSub, ReRunOrReload
Return

ReRunOrReload:
  GoSub, WriteINIFile
  If param_dock {
      Run, %A_AhkPath% "%A_ScriptName%" /dock %param_dock%
      ExitApp
  }Else
      Reload
Return

TrvScriptlets:
  If TreeSelectionInProcess
      Return
  TreeSelectionInProcess := True
  ID := TV_GetSelection()
  ParentID := TV_GetParent(ID)
  If ParentID {     ;its a scriptlet
      TV_GetText(GroupName, ParentID)
      TV_GetText(ScriptletName, ID)
      GuiControl,1:ChooseString, DdbScriptletInGroup, %GroupName%
      GuiControl,1:, EdtScriptletName, %ScriptletName%
      GuiControl,1:, EdtScriptletData, % %ID%Scriptlet
      GuiControl,1: Enable, EdtScriptletData
      GuiControl,1: Enable, EdtScriptletName
      GuiControl,1: Enable, BtnRemoveScriptlet
      GuiControl,1: Enable, DdbScriptletInGroup
      GuiControl,1: Enable, BtnCopyToClipboard
  }Else{
      TV_GetText(GroupName, ID)
      GuiControl,1:, EdtScriptletName,
      GuiControl,1:, EdtScriptletData,
      GuiControl,1: Disable, EdtScriptletData
      GuiControl,1: Disable, EdtScriptletName
      GuiControl,1: Disable, BtnRemoveScriptlet
      GuiControl,1: Disable, DdbScriptletInGroup
      GuiControl,1: Disable, BtnCopyToClipboard
    }
  GuiControl,1:, EdtGroupName, %GroupName%
  
  GuiControl,1: Enable, BtnAddScriptlet
  GuiControl,1: Enable, BtnRemoveGroup
  GuiControl,1: Enable, EdtGroupName
  GuiControl,1: Enable, BtnSave
  TreeSelectionInProcess := False
Return

BtnAddGroup:
  Gui, 1: Default
  ;find group name that doesn't exist yet
  Loop
      If !InStr(ListOfGroupNames, "`n" . DefaultNewGroupName . " " . A_Index . "`n"){
          NewGroupNumber := A_Index
          Break
        }
  ;add new group
  GroupName := DefaultNewGroupName " " NewGroupNumber
  ID := TV_Add(GroupName,"","Select Vis")
  ListOfGroupNames = %ListOfGroupNames%%GroupName%`n
  StringReplace, DdbScriptletInGroup, ListOfGroupNames, `n, |, All
  GuiControl, 1:, DdbScriptletInGroup, %DdbScriptletInGroup%
  GuiControl, 1:Focus, EdtGroupName
  sleep,20
  Send, +{End}
Return

EdtGroupName:
  ;check if new group name already exists
  GuiControlGet, EdtGroupName 
  If InStr(ListOfGroupNames, "`n" EdtGroupName "`n")
      Return

  ;get group id
  Gui, 1: Default
  ID := TV_GetSelection()
  ParentID := TV_GetParent(ID)
  If ParentID      ;its a scriptlet
      ID = %ParentID%
  
  ;replace old name with new one in list
  TV_GetText(GroupName, ID)  
  StringReplace, ListOfGroupNames, ListOfGroupNames, `n%GroupName%`n, `n%EdtGroupName%`n
  StringReplace, DdbScriptletInGroup, ListOfGroupNames, `n, |, All
  GuiControl, 1:, DdbScriptletInGroup, %DdbScriptletInGroup%

  ;change name in tree
  TV_Modify(ID, "", EdtGroupName) 
  TV_Modify(0, "Sort") 
Return

BtnRemoveGroup:
  Gui, 1: Default
  ;get group id
  ID := TV_GetSelection()
  ParentID := TV_GetParent(ID)
  If ParentID      ;its a scriptlet
      ID = %ParentID%

  ;get group name
  TV_GetText(GroupName, ID)
  
  MsgBox, 4, Delete Scriptlet Group?,
    (LTrim
      Please confirm deletion of current scriptlet group:
      %GroupName%
      
      This will also remove all scriptlets in that group !!!
    )
  IfMsgBox, Yes
    {
      ;get first scriptlet in that group and loop over all its siblings
      ScriptletID := TV_GetChild(ID)
      Loop {
          If !ScriptletID
              break
          ;remove scriptlet from memory
          %ScriptletID%Scriptlet =
          ;get next sibling in that group
          ScriptletID := TV_GetNext(ScriptletID)
        }
      ;remove group
      TV_Delete(ID) 
      ;remove group name from list
      StringReplace, ListOfGroupNames, ListOfGroupNames, `n%GroupName%`n, `n
      StringReplace, DdbScriptletInGroup, ListOfGroupNames, `n, |, All
      GuiControl, 1:, DdbScriptletInGroup, %DdbScriptletInGroup%
    }
Return

BtnAddScriptlet:
  Gui, 1: Default
  ;get group id
  ID := TV_GetSelection()
  ParentID := TV_GetParent(ID)
  If ParentID      ;its a scriptlet
      ID = %ParentID%

  ;add new scriptlet
  ScriptletNameIndex++
  ScriptletName = %DefaultNewScriptletName% %ScriptletNameIndex%
  ID := TV_Add(ScriptletName,ID,"Sort Select Vis")
  %ID%Scriptlet =
  GuiControl, 1:Focus, EdtScriptletName
  sleep,20
  Send, +{End}
Return

EdtScriptletName:
  Gui, 1: Default
  ;get scriptlet id
  ID := TV_GetSelection()
  ParentID := TV_GetParent(ID)
  If !ParentID      ;its a group
      Return

  GuiControlGet, EdtScriptletName 
  ;change name in tree
  TV_Modify(ID, "", EdtScriptletName) 
  TV_Modify(ID, "Sort") 
Return

BtnRemoveScriptlet:
  Gui, 1: Default
  ;get scriptlet id
  ID := TV_GetSelection()
  ParentID := TV_GetParent(ID)
  If !ParentID      ;its a group
      Return

  ;get scriptlet name
  TV_GetText(ScriptletName, ID)
  
  MsgBox, 4, Delete Scriptlet?,
    (LTrim
      Please confirm deletion of current scriptlet:
      %ScriptletName%
    )
  IfMsgBox, Yes
    {
      ;remove scriptlet from memory
      %ID%Scriptlet =
      ;remove group
      TV_Delete(ID) 
    }
Return

DdbScriptletInGroup:
  If TreeSelectionInProcess
      Return
  TreeSelectionInProcess := True
  Gui, 1: Default
  ;get scriptlet id and name
  ID := TV_GetSelection()
  ParentID := TV_GetParent(ID)
  If !ParentID      ;its a group
      Return
  TV_GetText(ScriptletName, ID)
  
  ;get new group ID
  GuiControlGet, DdbScriptletInGroup
  GroupID := TV_GetNext()
  Loop {
      If !GroupID
          Return
      TV_GetText(GrouptName, GroupID)
      If (GrouptName = DdbScriptletInGroup)    
          Break
      GroupID := TV_GetNext(GroupID)
    }
  ;create new key and delete old one
  NewID := TV_Add(ScriptletName,GroupID, "Sort Select Vis")
  %NewID%Scriptlet := %ID%Scriptlet
  TV_Delete(ID)
  %ID%Scriptlet =
  TreeSelectionInProcess := False
Return

EdtScriptletData:
  If TreeSelectionInProcess
      Return
  Gui, 1: Default
  ;get scriptlet id
  ID := TV_GetSelection()
  ParentID := TV_GetParent(ID)
  If !ParentID      ;its a group
      Return

  GuiControlGet, EdtScriptletData
  %ID%Scriptlet = %EdtScriptletData%
Return

BtnCopyToClipboard:
  GuiControlGet, EdtScriptletData
  Clipboard = %EdtScriptletData%
  If BolRollUpDown
      RollGuiUp(ScriptName)
Return

GuiEscape:
GuiClose:
2GuiClose:
  GoSub, WriteINIFile
  ExitApp
Return

WriteINIFile:
  If GuiRolledUp
      DllCall("AnimateWindow","UInt",Gui1UniqueID,"Int",0,"UInt","0x20005")
;      RollGuiDown(1, 1, 1, 1)
  FileDelete, %IniFile%
  WinGetPos, PosX, PosY, SizeW, SizeH, ahk_id %Gui1UniqueID%
  IniWrite, x%PosX% y%PosY% , %IniFile%, Settings, Gui1Pos
  IniWrite, %SizeW% , %IniFile%, Settings, Gui1W
  IniWrite, %SizeH% , %IniFile%, Settings, Gui1H
  IniWrite, %IntGuiStyle%, %IniFile%, Settings, IntGuiStyle
  IniWrite, %BolResizeTreeH%, %IniFile%, Settings, BolResizeTreeH
  IniWrite, %BolRollUpDown%,  %IniFile%, Settings, BolRollUpDown
  IniWrite, %BolAlwaysOnTop%, %IniFile%, Settings, BolAlwaysOnTop
  IniWrite, %StrFontName%,    %IniFile%, Settings, StrFontName
  IniWrite, %IntFontSize%,    %IniFile%, Settings, IntFontSize
  FileAppend, `n`n, %IniFile%
  
  ID = 0
  Gui, 1: Default
  ScriptletString = 
  Loop {
      ID := TV_GetNext(ID, "Full")
      If not ID
        break
      TV_GetText(Name, ID)
      ParentID := TV_GetParent(ID)
      If ParentID { ;it's a scriptlet
          Scriptlet := %ID%Scriptlet
          ScriptletString = %ScriptletString%%ScriptletStartString%%Name%`n%Scriptlet%`n%ScriptletEndString%%Name%`n`n`n
      }Else
          ScriptletString = %ScriptletString%%GroupStartString%%Name%`n

      ;remove the `n if no extra line break should be in the INI file
      If (Mod(A_index, 100)=0) {
          FileAppend, %ScriptletString%`n, %IniFile%
          ScriptletString =
        }
    }
  If ScriptletString
      FileAppend, %ScriptletString%`n, %IniFile%
Return

ToggleRollUpDown:
  BolRollUpDown := Not BolRollUpDown
SetRollUpDown:
  Menu, ContextMenu, ToggleCheck, Auto-Roll-Up when not active
  If BolRollUpDown {
      SetTimer, CheckIfActive, On
  }Else{
      SetTimer, CheckIfActive, Off
    }
Return

CheckIfActive:
  IfWinNotActive, ahk_id %Gui1UniqueID%
      RollGuiUp(ScriptName)
Return

RollGuiUp(BarName, vertical = "") {
    global Gui1UniqueID, GuiRolledUp
    SetTimer, CheckIfActive, Off
    WM_NCMouseMove = 0xA0
    OnMessage(WM_NCMouseMove , "RollGuiDown")
    WinGetPos, Gui1X, Gui1Y, , , ahk_id %Gui1UniqueID%
    Gui, 2: +ToolWindow -SysMenu +AlwaysOnTop 
    If vertical
        Gui, 2:Show, w0 h100 x%Gui1X% y%Gui1Y% NoActivate, %BarName%  ;vertical bar
    Else
        Gui, 2:Show, w150 h0 x%Gui1X% y%Gui1Y% NoActivate, %BarName%  ;horizontal bar
    DllCall("AnimateWindow","UInt",Gui1UniqueID,"Int",200,"UInt","0x3000a")
    GuiRolledUp := True
 }

RollGuiDown(wParam, lParam, msg, hwnd) {
    global Gui1UniqueID, GuiRolledUp
    WM_NCMouseMove = 0xA0
    OnMessage(WM_NCMouseMove , "")
    DllCall("AnimateWindow","UInt",Gui1UniqueID,"Int",200,"UInt","0x20005")
    WinActivate, ahk_id %Gui1UniqueID%
    SetTimer, CheckIfActive, On 
    Gui, 2:Destroy
    GuiRolledUp := False
  }

ToggleAlwaysOnTop:
  BolAlwaysOnTop := not BolAlwaysOnTop
SetAlwaysOnTop:
  Menu, ContextMenu, ToggleCheck, Always On Top
  WinGetTitle, CurrentTitle , ahk_id %Gui1UniqueID%
  If BolAlwaysOnTop {
        Gui, 1: +AlwaysOnTop
        WinSetTitle, ahk_id %Gui1UniqueID%, , %CurrentTitle% - *AOT*
  }Else{
        Gui, 1: -AlwaysOnTop
        StringTrimRight, CurrentTitle, CurrentTitle, 8
        WinSetTitle, ahk_id %Gui1UniqueID%, , %CurrentTitle%
    }
Return

;#Include ..\Anchor\Anchor_v3.3.ahk
#Include Anchor.ahk
GuiSize:
  If BolResizeTreeH {
      If (IntGuiStyle = 1) {
          ;       ControlName         , xwyh with factors [, True for MoveDraw]
          Anchor("EdtGroupName"       , "      w0.5   ")
          Anchor("BtnRemoveGroup"     , "x0.5         ")
          Anchor("BtnAddScriptlet"    , "x0.5         ")
          Anchor("EdtScriptletName"   , "x0.5  w0.25  ")
          Anchor("BtnRemoveScriptlet" , "x0.75        ")
          Anchor("DdbScriptletInGroup", "x0.75 w0.25  ")
          Anchor("BtnCopyToClipboard" , "x            ")
    
          Anchor("TrvScriptlets"      , "      w0.5  h")
          Anchor("EdtScriptletData"   , "x0.5  w0.5  h")
      }Else{
          ;       ControlName         , xwyh with factors [, True for MoveDraw]
          Anchor("EdtGroupName"       , "      w0.3   ")
          Anchor("BtnRemoveGroup"     , "x0.3         ")
          Anchor("EdtScriptletName"   , "      w0.3   ")
          Anchor("BtnRemoveScriptlet" , "x0.3         ")
          Anchor("DdbScriptletInGroup", "      w0.3   ")
          Anchor("BtnCopyToClipboard" , "x0.3            ")
    
          Anchor("TrvScriptlets"      , "      w0.3  h")
          Anchor("EdtScriptletData"   , "x0.3  w0.7  h")
        }
  }Else{
      Anchor("TrvScriptlets"      , "h")
      Anchor("EdtScriptletData"   , "wh")
    }
Return
