;-- Original coding for the HiEdit control written by skwire.
;-- Original highlighting file for the HiEdit control provided by skwire.
;**********************************************
;*                                            *
;*                                            *
;*                                            *
;*                                            *
;*                Main program                *
;*                                            *
;*                                            *
;*                                            *
;*                                            *
;**********************************************
$Version:="2.2"

;*************************
;*                       *
;*    AHK environment    *
;*                       *
;*************************
#ClipboardTimeout 1500
#NoEnv
#NoTrayIcon
#SingleInstance Off
ListLines Off
SetBatchLines 30ms  ;-- A little bump in speed

;-- Is this program already running?
AlreadyRunning()

;********************
;*                  *
;*    Initialize    *
;*                  *
;********************
;[==========]
;[  Global  ]
;[==========]
SplitPath A_ScriptName,,,,$ScriptName
$ConfigFile     :=A_ScriptDir . "\" . $ScriptName . ".ini"
$EditDir        :=A_ScriptDir . "\Edit"
$EditFile       :=$EditDir . "\" . $ScriptName . "_EditScript.ahk"
$EditBackupFile :=$EditDir . "\" . $ScriptName . "_EditScript.bak"
$HelpFile       :=A_ScriptDir . "\" . $ScriptName . ".chm"
$LibDir         :=A_ScriptDir . "\Lib"
$RPDir          :=A_ScriptDir . "\Restore"
$RunDir         :=A_ScriptDir . "\Run"
$RunFile        :=$RunDir . "\" . $ScriptName . "_RunScript.ahk"

$Resize         :=True
$Running        :=False
$BatchLines     :=A_BatchLines
Dlg_Flags       :="d"

;[=============]
;[  Constants  ]
;[=============]
;-- General Win32
WM_USER                       :=0x400   ;-- 1024
WM_RBUTTONUP                  :=0x205   ;-- 517

;-- Edit
EM_LINESCROLL                 :=0xB6
EM_SCROLLCARET                :=0xB7

;-- Cursor
IDC_WAIT                      :=0x32514

;-- Toolbar
TB_LOADIMAGES                 :=0x432

IDB_STD_SMALL_COLOR           :=0x0
IDB_STD_LARGE_COLOR           :=0x1
IDB_VIEW_SMALL_COLOR          :=0x4
IDB_VIEW_LARGE_COLOR          :=0x5
IDB_HIST_SMALL_COLOR          :=0x8
IDB_HIST_LARGE_COLOR          :=0x9

HINST_COMMCTRL                :=0xFFFFFFFF  ; (-1)

TB_GETMETRICS                 :=WM_USER+101
TB_SETMETRICS                 :=WM_USER+102
TBMF_PAD                      :=0x00000001
TBMF_BARPAD                   :=0x00000002  ;-- Not used (msdn)
TBMF_BUTTONSPACING            :=0x00000004

TB_GETPADDING                 :=0x456
TB_SETPADDING                 :=0x457

;-- GetLocaleInfo
LOCALE_USER_DEFAULT           :=0x400
LOCALE_IMEASURE               :=0xD
LOCALE_RETURN_NUMBER          :=0x20000000

;-- Page Setup
PSD_MARGINS                   :=0x2
PSD_INTHOUSANDTHSOFINCHES     :=0x4
PSD_INHUNDREDTHSOFMILLIMETERS :=0x8
PSD_DISABLEMARGINS            :=0x10
PSD_DISABLEPRINTER            :=0x20   ;-- Obsolete (msdn)
PSD_DISABLEORIENTATION        :=0x100
PSD_DISABLEPAPER              :=0x200
PSD_RETURNDEFAULT             :=0x400
PSD_ENABLEPAGESETUPTEMPLATE   :=0x8000

;-- Page/Printer
DMORIENT_PORTRAIT             :=0x1
DMORIENT_LANDSCAPE            :=0x2

;-- Data
$FieldDelimiter               :=Chr(139) . Chr(134) . Chr(155)
$RecordDelimiter              :=Chr(171) . Chr(135) . Chr(187)
$iniBorder                    :=Chr(142)

;-- Font
$DefaultFont                  :="Lucida Console"
$DefaultFontSize              :=10
$RPViewerDefaultFontSize      :=8
$MinimumFontSize              :=01
$MaximumFontSize              :=99

;-- Menu items
s_About_MI                    :="&About..."
s_AlwaysOnTop_MI              :="&Always On Top`tCtrl+Shift+A"
s_BlockComment_MI             :="Block Comment`tCtrl+Q"
s_BlockUncomment_MI           :="Block Uncomment`tCtrl+Shift+Q"
s_ClearRunWorkspaceOnExit_MI  :="Clear Run Workspace on Exit"
s_ClearRunWorkspaceOnRun_MI   :="Clear Run Workspace on Run"
s_ConvertCase_MI              :="Con&vert Case"
s_Copy_MI                     :="&Copy`tCtrl+C"
s_Cut_MI                      :="Cu&t`tCtrl+X"
s_Delete_MI                   :="Delete`tDel"
s_File_Stop_MI                :="S&top`tF10"
s_Find_MI                     :="&Find...`tCtrl+F"
s_FindNext_MI                 :="Find &Next`tF3"
s_FindPrevious_MI             :="Find Previous`tShift+F3"
s_Goto_MI                     :="&Go To...`tCtrl+G"
s_Help_MI                     :="&Help`tF1"
s_LineNumbersBar_MI           :="&Line Numbers Bar`tCtrl+L"
s_MenuBar_MI                  :="&Menu Bar`tCtrl+Shift+M"
s_Menubar_Stop_MI             :="S&top"
s_New_MI                      :="&New`tCtrl+N"
s_PageSetup_MI                :="Page Set&up...`tCtrl+Shift+P"
s_Paste_MI                    :="&Paste`tCtrl+V"
s_PasteC_MI                   :="PasteC`tF5"
s_Prepend_New_MI              :="Prepend N&ew`tCtrl+Shift+N"
s_Print_MI                    :="&Print...`tCtrl+P"
s_Redo_MI                     :="&Redo`tCtrl+Y"
s_Replace_MI                  :="R&eplace...`tCtrl+H"
s_Run_MI                      :="&Run`tF9"
s_RunDebug_MI                 :="Append Debug Script"
s_RunPrompt_MI                :="Prompt For Parameters"
s_RunSelected_MI              :="Run Selec&ted`tCtrl+F9"
s_RunWait_MI                  :="Wait For Script to Complete"
s_Save_MI                     :="&Save`tCtrl+S"
s_SaveTo_MI                   :="S&ave To...`tF12"
s_SelectAll_MI                :="Select A&ll`tCtrl+A"
s_StatusBar_MI                :="&Status Bar`tCtrl+Shift+S"
s_ToolBar_MI                  :="&Toolbar`tCtrl+T"
s_Undo_MI                     :="&Undo`tCtrl+Z"

;[==================]
;[  System metrics  ]
;[==================]
SysGet SM_CYCAPTION,4
    ;-- Height of a regular size caption area (title bar), in pixels.

SysGet SM_CYMENU,15
    ;-- Height of a single-line menu bar, in pixels.

SysGet SM_CXSIZEFRAME,32
    ;-- The width (in pixels) of the horizontal border for a window that can be
    ;   resized.

SysGet SM_CYSIZEFRAME,33
    ;-- The height (in pixels) of the vertical border for a window that can be
    ;   resized.

;-- Collect work area dimensions for primary monitor
SysGet $MonitorWorkArea,MonitorWorkArea
$MonitorWorkAreaWidth:=$MonitorWorkAreaRight-$MonitorWorkAreaLeft


;-- Compute maximum width of toolbar and GUI object
$MaxGUIW:=$MonitorWorkAreaWidth
    ;-- Width of the GUI when maximized (no vertical borders)

;[=================]
;[  GetLocaleInfo  ]
;[=================]
;-- Get locale system of measurement (0=Metric, 1=English)
VarSetCapacity(lpLCData,4,0)
DllCall("GetLocaleInfo"
    ,"UInt",LOCALE_USER_DEFAULT
    ,"UInt",LOCALE_IMEASURE|LOCALE_RETURN_NUMBER
    ,"UInt",&lpLCData
    ,"UInt",4)

if NumGet(lpLCData,0,"Unit")=0  ;-- 0=HiMetric (hundredths of millimeters)
    $MarginDefault:=1270        ;-- 12.7 mm (0.5 inch)
 else                           ;-- 1=HiEnglish (thousandths of inches)
    $MarginDefault:=500         ;-- 0.5 inch


;*****************
;*               *
;*    Process    *
;*               *
;*****************
;-- Set to full speed just to get started
SetBatchLines -1

;-- Process
gosub ReadConfiguration
gosub QAHKGUI

;-- Reset speed to program default
SetBatchLines %$BatchLines%
return



;*******************************************
;*                                         *
;*                                         *
;*                                         *
;*                                         *
;*                Functions                *
;*                                         *
;*                                         *
;*                                         *
;*                                         *
;*******************************************
#include _Functions\AddCommas.ahk
#include _Functions\AlreadyRunning.ahk
#include _Functions\Attach.ahk
#include _Functions\CompressFileName.ahk
#include _Functions\DDLManager.ahk
#include _Functions\Dlg.ahk
#include _Functions\FileMD5.ahk
#include _Functions\HiEdit.ahk
#include _Functions\InfoGUI.ahk
#include _Functions\MRUManager.ahk
#include _Functions\PopupXY.ahk
#include _Functions\SecondsToHHMMSS.ahk
#include _Functions\SetSystemCursor.ahk
#include _Functions\SystemMessage.ahk
#include _Functions\Toolbar.ahk


;**********************
;*                    *
;*    WM_RBUTTONUP    *
;*                    *
;**********************
WM_RBUTTONUP(wParam,lParam,msg,hWnd)
    {
    SetTimer QAHKGUI_ContextMenu2,0
    Return 0
    }


;***********************
;*                     *
;*    Block Comment    *
;*                     *
;***********************
HE_BlockComment(hEdit,p_Cmd="",p_BCChars="")
    {
    ;[=============]
    ;[  Intialize  ]
    ;[=============]
    l_NewText:=""
    l_XFactor:=0

    ;[==============]
    ;[  Parameters  ]
    ;[==============]
    ;-- p_Cmd
    if p_Cmd not in Add,Insert,Remove,Delete
        p_Cmd=Insert

    ;-- p_BCChars
    if StrLen(p_BCChars)=0
        p_BCChars:=";;;;;"  ;-- 5 semicolons (default)
            ;-- Programming note:  This was added as a convenience and as a
            ;   fail-safe.  The p_BCChars parameter cannot be empty/null.

    ;[===============]
    ;[  Preliminary  ]
    ;[===============]
    ;-- Get user select positions
    HE_GetSel(hEdit,l_StartSelPos,l_EndSelPos)

    ;-- Get position of the beginning of the line
    l_FirstCharPos:=HE_LineIndex(hEdit,HE_LineFromChar(hEdit,l_StartSelPos))

    ;-- Reselect if the user selection does not start at the beginning of the line
    if (l_FirstCharPos<>l_StartSelPos)
        HE_SetSel(hEdit,l_FirstCharPos,l_EndSelPos)

    ;-- Get selected text
    l_SelectedText:=HE_GetSelText(hEdit)

    ;[=========]
    ;[  Shift  ]
    ;[=========]
    if p_Cmd in Add,Insert
        {
        ;--------------
        ;-- Add/Insert
        ;--------------
        if StrLen(l_SelectedText)=0
            l_NewText:=p_BCChars
         else
            {
            ;-- Is last character a NL?
            l_LastSelChar:=""
            if SubStr(l_SelectedText,0)="`n"
                {
                l_LastSelChar:="`n"
                StringTrimRight l_SelectedText,l_SelectedText,1
                }

            ;-- Shift it
            Loop Parse,l_SelectedText,`n,`r
                {
                if StrLen(l_NewText)=0
                    l_NewText:=p_BCChars . A_LoopField
                 else
                    l_NewText.="`n" . p_BCChars . A_LoopField
                }

            ;-- Append last char if needed
            if StrLen(l_LastSelChar)
                l_NewText.=l_LastSelChar
            }

        ;-- Replace selected text with l_NewText
        HE_ReplaceSel(hEdit,l_NewText)

        ;-- Calculate new start/end select positions
        if (l_StartSelPos=l_EndSelPos)  ;-- User selected nothing
            {
            l_NewStartSelPos:=l_StartSelPos+StrLen(p_BCChars)
            l_NewEndSelPos  :=l_NewStartSelPos
            }
         else
            ;-- Cursor on the 1st char of the line?
            if (l_StartSelPos=l_FirstCharPos)
                {
                l_NewStartSelPos:=l_StartSelPos
                l_NewEndSelPos  :=l_StartSelPos+StrLen(l_NewText)
                }
             else
                {
                l_NewStartSelPos:=l_StartSelPos+StrLen(p_BCChars)
                l_NewEndSelPos  :=l_StartSelPos+StrLen(l_NewText)-(l_StartSelPos-l_FirstCharPos)
                }

        ;-- Reselect text
        HE_SetSel(hEdit,l_NewStartSelPos,l_NewEndSelPos)
        }
     else
        {
        ;-----------------
        ;-- Remove/Delete
        ;-----------------
        ;-- On a single line at the beginning of the line?
        if StrLen(l_SelectedText)=0
            {
            ;-- Able to look forward?
            if (l_StartSelPos<=(HE_GetTextLength(hEdit)-StrLen(p_BCChars)))
                ;-- Look forward to see if the first characters are at the
                ;   beginning of the a comment block
                if HE_GetTextRange(hEdit,l_StartSelPos,l_StartSelPos+StrLen(p_BCChars))=p_BCChars
                    {
                    ;-- Reselect and recapture
                    HE_SetSel(hEdit,l_StartSelPos,l_StartSelPos+StrLen(p_BCChars))
                    l_SelectedText:=HE_GetSelText(hEdit)
                    }
            }

        ;-- Process
        if StrLen(l_SelectedText)
            {
            ;-- Remove p_BCChars from the beginning of each line
            Loop Parse,l_SelectedText,`n
                {
                l_LoopField:=A_LoopField

                ;-- Remove p_BCChars if first characters
                if SubStr(l_LoopField,1,StrLen(p_BCChars))=p_BCChars
                    StringTrimLeft l_LoopField,l_LoopField,% StrLen(p_BCChars)

                ;-- Append to l_NewText
                if A_Index=1
                    l_NewText:=l_LoopField
                 else
                    l_NewText.="`n" . l_LoopField
                }
            }

        ;-- Replace selected text with l_NewText
        HE_ReplaceSel(hEdit,l_NewText)

        ;-- Calculate XFactor for reselection
        if SubStr(l_SelectedText,1,StrLen(p_BCChars))=p_BCChars
            {
            if (l_StartSelPos>l_FirstCharPos)
                if (l_StartSelPos-l_FirstCharPos)>StrLen(p_BCChars)
                    l_XFactor:=StrLen(p_BCChars)
                 else
                    l_XFactor:=l_StartSelPos-l_FirstCharPos
            }

        ;-- Calculate new start/end select positions
        if StrLen(l_SelectedText)=0     ;-- Nothing programmatically selected
        or (l_SelectedText=l_NewText)   ;-- Nothing changed
            {
            l_NewStartSelPos:=l_StartSelPos
            l_NewEndSelPos  :=l_EndSelPos
            }
         else
            {
            l_NewStartSelPos:=l_StartSelPos-l_XFactor
            l_NewEndSelPos  :=l_StartSelPos+StrLen(l_NewText)-(l_StartSelPos-l_FirstCharPos)
            }

        ;-- Reselect text
        HE_SetSel(hEdit,l_NewStartSelPos,l_NewEndSelPos)
        }

    ;[===============]
    ;[  Scroll left  ]
    ;[===============]
    HE_LineScroll(hEdit,-999999)
        ;-- Fixes a display problem that sometimes occurs if working with lines
        ;   that are wider than the control

    return
    }


;********************
;*                  *
;*    Shift Line    *
;*                  *
;********************
HE_ShiftLine(hEdit,p_Cmd="",p_Chars="")
    {
    ;[=============]
    ;[  Intialize  ]
    ;[=============]
    l_NewText=
    l_Reselect:=True

    ;[==============]
    ;[  Parameters  ]
    ;[==============]
    ;-----------
    ;-- p_Chars
    ;-----------
    if StrLen(p_Chars)=0
        {
        p_Chars:="    "  ;-- 4 spaces (Default)
        l_AllSpaces:=True
        }
     else
        {
        l_AllSpaces:=True
        Loop Parse,p_Chars
            {
            if (A_LoopField<>A_Space)
                {
                l_AllSpaces:=False
                Break
                }
            }
        }

    ;---------
    ;-- p_Cmd
    ;---------
    if p_Cmd not in Add,Insert,Remove,Delete
        p_Cmd=Insert

    ;[===========]
    ;[  Process  ]
    ;[===========]
    ;-- Get select positions
    HE_GetSel(hEdit,l_StartSelPos,l_EndSelPos)

    ;-- Get selected text
    l_SelectedText:=HE_GetSelText(hEdit)

    ;[==============]
    ;[  Shift line  ]
    ;[==============]
    if p_Cmd in Insert,Add
        {
        ;----------------------------
        ;-- Insert/Add (Shift right)
        ;----------------------------
        if StrLen(l_SelectedText)=0
            {
            l_NewText:=p_Chars

            ;-- If necessary, trim to account for column spacing
            if l_AllSpaces
                StringTrimRight
                    ,l_NewText
                    ,l_NewText
                    ,% Mod(l_StartSelPos-HE_LineIndex(hEdit,-1),StrLen(l_NewText))

            ;-- Programming note: This small adjustment (only performed if
            ;   p_Chars contains only space characters) helps to insure that
            ;   text is shifted to columns that are equal to a factor of the
            ;   length of p_Chars.
            }
         else
            {
            ;-- Is last character a NL?
            l_LastSelChar=
            if SubStr(l_SelectedText,0)="`n"
                {
                l_LastSelChar:="`n"
                StringTrimRight l_SelectedText,l_SelectedText,1
                }

            ;-- Single line?
             if InStr(l_SelectedText . l_LastSelChar,"`n")=0
            and HE_GetLine(hEdit)<>l_SelectedText
                {
                l_NewText :=p_Chars
                l_Reselect:=False
                }
             else
                ;- Shift it
                {
                Loop Parse,l_SelectedText,`n
                    {
                    if StrLen(l_NewText)=0
                        l_NewText:=p_Chars . A_LoopField
                     else
                        l_NewText.="`n" . p_Chars . A_LoopField
                    }
                }

            ;-- Append last char (if needed)
            l_NewText.=l_LastSelChar
            }
        }
     else
        {
        ;-----------------------
        ;-- Remove (Shift left)
        ;-----------------------
        if StrLen(l_SelectedText)=0
            {
            ;-- Check to see if the preceding chars are equal to p_Chars
            l_StartLinePos:=HE_LineIndex(hEdit,-1)
            if (l_StartSelPos>l_StartLinePos)
                {
                ;-- Get the line in question
                l_CurrentLine:=HE_GetLine(hEdit,-1)

                ;-- Init l_NewStartSelPos
                l_NewStartSelPos:=l_StartSelPos

                ;-- Enough characters to match p_Chars?
                if (l_StartSelPos-l_StartLinePos)>=StrLen(p_Chars)
                    {
                    if SubStr(l_CurrentLine,(l_StartSelPos-l_StartLinePos+1)-StrLen(p_Chars),StrLen(p_Chars))=p_Chars
                        l_NewStartSelPos:=l_StartSelPos-StrLen(p_Chars)
                    }

                ;-- One more chance.  If p_Chars are "all spaces", look for any
                ;   trailing spaces.
                if l_AllSpaces and (l_NewStartSelPos=l_StartSelPos)
                    {
                    Loop % StrLen(p_Chars)
                        {
                        if SubStr(l_CurrentLine,(l_StartSelPos-l_StartLinePos+1)-A_Index,1)=A_Space
                            l_NewStartSelPos--
                         else
                            Break
                        }
                    }

                ;-- Reselect if necessary
                if (l_NewStartSelPos<>l_StartSelPos)
                    {
                    l_StartSelPos:=l_NewStartSelPos
                    HE_SetSel(hEdit,l_StartSelPos,l_EndSelPos)

                    ;-- Get selected text
                    l_SelectedText:=HE_GetSelText(hEdit)
                    }
                }
            }

        if StrLen(l_SelectedText)
            {
            ;-- Remove p_Chars from the beginning of each line
            if StrLen(l_SelectedText)
                {
                Loop Parse,l_SelectedText,`n
                    {
                    ;-- Assign to l_LoopField
                    l_LoopField:=A_LoopField

                    ;-- All spaces?
                    if l_AllSpaces
                        {
                        ;-- Remove full or partial space indention
                        Loop % StrLen(p_Chars)
                            {
                            ;-- Not a space?
                            if SubStr(l_LoopField,1,1)<>A_Space
                                Break

                            ;-- Trim it
                            StringTrimLeft l_LoopField,l_LoopField,1
                            }
                        }
                     else
                        {
                        ;-- Remove p_Chars if leading characters and exact
                        if SubStr(l_LoopField,1,StrLen(p_Chars))=p_Chars
                            StringTrimLeft
                                ,l_LoopField
                                ,l_LoopField
                                ,% StrLen(p_Chars)
                        }

                    ;-- Append to l_NewText
                    if StrLen(l_NewText)=0
                        l_NewText:=l_LoopField
                     else
                        l_NewText.="`n" . l_LoopField
                    }
                }
            }
        }

    ;-- Replace selected text with l_NewText
    HE_ReplaceSel(hEdit,l_NewText)

    ;-- Reselect text
    if l_Reselect and StrLen(l_SelectedText)
        HE_SetSel(hEdit,l_StartSelPos,l_StartSelPos+StrLen(l_NewText))

    return
    }


;******************
;*                *
;*    HE_Print    *
;*                *
;******************
;
;
;   Description
;   ===========
;   Simple WYSIWYG print function for the HiEdit control.
;
;
;
;   Parameters
;   ==========
;
;       Name            Description
;       ----            -----------
;       hEdit           Handle to the HiEdit control.
;
;       p_Owner         Handle to the owner window.  [Optional]
;
;
;       p_MarginLeft    Page margins based upon the locale system of
;       p_MarginTop     measurement -- English or Metric. [Optional]  If
;       p_MarginRight   English, the margin is measured in thousandths of
;       p_MarginBottom  inches.  If metric, the margin is measured in hundredths
;                       of millimeters.
;
;                       English example: To get a 0.5 inch margin (12.7 mm), set
;                       the margin to 500.
;
;                       Metric example: To get a 25.40 mm margin (1 inch English
;                       equivalent), set the margin to 2540.
;
;
;   Credit
;   ======
;   Some of the ideas/code for this function was extracted from the source code
;   for the HiEditor demo program ("Print" procedure) and from the Notepad2
;   source code ("Print.cpp").
;
;-------------------------------------------------------------------------------
HE_Print(hEdit
        ,p_Owner=""
        ,p_MarginLeft=""
        ,p_MarginTop=""
        ,p_MarginRight=""
        ,p_MarginBottom="")
    {
    ;[====================]
    ;[  Global variables  ]
    ;[====================]
    Global $LineNumbersBar
                ;-- Set this global variable to TRUE if the line numbers bar
                ;   is showing, otherwise set it to FALSE
          ,hDevMode
          ,hDevNames

    ;[====================]
    ;[  Static variables  ]
    ;[====================]
    Static PD_ALLPAGES          :=0x0
          ,PD_SELECTION         :=0x1
          ,PD_PAGENUMS          :=0x2
          ,PD_NOSELECTION       :=0x4
          ,PD_NOPAGENUMS        :=0x8
          ,PD_RETURNDC          :=0x100
          ,PD_RETURNDEFAULT     :=0x400
          ,PD_ENABLEPRINTHOOK   :=0x1000    ;-- Not used (for now)
          ,PD_USEDEVMODECOPIES  :=0x40000   ;-- Same as PD_USEDEVMODECOPIESANDCOLLATE
          ,PD_DISABLEPRINTTOFILE:=0x80000
          ,PD_HIDEPRINTTOFILE   :=0x100000

          ,LOCALE_USER_DEFAULT  :=0x400
          ,LOCALE_IMEASURE      :=0xD
          ,LOCALE_RETURN_NUMBER :=0x20000000

          ,MM_TEXT              :=0x1
          ,HORZRES              :=0x8
          ,VERTRES              :=0xA
          ,LOGPIXELSX           :=0x58
          ,LOGPIXELSY           :=0x5A
          ,PHYSICALWIDTH        :=0x6E
          ,PHYSICALHEIGHT       :=0x6F
          ,PHYSICALOFFSETX      :=0x70
          ,PHYSICALOFFSETY      :=0x71

          ,WM_USER              :=0x400 ;-- 1024

          ,EM_EXGETSEL          :=1076  ;-- WM_USER+52
          ,EM_FORMATRANGE       :=1081  ;-- WM_uSER+57
          ,EM_SETTARGETDEVICE   :=1096  ;-- WM_USER+72
          ,WM_GETTEXTLENGTH     :=0xE

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    SplitPath A_ScriptName,,,,l_ScriptName

    ;-- Get locale system of measurement (0=Metric, 1=English)
    VarSetCapacity(lpLCData,4,0)
    DllCall("GetLocaleInfo"
        ,"UInt",LOCALE_USER_DEFAULT
        ,"UInt",LOCALE_IMEASURE|LOCALE_RETURN_NUMBER
        ,"UInt",&lpLCData
        ,"UInt",4)

    l_LOCALE_IMEASURE:=NumGet(lpLCData,0,"Unit")
    if l_LOCALE_IMEASURE=0      ;-- 0=HiMetric (hundredths of millimeters)
        l_LocaleUnits:=2540
     else                       ;-- 1=HiEnglish (thousandths of inches)
        l_LocaleUnits:=1000

    ;[==============]
    ;[  Parameters  ]
    ;[==============]
    if p_MarginLeft is not Integer
        p_MarginLeft:=l_LocaleUnits/2   ;-- (0.5 inch or 12.7 mm)

    if p_MarginTop is not Integer
        p_MarginTop:=l_LocaleUnits/2

    if p_MarginRight is not Integer
        p_MarginRight:=l_LocaleUnits/2

    if p_MarginBottom is not Integer
        p_MarginBottom:=l_LocaleUnits/2

    ;[================]
    ;[  Prep to call  ]
    ;[    PrintDlg    ]
    ;[================]
    ;-- Define/Populate the PRINTDLG structure
    VarSetCapacity(PRINTDLG_Structure,66,0)
    NumPut(66,PRINTDLG_Structure,0,"UInt")                  ;-- lStructSize

    if p_Owner is Integer
        Numput(p_Owner,PRINTDLG_Structure,4,"UInt")         ;-- hwndOwner

    if hDevMode is Integer
        NumPut(hDevMode,PRINTDLG_Structure,8,"UInt")        ;-- hDevMode

    if hDevNames is Integer
        NumPut(hDevNames,PRINTDLG_Structure,12,"UInt")      ;-- hDevMode

    ;-- Collect start/End select positions
    VarSetCapacity(CHARRANGE_Structure,8,0)
    SendMessage EM_EXGETSEL,0,&CHARRANGE_Structure,,ahk_id %hEdit%
    l_StartSelPos:=NumGet(CHARRANGE_Structure,0,"Int")      ;-- cpMin
    l_EndSelPos  :=NumGet(CHARRANGE_Structure,4,"Int")      ;-- cpMax
        ;-- Programming note: The HE_GetSel function is not used here so that
        ;   this function can be used independent of the HiEdit library.  This
        ;   will probably be changed in the future.

    ;-- Determine/Set Flags
    l_Flags:=PD_ALLPAGES|PD_RETURNDC|PD_USEDEVMODECOPIES
    if (l_StartSelPos=l_EndSelPos)
        l_Flags |= PD_NOSELECTION
     else
        l_Flags |= PD_SELECTION

    NumPut(l_Flags,PRINTDLG_Structure,20,"UInt")            ;-- Flags

    ;-- Page and copies
    NumPut(1 ,PRINTDLG_Structure,24,"UShort")               ;-- nFromPage
    NumPut(1 ,PRINTDLG_Structure,26,"UShort")               ;-- nToPage
    NumPut(1 ,PRINTDLG_Structure,28,"UShort")               ;-- nMinPage
    NumPut(-1,PRINTDLG_Structure,30,"UShort")               ;-- nMaxPage
    NumPut(1 ,PRINTDLG_Structure,32,"UShort")               ;-- nCopies
        ;-- Note: Use -1 to specify the maximum page number (65535).
        ;
        ;   Programming note:  The values that are loaded to these fields are
        ;   critical.  The Print dialog will not display (returns an error) if
        ;   unexpected values are loaded to one or more of these fields.

    ;[================]
    ;[  Print dialog  ]
    ;[================]
    ;-- Open the Print dialog.  Bounce if the user cancels.
    if not DllCall("comdlg32\PrintDlgA","UInt",&PRINTDLG_Structure)
        return

    hDevMode:=NumGet(PRINTDLG_Structure,8,"UInt")
        ;-- Handle to a global memory object that contains a DEVMODE structure

    hDevNames:=NumGet(PRINTDLG_Structure,12,"UInt")
        ;-- Handle to a movable global memory object that contains a DEVNAMES
        ;   structure.

    ;-- Free global structures created by PrintDlg
    ;
    ;   Programming note:  This function assumes that the user-selected printer
    ;   settings will be retained in-between print requests.  If this behaviour
    ;   is not desired, the global memory objects created by the PrintDlg
    ;   function can be released immediately by uncommenting the following code.
    ;   However, if this behavior is desired, the global memory objects should
    ;   be released before the script is terminated.  Copy the following code
    ;   (uncommented of course) to the appropriate "Exit" routine in your
    ;   script.
    ;
;;;;;    if hDevMode
;;;;;        {
;;;;;        DllCall("GlobalFree","UInt",hDevMode)
;;;;;        hDevMode:=0
;;;;;        }
;;;;;
;;;;;    if hDevNames
;;;;;        {
;;;;;        DllCall("GlobalFree","UInt",hDevNames)
;;;;;        hDevNames:=0
;;;;;        }

    ;-- Get the printer device context.  Bounce if not defined.
    l_hDC:=NumGet(PRINTDLG_Structure,16,"UInt")             ;-- hDC
    if not l_hDC
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% - Printer device context (hDC) not defined.
           )

        return
        }

    ;[====================]
    ;[  Prepare to print  ]
    ;[====================]
    ;-- Collect Flags
    l_Flags:=NumGet(PRINTDLG_Structure,20,"UInt")           ;-- Flags

    ;-- Determine From/To Page
    if l_Flags & PD_PAGENUMS
        {
        l_FromPage:=NumGet(PRINTDLG_Structure,24,"UShort")  ;-- nFromPage
        l_ToPage  :=NumGet(PRINTDLG_Structure,26,"UShort")  ;-- nToPage
        }
     else
        {
        l_FromPage:=1
        l_ToPage  :=65535
        }

    ;-- Collect printer statistics
    l_HORZRES:=DllCall("GetDeviceCaps","UInt",l_hDC,"UInt",HORZRES)
    l_VERTRES:=DllCall("GetDeviceCaps","UInt",l_hDC,"UInt",VERTRES)
        ;-- Width and height, in pixels, of the printable area of the page

    l_LOGPIXELSX:=DllCall("GetDeviceCaps","UInt",l_hDC,"UInt",LOGPIXELSX)
    l_LOGPIXELSY:=DllCall("GetDeviceCaps","UInt",l_hDC,"UInt",LOGPIXELSY)
        ;-- Number of pixels per logical inch along the page width and height

    l_PHYSICALWIDTH :=DllCall("GetDeviceCaps","UInt",l_hDC,"UInt",PHYSICALWIDTH)
    l_PHYSICALHEIGHT:=DllCall("GetDeviceCaps","UInt",l_hDC,"UInt",PHYSICALHEIGHT)
        ;-- The width and height of the physical page, in device units. For
        ;   example, a printer set to print at 600 dpi on 8.5" x 11" paper
        ;   has a physical width value of 5100 device units. Note that the
        ;   physical page is almost always greater than the printable area of
        ;   the page, and never smaller.

    l_PHYSICALOFFSETX:=DllCall("GetDeviceCaps","UInt",l_hDC,"UInt",PHYSICALOFFSETX)
    l_PHYSICALOFFSETY:=DllCall("GetDeviceCaps","UInt",l_hDC,"UInt",PHYSICALOFFSETY)
        ;-- The distance from the left/right edge (PHYSICALOFFSETX) and the
        ;   top/bottom edge (PHYSICALOFFSETY) of the physical page to the edge
        ;   of the printable area, in device units. For example, a printer set
        ;   to print at 600 dpi on 8.5-by-11-inch paper, that cannot print on
        ;   the leftmost 0.25-inch of paper, has a horizontal physical offset of
        ;   150 device units.

    ;-- Define/Populate the FORMATRANGE structure
    VarSetCapacity(FORMATRANGE_Structure,48,0)
    NumPut(l_hDC,FORMATRANGE_Structure,0,"UInt")            ;-- hdc
    NumPut(l_hDC,FORMATRANGE_Structure,4,"UInt")            ;-- hdcTarget

	;-- Define FORMATRANGE.rcPage
    ;
    ;   rcPage is the entire area of a page on the rendering device, measured in
    ;   twips (1/20 point or 1/1440 of an inch)
    ;
    ;   Note: rc defines the maximum printable area which does not include the
    ;   printer's margins (the unprintable areas at the edges of the page).  The
    ;   unprintable areas are represented by PHYSICALOFFSETX and
    ;   PHYSICALOFFSETY.
    ;
    NumPut(0,FORMATRANGE_Structure,24,"UInt")               ;-- rcPage.Left
    NumPut(0,FORMATRANGE_Structure,28,"UInt")               ;-- rcPage.Top

    l_rcPage_Right:=Round((l_HORZRES/l_LOGPIXELSX)*1440)
    NumPut(l_rcPage_Right,FORMATRANGE_Structure,32,"UInt")  ;-- rcPage.Right

    l_rcPage_Bottom:=Round((l_VERTRES/l_LOGPIXELSY)*1440)
    NumPut(l_rcPage_Bottom,FORMATRANGE_Structure,36,"UInt") ;-- rcPage.Bottom

	;-- Define FORMATRANGE.rc
    ;
    ;   rc is the area to render to (rcPage - margins), measured in twips (1/20
    ;   point or 1/1440 of an inch).
    ;
    ;   If the user-defined margins are smaller than the printer's margins (the
    ;   unprintable areas at the edges of each page), the user margins are set
    ;   to the printer's margins.
    ;
    ;   In addition, the user-defined margins must be adjusted to account for
    ;   the printer's margins.  For example: If the user requests a 3/4 inch
    ;   (19.05 mm) left margin but the printer's left margin is 1/4 inch
    ;   (6.35 mm), rc.Left is set to 720 twips (0.5 inch or 12.7 mm).
    ;
    ;-- Left
    if (l_PHYSICALOFFSETX/l_LOGPIXELSX>p_MarginLeft/l_LocaleUnits)
        p_MarginLeft:=Round((l_PHYSICALOFFSETX/l_LOGPIXELSX)*l_LocaleUnits)

    l_rc_Left:=Round(((p_MarginLeft/l_LocaleUnits)*1440)-((l_PHYSICALOFFSETX/l_LOGPIXELSX)*1440))
    NumPut(l_rc_Left,FORMATRANGE_Structure,8,"UInt")        ;-- rc.Left

    ;-- Top
    if (l_PHYSICALOFFSETY/l_LOGPIXELSY>p_MarginTop/l_LocaleUnits)
        p_MarginTop:=Round((l_PHYSICALOFFSETY/l_LOGPIXELSY)*l_LocaleUnits)

    l_rc_Top:=Round(((p_MarginTop/l_LocaleUnits)*1440)-((l_PHYSICALOFFSETY/l_LOGPIXELSY)*1440))
    NumPut(l_rc_Top,FORMATRANGE_Structure,12,"UInt")        ;-- rc.Top

    ;-- Right
    if (l_PHYSICALOFFSETX/l_LOGPIXELSX>p_MarginRight/l_LocaleUnits)
        p_MarginRight:=Round((l_PHYSICALOFFSETX/l_LOGPIXELSX)*l_LocaleUnits)

    l_rc_Right:=l_rcPage_Right-Round(((p_MarginRight/l_LocaleUnits)*1440)-((l_PHYSICALOFFSETX/l_LOGPIXELSX)*1440))
    NumPut(l_rc_Right,FORMATRANGE_Structure,16,"UInt")      ;-- rc.Right

    ;-- Bottom
    if (l_PHYSICALOFFSETY/l_LOGPIXELSY>p_MarginBottom/l_LocaleUnits)
        p_MarginBottom:=Round((l_PHYSICALOFFSETY/l_LOGPIXELSY)*l_LocaleUnits)

    l_rc_Bottom:=l_rcPage_Bottom-Round(((p_MarginBottom/l_LocaleUnits)*1440)-((l_PHYSICALOFFSETY/l_LOGPIXELSY)*1440))
    NumPut(l_rc_Bottom,FORMATRANGE_Structure,20,"UInt")     ;-- rc.Bottom

    ;-- Determine print range.
    ;
    ;   If "Selection" option is chosen, use selected text, otherwise use the
    ;   entire document.
    ;
    if l_Flags & PD_SELECTION
        {
        l_StartPrintPos:=l_StartSelPos
        l_EndPrintPos  :=l_EndSelPos
        }
     else
        {
        l_StartPrintPos:=0
        l_EndPrintPos  :=-1     ;-- (-1=Select All)
        }

    Numput(l_StartPrintPos,FORMATRANGE_Structure,40)        ;-- cr.cpMin
    NumPut(l_EndPrintPos  ,FORMATRANGE_Structure,44)        ;-- cr.cpMax

    ;-- Define/Populate the DOCINFO structure
    VarSetCapacity(DOCINFO_Structure,20,0)
    NumPut(20           ,DOCINFO_Structure,0)               ;-- cbSize
    NumPut(&l_ScriptName,DOCINFO_Structure,4)               ;-- lpszDocName
    NumPut(0            ,DOCINFO_Structure,8)               ;-- lpszOutput
        ;-- Programming note: All other DOCINFO_Structure fields intentionally
        ;   left as null.

    ;-- Determine l_MaxPrintIndex
    if l_Flags & PD_SELECTION
        l_MaxPrintIndex:=l_EndSelPos
     else
        {
        SendMessage WM_GETTEXTLENGTH,0,0,,ahk_id %hEdit%
        l_MaxPrintIndex:=ErrorLevel
            ;-- Programming note: HE_GetTextLength is not used here so that this
            ;   function can be used independent of the HiEdit library.  This
            ;   will probably be changed in the future.
        }

    ;-- Set LineNumbersBar to max size
    ;
    ;   Programming note:  This step is necessary because the LineNumbersBar
    ;   does not render correctly past the first couple of pages if the
    ;   "autosize" option is used.  A bug perhaps, but this workaround is
    ;   acceptable and the fixed size may even be desirable.
    ;
    ;   If you don't use the line numbers bar or you don't want to make any
    ;   changes to the line numbers bar, you can comment out this code.
    ;
    if $LineNumbersBar
        HE_LineNumbersBar(hEdit,"automaxsize")

	;-- Be sure that the printer device context is in text mode
    DllCall("SetMapMode","UInt",l_hDC,"UInt",MM_TEXT)

    ;[=============]
    ;[  Print it!  ]
    ;[=============]
    ;-- Start a print job.  Bounce if there is a problem.
    l_PrintJob:=DllCall("StartDoc","UInt",l_hDC,"UInt",&DOCINFO_Structure,"Int")
    if l_PrintJob<=0
        {
        outputdebug Function: %A_ThisFunc% - DLLCall of "StartDoc" failed.
        return
        }

    ;-- Print page loop
    l_Page:=0
    l_PrintIndex:=0
    While (l_PrintIndex<l_MaxPrintIndex)
        {
        l_Page++

        ;-- Are we done yet?
        if (l_Page>l_ToPage)
            Break

        ;-- If printing this page, do a StartPage
        l_Render:=False
        if l_Page between %l_FromPage% and %l_ToPage%
            {
            l_Render:=True

            ;-- StartPage function.  Break if there is a problem.
            if DllCall("StartPage","UInt",l_hDC,"Int")<=0
                {
                outputdebug,
                   (ltrim join`s
                    Function: %A_ThisFunc% - DLLCall of "StartPage" failed.
                   )

                Break
                }
            }

        ;-- Format or measure page
        SendMessage EM_FORMATRANGE,l_Render,&FORMATRANGE_Structure,,ahk_id %hEdit%
        l_PrintIndex:=ErrorLevel

        ;-- If a page was printed, do an EndPage
        if l_Page between %l_FromPage% and %l_ToPage%
            {
            ;-- EndPage function.  Break if there is a problem.
            if DllCall("EndPage","UInt",l_hDC,"Int")<=0
                {
                outputdebug,
                   (ltrim join`s
                    Function: %A_ThisFunc% - DLLCall of "EndPage" failed.
                   )

                Break
                }
            }

        ;-- Update FORMATRANGE_Structure for the next page
        Numput(l_PrintIndex ,FORMATRANGE_Structure,40)      ;-- cr.cpMin
        NumPut(l_EndPrintPos,FORMATRANGE_Structure,44)      ;-- cr.cpMax
        }

    ;-- End the print job
    DllCall("EndDoc","UInt",l_hDC)

    ;-- Delete the printer device context
    DllCall("DeleteDC","UInt",l_hDC)

    ;-- Reset control (free cached information)
    SendMessage EM_FORMATRANGE,0,0,,ahk_id %hEdit%

    ;-- Reset the LineNumbersBar
    ;
    ;   Programming note: If you don't use the line numbers bar or you don't
    ;   want to make any changes to the line numbers bar, you can comment out
    ;   this code.
    ;
    if $LineNumbersBar
        HE_LineNumbersBar(hEdit,"autosize")

    return
    }


;*******************************
;*                             *
;*         RPBuildTable        *
;*    (Build Restore table)    *
;*                             *
;*******************************
RPBuildTable()
    {
    ;-- Global variables
    Global $RPDir

    ;-- Build it
    Loop %$RPDir%\*.ahk
        {
        ;-- Derive restore time stamp
        StringTrimRight l_RestoreTimeStamp,A_LoopFileName,4

        ;-- Add to the restore table
        if StrLen(l_RestoreTable)=0
            l_RestoreTable:=l_RestoreTimeStamp
         else
            l_RestoreTable.="|" . l_RestoreTimeStamp
        }

    ;-- Sort it (descending order)
    Sort l_RestoreTable,RD|

    ;-- Return to sender
    Return l_RestoreTable
    }



;********************************
;*                              *
;*           RPCreate           *
;*    (Create restore point)    *
;*                              *
;********************************
RPCreate(p_CheckForDup=True)
    {
    ;[====================]
    ;[  Global variables  ]
    ;[====================]
    Global $QAHKGUI
          ,$QAHKGUI_hEdit
          ,$MaxRestorePoints
          ,$RPDir
          ,$RPViewerGUI
          ,$RPViewerGUI_hWnd

    ;[=======================]
    ;[  Bounce if workspace  ]
    ;[        is empty       ]
    ;[=======================]
    if HE_GetTextLength($QAHKGUI_hEdit)=0
        return

    ;[===========================]
    ;[  Create "Restore" folder  ]
    ;[  (If it doesn't exist)    ]
    ;[===========================]
    IfNotExist %$RPDir%\.
        {
        ;-- Create folder
        FileCreateDir %$RPDir%
        if ErrorLevel
            {
            gui +OwnDialogs
            MsgBox
                ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
                ,Create Restore Point Error,
                   (ltrim join`s
                    Unable to create the "Restore" folder.  Restore point not
                    created.  %A_Space%
                   )

            return
            }
        }

    ;[========================]
    ;[  Create restore point  ]
    ;[========================]
    l_RPFile:=$RPDir . "\" . A_Now . ".ahk"

    ;-- Bounce if restore point file already exists
    IfExist %l_RPFile%
        return
            ;-- Note: A restore point file may already exist if the user submits
            ;   multiple requests within a second

    ;-- Save current workspace to restore point file
    ErrorLevel:=HE_SaveFile($QAHKGUI_hEdit,l_RPFile)
;;;;;    if ErrorLevel
;;;;;        {
;;;;;        outputdebug ErrorLevel after HE_SaveFile=%ErrorLevel%
;;;;;        gui +OwnDialogs
;;;;;        MsgBox
;;;;;            ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
;;;;;            ,Create Restore Point Error,
;;;;;               (ltrim
;;;;;                Unable to create the restore point file:  %A_Space%
;;;;;                %l_RPFile%  %A_Space%
;;;;;               )
;;;;;
;;;;;        return
;;;;;        }

    ;-- Programming note: The value returned from HE_SaveFile is meaningless.
    ;   The function usually returns 0 regardless of whether the file was
    ;   successfully saved or not.  On rare occasion, the function returns 1.
    ;   This value is also meaningless if the return value 0 does not provide
    ;   guidance.


    ;-- Restore file created?
    IfNotExist %l_RPFile%
        {
        gui +OwnDialogs
        MsgBox
            ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,Create Restore Point Error,
               (ltrim
                Unable to create the restore point file:  %A_Space%
                %l_RPFile%  %A_Space%
               )

        return
        }

    ;[=======================]
    ;[  Check for duplicate  ]
    ;[=======================]
    if p_CheckForDup
        RPDeleteDup()

    ;[======================]
    ;[  Update RPViewerGUI  ]
    ;[======================]
    ;-- New restore point file retained?
    IfExist %l_RPFile%
        {
        ;-- RPViewerGUI window open?
        IfWinExist ahk_id %$RPViewerGUI_hWnd%
            {
            ;-- Change GUI default
            gui %$RPViewerGUI%:Default

            ;-- Extract restore time stamp
            SplitPath l_RPFile,l_RPFileName
            StringTrimRight $RPTimeStamp,l_RPFileName,4

            ;-- Convert timestamp into readable date/time format
            FormatTime
                ,$RPDisplayField
                ,%$RPTimeStamp%
                ,yyyy-MM-dd HH:mm:ss

            ;-- Get file size
            FileGetSize l_FileSize,%l_RPFile%

            ;-- Format size display
            if l_FileSize<1024
                $FileSize:=AddCommas(l_FileSize) . " bytes"
             else
                if l_FileSize<1048576
                    $FileSize:=AddCommas(Round(l_FileSize/1024,2)) . " KB"
                 else
                    $FileSize:=AddCommas(Round(l_FileSize/1048576,2)) . " MB"

            $RPDisplayField:=$RPDisplayField . "   " . $FileSize

            ;-- Create new row at the top
            LV_Insert(1,"",$RPDisplayField,l_RPFile)

            ;-- Size/Sort column
            LV_ModifyCol(1,"Auto SortDesc")
                ;-- Programming note:  This is necessary because the ListView
                ;   may have been empty and all columns sized to a minimum width

            ;-- Anything selected?
            if LV_GetCount("Selected")
                LV_Modify(LV_GetNext(0),"+Vis")  ;-- Make selected line visible

            ;-- Reset GUI default
            gui %$QAHKGUI%:Default
            }
        }

    ;[================]
    ;[  Housekeeping  ]
    ;[================]
    RPTrim($MaxRestorePoints)
    }


;*********************
;*                   *
;*    RPDeleteDup    *
;*                   *
;*********************
RPDeleteDup()
    {
    ;[====================]
    ;[  Global variables  ]
    ;[====================]
    Global $RPDir

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    l_RPTable:=RPBuildTable()

    ;-- Bounce if there aren't at least 2 entries in the table
    if l_RPTable not contains |
        return

    ;[======================]
    ;[  Delete most recent  ]
    ;[   RP if duplicate    ]
    ;[======================]

    ;-- Collect information on the first two table entries
    Loop Parse,l_RPTable,|
        {
        ;-- First (most recent) RP file?
        if A_Index=1
            {
            l_RPFile1:=$RPDir . "\" . A_LoopField . ".ahk"
            FileGetSize l_RPFileSize1,%l_RPFile1%
            Continue  ;-- Go on to the next
            }

        ;-- Collect name and size of 2nd most recent RP file
        l_RPFile2:=$RPDir . "\" . A_LoopField . ".ahk"
        FileGetSize l_RPFileSize2,%l_RPFile2%
        Break  ;-- We're done with this loop
        }

    ;-- Duplicate?
    ;
    ;   Programming note:  Because of AutoHotkey's optimization techniques, the
    ;   FileMD5 functions are only called if the file sizes are equal.
    ;
     if (l_RPFileSize1=l_RPFileSize2)
    and FileMD5(l_RPFile1,2)=FileMD5(l_RPFile2,2)
        {
        ;-- Delete most recent RP file
        FileDelete %l_RPFile1%
        if ErrorLevel
            outputdebug,
               (ltrim join`s
                Function: %A_ThisLabel% -
                Unable to delete "%l_RPFile1%"
               )
                    ;-- Note: A delete failure is effectively ignored here
        }

    return
    }


;***************************************
;*                                     *
;*                RPTrim               *
;*    (Delete superfluous RP files)    *
;*                                     *
;***************************************
RPTrim(p_MaxRestorePoints)
    {
    ;[====================]
    ;[  Global variables  ]
    ;[====================]
    Global $QAHKGUI
          ,$RPDir
          ,$RPViewerGUI
          ,$RPViewerGUI_hEdit
          ,$RPViewerGUI_hWnd

    ;-- Initialize
    l_DeleteCount:=0

    ;[=====================]
    ;[  Delete beyond-max  ]
    ;[       RP files      ]
    ;[=====================]
    l_RPTable:=RPBuildTable()
    Loop Parse,l_RPTable,|
        {
        ;-- More than max?
        if (A_Index>p_MaxRestorePoints)
            {
            ;-- Count it
            l_DeleteCount++

            ;-- Delete restore point file
            FileDelete %$RPDir%\%A_LoopField%.ahk
            if ErrorLevel
                outputdebug,
                   (ltrim join`s
                    Function: %A_ThisFunc% -
                    Unable to delete "%$RPDir%\%A_LoopField%.ahk"
                   )
                        ;-- Note: A delete failure is temporarily ignored.  If
                        ;   possible, the delinquent file is deleted the next
                        ;   time this routine is called.
            }
        }

    ;-- Anything deleted?
    if l_DeleteCount
        {
        ;-- RPViewerGUI window open?
        IfWinExist ahk_id %$RPViewerGUI_hWnd%
            {
            ;-- Change default GUI
            gui %$RPViewerGUI%:Default

            ;-- Redraw off
            GUIControl -Redraw,$RPViewerGUI_RPList

            ;-- Remove no-longer-valid entries from ListView
            l_Row:=1
            Loop % LV_GetCount()
                {
                LV_GetText(l_RPFIle,l_Row,2)
                IfNotExist %l_RPFIle%
                    {
                    LV_Delete(l_Row)
                    Continue  ;-- Keep the same row number
                    }

                l_Row++
                }

            ;-- Redraw on
            GUIControl +Redraw,$RPViewerGUI_RPList

            ;-- Nothing selected?
            if LV_GetCount("Selected")=0
                {
                ;-- Disable the Restore button
                GUIControl Disable,$RPViewerGUI_RestoreButton

                ;-- Close the last opened file (if any)
                HE_CloseFile($RPViewerGUI_hEdit)
                }

            ;-- Reset default GUI
            gui %$QAHKGUI%:Default
            }
        }

    Return l_DeleteCount
    }


;********************************
;*                              *
;*            RPClean           *
;*    (Clean Restore folder)    *
;*                              *
;********************************
;-- This functions deletes RP files that were created before A_Now minus
;   p_NbrOfDays.
;
RPClean(p_NbrOfDays)
    {
    ;[====================]
    ;[  Global variables  ]
    ;[====================]
    Global $RPDir

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    l_DeleteCount=0

    ;-- Identify threshold
    l_ThresholdTimeStamp:=A_Now
    EnvAdd l_ThresholdTimeStamp,-%p_NbrOfDays%,Days

    ;[=========]
    ;[  Clean  ]
    ;[=========]
    Loop %$RPDir%\*.ahk
        {
        ;-- Derive restore time stamp
        StringTrimRight l_RestoreTimeStamp,A_LoopFileName,4

        ;-- Older than threshhold?
        if (l_RestoreTimeStamp<l_ThresholdTimeStamp)
            {
            ;-- Delete it
            FileDelete %A_LoopFileFullPath%
            if ErrorLevel
                outputdebug,
                   (ltrim join`s
                    Function: %A_ThisFunc% -
                    Unable to delete "%A_LoopFileLongPath%"
                   )
                        ;-- Note: A delete failure is temporarily ignored.  If
                        ;   possible, the delinquent file will be deleted the
                        ;   next time this routine is called.
            }

            ;-- Count it
            l_DeleteCount++
        }

    ;-- Return to sender
    Return l_DeleteCount
    }


;**************************************************
;*                                                *
;*               Rebuild RunPIDList               *
;*    (Remove processes that have been closed)    *
;*                                                *
;**************************************************
RebuildRunPIDList(p_RunPIDList)
    {
    l_RunPIDList:=""  ;-- Redundant but included for clarity
    Loop Parse,p_RunPIDList,`,
        {
        Process Exist,%A_LoopField%
        if ErrorLevel
            if StrLen(l_RunPIDList)=0
                l_RunPIDList:=A_LoopField
             else
                l_RunPIDList.="," . A_LoopField
        }

    Return l_RunPIDList
    }



;*********************************************
;*                                           *
;*                                           *
;*                                           *
;*                                           *
;*                Subroutines                *
;*                                           *
;*                                           *
;*                                           *
;*                                           *
;*********************************************
;****************************
;*                          *
;*    Read configuration    *
;*                          *
;****************************
ReadConfiguration:

;[====================]
;[  Section: General  ]
;[====================]
iniRead
    ,$AlwaysOnTop
    ,%$ConfigFile%
    ,General
    ,AlwaysOnTop
    ,%False%

iniRead
    ,$ShowMenubar
    ,%$ConfigFile%
    ,General
    ,ShowMenubar
    ,%True%

iniRead
    ,$ShowStatusbar
    ,%$ConfigFile%
    ,General
    ,ShowStatusbar
    ,%True%

iniRead
    ,$EscapeToExit
    ,%$ConfigFile%
    ,General
    ,EscapeToExit
    ,%True%

iniRead
    ,$CopyFromPath
    ,%$ConfigFile%
    ,General
    ,CopyFromPath
    ,%A_Space%

iniRead
    ,$SaveToPath
    ,%$ConfigFile%
    ,General
    ,SaveToPath
    ,%A_Space%

iniRead
    ,$RecentFiles
    ,%$ConfigFile%
    ,General
    ,RecentFiles
    ,%A_Space%

;[===================]
;[  Section: Window  ]
;[===================]
iniRead
    ,$WindowX
    ,%$ConfigFile%
    ,Window
    ,X
    ,%A_Space%

iniRead
    ,$WindowY
    ,%$ConfigFile%
    ,Window
    ,Y
    ,%A_Space%

iniRead
    ,$WindowW
    ,%$ConfigFile%
    ,Window
    ,W
    ,%A_Space%

iniRead
    ,$WindowH
    ,%$ConfigFile%
    ,Window
    ,H
    ,%A_Space%

iniRead
    ,$WindowMaximized
    ,%$ConfigFile%
    ,Window
    ,Maximized
    ,%A_Space%

;-- Save original $WindowMaximized value
$Saved_WindowMaximized:=$WindowMaximized

;[==================]
;[  Section: Print  ]
;[==================]
iniRead
    ,$PrintMarginLeft
    ,%$ConfigFile%
    ,Print
    ,MarginLeft
    ,%$MarginDefault%

iniRead
    ,$PrintMarginTop
    ,%$ConfigFile%
    ,Print
    ,MarginTop
    ,%$MarginDefault%

iniRead
    ,$PrintMarginRight
    ,%$ConfigFile%
    ,Print
    ,MarginRight
    ,%$MarginDefault%

iniRead
    ,$PrintMarginBottom
    ,%$ConfigFile%
    ,Print
    ,MarginBottom
    ,%$MarginDefault%

iniRead
    ,$PrintOrientation
    ,%$ConfigFile%
    ,Print
    ,Orientation
    ,%A_Space%

;[===================]
;[  Section: Editor  ]
;[===================]
;-- Font
iniRead
    ,$Font
    ,%$ConfigFile%
    ,Editor
    ,Font
    ,%$DefaultFont%

iniRead
    ,$FontSize
    ,%$ConfigFile%
    ,Editor
    ,FontSize
    ,%$DefaultFontSize%

iniRead
    ,$FontStyle
    ,%$ConfigFile%
    ,Editor
    ,FontStyle
    ,%A_Space%

iniRead
    ,$AutoIndent
    ,%$ConfigFile%
    ,Editor
    ,AutoIndent
    ,%False%

iniRead
    ,$TabWidth
    ,%$ConfigFile%
    ,Editor
    ,TabWidth
    ,4

iniRead
    ,$RealTabs
    ,%$ConfigFile%
    ,Editor
    ,RealTabs
    ,%False%

iniRead
    ,$LineNumbersBar
    ,%$ConfigFile%
    ,Editor
    ,LineNumbersBar
    ,%True%

iniRead
    ,$AllowUndoAfterSave
    ,%$ConfigFile%
    ,Editor
    ,AllowUndoAfterSave
    ,%True%

iniRead
    ,$BlockComment
    ,%$ConfigFile%
    ,Editor
    ,BlockComment
    ,%A_Space%

if StrLen($BlockComment)=0
    $BlockComment:=";;;;;"
 else
    ;-- Remove borders
    $BlockComment:=SubStr($BlockComment,2,-1)

;[======================]
;[  Section: ExtEditor  ]
;[======================]
iniRead
    ,$ExtEditorName
    ,%$ConfigFile%
    ,ExtEditor
    ,Name
    ,%A_Space%

iniRead
    ,$ExtEditorPath
    ,%$ConfigFile%
    ,ExtEditor
    ,Path
    ,%A_Space%

;[====================]
;[  Section: Toolbar  ]
;[====================]
iniRead
    ,$ShowToolbar
    ,%$ConfigFile%
    ,Toolbar
    ,ShowToolbar
    ,%True%

iniRead
    ,$ToolbarIconSize
    ,%$ConfigFile%
    ,Toolbar
    ,IconSize
    ,Large

if $ToolbarIconSize not in Large,Small
    $ToolbarIconSize=Large

iniRead
    ,$ToolbarButtons
    ,%$ConfigFile%
    ,Toolbar
    ,Buttons
    ,%A_Space%

if $ToolbarButtons is not Space
    {
    ;-- Remove borders
    $ToolbarButtons:=SubStr($ToolbarButtons,2,-1)

    ;-- Restore line feeds
    StringReplace
        ,$ToolbarButtons
        ,$ToolbarButtons
        ,%$RecordDelimiter%
        ,`n
        ,All
    }

;[================]
;[  Section: Run  ]
;[================]
iniRead
    ,$AutoHotkeyPath
    ,%$ConfigFile%
    ,Run
    ,AutoHotkeyPath
    ,%A_Space%

iniRead
    ,$RunPrompt
    ,%$ConfigFile%
    ,Run
    ,RunPrompt
    ,%False%

iniRead
    ,$RunDebug
    ,%$ConfigFile%
    ,Run
    ,RunDebug
    ,%False%

iniRead
    ,$RunWait
    ,%$ConfigFile%
    ,Run
    ,RunWait
    ,%True%

iniRead
    ,$ConfirmExitIfRunning
    ,%$ConfigFile%
    ,Run
    ,ConfirmExitIfRunning
    ,%True%

iniRead
    ,$ClearRunWorkspaceOnRun
    ,%$ConfigFile%
    ,Run
    ,ClearRunWorkspaceOnRun
    ,%False%

iniRead
    ,$ClearRunWorkspaceOnExit
    ,%$ConfigFile%
    ,Run
    ,ClearRunWorkspaceOnExit
    ,%False%

;-- $RunParms
iniRead
    ,$RunParms
    ,%$ConfigFile%
    ,Run
    ,RunParms
    ,%A_Space%

if StrLen($RunParms)=0
    $RunParms=
       (ltrim
        All parameters on "one line"
        Parameters
        on
        "separate lines"
       )
 else
    {
    ;-- Remove borders
    $RunParms:=SubStr($RunParms,2,-1)

    ;-- Restore line feeds
    StringReplace
        ,$RunParms
        ,$RunParms
        ,%$RecordDelimiter%
        ,`n
        ,All
    }

;-- $RunParmsDDL
iniRead
    ,$RunParmsDDL
    ,%$ConfigFile%
    ,Run
    ,RunParmsDDL
    ,%A_Space%

if StrLen($RunParmsDDL)
    {
    ;-- Remove borders
    $RunParmsDDL:=SubStr($RunParmsDDL,2,-1)

    ;-- Restore line feeds
    StringReplace
        ,$RunParmsDDL
        ,$RunParmsDDL
        ,%$RecordDelimiter%
        ,`n
        ,All
    }

;[====================]
;[  Section: Restore  ]
;[====================]
iniRead
    ,$MaxRestorePoints
    ,%$ConfigFile%
    ,Restore
    ,MaxRestorePoints
    ,20

iniRead
    ,$CreateRPOnCopyfromDrop
    ,%$ConfigFile%
    ,Restore
    ,CreateRPOnCopyfromDrop
    ,%False%

iniRead
    ,$CreateRPOnRun
    ,%$ConfigFile%
    ,Restore
    ,CreateRPOnRun
    ,%False%

iniRead
    ,$CreateRPOnSave
    ,%$ConfigFile%
    ,Restore
    ,CreateRPOnSave
    ,%False%

iniRead
    ,$CreateRPOnExit
    ,%$ConfigFile%
    ,Restore
    ,CreateRPOnExit
    ,%True%

;[=====================]
;[  Section: RPViewer  ]
;[=====================]
iniRead
    ,$RPViewerX
    ,%$ConfigFile%
    ,RPViewer
    ,X
    ,%A_Space%

iniRead
    ,$RPViewerY
    ,%$ConfigFile%
    ,RPViewer
    ,Y
    ,%A_Space%

iniRead
    ,$RPViewerW
    ,%$ConfigFile%
    ,RPViewer
    ,W
    ,%A_Space%

iniRead
    ,$RPViewerH
    ,%$ConfigFile%
    ,RPViewer
    ,H
    ,%A_Space%

iniRead
    ,$RPViewerFont
    ,%$ConfigFile%
    ,RPViewer
    ,Font
    ,%$DefaultFont%

iniRead
    ,$RPViewerFontSize
    ,%$ConfigFile%
    ,RPViewer
    ,FontSize
    ,%$RPViewerDefaultFontSize%

iniRead
    ,$RPViewerFontStyle
    ,%$ConfigFile%
    ,RPViewer
    ,FontStyle
    ,%A_Space%

iniRead
    ,$RPViewerLineNumbersBar
    ,%$ConfigFile%
    ,RPViewer
    ,LineNumbersBar
    ,%False%

iniRead
    ,$RPViewerSaveWindowPos
    ,%$ConfigFile%
    ,RPViewer
    ,SaveWindowPos
    ,%False%

iniRead
    ,$RPViewerCloseOnRestore
    ,%$ConfigFile%
    ,RPViewer
    ,CloseOnRestore
    ,%True%

iniRead
    ,$RPViewerEscapeToClose
    ,%$ConfigFile%
    ,RPViewer
    ,EscapeToClose
    ,%True%

;[================]
;[  Section: New  ]
;[================]
iniRead
    ,$NewScriptSystemDefault
    ,%$ConfigFile%
    ,New
    ,SystemDefault
    ,%True%

iniRead
    ,$NewScript
    ,%$ConfigFile%
    ,New
    ,Script
    ,%A_Space%

if StrLen($NewScript)=0
    $NewScript:="; Put code for new script here"
 else
    {
    ;-- Remove borders
    $NewScript:=SubStr($NewScript,2,-1)

    ;-- Restore line feeds
    StringReplace
        ,$NewScript
        ,$NewScript
        ,%$RecordDelimiter%
        ,`n
        ,All
    }

;[==================]
;[  Section: Debug  ]
;[==================]
iniRead
    ,$DebugScript
    ,%$ConfigFile%
    ,Debug
    ,Script
    ,%A_Space%

if StrLen($DebugScript)=0
    $DebugScript=
       (ltrim
        ;-- Begin debug script ---
        ExitApp  ;-- Useful for "Run Selected" command

        ;-- A few example hotkeys.  Change to fit your needs
        #!h::ListHotkeys
        #!k::KeyHistory
        #!l::ListLines
        #!p::Pause    ;-- Toggle
        #!q::ExitApp
        #!s::Suspend  ;-- Toggle
        #!v::ListVars
       )
 else
    {
    ;-- Remove borders
    $DebugScript:=SubStr($DebugScript,2,-1)

    ;-- Restore line feeds
    StringReplace
        ,$DebugScript
        ,$DebugScript
        ,%$RecordDelimiter%
        ,`n
        ,All
    }

;[=======================]
;[  Section: OptionsGUI  ]
;[=======================]
iniRead
    ,$OptionsGUI_Tab
    ,%$ConfigFile%
    ,OptionsGUI
    ,Tab
    ,%A_Space%

return


;****************************
;*                          *
;*    Save configuration    *
;*                          *
;****************************
SaveConfiguration:
SetTimer %A_ThisLabel%,Off

;[====================]
;[  Section: General  ]
;[====================]
iniWrite
    ,%$AlwaysOnTop%
    ,%$ConfigFile%
    ,General
    ,AlwaysOnTop

iniWrite
    ,%$ShowMenubar%
    ,%$ConfigFile%
    ,General
    ,ShowMenubar

iniWrite
    ,%$ShowStatusbar%
    ,%$ConfigFile%
    ,General
    ,ShowStatusbar

iniWrite
    ,%$EscapeToExit%
    ,%$ConfigFile%
    ,General
    ,EscapeToExit

iniWrite
    ,%$CopyFromPath%
    ,%$ConfigFile%
    ,General
    ,CopyFromPath

iniWrite
    ,%$SaveToPath%
    ,%$ConfigFile%
    ,General
    ,SaveToPath

iniWrite
    ,%$RecentFiles%
    ,%$ConfigFile%
    ,General
    ,RecentFiles

;[===================]
;[  Section: Window  ]
;[===================]
WinGetPos
    ,$WindowX
    ,$WindowY
    ,$WindowW
    ,$WindowH
    ,ahk_id %$QAHKGUI_hWnd%

iniWrite
    ,%$WindowX%
    ,%$ConfigFile%
    ,Window
    ,X

iniWrite
    ,%$WindowY%
    ,%$ConfigFile%
    ,Window
    ,Y

iniWrite
    ,%$WindowW%
    ,%$ConfigFile%
    ,Window
    ,W

iniWrite
    ,%$WindowH%
    ,%$ConfigFile%
    ,Window
    ,H

iniWrite
    ,%$WindowMaximized%
    ,%$ConfigFile%
    ,Window
    ,Maximized

;[==================]
;[  Section: Print  ]
;[==================]
iniWrite
    ,%$PrintMarginLeft%
    ,%$ConfigFile%
    ,Print
    ,MarginLeft

iniWrite
    ,%$PrintMarginTop%
    ,%$ConfigFile%
    ,Print
    ,MarginTop

iniWrite
    ,%$PrintMarginRight%
    ,%$ConfigFile%
    ,Print
    ,MarginRight

iniWrite
    ,%$PrintMarginBottom%
    ,%$ConfigFile%
    ,Print
    ,MarginBottom

iniWrite
    ,%$PrintOrientation%
    ,%$ConfigFile%
    ,Print
    ,Orientation

;[===================]
;[  Section: Editor  ]
;[===================]
;-- Font
iniWrite
    ,%$Font%
    ,%$ConfigFile%
    ,Editor
    ,Font

iniWrite
    ,%$FontSize%
    ,%$ConfigFile%
    ,Editor
    ,FontSize

iniWrite
    ,%$FontStyle%
    ,%$ConfigFile%
    ,Editor
    ,FontStyle

iniWrite
    ,%$AutoIndent%
    ,%$ConfigFile%
    ,Editor
    ,AutoIndent

iniWrite
    ,%$TabWidth%
    ,%$ConfigFile%
    ,Editor
    ,TabWidth

iniWrite
    ,%$RealTabs%
    ,%$ConfigFile%
    ,Editor
    ,RealTabs

iniWrite
    ,%$LineNumbersBar%
    ,%$ConfigFile%
    ,Editor
    ,LineNumbersBar

iniWrite
    ,%$AllowUndoAfterSave%
    ,%$ConfigFile%
    ,Editor
    ,AllowUndoAfterSave

iniWrite
    ,% $iniBorder . $BlockComment . $iniBorder
    ,%$ConfigFile%
    ,Editor
    ,BlockComment
        ;-- Note: Borders added to preserve leading/trailing whitespace

;[======================]
;[  Section: ExtEditor  ]
;[======================]
iniWrite
    ,%$ExtEditorName%
    ,%$ConfigFile%
    ,ExtEditor
    ,Name

iniWrite
    ,%$ExtEditorPath%
    ,%$ConfigFile%
    ,ExtEditor
    ,Path

;[====================]
;[  Section: Toolbar  ]
;[====================]
iniWrite
    ,%$ShowToolbar%
    ,%$ConfigFile%
    ,Toolbar
    ,ShowToolbar

iniWrite
    ,%$ToolbarIconSize%
    ,%$ConfigFile%
    ,Toolbar
    ,IconSize

;------------------------------
;--  Clean up $ToolbarButtons
;-- {ToolBar_Define adds junk}
;------------------------------
;-- Convert all CRLF to LFs
StringReplace
    ,$ToolbarButtons
    ,$ToolbarButtons
    ,`r`n
    ,`n
    ,All

;-----------
;-- Buttons
;-----------
;-- Assign to output variable
$ini_ToolbarButtons:=$ToolbarButtons

;-- Convert LFs to record delimiters
StringReplace
    ,$ini_ToolbarButtons
    ,$ini_ToolbarButtons
    ,`n
    ,%$RecordDelimiter%
    ,All

;-- Add borders to preserve leading/trailing whitespace
$ini_ToolbarButtons:=$iniBorder . $ini_ToolbarButtons . $iniBorder

;-- Save it
iniWrite
    ,%$ini_ToolbarButtons%
    ,%$ConfigFile%
    ,Toolbar
    ,Buttons

;[================]
;[  Section: Run  ]
;[================]
iniWrite
    ,%$AutoHotkeyPath%
    ,%$ConfigFile%
    ,Run
    ,AutoHotkeyPath

iniWrite
    ,%$RunPrompt%
    ,%$ConfigFile%
    ,Run
    ,RunPrompt

iniWrite
    ,%$RunDebug%
    ,%$ConfigFile%
    ,Run
    ,RunDebug

iniWrite
    ,%$RunWait%
    ,%$ConfigFile%
    ,Run
    ,RunWait

iniWrite
    ,%$ConfirmExitIfRunning%
    ,%$ConfigFile%
    ,Run
    ,ConfirmExitIfRunning

iniWrite
    ,%$ClearRunWorkspaceOnRun%
    ,%$ConfigFile%
    ,Run
    ,ClearRunWorkspaceOnRun

iniWrite
    ,%$ClearRunWorkspaceOnExit%
    ,%$ConfigFile%
    ,Run
    ,ClearRunWorkspaceOnExit

;-------------
;-- $RunParms
;-------------
;-- Assign to output variable
$ini_RunParms:=$RunParms

;-- Convert newline to record delimiters
StringReplace
    ,$ini_RunParms
    ,$ini_RunParms
    ,`n
    ,%$RecordDelimiter%
    ,All

;-- Add borders to preserve leading/trailing whitespace
$ini_RunParms:=$iniBorder . $ini_RunParms . $iniBorder

;-- Save it
iniWrite
    ,%$ini_RunParms%
    ,%$ConfigFile%
    ,Run
    ,RunParms

;----------------
;-- $RunParmsDDL
;----------------
;-- Assign to output variable
$ini_RunParmsDDL:=$RunParmsDDL

;-- Convert newline to record delimiters
StringReplace
    ,$ini_RunParmsDDL
    ,$ini_RunParmsDDL
    ,`n
    ,%$RecordDelimiter%
    ,All

;-- Add borders to preserve leading/trailing whitespace
$ini_RunParmsDDL:=$iniBorder . $ini_RunParmsDDL . $iniBorder

;-- Save it
iniWrite
    ,%$ini_RunParmsDDL%
    ,%$ConfigFile%
    ,Run
    ,RunParmsDDL

;[====================]
;[  Section: Restore  ]
;[====================]
iniWrite
    ,%$MaxRestorePoints%
    ,%$ConfigFile%
    ,Restore
    ,MaxRestorePoints

iniWrite
    ,%$CreateRPOnCopyfromDrop%
    ,%$ConfigFile%
    ,Restore
    ,CreateRPOnCopyfromDrop

iniWrite
    ,%$CreateRPOnRun%
    ,%$ConfigFile%
    ,Restore
    ,CreateRPOnRun

iniWrite
    ,%$CreateRPOnSave%
    ,%$ConfigFile%
    ,Restore
    ,CreateRPOnSave

iniWrite
    ,%$CreateRPOnExit%
    ,%$ConfigFile%
    ,Restore
    ,CreateRPOnExit

;[=====================]
;[  Section: RPViewer  ]
;[=====================]
iniWrite
    ,%$RPViewerFont%
    ,%$ConfigFile%
    ,RPViewer
    ,Font

iniWrite
    ,%$RPViewerFontSize%
    ,%$ConfigFile%
    ,RPViewer
    ,FontSize

iniWrite
    ,%$RPViewerFontStyle%
    ,%$ConfigFile%
    ,RPViewer
    ,FontStyle

iniWrite
    ,%$RPViewerLineNumbersBar%
    ,%$ConfigFile%
    ,RPViewer
    ,LineNumbersBar

iniWrite
    ,%$RPViewerSaveWindowPos%
    ,%$ConfigFile%
    ,RPViewer
    ,SaveWindowPos

iniWrite
    ,%$RPViewerCloseOnRestore%
    ,%$ConfigFile%
    ,RPViewer
    ,CloseOnRestore

iniWrite
    ,%$RPViewerEscapeToClose%
    ,%$ConfigFile%
    ,RPViewer
    ,EscapeToClose

;[================]
;[  Section: New  ]
;[================]
iniWrite
    ,%$NewScriptSystemDefault%
    ,%$ConfigFile%
    ,New
    ,SystemDefault

;----------
;-- Script
;----------
;-- Assign to output variable
$ini_NewScript:=$NewScript

;-- Convert newline to record delimiters
StringReplace
    ,$ini_NewScript
    ,$ini_NewScript
    ,`n
    ,%$RecordDelimiter%
    ,All

;-- Add borders to preserve leading/trailing whitespace
$ini_NewScript:=$iniBorder . $ini_NewScript . $iniBorder

;-- Save it
iniWrite
    ,%$ini_NewScript%
    ,%$ConfigFile%
    ,New
    ,Script

;[==================]
;[  Section: Debug  ]
;[==================]
;-- Assign to output variable
$ini_DebugScript:=$DebugScript

;-- Convert newline to record delimiters
StringReplace
    ,$ini_DebugScript
    ,$ini_DebugScript
    ,`n
    ,%$RecordDelimiter%
    ,All

;-- Add borders to preserve leading/trailing whitespace
$ini_DebugScript:=$iniBorder . $ini_DebugScript . $iniBorder

;-- Save it
iniWrite
    ,%$ini_DebugScript%
    ,%$ConfigFile%
    ,Debug
    ,Script

;[=======================]
;[  Section: OptionsGUI  ]
;[=======================]
iniWrite
    ,%$OptionsGUI_Tab%
    ,%$ConfigFile%
    ,OptionsGUI
    ,Tab

return


;***********************
;*                     *
;*    Save RPViewer    *
;*    configuration    *
;*                     *
;***********************
SaveRPViewerConfiguration:
SetTimer %A_ThisLabel%,Off

;-- Bounce if window is not open
IfWinNotExist ahk_id %$RPViewerGUI_hWnd%
    return
        ;-- Programming note: This test s/b redundant but remains as a fail-safe

WinGetPos
    ,$RPViewerX
    ,$RPViewerY
    ,$RPViewerW
    ,$RPViewerH
    ,ahk_id %$RPViewerGUI_hWnd%

iniWrite
    ,%$RPViewerX%
    ,%$ConfigFile%
    ,RPViewer
    ,X

iniWrite
    ,%$RPViewerY%
    ,%$ConfigFile%
    ,RPViewer
    ,Y

iniWrite
    ,%$RPViewerW%
    ,%$ConfigFile%
    ,RPViewer
    ,W

iniWrite
    ,%$RPViewerH%
    ,%$ConfigFile%
    ,RPViewer
    ,H

return


;****************************
;*                          *
;*    Process parameters    *
;*                          *
;****************************
ProcessParameters:

;-- Bounce if no parameters
if not %0%
    return

;[======================]
;[  Process parameters  ]
;[======================]
;-- 1st parameter only (for now)
$CLParameter=%1%

;-- Remove last character if a double-quote
if SubStr($CLParameter,0)=""""
    StringTrimRight $CLParameter,$CLParameter,1

;-- Error if file doesn't exist
IfNotExist %$CLParameter%
    {
    gui +OwnDialogs
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,File Not Found,
           (ltrim
            Specified file not found:  %A_Space%
            "%$CLParameter%"  %A_Space%
            `nProgram stopped.  %A_Space%
           )

    ExitApp
    }

;-- Error if directory
if InStr(FileExist($CLParameter),"D")
    {
    gui +OwnDialogs
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Command-line Error,
           (ltrim
            Command-line parameter contains a folder name:  %A_Space%
            "%$CLParameter%"  %A_Space%
            `nProgram stopped.  %A_Space%
           )

    ExitApp
    }

;[=====================]
;[  Prepare workspace  ]
;[=====================]
gosub PrepareWorkspace

;[=============]
;[  Copy file  ]
;[=============]
;-- Copy specified file over workspace file
FileCopy %$CLParameter%,%$EditFile%,1  ;-- 1=overwrite
If ErrorLevel
    {
    gui +OwnDialogs
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Copy Error,
           (ltrim
            Unable to copy the specified file to the workspace:  %A_Space%
            "%$CLParameter%"  %A_Space%
            `nProgram stopped.  %A_Space%
           )

    ExitApp
    }

;-- Reset file attributes
FileSetAttrib -RSH,%$EditFile%

;-- Redefine $CopyFromPath
SplitPath $CLParameter,,$CopyFromPath

;-- Push to $RecentFiles and reload menu
MRUManager($RecentFiles,"Push",$CLParameter,"|",9)
gosub QAHKGUI_ReloadRecentFilesMenu

;-- Update status bar
SB_SetText("Contents of " . CompressFileName($CLParameter,65) . " copied to the workspace.")
SetTimer QAHKGUI_ClearStatusBar,25000
return


;***************************
;*                         *
;*    Prepare workspace    *
;*                         *
;***************************
PrepareWorkspace:

;[=========================]
;[   Create "Edit" folder  ]
;[  (If it doesn't exist)  ]
;[=========================]
IfNotExist %$EditDir%\.
    {
    FileCreateDir %$EditDir%
    if ErrorLevel
        {
        gui +OwnDialogs
        MsgBox
            ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,Prepare Workspace Error,
               (ltrim
                Unable to create the "Edit" folder.  %A_Space%
                Program stopped.  %A_Space%
               )

        ExitApp
        }
    }

;[=========================]
;[  Create workspace file  ]
;[  (If it doesn't exist)  ]
;[=========================]
IfNotExist %$EditFile%
    {
    FileAppend MsgBox Enter script here,%$EditFile%
    if ErrorLevel
        {
        gui +OwnDialogs
        MsgBox
            ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,Prepare Workspace Error,
               (ltrim join`s
                Error occurred while attempting to create the initial
                workspace.  %A_Space%
                `nProgram stopped.  %A_Space%
               )

        ExitApp
        }
    }

return


;************************
;*                      *
;*    Load workspace    *
;*                      *
;************************
LoadWorkspace:

;-- Close current file
HE_CloseFile($QAHKGUI_hEdit)

;-- Prepare workspace
gosub PrepareWorkspace

;-- Open workspace file
HE_OpenFile($QAHKGUI_hEdit,$EditFile)
if not ErrorLevel
    {
    ;-- Notify the user
    gui +OwnDialogs
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Load Workspace Error,
           (ltrim
            Could not find/open the workspace file:  %A_Space%
            %$EditFile%  %A_Space%

            This file is probably locked by another program or process.  %A_Space%
            Program stopped.  %A_Space%
           )

    ExitApp
    }

return


;************************
;*                      *
;*    Save workspace    *
;*                      *
;************************
SaveWorkspace:

;-- Bounce if there are no changes
if HE_GetModify($QAHKGUI_hEdit)=0
    return

;-- Prep
gosub PrepareWorkspace
    ;-- Note: This routine is called here to check/rebuild the workspace area
    ;   just in case it was destroyed during a run or other program/user action.

;-- Save it
ErrorLevel :=HE_SaveFile($QAHKGUI_hEdit,$EditFile)
;;;;;If ErrorLevel
;;;;;    {
;;;;;    gui +OwnDialogs
;;;;;    MsgBox
;;;;;        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
;;;;;        ,Save Workspace Error
;;;;;        ,Unable to save the current workspace.  %A_Space%
;;;;;
;;;;;    return
;;;;;    }

;-- Programming note: The value returned from HE_SaveFile is meaningless.  The
;   function usually returns 0 regardless of whether the file was successfully
;   saved or not.  On rare occasion, the function returns 1.  This value is also
;   meaningless if the return value 0 does not provide guidance.

;-- Workspace file exist?
;
;   Programming note: For the most part, this test is meaningless but remains
;   as a fail-safe.
;
IfNotExist %$EditFile%
    {
    gui +OwnDialogs
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Save Workspace Error
        ,Unable to save the current workspace.  %A_Space%

    return
    }

;-- Reset Modify flag
HE_SetModify($QAHKGUI_hEdit,False)
return


;**************************
;*                        *
;*    Backup workspace    *
;*                        *
;**************************
BackupWorkspace:

;-- Programming note:  This routine assumes that the workspace environment
;   exists.  If you're not sure that the workspace environment has been
;   prepared, run the PrepareWorkspace routine before calling this routine.


;-- Copy workspace file over workspace backup file
FileCopy %$EditFile%,%$EditBackupFile%,1  ;-- 1=overwrite
If ErrorLevel
    {
    gui +OwnDialogs
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Workspace Backup Error
        ,Unable to create/update the workspace backup file.  %A_Space%

    return
    }

;-- Reset file attributes
FileSetAttrib -RSH,%$EditBackupFile%
    ;-- Usually redundant but remains as a fail-safe

return


;***************************
;*                         *
;*    Delete Run folder    *
;*                         *
;***************************
DeleteRunFolder:

;-- "Run" folder exists?
IfExist %$RunDir%\.
    {
    ;-- Delete it
    FileRemoveDir %$RunDir%,1  ;-- 1=Remove all files and subdirectories
    if ErrorLevel
        {
        gui +OwnDialogs
        MsgBox
            ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,Clear Run Workspace Error,
               (ltrim join`s
                Unable to clear the Run workspace.  It's likely that one or more
                files or folders are in use.  %A_Space%
               )
        }
    }

return


;*******************************
;*                             *
;*    Delete Restore folder    *
;*                             *
;*******************************
DeleteRestoreFolder:

;-- "Restore" folder exist?
IfExist %$RPDir%\.
    {
    ;-- Delete it
    FileRemoveDir %$RPDir%,1  ;-- 1=Remove all files and subdirectories
    if ErrorLevel
        {
        gui +OwnDialogs
        MsgBox
            ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,Delete Restore Folder Error,
               (ltrim join`s
                Unable to clear the "Restore" folder.  It's likely that one or
                more files are in use.  %A_Space%
               )
        }
    }

return


;*********************************
;*                               *
;*    Update printer settings    *
;*                               *
;*********************************
UpdatePrinterSettings:

;-- Bounce if the PageSetupDlg or PrintDlg functions have been called before
if hDevMode
    return

;-- Load ComDlg32 library
;
;   Programming note: Since both the PageSetup and Print routines call this
;   subroutine, the comdlg32.dll library is loaded here.  It is not unloaded
;   until the script ends.
;
if not hComDlg32
    hComDlg32:=DllCall("LoadLibrary","Str","comdlg32.dll")

;-- Create/Define PAGESETUPDLG Structure
VarSetCapacity(PAGESETUPDLG_Structure,84,0)
NumPut(84,PAGESETUPDLG_Structure,0,"UInt")                      ;-- lStructSize
NumPut($QAHKGUI_hWnd,PAGESETUPDLG_Structure,4,"UInt")           ;-- hwndOwner
NumPut(PSD_RETURNDEFAULT,PAGESETUPDLG_Structure,16,"UInt")      ;-- Flags

;-- Call Page Setup using ReturnDefault flag.  Bounce if there is an error.
if not DllCall("comdlg32\PageSetupDlgA","UInt",&PAGESETUPDLG_Structure)
    {
    outputdebug End Subrou: %A_ThisLabel% -- Error returned from PageSetupDlgA
    return
    }

;-- Collect handles
hDevMode :=NumGet(PAGESETUPDLG_Structure,8,"UInt")
    ;-- Handle to a global memory object that contains a DEVMODE structure

hDevNames :=NumGet(PAGESETUPDLG_Structure,12,"UInt")
    ;-- Handle to a movable global memory object that contains a DEVNAMES
    ;   structure

;-- Update orientation
if $PrintOrientation is Integer
    {
    ;-- Lock the moveable memory, retrieving a pointer to it
    pDevMode:=DllCall("GlobalLock","UInt",hDevMode)

    ;-- Orientation
    NumPut($PrintOrientation,pDevMode+0,44,"Short")

    ;-- Unlock the moveable memory
    DllCall("GlobalUnlock","Uint",hDevMode)
    }

return



;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;----------------------------- Begin QAHKGUI Stuff -----------------------------
;-------------------------------------------------------------------------------
;***************************
;*                         *
;*                         *
;*        Functions        *
;*        (QAHKGUI)        *
;*                         *
;*                         *
;***************************
;*******************
;*                 *
;*    OnToolbar    *
;*    (QAHKGUI)    *
;*                 *
;*******************
QAHKGUI_OnToolbar(p_hToolbar,p_Event,p_Button,p_ButtonPos)
    {
    ;[====================]
    ;[  Global variables  ]
    ;[====================]
    Global $hToolbar
          ,$ToolbarButtons

    ;[=====================]
    ;[  Clean up p_Button  ]
    ;[=====================]
    StringReplace p_Button,p_Button,%A_Space%,,All
    StringReplace p_Button,p_Button,$,,All  ;-- NL delimiter.  Feature doesn't work (yet)
    StringReplace p_Button,p_Button,.,,All

    ;[===============]
    ;[  Event: Menu  ]
    ;[===============]
    if p_Event=Menu
        QAHKGUI_ToolbarMenu(p_Button,p_ButtonPos)
            ;-- Programming note: Don't create an independent thread (SetTimer)
            ;   when calling a routine that shows a menu for a button.  Two
            ;   reasons:
            ;
            ;    1) The right side of the button should remain in a depressed
            ;       state while the menu is displayed.  The button remains in a
            ;       depressed state until the OnToolbar routine has been
            ;       completed.
            ;
            ;    2) All other OnToolbar messages should be ignored while the
            ;       menu is shown.  The toolbar appears to locked out until the
            ;       user selects one of the menu options or until the menu is
            ;       dismissed.

    ;[================]
    ;[  Event: Click  ]
    ;[================]
    if p_Event=Click
        {
        ;-- Programming note: Most (all?) Click events are initiated by creating
        ;   an independent thread via a SetTimer command with a 0 (start
        ;   immediately) period.  To insure that the routine is only called
        ;   once, make sure that the routine turns off the timer as the first
        ;   step.  If the routine fails to turn off the the timer, the SetTimer
        ;   command becomes an infinite loop.
        ;
        ;-- Most buttons
        if IsLabel("QAHKGUI_" . p_Button)
            SetTimer QAHKGUI_%p_Button%,0
         else
            {
            ;-- Edit
            if IsLabel("QAHKGUI_Edit" . p_Button)
                SetTimer QAHKGUI_Edit%p_Button%,0
             else
                {
                ;-- Exceptions
                if p_Button=Options
                    SetTimer OptionsGUI,0
                 else
                    if p_Button=Restore
                        SetTimer RPViewerGUI,0
                }
            }
        }

    ;[===========================]
    ;[  Event: Adjust or Change  ]
    ;[===========================]
    if p_Event in Adjust,Change
        {
        $ToolbarButtons:=Toolbar_Define($hToolbar)
        SetTimer SaveConfiguration,0
        SetTimer QAHKGUI_SetToolbarButtonState,250
        }

    return
    }


;*********************
;*                   *
;*    ToolbarMenu    *
;*     (QAHKGUI)     *
;*                   *
;*********************
;
;   Description
;   ===========
;   This function, called by the QAHKGUI_OnToolbar function when there is a
;   "Menu" event, shows a context menu specifically designed for the toolbar.
;   The function does not end until the user has selected one of the menu
;   items or the menu is dismissed.
;
;
;   Programming Notes
;   ================
;    -  This function will stop with an "Unable to find xxxx menu" error message
;       if a menu for the associated toolbar menu button does not exist.  Be
;       sure to test all toolbar menu buttons.
;
;    -  Any routine called from a toolbar menu should either  1) finish quickly
;       or  2) should spawn an independent thread to complete the task.  If a
;       new thread is not spawned, this function will not complete until the
;       request has completed.  In addition, the button will remain depressed
;       until the request has completed.
;
;-------------------------------------------------------------------------------
QAHKGUI_ToolbarMenu(p_Button,p_ButtonPos)
    {
    ;[====================]
    ;[  Global variables  ]
    ;[====================]
    Global SM_CXSIZEFRAME
          ,SM_CYSIZEFRAME
          ,SM_CYCAPTION
          ,SM_CYMENU
          ,$hToolbar
          ,$ScriptName
          ,$ShowMenubar

    ;-- Collect button statistics
    l_ButtonStats:=Toolbar_GetRect($hToolbar,p_ButtonPos)
    StringSplit l_ButtonRect,l_ButtonStats,%A_Space%

    ;-- Show menu
    Menu Tray,UseErrorLevel
    Menu Toolbar_%p_Button%
        ,Show
        ,% SM_CXSIZEFRAME+l_ButtonRect1     ;-- The button's X (left) position
        ,% SM_CYSIZEFRAME
         + SM_CYCAPTION
         + ($ShowMenubar ? SM_CYMENU:0)
         + 2                                ;-- see Note 1
         + l_ButtonRect2                    ;-- The button's Y (top) position
         + l_ButtonRect4                    ;-- The button's height

        ;-- Note 1: +2 is needed because Toolbar_GetRect doesn't account for a
        ;   2-pixel line top border.
        ;
        ;-- Note 2: This calculation only works if the toolbar is at the top of
        ;   the form.  If the menubar is wrapped, the Y position will be off by
        ;   the size of the extra menubar line(s).

    ;-- Menu not found?
    if ErrorLevel
        MsgBox
            ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,%$ScriptName% - Programmer Error
            ,Unable to find the "Toolbar_%p_Button%" menu.  %A_Space%

    ;-- Reset UseErrorLevel
    Menu Tray,UseErrorLevel,Off
    return
    }


;*******************
;*                 *
;*      OnFind     *
;*    (QAHKGUI)    *
;*                 *
;*******************
QAHKGUI_OnFind(p_Event,p_Flags,p_FindWhat,Dummy="")
    {
    ;[====================]
    ;[  Global variables  ]
    ;[====================]
    Global Dlg_hWnd
          ,Dlg_Flags
          ,Dlg_FindWhat
          ,Dlg_FindFromTheTop
          ,$QAHKGUI
          ,$QAHKGUI_hEdit

    ;[==========]
    ;[  Close?  ]
    ;[==========]
    if p_Event=C
        return

    ;-- If open, manually close the Find dialog
    IfWinExist ahk_id %Dlg_hWnd%
        {
        WinClose ahk_id %Dlg_hWnd%
        Dlg_hWnd:=0
        }

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    ;-- Update Globals
    Dlg_Flags   :=p_Flags
    Dlg_FindWhat:=p_FindWhat
        ;-- These global variables are used by Find, FindNext, FindPrevious, and
        ;   Replace routines.

    ;-- Convert Dlg_Find flags to HE_FindText flags
    l_Flags:=""
    if p_Flags contains c
        l_Flags:=l_Flags . "MATCHCASE "

    if p_Flags contains w
        l_Flags:=l_Flags . "WHOLEWORD "

    ;[===========]
    ;[  Find it  ]
    ;[===========]
    HE_GetSel($QAHKGUI_hEdit,l_StartSelPos,l_EndSelPos)

    ;-- Which direction?
    if p_Flags contains d
        l_FindPos:=HE_FindText($QAHKGUI_hEdit,p_FindWhat,l_EndSelPos,-1,l_Flags)<<32>>32
     else
        l_FindPos:=HE_FindText($QAHKGUI_hEdit,p_FindWhat,l_StartSelPos,0,l_Flags)<<32>>32

    ;-- Anything found?
    if (l_FindPos>=0)
        {
        ;-- Select and scroll to it
        HE_SetSel($QAHKGUI_hEdit,l_FindPos,l_FindPos+StrLen(p_FindWhat))
        HE_ScrollCaret($QAHKGUI_hEdit)
        }
     else
        {
        ;-- Attach dialog to QAHKGUI window
        gui %$QAHKGUI%:+OwnDialogs

        ;-- Notify/Prompt the user
        $Message=Next occurrence of "%p_FindWhat%" not found.
        if Dlg_FindFromTheTop or InStr(p_Flags,"D")=0
            {
            MsgBox
                ,64     ;-- 64 = 0 (OK button) + 64 (Info icon)
                ,Find
                ,%$Message%  %A_Space%

            Dlg_FindFromTheTop:=False
            return
            }

        MsgBox
            ,33     ;-- 33 = 1 (OK/Cancel buttons) + 32 ("?" icon)
            ,Find
            ,%$Message%`nContinue search from the top?  %A_Space%

        IfMsgBox Cancel
            {
            Dlg_FindFromTheTop:=False
            return
            }

        ;[===================]
        ;[  Start searching  ]
        ;[    from the top   ]
        ;[===================]
        Dlg_FindFromTheTop:=True
        HE_SetSel($QAHKGUI_hEdit,0,0)   ;-- Move caret to the top
        QAHKGUI_OnFind("F",p_Flags,p_FindWhat)
            ;-- Recursive call
        }

    return
    }


;*******************
;*                 *
;*    OnReplace    *
;*    (QAHKGUI)    *
;*                 *
;*******************
QAHKGUI_OnReplace(p_Event,p_Flags,p_FindWhat,p_ReplaceWith)
    {
    ;[====================]
    ;[  Global variables  ]
    ;[====================]
    Global Dlg_hWnd
          ,Dlg_Flags
          ,Dlg_FindWhat
          ,Dlg_ReplaceWith
          ,Dlg_FindFromTheTop
          ,$QAHKGUI
          ,$QAHKGUI_hEdit

    ;[====================]
    ;[  Static variables  ]
    ;[====================]
    Static s_ReplaceCount:=0
                ;-- Counter to track the number of standard "Replace"  commands
                ;   that have been performed.

    ;[==========]
    ;[  Close?  ]
    ;[==========]
    if p_Event=C
        return

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    ;-- Update Globals
    Dlg_Flags      :=p_Flags
    Dlg_FindWhat   :=p_FindWhat
    Dlg_ReplaceWith:=p_ReplaceWith
        ;-- These global variables are used by Find, FindNext, FindPrevious, and
        ;   Replace routines.

    ;-- Convert Dlg_Find flags to HE_FindText flags
    l_Flags:=""
    if p_Flags contains c
        l_Flags:=l_Flags . "MATCHCASE "

    if p_Flags contains w
        l_Flags:=l_Flags . "WHOLEWORD "

    ;-- Get select positions
    HE_GetSel($QAHKGUI_hEdit,l_StartSelPos,l_EndSelPos)

    ;[=========]
    ;[  Find   ]
    ;[=========]
    if p_Event=F
        {
        ;-- Look for it
        l_FindPos:=HE_FindText($QAHKGUI_hEdit,p_FindWhat,l_EndSelPos,-1,l_Flags)<<32>>32

        ;-- Anything found?
        if (l_FindPos>=0)
            {
            ;-- Select and scroll to it
            HE_SetSel($QAHKGUI_hEdit,l_FindPos,l_FindPos+StrLen(p_FindWhat))
            HE_ScrollCaret($QAHKGUI_hEdit)
            }
         else
            {
            ;-- Attach MsgBox dialog to QAHKGUI window
            gui %$QAHKGUI%:+OwnDialogs

            ;-- Disable dialog
            WinSet Disable,,ahk_id %Dlg_hWnd%

            ;-- Notify/Prompt the user
            $Message="%p_FindWhat%" not found.
            if Dlg_FindFromTheTop
                {
                MsgBox
                    ,64     ;-- 64 = 0 (OK button) + 64 (Info icon)
                    ,Replace
                    ,%$Message%  %A_Space%

                Dlg_FindFromTheTop:=False
                WinSet Enable,,ahk_id %Dlg_hWnd%
                return
                }

            MsgBox
                ,33     ;-- 33 = 1 (OK/Cancel buttons) + 32 ("?" icon)
                ,Replace
                ,%$Message%`nContinue search from the top?  %A_Space%

            ;-- Enable dialog
            WinSet Enable,,ahk_id %Dlg_hWnd%

            IfMsgBox Cancel
                {
                Dlg_FindFromTheTop:=False
                return
                }

            ;[===================]
            ;[  Start searching  ]
            ;[    from the top   ]
            ;[===================]
            Dlg_FindFromTheTop:=True
            HE_SetSel($QAHKGUI_hEdit,0,0)  ;-- Move caret to the top
            QAHKGUI_OnReplace("F",p_Flags,p_FindWhat,p_ReplaceWith)
                ;-- Recursive call
            }
        }

    ;[===========]
    ;[  Replace  ]
    ;[===========]
    if p_Event=R
        {
        ;-- Anything selected and if so, is it the same length of p_FindWhat?
         if (l_StartSelPos<>l_EndSelPos)
        and StrLen(p_FindWhat)=l_EndSelPos-l_StartSelPos
            {
            ;-- Look for it within the selected area
            l_FindPos:=HE_FindText($QAHKGUI_hEdit,p_FindWhat,l_StartSelPos,l_EndSelPos,l_Flags)
                ;-- Programming note: The HE_FindText function is called here
                ;   instead of just doing a plain "If selected=p_FindWhat"
                ;   test because the function takes into consideration the
                ;   optional "Match case" and "Match Whole Word" flags.

            ;-- If found, replace with p_ReplaceWith
            if (l_FindPos=l_StartSelPos)
                {
                HE_ReplaceSel($QAHKGUI_hEdit,p_ReplaceWith)

                ;-- Count it
                s_ReplaceCount++
                }
            }
        ;-- Find next
        QAHKGUI_OnReplace("F",p_Flags,p_FindWhat,p_ReplaceWith)
            ;-- Recursive call
        }

    ;[================]
    ;[  Replace All   ]
    ;[================]
    if p_Event=A
        {
        ;-- Manually close the Replace dialog
        WinClose ahk_id %Dlg_hWnd%
        Dlg_hWnd:=0


        ;-- Set focus
        ControlFocus,,ahk_id %$QAHKGUI_hEdit%
            ;-- Not sure if this is necessary

        ;-- Set to Wait (Hourglass) cursor
        SetSystemCursor("IDC_Wait")

        ;-- Position caret
         if (l_StartSelPos<>l_EndSelPos)
            if StrLen(p_FindWhat)=l_EndSelPos-l_StartSelPos
                HE_SetSel($QAHKGUI_hEdit,l_StartSelPos,l_StartSelPos)
             else
                HE_SetSel($QAHKGUI_hEdit,l_EndSelPos+1,l_EndSelPos+1)

        ;-- Replace All
        l_ReplaceCount:=0
        Loop
            {
            ;-- Get select positions
            rHE_GetSel:=HE_GetSel($QAHKGUI_hEdit,Dummy,l_EndSelPos)

            ;-- Look for next
            l_FindPos:=HE_FindText($QAHKGUI_hEdit,p_FindWhat,l_EndSelPos,-1,l_Flags)<<32>>32

            ;-- Anything found?
            if (l_FindPos>=0)
                {
                ;-- Select and scroll to it
                rHE_SetSel:=HE_SetSel($QAHKGUI_hEdit,l_FindPos,l_FindPos+StrLen(p_FindWhat))
                HE_ScrollCaret($QAHKGUI_hEdit)

                ;-- Replace with p_ReplaceWith
                rHE_ReplaceSel:=HE_ReplaceSel($QAHKGUI_hEdit,p_ReplaceWith)

                ;-- Count it
                l_ReplaceCount++
                }
             else
                Break
            }

            ;-- Restore the cursor
            SetSystemCursor("restore")

            ;-------------------
            ;-- Notify the user
            ;-------------------
            ;-- Attach dialog to QAHKGUI window
            gui %$QAHKGUI%:+OwnDialogs

            ;-- Display message
            if l_ReplaceCount=0
                $Message="%p_FindWhat%" not found.
             else
                $Message="%p_FindWhat%" replaced %l_ReplaceCount% times.

            MsgBox
                ,64     ;-- 64 = 0 (OK button) + 64 (Info icon)
                ,Replace All
                ,%$Message%  %A_Space%
            }

    return
    }


;*********************
;*                   *
;*    ConvertCase    *
;*     (QAHKGUI)     *
;*                   *
;*********************
QAHKGUI_ConvertCase(hEdit,p_Case)
    {
    ;-- Convert p_case to format used by HE_ConvertCase
    StringReplace p_Case,p_Case,case,,All

    ;-- Get select positions
    HE_GetSel(hEdit,l_StartSelPos,l_EndSelPos)

    ;-- Bounce if nothing is selected
    if (l_StartSelPos=l_EndSelPos)
        return

    ;-- Convert Case
    HE_ConvertCase(hEdit,p_Case)

    ;-- Reselect
    HE_SetSel(hEdit,l_StartSelPos,l_EndSelPos)
    return
    }


;**********************
;*                    *
;*    Confirm Exit    *
;*     (QAHKGUI)      *
;*                    *
;**********************
QAHKGUI_ConfirmExit()
    {
    ;[====================]
    ;[  Global variables  ]
    ;[====================]
    Global $RunPIDList
          ,$ScriptName

    ;[===============]
    ;[  OK to exit?  ]
    ;[===============]
    $RunPIDList:=RebuildRunPIDList($RunPIDList)
    if StrLen($RunPIDList)
        {
        gui +OwnDialogs
        MsgBox
            ,49     ;-- 49 = 1 (OK/Cancel buttons) + 48 ("!" icon)
            ,Confirm Exit,
               (ltrim join`s
                Warning: There is at least one script started by
                %$ScriptName% that is still running.  %A_Space%
                `n`nPlease note that scripts started by %$ScriptName% will not
                be stopped when the program is closed.  Also, scripts started by
                this session of %$ScriptName% will not be recognized by future
                sessions.  %A_Space%
                `n`nPress OK to exit %$ScriptName%.  %A_Space%
               )

        ;-- Cancel?
        IfMsgBox Cancel
            Return False
        }

    ;-- It's all good
    Return True
    }



;*****************************
;*                           *
;*                           *
;*        Subroutines        *
;*        (QAHKGUI)          *
;*                           *
;*                           *
;*****************************
;*****************
;*               *
;*    QAHKGUI    *
;*               *
;*****************
QAHKGUI:

;-- Initialize
$QAHKGUI=11

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- Identify window handle
gui %$QAHKGUI%:+LastFound
WinGet $QAHKGUI_hWnd,ID
GroupAdd $QAHKGUI_Group,ahk_id %$QAHKGUI_hWnd%

;-- Build menus
gosub QAHKGUI_BuildMenus

;-- Build GUI
gosub QAHKGUI_BuildGUI

;-- Build $Tab variable - Used by the Tab and Shift+Tab hotkeys
$Tab=
if $RealTabs
    $Tab:="`t"
 else
    Loop % $TabWidth
        $Tab.=A_Space

;-- Trap right click
OnMessage(WM_RBUTTONUP,"WM_RBUTTONUP")
return


;*********************
;*                   *
;*    Build menus    *
;*     (QAHKGUI)     *
;*                   *
;*********************
QAHKGUI_BuildMenus:

;[========]
;[  Menu  ]
;[========]
;-- RecentFiles (sub-menu of File menu)
gosub QAHKGUI_BuildRecentFilesMenu

;--------
;-- File
;--------
Menu QAHKGUI_FileMenu
    ,Add
    ,%s_New_MI%
    ,QAHKGUI_New

Menu QAHKGUI_FileMenu
    ,Add
    ,%s_Prepend_New_MI%
    ,QAHKGUI_PrependNew

Menu QAHKGUI_FileMenu
    ,Add
    ,&Copy From...`tCtrl+O
    ,QAHKGUI_CopyFrom

Menu QAHKGUI_FileMENU
    ,Add
    ,Copy Recent
    ,:QAHKGUI_RecentFilesMenu

Menu QAHKGUI_FileMenu
    ,Add

;-- External editor?
if $ExtEditorPath is not Space
    {
    if $ExtEditorName
        Menu QAHKGUI_FileMenu
            ,Add
            ,Edit with %$ExtEditorName%`tF8
            ,QAHKGUI_ExternalEditor
     else
        Menu QAHKGUI_FileMenu
            ,Add
            ,Edit with external editor`tF8
            ,QAHKGUI_ExternalEditor

    Menu QAHKGUI_FileMenu
        ,Add
    }

Menu QAHKGUI_FileMenu
    ,Add
    ,%s_Run_MI%
    ,QAHKGUI_Run

Menu QAHKGUI_FileMenu
    ,Add
    ,%s_RunSelected_MI%
    ,QAHKGUI_RunSelected

Menu QAHKGUI_FileMenu
    ,Add
    ,%s_File_Stop_MI%
    ,QAHKGUI_Stop

Menu QAHKGUI_FileMenu
    ,Disable
    ,%s_File_Stop_MI%

Menu QAHKGUI_FileMenu
    ,Add
    ,Exp&lore Run Workspace`tCtrl+Shift+F9
    ,QAHKGUI_ExploreRunWorkspace

Menu QAHKGUI_FileMenu
    ,Add
    ,Clear Run &Workspace`tCtrl+Alt+F9
    ,QAHKGUI_ClearRunWorkspace

Menu QAHKGUI_FileMenu
    ,Add

Menu QAHKGUI_FileMenu
    ,Add
    ,%s_Save_MI%
    ,QAHKGUI_Save

Menu QAHKGUI_FileMenu
    ,Add
    ,%s_SaveTo_MI%
    ,QAHKGUI_SaveTo

Menu QAHKGUI_FileMenu
    ,Add
    ,Re&vert`tCtrl+Shift+Z
    ,QAHKGUI_Revert

Menu QAHKGUI_FileMenu
    ,Add

Menu QAHKGUI_FileMenu
    ,Add
    ,Create Restore &Point`tCtrl+Shift+R
    ,QAHKGUI_CreateRestorePoint

Menu QAHKGUI_FileMenu
    ,Add
    ,Rest&ore...`tF4
    ,RPViewerGUI

Menu QAHKGUI_FileMenu
    ,Add

Menu QAHKGUI_FileMenu
    ,Add
    ,%s_PageSetup_MI%
    ,QAHKGUI_PageSetup

Menu QAHKGUI_FileMenu
    ,Add
    ,%s_Print_MI%
    ,QAHKGUI_Print

Menu QAHKGUI_FileMenu
    ,Add

Menu QAHKGUI_FileMenu
    ,Add
    ,E&xit`tAlt+F4
    ,QAHKGUI_Close

;---------------------------
;--       Convert Case
;-- (Sub-Menu of Edit menu)
;---------------------------
Menu QAHKGUI_ConvertCaseMenu
    ,Add
    ,&Uppercase`tCtrl+Shift+U
    ,QAHKGUI_Uppercase

Menu QAHKGUI_ConvertCaseMenu
    ,Add
    ,&Lowercase`tCtrl+Shift+L
    ,QAHKGUI_Lowercase

Menu QAHKGUI_ConvertCaseMenu
    ,Add
    ,&Capitalize`tCtrl+Shift+C
    ,QAHKGUI_Capitalize

Menu QAHKGUI_ConvertCaseMenu
    ,Add
    ,&Toggle case`tCtrl+Shift+T
    ,QAHKGUI_ToggleCase

;----------
;-- Edit
;----------
Menu QAHKGUI_EditMenu
    ,Add
    ,%s_Undo_MI%
    ,QAHKGUI_Undo

Menu QAHKGUI_EditMenu
    ,Add
    ,%s_Redo_MI%
    ,QAHKGUI_Redo

Menu QAHKGUI_EditMenu
    ,Add

Menu QAHKGUI_EditMenu
    ,Add
    ,%s_Cut_MI%
    ,QAHKGUI_EditCut

Menu QAHKGUI_EditMenu
    ,Add
    ,%s_Copy_MI%
    ,QAHKGUI_EditCopy

Menu QAHKGUI_EditMenu
    ,Add
    ,%s_Paste_MI%
    ,QAHKGUI_EditPaste

Menu QAHKGUI_EditMenu
    ,Add
    ,%s_PasteC_MI%
    ,QAHKGUI_PasteClipboard

Menu QAHKGUI_EditMenu
    ,Add
    ,%s_Delete_MI%
    ,QAHKGUI_Editclear

Menu QAHKGUI_EditMenu
    ,Add
    ,%s_SelectAll_MI%
    ,QAHKGUI_EditSelectAll

Menu QAHKGUI_EditMenu
    ,Add

Menu QAHKGUI_EditMenu
    ,Add
    ,%s_BlockComment_MI%
    ,QAHKGUI_BlockComment

Menu QAHKGUI_EditMenu
    ,Add
    ,%s_BlockUncomment_MI%
    ,QAHKGUI_BlockUncomment

Menu QAHKGUI_EditMenu
    ,Add

Menu QAHKGUI_EditMenu
    ,Add
    ,%s_ConvertCase_MI%
    ,:QAHKGUI_ConvertCaseMenu

;----------------
;-- Context Menu
;----------------
Menu QAHKGUI_ContextMenu
    ,Add
    ,%s_Undo_MI%
    ,QAHKGUI_Undo

Menu QAHKGUI_ContextMenu
    ,Add
    ,%s_Redo_MI%
    ,QAHKGUI_Redo

Menu QAHKGUI_ContextMenu
    ,Add

Menu QAHKGUI_ContextMenu
    ,Add
    ,%s_Cut_MI%
    ,QAHKGUI_EditCut

Menu QAHKGUI_ContextMenu
    ,Add
    ,%s_Copy_MI%
    ,QAHKGUI_EditCopy

Menu QAHKGUI_ContextMenu
    ,Add
    ,%s_Paste_MI%
    ,QAHKGUI_EditPaste

Menu QAHKGUI_ContextMenu
    ,Add
    ,%s_PasteC_MI%
    ,QAHKGUI_PasteClipboard

Menu QAHKGUI_ContextMenu
    ,Add
    ,%s_Delete_MI%
    ,QAHKGUI_Editclear

Menu QAHKGUI_ContextMenu
    ,Add
    ,%s_SelectAll_MI%
    ,QAHKGUI_EditSelectAll

Menu QAHKGUI_ContextMenu
    ,Add

Menu QAHKGUI_ContextMenu
    ,Add
    ,%s_BlockComment_MI%
    ,QAHKGUI_BlockComment

Menu QAHKGUI_ContextMenu
    ,Add
    ,%s_BlockUncomment_MI%
    ,QAHKGUI_BlockUncomment

Menu QAHKGUI_ContextMenu
    ,Add

Menu QAHKGUI_ContextMenu
    ,Add
    ,%s_ConvertCase_MI%
    ,:QAHKGUI_ConvertCaseMenu

Menu QAHKGUI_ContextMenu
    ,Add

Menu QAHKGUI_ContextMenu
    ,Add
    ,%s_RunSelected_MI%
    ,QAHKGUI_ContextMenu_RunSelected

;----------
;-- Search
;----------
Menu QAHKGUI_SearchMenu
    ,Add
    ,%s_Find_MI%
    ,QAHKGUI_Find

Menu QAHKGUI_SearchMenu
    ,Add
    ,%s_FindNext_MI%
    ,QAHKGUI_FindNext

Menu QAHKGUI_SearchMenu
    ,Add
    ,%s_FindPrevious_MI%
    ,QAHKGUI_FindPrevious

Menu QAHKGUI_SearchMenu
    ,Add
    ,%s_Replace_MI%
    ,QAHKGUI_Replace

Menu QAHKGUI_SearchMenu
    ,Add
    ,%s_Replace_MI%
    ,QAHKGUI_Replace

Menu QAHKGUI_SearchMenu
    ,Add

Menu QAHKGUI_SearchMenu
    ,Add
    ,%s_Goto_MI%
    ,QAHKGUI_Goto

;--------
;-- View
;--------
Menu QAHKGUI_ViewMenu
    ,Add
    ,%s_AlwaysOnTop_MI%
    ,QAHKGUI_MenuAction

Menu QAHKGUI_ViewMenu
    ,Add

Menu QAHKGUI_ViewMenu
    ,Add
    ,%s_MenuBar_MI%
    ,QAHKGUI_MenuAction

Menu QAHKGUI_ViewMenu
    ,Add
    ,%s_ToolBar_MI%
    ,QAHKGUI_MenuAction

Menu QAHKGUI_ViewMenu
    ,Add
    ,%s_LineNumbersBar_MI%
    ,QAHKGUI_MenuAction

Menu QAHKGUI_ViewMenu
    ,Add
    ,%s_StatusBar_MI%
    ,QAHKGUI_MenuAction

;-------
;-- Run
;-------
Menu QAHKGUI_RunMenu
    ,Add
    ,%s_Run_MI%
    ,QAHKGUI_Run

Menu QAHKGUI_RunMenu
    ,Add
    ,%s_RunSelected_MI%
    ,QAHKGUI_RunSelected

Menu QAHKGUI_RunMenu
    ,Add

Menu QAHKGUI_RunMenu
    ,Add
    ,%s_RunPrompt_MI%
    ,QAHKGUI_MenuAction

Menu QAHKGUI_RunMenu
    ,Add
    ,%s_RunDebug_MI%
    ,QAHKGUI_MenuAction

Menu QAHKGUI_RunMenu
    ,Add
    ,%s_RunWait_MI%
    ,QAHKGUI_MenuAction

Menu QAHKGUI_RunMenu
    ,Add

Menu QAHKGUI_RunMenu
    ,Add
    ,%s_ClearRunWorkspaceOnRun_MI%
    ,QAHKGUI_MenuAction

Menu QAHKGUI_RunMenu
    ,Add
    ,%s_ClearRunWorkspaceOnExit_MI%
    ,QAHKGUI_MenuAction

;--------
;-- Help
;--------
Menu QAHKGUI_HelpMenu
    ,Add
    ,%s_Help_MI%
    ,QAHKGUI_Help

Menu QAHKGUI_HelpMenu
    ,Add
    ,%s_About_MI%
    ,QAHKGUI_About

;-----------
;-- Menubar
;-----------
Menu QAHKGUI_Menubar
    ,Add
    ,&File
    ,:QAHKGUI_FileMenu

Menu QAHKGUI_Menubar
    ,Add
    ,&Edit
    ,:QAHKGUI_EditMenu

Menu QAHKGUI_Menubar
    ,Add
    ,&Search
    ,:QAHKGUI_SearchMenu

Menu QAHKGUI_Menubar
    ,Add
    ,&View
    ,:QAHKGUI_ViewMenu

Menu QAHKGUI_Menubar
    ,Add
    ,&Options
    ,OptionsGUI

Menu QAHKGUI_Menubar
    ,Add
    ,&New
    ,QAHKGUI_New

Menu QAHKGUI_Menubar
    ,Add
    ,&PasteC
    ,QAHKGUI_PasteClipboard

Menu QAHKGUI_Menubar
    ,Add
    ,Run
    ,:QAHKGUI_RunMenu

Menu QAHKGUI_Menubar
    ,Add
    ,%s_Menubar_Stop_MI%
    ,QAHKGUI_Stop

Menu QAHKGUI_Menubar
    ,Disable
    ,%s_Menubar_Stop_MI%

Menu QAHKGUI_Menubar
    ,Add
    ,Rest&ore
    ,RPViewerGUI

Menu QAHKGUI_Menubar
    ,Add
    ,&Help
    ,:QAHKGUI_HelpMenu

;------------------
;-- MenubarRunWait
;------------------
Menu QAHKGUI_MenubarRunWait
    ,Add
    ,%s_Menubar_Stop_MI%
    ,QAHKGUI_Stop

;----------------
;-- Toolbar: New
;----------------
Menu Toolbar_New
    ,Add
    ,%s_New_MI%
    ,QAHKGUI_New

Menu Toolbar_New
    ,Default
    ,%s_New_MI%

Menu Toolbar_New
    ,Add
    ,%s_Prepend_New_MI%
    ,QAHKGUI_PrependNew

;-----------------
;-- Toolbar: Save
;-----------------
Menu Toolbar_Save
    ,Add
    ,%s_Save_MI%
    ,QAHKGUI_Save

Menu Toolbar_Save
    ,Default
    ,%s_Save_MI%

Menu Toolbar_Save
    ,Add
    ,%s_SaveTo_MI%
    ,QAHKGUI_Toolbar_SaveTo

;------------------
;-- Toolbar: Print
;------------------
Menu Toolbar_Print
    ,Add
    ,%s_Print_MI%
    ,QAHKGUI_Toolbar_Print

Menu Toolbar_Print
    ,Default
    ,%s_Print_MI%

Menu Toolbar_Print
    ,Add
    ,%s_PageSetup_MI%
    ,QAHKGUI_Toolbar_PageSetup

;-----------------
;-- Toolbar: Find
;-----------------
Menu Toolbar_Find
    ,Add
    ,%s_Find_MI%
    ,QAHKGUI_Find

Menu Toolbar_Find
    ,Default
    ,%s_Find_MI%

Menu Toolbar_Find
    ,Add
    ,%s_FindNext_MI%
    ,QAHKGUI_FindNext

Menu Toolbar_Find
    ,Add
    ,%s_FindPrevious_MI%
    ,QAHKGUI_FindPrevious

Menu Toolbar_Find
    ,Add
    ,%s_Replace_MI%
    ,QAHKGUI_Replace

Menu Toolbar_Find
    ,Add

Menu Toolbar_Find
    ,Add
    ,%s_Goto_MI%
    ,QAHKGUI_Toolbar_Goto

;----------------
;-- Toolbar: Run
;----------------
Menu Toolbar_Run
    ,Add
    ,%s_Run_MI%
    ,QAHKGUI_Toolbar_Run

Menu Toolbar_Run
    ,Default
    ,%s_Run_MI%

Menu Toolbar_Run
    ,Add
    ,%s_RunSelected_MI%
    ,QAHKGUI_Toolbar_RunSelected

;-----------------
;-- Toolbar: Help
;-----------------
Menu Toolbar_Help
    ,Add
    ,%s_Help_MI%
    ,QAHKGUI_Help

Menu Toolbar_Help
    ,Default
    ,%s_Help_MI%

Menu Toolbar_Help
    ,Add
    ,%s_About_MI%
    ,QAHKGUI_Toolbar_About

return


QAHKGUI_BuildRecentFilesMenu:

;-- Create stub (needed for the 1st call)
Menu QAHKGUI_RecentFilesMenu,Add

;-- Clear menu
Menu QAHKGUI_RecentFilesMenu,DeleteAll

;-- Populate Recent Files Menu
Loop Parse,$RecentFiles,|
    Menu QAHKGUI_RecentFilesMenu
        ,Add
        ,% A_Index . ". " . CompressFileName(A_LoopField,65)
        ,QAHKGUI_RecentFilesMenu

if $RecentFiles is not Space
    Menu QAHKGUI_RecentFilesMenu,Add

Menu QAHKGUI_RecentFilesMenu,Add,Clear List,QAHKGUI_ClearRecentFilesMenu

if $RecentFiles is Space
    Menu QAHKGUI_RecentFilesMenu,Disable,Clear List

;-- Update $RecentFilesMenu
$RecentFilesMenu:=$RecentFiles
    ;-- Programming note: $RecentFiles and $RecentFilesMenu contain the same
    ;   information but $RecentFilesMenu always has the information in the order
    ;   defined in the menu.

return


;*******************
;*                 *
;*    Build GUI    *
;*    (QAHKGUI)    *
;*                 *
;*******************
QAHKGUI_BuildGUI:

;[============]
;[  Build it  ]
;[============]
;-- GUI options
gui Margin,0,0

if $ShowMenubar
    gui Menu,QAHKGUI_Menubar

gui +Resize
    || +LabelQAHKGUI_

;-- AOT
if $AlwaysOnTop
    gui +AlwaysOnTop

;-- Dummy fields
gui Add
   ,Text
   ,% "x" . $MaxGUIW . " ym w0 h0"
   ,DummyX

gui Add
   ,Text
   ,xm y300 w0 h0
   ,DummyY

;-- The preceding two dummy controls are necessary because AutoHotkey does not
;   see the HiEdit object and therefore will not autosize the window correctly.
;   Setting a fixed size on the "gui Show" command will also work but additional
;   calculations must be performed to correctly account for the status bar and
;   the menu bar.

;------------------
;-- HiEdit control
;------------------
$QAHKGUI_hEdit:=HE_Add($QAHKGUI_hWnd,0,0,$MaxGUIW,300,"HSCROLL VSCROLL HILIGHT",$LibDir . "\HiEdit.dll")
if not $QAHKGUI_hEdit
    {
    gui +OwnDialogs
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,%$ScriptName% Error
        ,Unable to find HiEdit.dll.  Program stopped.  %A_Space%

    ExitApp
    }

;-- Get the default colors
$DefaultColors:=HE_GetColors($QAHKGUI_hEdit)

;-- Change selected colors
$Colors=
Loop Parse,$DefaultColors,`n
    {
    $Key:=A_LoopField
    if $Key contains InSelBack
        $Key:="InSelBack=0xC56A31"
            ;-- Programming note: This change allows selected text to appear
            ;   prominent while the main window is not in focus.  This
            ;   modification was included to support the Replace dialog which
            ;   remains in focus until all changes are made.

    if $Colors is Space
        $Colors:=$Key
     else
        $Colors:=$Colors . "`n" . $Key
    }

;-- Set colors to include changes
HE_SetColors($QAHKGUI_hEdit,$Colors)

;-- Font and font size
HE_SetFont($QAHKGUI_hEdit,"s" . $FontSize . A_Space . $FontStyle . "," . $Font)

;-- Keywords file
HE_SetKeywordFile($LibDir . "\KeyWords.hes")

;-- Tab width
if $TabWidth
    HE_SetTabWidth($QAHKGUI_hEdit,$TabWidth)

;-- Auto indent
if $AutoIndent
    HE_AutoIndent($QAHKGUI_hEdit,True)

;-- Line numbers bar
if $LineNumbersBar
    HE_LineNumbersBar($QAHKGUI_hEdit,"autosize")

;--------------
;-- Status bar
;--------------
gui Add
   ,StatusBar
   ,Hidden
        || v$QAHKGUI_StatusBar

if $ShowStatusbar
    GUIControl Show,$QAHKGUI_StatusBar

;-- Get statusbar statistics
GUIControlGet $StatusBar,Pos,$QAHKGUI_StatusBar

;-- Programming note: Status bar must be added before the toolbar so
;   that the window can be autosized...    #####  need to finish this thought...

;-----------
;-- Toolbar
;-----------
gosub QAHKGUI_AddToolbar


;-- Collect toolbar height
$ToolbarH:=Toolbar_GetRect($hToolbar,"","h")+2
    ;-- Note: +2 is added because Toolbar_GetRect doesn't account for a 2-pixel
    ;   line top border.
    ;
    ;-- Programming notes: The Toolbar_GetRect is a tiny bit faster than the
    ;   ControlGetPos command.  Also, the values returned differs (for both
    ;   commands), sometimes in unexpected ways, depending on which options are
    ;   used when the toolbar is created.

;-- Toolbar showing?
if $ShowToolbar
    {
    ;-- Move HiEdit control to accommodate the Toolbar
    ControlGetPos X,Y,W,H,,ahk_id %$QAHKGUI_hEdit%
    ControlMove,,,% Y+$ToolbarH,,% H-$ToolbarH,ahk_id %$QAHKGUI_hEdit%
    }
 else
    Control Hide,,,ahk_id %$hToolbar%

;-- Process parameters (if any)
gosub ProcessParameters

;-- Load workspace
gosub LoadWorkspace

;-- Backup workspace
gosub BackupWorkspace

;-- Set focus
ControlFocus,,ahk_id %$QAHKGUI_hEdit%

;---------------------------------------------------------- Not sure of this location
;--- Initialize menu values
gosub QAHKGUI_MenuAction

;[============]
;[  Show it!  ]
;[============]
;-- Set/Restore window position
DetectHiddenWindows On
if $WindowX is Space
    {
    $WindowW:=600
    $WindowH:=400
    $WindowX:=Round($MonitorWorkAreaLeft+(($MonitorWorkAreaWidth-$WindowW)/2))
    $WindowY:=Round($MonitorWorkAreaTop+(($MonitorWorkAreaBottom-$WindowH)/2))
    }

WinMove ahk_id %$QAHKGUI_hWnd%,,%$WindowX%,%$WindowY%,%$WindowW%,%$WindowH%
DetectHiddenWindows Off

;-- Show it
if $Saved_WindowMaximized
    gui Show,Maximize
 else
    gui Show

return



;*********************
;*                   *
;*    Add Toolbar    *
;*     (QAHKGUI)     *
;*                   *
;*********************
QAHKGUI_AddToolbar:

;[=========================]
;[  Render but don't show  ]
;[=========================]
gui Show,% "w" . $MaxGUIW . " h300 AutoSize Hide",%$ScriptName%
    ;-- Programming note: The window must be rendered in order for the Toolbar
    ;   feature to work.  The AutoSize option is necessary to make sure that the
    ;   status bar is taken into consideration.

;[==================]
;[  Create toolbar  ]
;[==================]
$hToolbar:=Toolbar_Add($QAHKGUI_hWnd,"QAHKGUI_OnToolbar","Adjustable Flat List ToolTips Wrapable","")
    ;-- Programming note: The toolbar is created with no image list.  The
    ;   ImageList parameter must be set to blank or the default image list (1L)
    ;   will be created and assigned.

;[=======================]
;[  Create and populate  ]
;[  small and large ILs  ]
;[=======================]
Loop 2
    {
    if A_Index=1
        {
        $TBIconSize:=16
        $TBIconSizeA:="Small"
        }
     else
        {
        $TBIconSize:=24
        $TBIconSizeA:="Large"
        }

    ;[=====================]
    ;[  Create image list  ]
    ;[=====================]
    $hToolbar%$TBIconSizeA%IL:=DllCall("ImageList_Create"
            ,"Int",$TBIconSize  ;-- cx (The width, in pixels, of each image)
            ,"Int",$TBIconSize  ;-- cy (The height, in pixels, of each image)
            ,"UInt",0x21        ;-- flags
            ,"Int",300          ;-- cInitial
            ,"Int",10)          ;-- cGrow

        ;-- Programming note:  AutoHotkey's IL_Create command can be used if
        ;   small (16x16) or medium (32x32) icons are used but does not work for
        ;   toolbar (24x24) icons.

    ;[====================]
    ;[  Attach imagelist  ]
    ;[   to the toolbar   ]
    ;[====================]
    Toolbar_SetImageList($hToolbar,$hToolbar%$TBIconSizeA%IL)
        ;   Programming note:  The toolbar is assigned an empty image list.
        ;   Images are added later but before buttons are added.  Creating a
        ;   toolbar with images already loaded doesn't work if using a mix
        ;   of standard (catalog) icons and "other" icons.

    ;[======================]
    ;[  Add standard icons  ]
    ;[   to the image list  ]
    ;[======================]
    SendMessage TB_LOADIMAGES,IDB_STD_%$TBIconSizeA%_COLOR,HINST_COMMCTRL,,ahk_id %$hToolbar%
        ;-- Standard icons (Catalog 1) - 15 icons
        ;   Icons 1-15

    SendMessage TB_LOADIMAGES,IDB_VIEW_%$TBIconSizeA%_COLOR,HINST_COMMCTRL,,ahk_id %$hToolbar%
        ;-- View icons (Catalog 2) - 12 icons
        ;   Icons 16-27

    SendMessage TB_LOADIMAGES,IDB_HIST_%$TBIconSizeA%_COLOR,HINST_COMMCTRL,,ahk_id %$hToolbar%
        ;-- Windows Explorer travel buttons and favorites (Catalog 3) - 5 icons
        ;   Icons 28-32

    ;-- Programming note:  The standard (catalog) images are added to the IL
    ;   via messages to the toolbar.  It would be nice if the images could be
    ;   added directly to the IL but I haven't figured out a way to do it.

    ;[========================]
    ;[  Selected shell icons  ]
    ;[========================]
    ;-- Icons 33, 34, 35
    $shell32List:="23,24,166"
    Loop Parse,$shell32List,`,
        IL_AddIcon($hToolbar%$TBIconSizeA%IL,"shell32.dll",A_LoopField,$TBIconSize)

    ;[==================]
    ;[  Resource icons  ]
    ;[==================]
    ;-- Icons 36 thru 69
    Loop 34
        IL_AddIcon($hToolbar%$TBIconSizeA%IL,$LibDir . "\QuickAHK.dll",A_Index,$TBIconSize)
    }

;[=========================]
;[  Build toolbar buttons  ]
;[=========================]
if $ToolbarButtons is Space
    $ToolbarButtons=
       (ltrim
        New,7
        Copy From...,8
        Save,9
        Create Restore Point,42
        -
        Print,15
        -
        Revert,59
        Restore,58
        -
        Find,33,,Dropdown
        -
        PasteC,56
        -
        Undo,4
        Redo,5
        -
        Run,61,,Dropdown
        Stop,67
        -
        Options,35
        Help,34

        *New,7,,Dropdown
        *Prepend New,57
        *Save,9,,Dropdown
        *Save To,65
        *Page Setup,55
        *Print,15,,Dropdown
        *Find,33
        *Find,13,,Dropdown
        *Find,13
        *Find Next,48
        *Find Previous,49
        *Replace,14
        *Go To...,50
        *Cut,1
        *Copy,2
        *Paste,3
        *Clear,6
        *Block Comment,38
        *Block Uncomment,39
        *Uppercase,69
        *Lowercase,53
        *Capitalize,40
        *Toggle Case,68
        *Increase Font Size,51
        *Decrease Font Size,43
        *Default Font Size,44
        *Run,61
        *Run Selected,60
        *Explore Run Workspace,46
        *Clear Run Workspace,41
        *Always On Top,37
        *External Editor,47
        *Toggle Line Numbers Bar,52
        *Toggle Menu Bar,54
        *Toggle Toolbar Icon Size,16
        *Toggle Status Bar,66
        *Toggle RunDebug,62
        *Toggle RunPrompt,63
        *Toggle RunWait,64
        *Help,34,,Dropdown
        *About,36
        *Exit,45
       )

;   Programming notes
;   -----------------
;   The button labels have a direct relationship to routine names in this
;   script.  Do not change the value of the labels without changing the
;   associated routine names.
;
;   Buttons that may look to be duplicates are either buttons with different
;   icons and/or buttons with/without a dropdown.  These additional buttons give
;   the user a few options that are different than the standard buttons.

;[=========================]
;[  Change button padding  ]
;[=========================]
;-- Collect initial cxPad and cyPad values (padding inside the toolbar buttons)
VarSetCapacity(TBMETRICS_Structure,32,0)
NumPut(32,TBMETRICS_Structure,0,"UInt")                 ;-- cbSize
NumPut(TBMF_PAD,TBMETRICS_Structure,4,"Int")            ;-- dwMask
SendMessage TB_GETMETRICS,0,&TBMETRICS_Structure,,ahk_id %$hToolbar%

cxPad :=NumGet(TBMETRICS_Structure,8,"Int")
cyPad :=NumGet(TBMETRICS_Structure,12,"Int")
    ;-- Programming note: The cxPad and cYPad values collected here are reused
    ;   if/when the toolbar is changed.

;-- Any active dropdown buttons?
Loop Parse,$ToolbarButtons,`n
    {
    if SubStr(A_LoopField,1,1)="-"  ;-- Spacer
        Continue

    if SubStr(A_LoopField,1,1)="*"  ;-- Inactive button
        Continue

    ;-- Active dropdown button?
    if A_LoopField contains DropDown
        {
        ;-- Set cyPad (height of the padding inside the toolbar buttons) to 0
        VarSetCapacity(TBMETRICS_Structure,32,0)
        NumPut(32,TBMETRICS_Structure,0,"UInt")                 ;-- cbSize
        NumPut(TBMF_PAD,TBMETRICS_Structure,4,"Int")            ;-- dwMask
        NumPut(cxPad,TBMETRICS_Structure,8,"Int")               ;-- cxPad
        NumPut(0,TBMETRICS_Structure,12,"Int")                  ;-- cyPad
        SendMessage TB_SETMETRICS,0,&TBMETRICS_Structure,,ahk_id %$hToolbar%
            ;-- Programming note:  This step recovers ~6 of the 8 pixels of
            ;   height that is added to all buttons when at least one button
            ;   with dropdown style is shown on the toolbar.  Without this step,
            ;   the buttons look too tall.  I'm still looking for a better way
            ;   to recover this extra space but this works OK for now.
            ;

        Break  ;-- We're done here
        }
    }

;[======================]
;[  Assign appropriate  ]
;[   IL to the toolbar  ]
;[======================]
Toolbar_SetImageList($hToolbar,$hToolbar%$ToolbarIconSize%IL)

;[==================]
;[  Add buttons to  ]
;[    the toolbar   ]
;[==================]
Toolbar_SetButtonWidth($hToolbar,40)
    ;-- This option only works if the "List" style is not used

Toolbar_Insert($hToolbar,$ToolbarButtons)

;-- Find IDs for buttons that will accessed in other routines
$Toolbar_AOTButtonID       :=0
$Toolbar_RunButtonList     :=""  ;-- List of "Run" and "Run Selected" buttons
$Toolbar_RunPromptButtonID :=0
$Toolbar_RunDebugButtonID  :=0
$Toolbar_RunWaitButtonID   :=0
Loop 2
    {
    if A_Index=1
        {
        $Index=1
        $Increment=1
        $MaxIndex:=Toolbar_Count($hToolbar,"c")  ;-- Current icons only
        }
     else
        {
        $Index=-1
        $Increment=-1
        $MaxIndex:=Toolbar_Count($hToolbar,"a")  ;-- Available icons only
        }

    While (Abs($Index)<=$MaxIndex)
        {
        ;-- Aways On Top
        if InStr(Toolbar_GetButton($hToolbar,$Index,"C"),"Always On Top")
            $Toolbar_AOTButtonID:="." . Toolbar_GetButton($hToolbar,$Index,"ID")

        ;-- "Run" or "Run Selected" buttons
        $Pos:=InStr(Toolbar_GetButton($hToolbar,$Index,"C") . A_Space,"Run ")
        if $Pos in 1,2
            if not $Toolbar_RunButtonList
                $Toolbar_RunButtonList:="." . Toolbar_GetButton($hToolbar,$Index,"ID")
             else
                $Toolbar_RunButtonList:=$Toolbar_RunButtonList
                    . ",."
                    . Toolbar_GetButton($hToolbar,$Index,"ID")

        ;-- Run Prompt
        if InStr(Toolbar_GetButton($hToolbar,$Index,"C"),"RunPrompt")
            $Toolbar_RunPromptButtonID:="." . Toolbar_GetButton($hToolbar,$Index,"ID")

        ;-- Run Debug
        if InStr(Toolbar_GetButton($hToolbar,$Index,"C"),"RunDebug")
            $Toolbar_RunDebugButtonID:="." . Toolbar_GetButton($hToolbar,$Index,"ID")

        ;-- "RunWait"
        if InStr(Toolbar_GetButton($hToolbar,$Index,"C"),"RunWait")
            $Toolbar_RunWaitButtonID:="." . Toolbar_GetButton($hToolbar,$Index,"ID")

        ;-- Bump index
        $Index:=$Index+$Increment
        }
    }

;-- Set initial button state
gosub QAHKGUI_SetToolbarButtonState
return


;***************************
;*                         *
;*    Set toolbar state    *
;*        (QAHKGUI)        *
;*                         *
;***************************
QAHKGUI_SetToolbarButtonState:
SetTimer %A_ThisLabel%,Off

;-- Always On Top
if $Toolbar_AOTButtonID
    if $AlwaysOnTop
        Toolbar_SetButton($hToolbar,$Toolbar_AOTButtonID,"Checked")
     else
        Toolbar_SetButton($hToolbar,$Toolbar_AOTButtonID,"-Checked")

;-- Run and Run Selected
if $Toolbar_RunButtonList
    if $Running
        Loop Parse,$Toolbar_RunButtonList,`,
            Toolbar_SetButton($hToolbar,A_LoopField,"Disabled")
     else
        Loop Parse,$Toolbar_RunButtonList,`,
            Toolbar_SetButton($hToolbar,A_LoopField,"-Disabled")

;-- RunPrompt
if $Toolbar_RunPromptButtonID
    if $RunPrompt
        Toolbar_SetButton($hToolbar,$Toolbar_RunPromptButtonID,"Checked")
     else
        Toolbar_SetButton($hToolbar,$Toolbar_RunPromptButtonID,"-Checked")

;-- RunDebug
if $Toolbar_RunDebugButtonID
    if $RunDebug
        Toolbar_SetButton($hToolbar,$Toolbar_RunDebugButtonID,"Checked")
     else
        Toolbar_SetButton($hToolbar,$Toolbar_RunDebugButtonID,"-Checked")

;-- RunWait
if $Toolbar_RunWaitButtonID
    if $RunWait
        Toolbar_SetButton($hToolbar,$Toolbar_RunWaitButtonID,"Checked")
     else
        Toolbar_SetButton($hToolbar,$Toolbar_RunWaitButtonID,"-Checked")

return
    ;-- Programming note: This routine is called once on startup and again
    ;   if/when the toolbar buttons change.



;------------------------------------------------------------ Temporary location
;-- Some code for this function extracted from the MI_ExtractIcon
;   function. Author: Lexikos
ExtractIcon(p_lpszFile,p_nIconIndex,p_cxIcon,p_cyIcon=0)
    {
    ;-- Static variables
    Static SM_CXSMICON

    ;-- Initialize
    if not SM_CXSMICON
        SysGet SM_CXSMICON,49

    ;-- Parameters
    if p_cyIcon=0
        p_cyIcon:=p_cxIcon

    ;-- If possible, use PrivateExtractIcons (only available for W2K+)
    if A_OSVersion not in WIN_95,WIN_98,WIN_ME,WIN_NT4
        {
        l_Return:=DllCall("PrivateExtractIcons"
            ,"Str",p_lpszFile           ;-- lpszFile
            ,"Int",p_nIconIndex-1       ;-- nIconIndex
            ,"Int",p_cxIcon             ;-- cxIcon
            ,"Int",p_cyIcon             ;-- cyIcon
            ,"UInt*",l_hIcon            ;-- *phicon
            ,"UInt*",0                  ;-- *piconid
            ,"UInt",1                   ;-- nIcons
            ,"UInt",0                   ;-- flags
            ,"Int")                     ;-- Return type

        if (l_Return=-1) or ErrorLevel
            {
            outputdebug,
               (ltrim join
                Function: %A_ThisFunc%: PrivateExtractIcons DllCall
                failure.  Return=%l_Return%,  ErrorLevel=%ErrorLevel%
               )

            Return 0
            }

        ;-- Return *icon
        Return l_hIcon
        }

    ;---------------------------
    ;-- Begin code for older OS
    ;---------------------------
    ;-- Extract icons
    l_Return:=DllCall("shell32.dll\ExtractIconExA"
        ,"Str",p_lpszFile               ;-- lpszFile
        ,"Int",p_nIconIndex-1           ;-- nIconIndex
        ,"UInt*",l_hIconLarge           ;-- *phiconLarge
        ,"UInt*",l_hIconSmall           ;-- *phiconSmall
        ,"UInt",1)                      ;-- nIcons (Number of icons to extract)

    ;-- Anything found?
    if not l_Return
        Return 0

    ;-- Decide which icon to use.  Destroy the other.
    if (p_cxIcon<=SM_CXSMICON)
        {
        l_hIcon:=l_hIconSmall
        DllCall("DeStroyIcon","UInt",l_hIconLarge)
        }
    else
        {
        l_hIcon:=l_hIconLarge
        DllCall("DeStroyIcon","UInt",l_hIconSmall)
        }

    ;-- Convert icon to the desired size
    if l_hIcon and p_cxIcon
        l_hIcon:=DllCall("CopyImage"
            ,"UInt",l_hIcon             ;-- hImage
            ,"UInt",0x1                 ;-- uType (0x1=IMAGE_ICON)
            ,"Int",p_cxIcon             ;-- cxDesired
            ,"Int",p_cyIcon             ;-- cyDesired
            ,"UInt",0x4|0x8)            ;-- fuFlags
                ;-- 0x4=LR_COPYDELETEORG - Delete original after copy.
                ;-- 0x8=LR_COPYRETURNORG - Returns original if size matches the
                ;   requested size.

    ;-- Return to sender
    Return l_hIcon ? l_hIcon:0
    }

IL_AddIcon(p_hIL,p_lpszFile,p_nIconIndex,p_cxIcon,p_cyIcon=0)
    {
    ;-- Initialize
    if p_cyIcon=0
        p_cyIcon:=p_cxIcon

    ;-- Extract icon
    l_hIcon:=ExtractIcon(p_lpszFile,p_nIconIndex,p_cxIcon,p_cyIcon=0)

    ;-- Icon not found?
    if not l_hIcon
        Return False

    ;-- Add icon to the IL
    DllCall("ImageList_ReplaceIcon"
        ,"UInt",p_hIL                   ;-- himl
        ,"Int",-1                       ;-- i (if -1, image appended to the end)
        ,"UInt",l_hIcon)                ;-- hicon

    ;-- Destroy icon
    DllCall("DeStroyIcon","UInt",l_hIcon)

    ;-- Return icon # added to the image list
    Return DllCall("ImageList_GetImageCount","UInt",p_hIL)
    }
;-------------------------------------------------------- End Temporary location


;*******************
;*                 *
;*      Resize     *
;*    (QAHKGUI)    *
;*                 *
;*******************
QAHKGUI_Size:

;-- Bounce?
if not $Resize
    return

;-- Minimize?
$WindowMinimized:=False
if A_EventInfo=1
    {
    $WindowMinimized:=True
    return  ;-- Nothing else to do here
    }

;-- Maximize?
$WindowMaximized:=False
if A_EventInfo=2
    {
    $WindowMaximized:=True
    Sleep 75  ;-- Give the window a chance to render
    }

;-- Move it!
ControlMove,,,,%A_GuiWidth%,% A_GuiHeight-(($ShowToolbar) ? $ToolBarH:0)-(($ShowStatusbar) ? $StatusBarH:0),ahk_id %$QAHKGUI_hEdit%
return


;*********************
;*                   *
;*    Drag & Drop    *
;*     (QAHKGUI)     *
;*                   *
;*********************
QAHKGUI_DropFiles:

;-- Create resore point?
if $CreateRPOnCopyfromDrop
    RPCreate()

;-- Get the first file
Loop Parse,A_GuiControlEvent,`n,`r
    {
	$DropFile=%A_LoopField%  ;-- Assign and AutoTrim
	Break
    }

;-- Copy dropped file over workspace file
FileCopy %$DropFile%,%$EditFile%,1  ;-- 1=overwrite
If ErrorLevel
    {
    ;-- Notify the user
    gui +OwnDialogs
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Drop File Error
        ,Unable to copy the dropped file to the workspace.  %A_Space%

    return
    }

;-- Reset file attributes
FileSetAttrib -RSH,%$EditFile%

;-- Reload workspace
gosub LoadWorkspace

;-- Push to $RecentFiles and reload menu
MRUManager($RecentFiles,"Push",$DropFile,"|",9)
gosub QAHKGUI_ReloadRecentFilesMenu

;-- Update status bar
SB_SetText("Contents of " . CompressFileName($DropFile,65) . " copied to the workspace.")
SetTimer QAHKGUI_ClearStatusBar,25000
return


;;;;;QAHKGUI_ContextMenu:
    ;-- This label is not used because it only fires when the mouse is not over
    ;   the HiEdit control (Ex: toolbar)

QAHKGUI_ContextMenu2:                     ;---------- Better name than ...Menu2?
SetTimer %A_ThisLabel%,Off

;-- Mouse over the HiEdit control?
MouseGetPos,,,,$MousePos_ControlhWnd,2
if ($MousePos_ControlhWnd=$QAHKGUI_hEdit)
    {
    ;-- Update and show menu
    gosub QAHKGUI_UpdateContextMenu
    Menu QAHKGUI_ContextMenu,Show,%A_GuiX%,%A_GuiY%
    }


return


;*****************************
;*                           *
;*    Update Context Menu    *
;*         (QAHKGUI)         *
;*                           *
;*****************************
QAHKGUI_UpdateContextMenu:

;-- Undo
if HE_CanUndo($QAHKGUI_hEdit)
    Menu QAHKGUI_ContextMenu,Enable,%s_Undo_MI%
 else
    Menu QAHKGUI_ContextMenu,Disable,%s_Undo_MI%

;-- Redo
if HE_CanRedo($QAHKGUI_hEdit)
    Menu QAHKGUI_ContextMenu,Enable,%s_Redo_MI%
 else
    Menu QAHKGUI_ContextMenu,Disable,%s_Redo_MI%

;-- Get select positions
HE_GetSel($QAHKGUI_hEdit,$StartSelPos,$EndSelPos)

;-- Cut, Copy, Delete, Convert Case, and Run Selected
if ($StartSelPos<>$EndSelPos)
    {
    Menu QAHKGUI_ContextMenu,Enable,%s_Cut_MI%
    Menu QAHKGUI_ContextMenu,Enable,%s_Copy_MI%
    Menu QAHKGUI_ContextMenu,Enable,%s_Delete_MI%
    Menu QAHKGUI_ContextMenu,Enable,%s_ConvertCase_MI%
    Menu QAHKGUI_ContextMenu,Enable,%s_RunSelected_MI%
    }
 else
    {
    Menu QAHKGUI_ContextMenu,Disable,%s_Cut_MI%
    Menu QAHKGUI_ContextMenu,Disable,%s_Copy_MI%
    Menu QAHKGUI_ContextMenu,Disable,%s_Delete_MI%
    Menu QAHKGUI_ContextMenu,Disable,%s_ConvertCase_MI%
    Menu QAHKGUI_ContextMenu,Disable,%s_RunSelected_MI%
    }

;-- Paste
if HE_CanPaste($QAHKGUI_hEdit)
    {
    Menu QAHKGUI_ContextMenu,Enable,%s_Paste_MI%
    Menu QAHKGUI_ContextMenu,Enable,%s_PasteC_MI%
    }
 else
    {
    Menu QAHKGUI_ContextMenu,Disable,%s_Paste_MI%
    Menu QAHKGUI_ContextMenu,Disable,%s_PasteC_MI%
    }

return


;*********************
;*                   *
;*    Menu Action    *
;*     (QAHKGUI)     *
;*                   *
;*********************
QAHKGUI_MenuAction:

if A_ThisMenu is Space
    {
    ;-- Initial View menu values
    if $AlwaysOnTop
        Menu QAHKGUI_ViewMenu,Check,%s_AlwaysOnTop_MI%

    if $ShowMenuBar
        Menu QAHKGUI_ViewMenu,Check,%s_MenuBar_MI%

    if $ShowToolBar
        Menu QAHKGUI_ViewMenu,Check,%s_ToolBar_MI%

    if $LineNumbersBar
        Menu QAHKGUI_ViewMenu,Check,%s_LineNumbersBar_MI%

    if $ShowStatusBar
        Menu QAHKGUI_ViewMenu,Check,%s_StatusBar_MI%


    ;-- Initial Run menu values
    if $RunPrompt
        Menu QAHKGUI_RunMenu,Check,%s_RunPrompt_MI%

    if $RunDebug
        Menu QAHKGUI_RunMenu,Check,%s_RunDebug_MI%

    if $RunWait
        Menu QAHKGUI_RunMenu,Check,%s_RunWait_MI%

    if $ClearRunWorkspaceOnRun
        Menu QAHKGUI_RunMenu,Check,%s_ClearRunWorkspaceOnRun_MI%

    if $ClearRunWorkspaceOnExit
        Menu QAHKGUI_RunMenu,Check,%s_ClearRunWorkspaceOnExit_MI%
    }
 else
    {
    ;-- Toggle
    if A_ThisMenu=QAHKGUI_ViewMenu
        {
        if (A_ThisMenuItem=s_AlwaysOnTop_MI)
            gosub QAHKGUI_ToggleAlwaysOnTop

        if (A_ThisMenuItem=s_MenuBar_MI)
            gosub QAHKGUI_ToggleMenuBar

        if (A_ThisMenuItem=s_ToolBar_MI)
            gosub QAHKGUI_ToggleToolbar

        if (A_ThisMenuItem=s_LineNumbersBar_MI)
            gosub QAHKGUI_ToggleLineNumbersBar

        if (A_ThisMenuItem=s_StatusBar_MI)
            gosub QAHKGUI_ToggleStatusBar
        }
     else
        {
        if (A_ThisMenuItem=s_RunPrompt_MI)
            gosub QAHKGUI_ToggleRunPrompt

        if (A_ThisMenuItem=s_RunDebug_MI)
            gosub QAHKGUI_ToggleRunDebug

        if (A_ThisMenuItem=s_RunWait_MI)
            gosub QAHKGUI_ToggleRunWait

        if (A_ThisMenuItem=s_ClearRunWorkspaceOnRun_MI)
            {
            $ClearRunWorkspaceOnRun:=$ClearRunWorkspaceOnRun ? False:True
            Menu QAHKGUI_RunMenu,ToggleCheck,%A_ThisMenuItem%
            }

        if (A_ThisMenuItem=s_ClearRunWorkspaceOnExit_MI)
            {
            $ClearRunWorkspaceOnExit:=$ClearRunWorkspaceOnExit ? False:True
            Menu QAHKGUI_RunMenu,ToggleCheck,%A_ThisMenuItem%
            }
        }
    }

return


;***************************
;*                         *
;*    Default font size    *
;*        (QAHKGUI)        *
;*                         *
;***************************
QAHKGUI_DefaultFontSize:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- Default font size
$FontSize:=$DefaultFontSize
HE_SetFont($QAHKGUI_hEdit,"s" . $FontSize . A_Space . $FontStyle . "," . $Font)

;-- Update status bar
SB_SetText("Default font size set.  Font=" . $Font . "   Size=" . $FontSize)
SetTimer QAHKGUI_ClearStatusBar,15000
return


;****************************
;*                          *
;*    Decrease font size    *
;*         (QAHKGUI)        *
;*                          *
;****************************
QAHKGUI_DecreaseFontSize:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- Decrease font szie
if ($FontSize>$MinimumFontSize)
    {
    $FontSize--
    HE_SetFont($QAHKGUI_hEdit,"s" . $FontSize . A_Space . $FontStyle . "," . $Font)

    ;-- Update status bar
    SB_SetText("Font size changed.  Font=" . $Font . "   Size=" . $FontSize)
    SetTimer QAHKGUI_ClearStatusBar,15000
    }
 else
    SoundPlay *-1  ;-- System default sound

return


;****************************
;*                          *
;*    Increase font size    *
;*         (QAHKGUI)        *
;*                          *
;****************************
QAHKGUI_IncreaseFontSize:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- Increase font size
if ($FontSize<$MaximumFontSize)
    {
    $FontSize++
    HE_SetFont($QAHKGUI_hEdit,"s" . $FontSize . A_Space . $FontStyle . "," . $Font)

    ;-- Update status bar
    SB_SetText("Font size changed.  Font=" . $Font . "   Size=" . $FontSize)
    SetTimer QAHKGUI_ClearStatusBar,15000
    }
 else
    SoundPlay *-1  ;-- System default sound

return


;******************************
;*                            *
;*    Toggle Always On Top    *
;*          (QAHKGUI)         *
;*                            *
;******************************
QAHKGUI_AlwaysOnTop:
QAHKGUI_ToggleAlwaysOnTop:
SetTimer %A_ThisLabel%,Off

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- Toggle
if $AlwaysOnTop
    {
    gui -AlwaysOnTop
    $AlwaysOnTop:=False
    if $Toolbar_AOTButtonID
        Toolbar_SetButton($hToolbar,$Toolbar_AOTButtonID,"-Checked")
    }
 else
    {
    gui +AlwaysOnTop
    $AlwaysOnTop:=True
    if $Toolbar_AOTButtonID
        Toolbar_SetButton($hToolbar,$Toolbar_AOTButtonID,"Checked")
    }

;-- Update menu
Menu QAHKGUI_ViewMenu
    ,ToggleCheck
    ,%s_AlwaysOnTop_MI%

;-- Update status bar
if not $Running
    {
    SB_SetText("Always On Top " . ($AlwaysOnTop ? "enabled.":"disabled."))
    SetTimer QAHKGUI_ClearStatusBar,8000
    }

return


;*********************************
;*                               *
;*    Toggle line numbers bar    *
;*           (QAHKGUI)           *
;*                               *
;*********************************
QAHKGUI_ToggleLineNumbersBar:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Toggle
if $LineNumbersBar
    {
    HE_LineNumbersBar($QAHKGUI_hEdit,"hide",0,0)
    $LineNumbersBar:=False
    }
 else
    {
    HE_LineNumbersBar($QAHKGUI_hEdit,"autosize")
    $LineNumbersBar:=True
    }

;-- Update menu
Menu QAHKGUI_ViewMenu
    ,ToggleCheck
    ,%s_LineNumbersBar_MI%

return


;************************
;*                      *
;*    Toggle Menubar    *
;*       (QAHKGUI)      *
;*                      *
;************************
QAHKGUI_ToggleMenubar:
SetTimer %A_ThisLabel%,Off

;-- Toggle
if $ShowMenubar
    {
    gui %$QAHKGUI%:Menu
    $ShowMenubar:=False
    }
 else
    {
    if $Running
        gui %$QAHKGUI%:Menu,QAHKGUI_MenubarRunWait
     else
        gui %$QAHKGUI%:Menu,QAHKGUI_Menubar

    $ShowMenubar:=True
    }

;-- Update menu
Menu QAHKGUI_ViewMenu
    ,ToggleCheck
    ,%s_MenuBar_MI%

return


;************************
;*                      *
;*    Toggle Toolbar    *
;*       (QAHKGUI)      *
;*                      *
;************************
QAHKGUI_ToggleToolbar:
SetTimer %A_ThisLabel%,Off

;-- Toggle
if $ShowToolbar
    {
    ;-- Hide it
    Control Hide,,,ahk_id %$hToolbar%
    $ShowToolbar:=False

    ;-- Toolbar gone.  Move HiEdit control to compensate.
    ControlGetPos X,Y,W,H,,ahk_id %$QAHKGUI_hEdit%
    ControlMove,,,% Y-$ToolbarH,,% H+$ToolbarH,ahk_id %$QAHKGUI_hEdit%
    }
 else
    {
    ;-- Show it
    Control Show,,,ahk_id %$hToolbar%
    $ShowToolbar:=True

    ;-- Toolbar is back!  Move HiEdit control to compensate.
    ControlGetPos X,Y,W,H,,ahk_id %$QAHKGUI_hEdit%
    ControlMove,,,% Y+$ToolbarH,,% H-$ToolbarH,ahk_id %$QAHKGUI_hEdit%
    WinSet Redraw,,ahk_id %$QAHKGUI_hEdit%
    }

;-- Update menu
Menu QAHKGUI_ViewMenu
    ,ToggleCheck
    ,%s_ToolBar_MI%

return


;**********************************
;*                                *
;*    Toggle Toolbar Icon Size    *
;*            (QAHKGUI)           *
;*                                *
;**********************************
QAHKGUI_ToggleToolbarIconSize:
SetTimer %A_ThisLabel%,Off

;-- Turn off sizing during this exercise
$Resize:=False

;-- If toolbar is showing, move HiEdit control
if $ShowToolBar
    {
    ;-- Move HiEdit control to assume there is no toolbar
    ControlGetPos X,Y,W,H,,ahk_id %$QAHKGUI_hEdit%
    ControlMove,,,% Y-$ToolbarH,,% H+$ToolbarH,ahk_id %$QAHKGUI_hEdit%
        ;-- Programming note:  It's easier to that assume that the current toolbar
        ;   doesn't exist ##### need to finish my thought here.
    }

;-- Get Current window statistics
WinGetPos,$WindowX,$WindowY,$WindowW,$WindowH,ahk_id %$QAHKGUI_hWnd%

;-- Set to window to max width
WinMove ahk_id %$QAHKGUI_hWnd%,,%$MonitorWorkAreaLeft%,,% $MaxGUIW+12
    ;-- Haven't figured out why the window can be 12 pixels bigger that the
    ;   $MonitorWorkAreaWidth but there you go...

;-- Toggle icon size
if $ToolbarIconSize=Large
    $ToolbarIconSize=Small
 else
    $ToolbarIconSize=Large

;-- Set cyPad & cyPad (padding inside the toolbar buttons) to initial values
VarSetCapacity(TBMETRICS_Structure,32,0)
NumPut(32,TBMETRICS_Structure,0,"UInt")                 ;-- cbSize
NumPut(TBMF_PAD,TBMETRICS_Structure,4,"Int")            ;-- dwMask
NumPut(cxPad,TBMETRICS_Structure,8,"Int")               ;-- cxPad
NumPut(cyPad,TBMETRICS_Structure,12,"Int")              ;-- cyPad
SendMessage TB_SETMETRICS,0,&TBMETRICS_Structure,,ahk_id %$hToolbar%

;-- Any active dropdown buttons?
Loop Parse,$ToolbarButtons,`n
    {
    if SubStr(A_LoopField,1,1)="-"  ;-- Spacer
    or SubStr(A_LoopField,1,1)="*"  ;-- Inactive button
        Continue

    ;-- Active dropdown button?
    if A_LoopField contains DropDown
        {
        ;-- Set cyPad (height of the padding inside the toolbar buttons) to 0
        VarSetCapacity(TBMETRICS_Structure,32,0)
        NumPut(32,TBMETRICS_Structure,0,"UInt")                 ;-- cbSize
        NumPut(TBMF_PAD,TBMETRICS_Structure,4,"Int")            ;-- dwMask
        NumPut(cxPad,TBMETRICS_Structure,8,"Int")               ;-- cxPad
        NumPut(0,TBMETRICS_Structure,12,"Int")                  ;-- cyPad
        SendMessage TB_SETMETRICS,0,&TBMETRICS_Structure,,ahk_id %$hToolbar%
            ;-- Programming note:  This step recovers ~6 of the 8 pixels of
            ;   height that is added to all buttons when at least 1 button with
            ;   dropdown style is shown on the toolbar.  Without this step, the
            ;   buttons look too tall.  I'm still looking for a better way to
            ;   recover this extra space but this works OK for now.
            ;

        Break  ;-- We're done here
        }
    }

;-- Set to new icon list
Toolbar_SetImageList($hToolbar,$hToolbar%$ToolbarIconSize%IL)

;-- Set button size to smallest possible size.  Let AutoSize figure it out.
Toolbar_SetButtonSize($hToolbar,1,1)

;-- Reset window to original width
WinMove ahk_id %$QAHKGUI_hWnd%,,%$WindowX%,,%$WindowW%

;-- Collect new toolbar statistics
$ToolbarH:=Toolbar_GetRect($hToolbar,"","h")+2
    ;-- Note: +2 is needed because Toolbar_GetRect doesn't account for a 2-pixel
    ;   line top border

;-- If toolbar is showing, move HiEdit control
if $ShowToolBar
    {
    ;-- Move HiEdit control to accommodate the new toolbar size
    ControlGetPos X,Y,W,H,,ahk_id %$QAHKGUI_hEdit%
    ControlMove,,,% Y+$ToolbarH,,% H-$ToolbarH,ahk_id %$QAHKGUI_hEdit%
    WinSet Redraw,,ahk_id %$QAHKGUI_hEdit%
    }

;-- Restore sizing
$Resize:=True
return


;**************************
;*                        *
;*    Toggle Statusbar    *
;*        (QAHKGUI)       *
;*                        *
;**************************
QAHKGUI_ToggleStatusbar:
SetTimer %A_ThisLabel%,Off

;-- Toggle
if $ShowStatusbar
    {
    GUIControl %$QAHKGUI%:Hide,$QAHKGUI_StatusBar
    $ShowStatusbar:=False

    ;-- Move HiEdit control to accommodate the Statusbar
    ControlGetPos X,Y,W,H,,ahk_id %$QAHKGUI_hEdit%
    ControlMove,,,,,% H+$StatusBarH,ahk_id %$QAHKGUI_hEdit%
    }
 else
    {
    GUIControl %$QAHKGUI%:Show,$QAHKGUI_StatusBar
    $ShowStatusbar:=True

    ;-- Move HiEdit control to accommodate the Statusbar
    ControlGetPos X,Y,W,H,,ahk_id %$QAHKGUI_hEdit%
    ControlMove,,,,,% H-$StatusBarH,ahk_id %$QAHKGUI_hEdit%
    }

;-- Update menu
Menu QAHKGUI_ViewMenu
    ,ToggleCheck
    ,%s_StatusBar_MI%

return


;**************************
;*                        *
;*    Toggle RunPrompt    *
;*        (QAHKGUI)       *
;*                        *
;**************************
QAHKGUI_ToggleRunPrompt:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Toggle
if $RunPrompt
    {
    $RunPrompt:=False
    if $Toolbar_RunPromptButtonID
        Toolbar_SetButton($hToolbar,$Toolbar_RunPromptButtonID,"-Checked")
    }
 else
    {
    $RunPrompt:=True
    if $Toolbar_RunPromptButtonID
        Toolbar_SetButton($hToolbar,$Toolbar_RunPromptButtonID,"Checked")
    }

;-- Update menu
Menu QAHKGUI_RunMenu
    ,ToggleCheck
    ,%s_RunPrompt_MI%

return


;*************************
;*                       *
;*    Toggle RunDebug    *
;*       (QAHKGUI)       *
;*                       *
;*************************
QAHKGUI_ToggleRunDebug:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Toggle
if $RunDebug
    {
    $RunDebug:=False
    if $Toolbar_RunDebugButtonID
        Toolbar_SetButton($hToolbar,$Toolbar_RunDebugButtonID,"-Checked")
    }
 else
    {
    $RunDebug:=True
    if $Toolbar_RunDebugButtonID
        Toolbar_SetButton($hToolbar,$Toolbar_RunDebugButtonID,"Checked")
    }

;-- Update menu
Menu QAHKGUI_RunMenu
    ,ToggleCheck
    ,%s_RunDebug_MI%

return


;************************
;*                      *
;*    Toggle RunWait    *
;*       (QAHKGUI)      *
;*                      *
;************************
QAHKGUI_ToggleRunWait:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Toggle
if $RunWait
    {
    $RunWait:=False
    if $Toolbar_RunWaitButtonID
        Toolbar_SetButton($hToolbar,$Toolbar_RunWaitButtonID,"-Checked")
    }
 else
    {
    $RunWait:=True
    if $Toolbar_RunWaitButtonID
        Toolbar_SetButton($hToolbar,$Toolbar_RunWaitButtonID,"Checked")
    }

;-- Update menu
Menu QAHKGUI_RunMenu
    ,ToggleCheck
    ,%s_RunWait_MI%

return


;*******************
;*                 *
;*       Find      *
;*    (QAHKGUI)    *
;*                 *
;*******************
QAHKGUI_Find:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Bounce if Find or Replace dialog is already showing
IfWinExist ahk_id %Dlg_hWnd%
    return

;-- Where are we starting from?
HE_GetSel($QAHKGUI_hEdit,Dummy,$EndSelectPos)
if $EndSelectPos=0
    Dlg_FindFromTheTop:=True
 else
    Dlg_FindFromTheTop:=False

;-- Anything selected?
$Selected:=HE_GetSelText($QAHKGUI_hEdit)
if StrLen($Selected)
    {
    ;-- Ignore if multiple lines are selected
    if InStr($Selected,"`n")=0
        Dlg_FindWhat:=$Selected
    }

;-- Show the Find dialog
Dlg_hWnd :=Dlg_Find($QAHKGUI_hWnd,"QAHKGUI_OnFind",Dlg_Flags,Dlg_FindWhat)
return



;*******************
;*                 *
;*    Find Next    *
;*    (QAHKGUI)    *
;*                 *
;*******************
QAHKGUI_FindNext:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Bounce if Find was never called
if StrLen(Dlg_FindWhat)=0
	return

;-- Save Dlg_Flags
$Saved_Dlg_Flags:=Dlg_Flags

;-- If necessary, update Dlg_Flags
if Dlg_Flags not contains d
    Dlg_Flags:="d" . Dlg_Flags

;-- Find next
QAHKGUI_OnFind("F",Dlg_Flags,Dlg_FindWhat)

;-- Restore Dlg_Flags
Dlg_Flags :=$Saved_Dlg_Flags
return


;***********************
;*                     *
;*    Find Previous    *
;*      (QAHKGUI)      *
;*                     *
;***********************
QAHKGUI_FindPrevious:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Bounce if Find was never called
if StrLen(Dlg_FindWhat)=0
	return

;-- Save Dlg_Flags
$Saved_Dlg_Flags:=Dlg_Flags

;-- If necessary, update Dlg_Flags
if Dlg_Flags contains d
    StringReplace Dlg_Flags,Dlg_Flags,d

;-- Find previous
QAHKGUI_OnFind("F",Dlg_Flags,Dlg_FindWhat)

;-- Restore Dlg_Flags
Dlg_Flags :=$Saved_Dlg_Flags
return


;*******************
;*                 *
;*       Goto      *
;*    (QAHKGUI)    *
;*                 *
;*******************
QAHKGUI_Toolbar_Goto:
SetTimer %A_ThisLabel%,Off
SetTimer QAHKGUI_GoTo,0
return



QAHKGUI_GoTo:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;[===================]
;[  Prompt the user  ]
;[===================]
gui %$QAHKGUI%:+OwnDialogs
InputBox $GoToLine,Go To,Line Number:, ,130,130
if ErrorLevel
	return

;-- Adjust GoTo line for zero-based index
$MaxLineNumber:=HE_GetLineCount($QAHKGUI_hEdit)
if ($GoToLine>$MaxLineNumber)
	$GoToLine:=$MaxLineNumber-1
 else
    $GotoLine--


;[========]
;[  GoTo  ]
;[========]
;-- Collect first visible line
$FirstVisibleLine:=HE_GetFirstVisibleLine($QAHKGUI_hEdit)

;-- Collect the line index for the requested line and select it
$LineIndex:=HE_LineIndex($QAHKGUI_hEdit,$GoToLine)
HE_SetSel($QAHKGUI_hEdit,$LineIndex,$LineIndex)

;-- Scroll to make the caret visible
HE_ScrollCaret($QAHKGUI_hEdit)

;[====================]
;[  Scroll to center  ]
;[====================]
$FirstVisibleLine2:=HE_GetFirstVisibleLine($QAHKGUI_hEdit)

;-- If no movement, bounce because the requested line is already visible
if ($FirstVisibleLine=$FirstVisibleLine2)
    return

;-- Reset 1st visible line, collect last visible line
$FirstVisibleLine:=$FirstVisibleLine2
$LastVisibleLine :=HE_GetLastVisibleLine($QAHKGUI_hEdit)-1
    ;-- Subtract 1 because there is significant chance (90%+ depending on the
    ;   font size) that the last visible line is only a partially displayed
    ;   line.

;-- On the first visible line?
if ($GoToLine=$FirstVisibleLine)
    HE_LineScroll($QAHKGUI_hEdit,0,Round((($LastVisibleLine-$FirstVisibleLine+1)/2)-1)*-1)
 else
    ;-- On or very near the last visible line?
    if ($GoToLine>=$LastVisibleLine-1)
        {
        if ($LastVisibleLine>$GoToLine)
            $LastVisibleLine:=$LastVisibleLine-2
                ;-- Rarely needed adjustment but allows for consistent results

        HE_LineScroll($QAHKGUI_hEdit,0,Floor(($LastVisibleLine-$FirstVisibleLine+1)/2))
        }

;-- Programming notes:  This routine uses the HE_ScrollCaret function to move
;   the selected "go to" line number within view.  If the caret is anywhere in
;   the middle of the control, the user either requested to go to a line number
;   that was already visible or the "go to" line number is near the top of the
;   the control.  If the caret is on the first visible line of the control, the
;   user requested to go to a line number earlier in the control.  If the caret
;   is on the last (full) visible line on the control, the user requested to go
;   to a line number further down in the control.  After the HE_ScrollCaret
;   brings the caret into view, this routine attempts to scroll the control so
;   that the caret is in the middle of the control.
;
;   The calculation for deteriming how many lines to scroll up when the caret is
;   at the top of the control (go to an earlier line number) is fairly
;   straightforward -- Round(VisibleLineCount/2)-1.
;
;   The calculation for determining how many lines to scroll down when the carat
;   is at the bottom of the control (go to a later line number) is a bit tenuous
;   because the caret is not always on the very last fully visible line.  The
;   reason: If the last visible line fits exactly (to the pixel) at the bottom
;   of the control, the HE_ScrollCaret function will scroll the control up 1
;   additional line because the caret is actually 2 pixels larger (1 at the top,
;   1 at the bottom) larger than an individual line.


return


;*******************
;*                 *
;*     Replace     *
;*    (QAHKGUI)    *
;*                 *
;*******************
QAHKGUI_Replace:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Bounce if Find or Replace dialog is already showing
IfWinExist ahk_id %Dlg_hWnd%
    return

;-- Where are we starting from?
HE_GetSel($QAHKGUI_hEdit,Dummy,$EndSelectPos)
if $EndSelectPos=0
    Dlg_FindFromTheTop:=True
 else
    Dlg_FindFromTheTop:=False

;-- Anything selected?
$Selected:=HE_GetSelText($QAHKGUI_hEdit)
if StrLen($Selected)
    {
    ;-- Ignore if multiple lines are selected
    if InStr($Selected,"`n")=0
        Dlg_FindWhat:=$Selected
    }

;-- Set direction
if Dlg_Flags not contains d
   Dlg_Flags:=Dlg_Flags . "d"

;-- Show Replace dialog
Dlg_hWnd :=Dlg_Replace($QAHKGUI_hWnd,"QAHKGUI_OnReplace",Dlg_Flags,Dlg_FindWhat,Dlg_ReplaceWith)
return


;*******************************
;*                             *
;*    Explore Run workspace    *
;*          (QAHKGUI)          *
;*                             *
;*******************************
QAHKGUI_ExploreRunFolder:
QAHKGUI_ExploreRunWorkspace:
SetTimer %A_ThisLabel%,Off

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- Attach messages to the current GUI
gui +OwnDialogs

;-- Run workspace exists?
IfNotExist %$RunDir%\.
    {
    $Message=The Run Workspace has been cleared.  There is nothing to explore.

    ;-- Status bar showing?
    if $ShowStatusBar
        {
        ;-- Update status bar
        SB_SetText($Message)
        SetTimer QAHKGUI_ClearStatusBar,8000

        ;-- Make a "not gonna happen" noise
        SoundPlay *16  ;-- System error sound
        }
     else
        MsgBox
            ,48     ;-- 48 = 0 (OK button) + 48 ('!" icon)
            ,Explore Run Workspace
            ,%$Message%   %A_Space%

    ;-- Bounce
    return
    }

;-- Open Windows Explorer to the "Run" folder
Run explorer.exe /e`,"%$RunDir%",,UseErrorLevel
if ErrorLevel
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Explore Error
        ,% SystemMessage(A_LastError)

return


;*****************************
;*                           *
;*    Clear Run workspace    *
;*         (QAHKGUI)         *
;*                           *
;*****************************
QAHKGUI_ClearRunWorkspace:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- Attach messages to the current GUI
gui +OwnDialogs

;-- Anything to clear?
IfNotExist %$RunDir%\.
    {
    $Message=The Run workspace has already been cleared.

    ;-- Status bar showing?
    if $ShowStatusBar
        {
        ;-- Update status bar
        SB_SetText($Message)
        SetTimer QAHKGUI_ClearStatusBar,8000

        ;-- Make a "not gonna happen" noise
        SoundPlay *16  ;-- System error sound
        }
     else
        MsgBox
            ,48     ;-- 49 = 1 (OK buttons) + 48 ("!" icon)
            ,No Run Workspace
            ,%$Message%  %A_Space%


    ;-- Bounce
    return
    }

;--  Script(s) running?
$RunPIDList:=RebuildRunPIDList($RunPIDList)
if StrLen($RunPIDList)
    {
    MsgBox
        ,16  ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Clear Run Workspace Error,
           (ltrim join`s
            One or more scripts are still running.  Please stop all running
            scripts before attempting to clear the Run workspace.  %A_Space%
           )

    ;-- Bounce
    return
    }


;-- Confirm
MsgBox
    ,49     ;-- 49 = 1 (OK/Cancel buttons) + 48 ("!" icon)
    ,Clear Run Workspace,
       (ltrim join`s
        All files and folders in the Run workspace will be deleted.  Press OK to
        proceed.  %A_Space%
       )

;-- Bounce if Cancel
IfMsgBox Cancel
    return

;-- Delete "Run" Folder
gosub DeleteRunFolder

;-- Update status bar
SB_SetText("Run workspace cleared.")
SetTimer QAHKGUI_ClearStatusBar,10000

;-- Make a "OK, I did it" noise
SoundPlay *64  ;-- System info sound
return


;*********************
;*                   *
;*        New        *
;*    Prepend New    *
;*     (QAHKGUI)     *
;*                   *
;*********************
QAHKGUI_New:
QAHKGUI_PrependNew:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- Attach messages to the current GUI
gui +OwnDialogs

;[===================]
;[  Find new script  ]
;[===================]
;-- System default?
if $NewScriptSystemDefault
    {
    ;-- Not found?
    IfNotExist %A_Windir%\ShellNew\Template.ahk
        {
        MsgBox
            ,48     ;-- 48 = 0 (OK button) + 48 ("!" icon)
            ,New Script Error,
               (ltrim
                Cannot find the AutoHotkey new script template:  %A_Space%
                %A_Windir%\ShellNew\Template.ahk  %A_Space%
               )

        return
        }

    ;-- Read into t_NewScript
    FileRead t_NewScript,%A_Windir%\ShellNew\Template.ahk
    if ErrorLevel
        {
        outputdebug A_LastError=%A_LastError%
        MsgBox
            ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,New Script Error,
               (ltrim
                Cannot read the AutoHotkey new script template:  %A_Space%
                %A_Windir%\ShellNew\Template.ahk  %A_Space%
               )

        return
        }
    }
 else
    {
    ;-- Program "new script" not defined?
    if StrLen($NewScript)=0
        {
        MsgBox
            ,48     ;-- 48 = 0 (OK button) + 48 ("!" icon)
            ,New Script Error,
               (ltrim join`s
                No "New Script" has been defined.  Check Options for more
                information.  %A_Space%
               )

        return
        }

    ;-- Assign to t_NewScript.  Convert NL chars to CRNL chars
    t_NewScript:=$NewScript
    StringReplace t_NewScript,t_NewScript,`n,`r`n,All
    }

;-- Update workspace
if A_ThisLabel contains Prepend
    HE_SetSel($QAHKGUI_hEdit,0,0)
 else
    HE_SetSel($QAHKGUI_hEdit,0,-1)

HE_ReplaceSel($QAHKGUI_hEdit,t_NewScript)
    ;-- Note:  This method is a bit choppy but it does allow for undo

;-- Scroll to the top/left
HE_LineScroll($QAHKGUI_hEdit,-999999,-999999)

;-- Update status bar
if A_ThisLabel contains Prepend
    $Message=
       (ltrim join`s
        "New" script template prepended to the current script.  Use Ctrl+Z to
        undo.
       )
 else
    $Message="New" script template copied to the workspace.  Use Ctrl+Z to undo.

SB_SetText($Message)
SetTimer QAHKGUI_ClearStatusBar,20000
return


;*******************
;*                 *
;*    Copy From    *
;*    (QAHKGUI)    *
;*                 *
;*******************
QAHKGUI_CopyFrom:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- Attach messages and dialogs to the current GUI
gui +OwnDialogs

;-- Initialize $CopyFromPath
if $CopyFromPath is Space
    if $SaveToPath is not Space
        $CopyFromPath:=$SaveToPath
     else
        $CopyFromPath:=A_MyDocuments

;[=================]
;[  Browse for it  ]
;[=================]
FileSelectFile
    ,$QAHKGUI_CopyFromFileName                  ;-- OutputVar
    ,1                                          ;-- Options. 1=File must exist
    ,%$CopyFromPath%                            ;-- Starting path
    ,Copy From                                  ;-- Prompt
    ,*.ahk;*.ini;*.txt                          ;-- Filter

;-- Cancel?
If ErrorLevel
    return

;-- Create restore point?
if $CreateRPOnCopyfromDrop
    RPCreate()

;[===========]
;[  Copy it  ]
;[===========]
;-- Copy selected file over workspace file
FileCopy %$QAHKGUI_CopyFromFileName%,%$EditFile%,1  ;-- 1=overwrite
If ErrorLevel
    {
    ;-- Notify the user
    gui +OwnDialogs
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Copy From Error
        ,Unable to copy the selected file to the workspace.  %A_Space%

    return
    }

;-- Reset file attributes
FileSetAttrib -RSH,%$EditFile%

;-- Reload workspace
gosub LoadWorkspace

;-- Redefine $CopyFromPath
SplitPath $QAHKGUI_CopyFromFileName,,$CopyFromPath

;-- Push to $RecentFiles and reload menu
MRUManager($RecentFiles,"Push",$QAHKGUI_CopyFromFileName,"|",9)
gosub QAHKGUI_ReloadRecentFilesMenu

;-- Update status bar
SB_SetText("Contents of " . CompressFileName($QAHKGUI_CopyFromFileName,65) . " copied to the workspace.")
SetTimer QAHKGUI_ClearStatusBar,25000
return


;**********************
;*                    *
;*    Recent Files    *
;*      (QAHKGUI)     *
;*                    *
;**********************
QAHKGUI_RecentFilesMenu:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- Attach messages and dialogs to the current GUI
gui +OwnDialogs

;-- Determine file name
$QAHKGUI_CopyFromFileName :=""
Loop Parse,$RecentFilesMenu,|
    if (A_ThisMenuItemPos=A_Index)
        {
        $QAHKGUI_CopyFromFileName:=A_LoopField
        Break
        }

;-- File exists?
IfNotExist %$QAHKGUI_CopyFromFileName%
    {
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,File Not Found,
           (ltrim
            Selected file not found:  %A_Space%
            %$QAHKGUI_CopyFromFileName%  %A_Space%
           )

    return
    }

;-- Create restore point?
if $CreateRPOnCopyfromDrop
    RPCreate()

;-- Copy selected file over workspace file
FileCopy %$QAHKGUI_CopyFromFileName%,%$EditFile%,1  ;-- 1=overwrite
If ErrorLevel
    {
    ;-- Notify the user
    gui +OwnDialogs
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Copy From Error
        ,Unable to copy the selected file to the workspace.  %A_Space%

    return
    }

;-- Reset file attributes
FileSetAttrib -RSH,%$EditFile%

;-- Reload workspace
gosub LoadWorkspace

;-- Redefine $CopyFromPath
SplitPath $QAHKGUI_CopyFromFileName,,$CopyFromPath

;-- Push to $RecentFiles
MRUManager($RecentFiles,"Push",$QAHKGUI_CopyFromFileName,"|",9)
    ;-- Note: Although $QAHKGUI_CopyFromFileName is pushed to $RecentFiles, the
    ;   Recent Files menu is not reloaded here.  This allows the user to copy
    ;   only recent files without having to see a resequenced (LIFO) list
    ;   every time.  However, the recent files list will automatically be
    ;   resequenced if other methods to load the workspace are used.

;-- Update status bar
SB_SetText("Contents of " . CompressFileName($QAHKGUI_CopyFromFileName,65) . " copied to the workspace.")
SetTimer QAHKGUI_ClearStatusBar,25000
return


QAHKGUI_ClearRecentFilesMenu:
MRUManager($RecentFiles,"Clear")
gosub QAHKGUI_ReloadRecentFilesMenu
return


QAHKGUI_ReloadRecentFilesMenu:

if $ShowMenubar
    {
    ;-- Temporarily turn off sizing
    $Resize:=False

    ;-- Hide menu bar
    gui %$QAHKGUI%:Menu
    }

;-- Rebuild RecentFiles menu
gosub QAHKGUI_BuildRecentFilesMenu

if $ShowMenubar
    {
    ;-- Show menu
    gui %$QAHKGUI%:Menu,QAHKGUI_Menubar

    ;-- Allow resizing to occur
    Sleep 1

    ;-- Restore sizing
    $Resize:=True
    }

return


;*************************
;*                       *
;*    External Editor    *
;*       (QAHKGUI)       *
;*                       *
;*************************
QAHKGUI_ExternalEditor:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- Attach messages to the current GUI
gui +OwnDialogs

;-- External editor defined?
if $ExtEditorPath is Space
    {
    MsgBox
        ,48     ;-- 48 = 0 (OK button) + 48 ("!" icon)
        ,External Editor Error
        ,No external editor has been defined.   %A_Space%

    return
    }

;-- Format editor name
t_EditorName :=""
if StrLen($ExtEditorName)
    StringReplace t_EditorName,$ExtEditorName,&,,All

t_EditorName2 :=t_EditorName
if t_EditorName is Space
    {
    t_EditorName :="An external editor"
    t_EditorName2:="the external editor"
    }

;-- Instructions/Confirm
MsgBox
    ,49     ;-- 49 = 1 (OK/Cancel buttons) + 48 ("!" icon)
    ,External Editor,
       (ltrim join`s
        %t_EditorName% will be called to edit the current workspace.  When
        you have finished making changes, save the file, close %t_EditorName2%,
        and restart %$ScriptName%.   `n`nPress OK to continue.  %A_Space%
       )

IfMsgBox Cancel
    return

;-- OK to exit?
if $ConfirmExitIfRunning
    if not QAHKGUI_ConfirmExit()
        return

;-- Close RPViewerGUI?
IfWinExist ahk_id %$RPViewerGUI_hWnd%
    gosub RPViewerGUI_Close

;-- Save workspace
gosub SaveWorkspace

;-- Create resore point?
if $CreateRPOnExit
    RPCreate()

;-- Clear run workspace?
if $ClearRunWorkspaceOnExit
    gosub DeleteRunFolder

;-- Save configuration
gosub SaveConfiguration

;-- Destroy GUI to ensure that there is no confict with the editor
gui Destroy

;-- Run it!
Run "%$ExtEditorPath%" "%$EditFile%",,UseErrorLevel
if ErrorLevel
    {
    if A_LastError=2
        MsgBox
            ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,Run External Editor Error,
               (ltrim join`s
                Unable to find and/or run the external editor
                program:  %A_Space%`n"%$ExtEditorPath%"  %A_Space%
               )
     else
        MsgBox
            ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,Run External Editor Error
            ,% SystemMessage(A_LastError)

    ExitApp
    }

;-- Shut it down
ExitApp
return



;*******************
;*                 *
;*       Save      *
;*    (QAHKGUI)    *
;*                 *
;*******************
QAHKGUI_Save:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- Save and backup workspace
gosub SaveWorkspace
gosub BackupWorkspace

;-- Flush Undo buffer?
if not $AllowUndoAfterSave
    HE_EmptyUndoBuffer($QAHKGUI_hEdit)

;-- Programming note: The Undo buffer is only flushed (if requested) when the
;   the user requests a manual save.

;-- Create restore point?
if $CreateRPOnSave
    RPCreate()

;-- Update status bar
SB_SetText("Workspace saved.")
SetTimer QAHKGUI_ClearStatusBar,15000
return


;*******************
;*                 *
;*     Save To     *
;*    (QAHKGUI)    *
;*                 *
;*******************
QAHKGUI_Toolbar_SaveTo:
SetTimer %A_ThisLabel%,Off
SetTimer QAHKGUI_SaveTo,0
return


QAHKGUI_SaveTo:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- Attach dialogs and messages to current GUI
gui +OwnDialogs

;-- Initialize $SaveToPath
if $SaveToPath is Space
    if $CopyFromPath is not Space
        $SaveToPath:=$CopyFromPath
     else
        $SaveToPath:=A_MyDocuments

;[=================]
;[  Browse for it  ]
;[=================]
FileSelectFile
    ,$QAHKGUI_SaveToFileName            ;-- OutputVar
    ,S16                                ;-- Options. 16=Prompt to overWrite file
    ,%$SaveToPath%                      ;-- Starting path
    ,Save To                            ;-- Prompt
    ,*.ahk;*.txt;*.ini                  ;-- Filter

;-- Cancel?
if ErrorLevel
    return

;-- Redefine $SaveToPath
SplitPath $QAHKGUI_SaveToFileName,,$SaveToPath

;[=============]
;[  Save file  ]
;[=============]
HE_SaveFile($QAHKGUI_hEdit,$QAHKGUI_SaveToFileName)
;;;;;If ErrorLevel
;;;;;    {
;;;;;    MsgBox
;;;;;        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
;;;;;        ,Save To Error
;;;;;        ,Unable to save the workspace to:   `n%$QAHKGUI_SaveToFileName%  %A_Space%
;;;;;
;;;;;    return
;;;;;    }

;-- Programming note: The value returned from HE_SaveFile is meaningless.  The
;   function usually returns 0 regardless of whether the file was successfully
;   saved or not.  On rare occasion, the function returns 1.  This value is also
;   meaningless if the return value 0 does not provide guidance.

;-- SaveToFile created?
IfNotExist %$QAHKGUI_SaveToFileName%
    {
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Save To Error
        ,Unable to save the workspace to:   `n%$QAHKGUI_SaveToFileName%  %A_Space%

    return
    }

;-- Push to $RecentFiles and reload menu
MRUManager($RecentFiles,"Push",$QAHKGUI_SaveToFileName,"|",9)
gosub QAHKGUI_ReloadRecentFilesMenu

;-- Update status bar
SB_SetText("Workspace saved to " . CompressFileName($QAHKGUI_SaveToFileName,65))
SetTimer QAHKGUI_ClearStatusBar,25000
return


;*******************
;*                 *
;*      Revert     *
;*    (QAHKGUI)    *
;*                 *
;*******************
QAHKGUI_Revert:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- Attach messages to the current GUI
gui +OwnDialogs

;-- Save workspace
gosub SaveWorkspace
    ;-- A little ironic I know, but we need to compare the current workspace
    ;   against the workspace backup file.

;-- Collect file sizes
FileGetSize $EditFileSize,%$EditFile%
FileGetSize $EditBackupFileSize,%$EditBackupFile%

;-- Bounce if there is nothing to revert to
;
;   Programming note:  Because of AutoHotkey's optimization techniques, the
;   FileMD5 functions are only called if the file sizes are equal.
;
 if ($EditFileSize=$EditBackupFileSize)
and FileMD5($EditFile,2)=FileMD5($EditBackupFile,2)
    {
    ;-- Status bar showing?
    if $ShowStatusBar
        {
        ;-- Update status bar
        SB_SetText("There are no changes to revert.")
        SetTimer QAHKGUI_ClearStatusBar,8000

        ;-- Make a "not gonna happen" noise
        SoundPlay *16  ;-- System error sound
        }
     else
        {
        gui +OwnDialogs
        MsgBox
            ,48     ;-- 48 = 0 (OK button) + 48 ("!" icon)
            ,Revert
            ,There are no changes to revert.  %A_Space%
        }

    ;-- Bounce
    return
    }

;-- Confirm
MsgBox
    ,33     ;-- 32 = 1 (OK/Cancel buttons) + 32 ("?" icon)
    ,Revert
    ,Revert to the last saved version?  %A_Space%

IfMsgBox Cancel
    return


;-- Copy backup file over workspace file
FileCopy %$EditBackupFile%,%$EditFile%,1  ;-- 1=overwrite
If ErrorLevel
    {
    gui +OwnDialogs
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Revert Error
        ,Unable to copy the backup file to the workspace.  %A_Space%

    return
    }

;-- Reset file attributes
FileSetAttrib -RSH,%$EditFile%
    ;-- Probably redundant but remains as a fail-safe

;-- Reload workspace
gosub LoadWorkspace

;-- Update status bar
SB_SetText("Workspace reverted to the last saved version.")
SetTimer QAHKGUI_ClearStatusBar,10000
return


;*************************
;*                       *
;*    Paste clipboard    *
;*       (QAHKGUI)       *
;*                       *
;*************************
QAHKGUI_PasteC:
QAHKGUI_PasteClipboard:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- Empty clipboard?
if StrLen(Clipboard)=0
    {
    gui +OwnDialogs
    MsgBox
        ,48     ;-- 48 = 0 (OK button) + 48 ("!" icon)
        ,Clipboard Empty
        ,The clipboard is empty.  Command aborted.  %A_Space%

    return
    }

;-- Autotrim/Convert to text
Clipboard=%Clipboard%

;-- Replace workspace
HE_SetSel($QAHKGUI_hEdit,0,-1)
HE_ReplaceSel($QAHKGUI_hEdit,Clipboard)

;-- Update status bar
$Message=
   (ltrim join`s
    Contents of the clipboard copied to the workspace.  Use Ctrl+Z to undo.
   )

SB_SetText($Message)
SetTimer QAHKGUI_ClearStatusBar,12000
return


;*******************
;*                 *
;*       Run       *
;*    (QAHKGUI)    *
;*                 *
;*******************
QAHKGUI_ContextMenu_RunSelected:
QAHKGUI_Toolbar_Run:
QAHKGUI_Toolbar_RunSelected:
SetTimer %A_ThisLabel%,Off

if A_ThisLabel contains Selected
    SetTimer QAHKGUI_RunSelected,0
 else
    SetTimer QAHKGUI_Run,0

return


QAHKGUI_Run:
QAHKGUI_RunSelected:
SetTimer %A_ThisLabel%,Off

;-- Already running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- Attach messages to the current GUI
gui +OwnDialogs


;[==============]
;[  Initialize  ]
;[==============]
$RunSelected:=False
$CLParms:=""

;[====================]
;[  Anything to run?  ]
;[====================]
if A_ThisLabel contains Selected
    {
    $RunSelected:=True
    if StrLen(HE_GetSelText($QAHKGUI_hEdit))=0
        {
        ;-- Status bar showing?
        if $ShowStatusBar
            {
            ;-- Update status bar
            SB_SetText("Nothing selected.  Script not run.")
            SetTimer QAHKGUI_ClearStatusBar,10000

            ;-- Make a "I couldn't do it" noise
            SoundPlay *16  ;-- System error sound
            }
         else
            {
            gui +OwnDialogs
            MsgBox
                ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
                ,Run Error
                ,Nothing selected.  Script not run.  %A_Space%
            }

        ;-- Bounce
        return
        }
    }
 else
    {
    if HE_GetTextLength($QAHKGUI_hEdit)=0
        {
        ;-- Status bar showing?
        if $ShowStatusBar
            {
            ;-- Update status bar
            SB_SetText("Workspace is empty.  Script not run.")
            SetTimer QAHKGUI_ClearStatusBar,10000

            ;-- Make a "I couldn't do it" noise
            SoundPlay *16  ;-- System error sound
            }
         else
            {
            gui +OwnDialogs
            MsgBox
                ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
                ,Run Error
                ,Workspace is empty.  Script not run.  %A_Space%
            }

        return
        }
    }

if $RunPrompt
    {
    gosub RunPromptGUI
    return
    }


QAHKGUI_Run_AfterPrompt:
SetTimer %A_ThisLabel%,Off

;-- Reset GUI default
gui %$QAHKGUI%:Default

;-- Attach messages to the current GUI
gui +OwnDialogs

;[===============]
;[  Preliminary  ]
;[===============]
;-- Save workspace
gosub SaveWorkspace

;-- Create resore point?
if $CreateRPOnRun
    RPCreate()

;-- Clear Run workspace?
if $ClearRunWorkspaceOnRun
    gosub DeleteRunFolder

;-- Save configuration
gosub SaveConfiguration

;[=========================]
;[    Create "Run" folder  ]
;[  (If it doesn't exist)  ]
;[=========================]
IfNotExist %$RunDir%\.
    {
    ;-- Create folder
    FileCreateDir %$RunDir%
    if ErrorLevel
        {
        MsgBox
            ,48     ;-- 48 = 0 (OK button) + 48 ("!" icon)
            ,Run Error
            ,Unable to create the Run workspace.  Script not run.  %A_Space%

        return
        }
    }

;[===================]
;[    Copy script    ]
;[  to "Run" folder  ]
;[===================]
if $RunSelected
    {
    ;-- Delete Run file (if it exists)
    IfExist %$RunFile%
        {
        FileDelete %$RunFile%
        if ErrorLevel
            {
            MsgBox
                ,16  ;-- 16 = 0 (OK button) + 16 (Error icon)
                ,Run Error,
                   (ltrim
                    Unable to delete the Run file:  %A_Space%
                    %$RunFile%  %A_Space%
                    `nThis file may be in use by another program.  %A_Space%
                   )

            outputdebug End Subrou: %A_ThisLabel% - Unable to delete Run file
            return
            }
        }

    ;-- Write selected text to Run file
    FileAppend % HE_GetSelText($QAHKGUI_hEdit),%$RunFile%
    If ErrorLevel
        {
        MsgBox
            ,16  ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,Run Error,
               (ltrim join`s
                Unable to copy the selected text to the Run workspace.  Script
                not run.  %A_Space%
               )

        outputdebug,
           (ltrim join`s
            End Subrou: %A_ThisLabel% - Unable to write selected text to the Run
            file
           )

        return
        }
    }
 else
    {
    ;-- Create/Overwrite the Run file
    FileCopy %$EditFile%,%$RunFile%,1  ;-- 1=Overwrite existing file(s)
    If ErrorLevel
        {
        MsgBox
            ,48     ;-- 48 = 0 (OK button) + 48 ("!" icon)
            ,Run Error,
               (ltrim join`s
                Unable to copy the workspace script to the Run
                workspace.  Script not run.  %A_Space%
               )

        outputdebug,
           (ltrim join`s
            End Subrou: %A_ThisLabel% - Unable to copy workspace script to the
            "Run" folder
           )
        return
        }
    }

;[================]
;[  Debug script  ]
;[================]
if $RunDebug
    {
    ;-- Append debug script to Run file
    FileAppend % "`n" . $DebugScript,%$RunFile%
    If ErrorLevel
        {
        MsgBox
            ,16  ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,Run Error,
               (ltrim join`s
                Unable to append the debug script to the Run script.  Script not
                run.  %A_Space%
               )

        outputdebug,
           (ltrim join`s
            End Subrou: %A_ThisLabel% - Unable to append the debug script to the
            Run file
           )

        return
        }
    }

;[=============================]
;[  Determine Autohotkey path  ]
;[=============================]
;-- Set to blank
$AHKRunPath=

;-- First, try user-defined path
if $AutoHotkeyPath is not Space
    {
    $AHKRunPath:=$AutoHotkeyPath

    ;-- Blank if not found
    IfNotExist %$AHKRunPath%
        $AHKRunPath=
    }

;-- If blank, try A_AhkPath
if $AHKRunPath is Space
    {
    $AHKRunPath:=A_AhkPath

    ;-- Blank if not found
    if $AHKRunPath is not Space
        IfNotExist %$AHKRunPath%
            $AHKRunPath=
    }

;-- Still blank, error
if $AHKRunPath is Space
    {
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Run Error,
           (ltrim join`s
            Cannot find the AutoHotkey program.  The AutoHotkey path has not
            been defined (Options window, "Run" tab) or is invalid, or
            AutoHotkey has not been installed on this computer.
           )

    return
    }

;[======================]
;[  Run but don't wait  ]
;[======================]
if not $RunWait
    {
    ;-- Enable menu and toolbar items
    Menu QAHKGUI_FileMenu
        ,Enable
        ,%s_File_Stop_MI%

    Menu QAHKGUI_Menubar
        ,Enable
        ,%s_Menubar_Stop_MI%

    ;----------
    ;-- Run it
    ;----------
    $RunPID=0
    Run
        ,"%$AHKRunPath%" "%$RunFile%" %$CLParms%
        ,%$RunDir%
        ,UseErrorLevel
        ,$RunPID

    ;-- Run error?
    if A_LastError
        {
        MsgBox
            ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,Run Error
            ,% SystemMessage(A_LastError)

        return
        }

    ;-- Add $RunPID to $RunPIDList
    gosub QAHKGUI_AddRunPID

    ;-- Update status bar
    SB_SetText("Script run without waiting to complete.")
    SetTimer QAHKGUI_ClearStatusBar,10000
    return
    }

;[================]
;[  Run and wait  ]
;[================]
;-- Update status bar
if $RunDebug
    $Message:="Running script with appended debug script..."
 else
    $Message:="Running script..."

SB_SetText($Message)
SetTimer QAHKGUI_ClearStatusBar,Off

;-- Update menu, toolbar, and GUI objects
if $ShowMenubar
    gui Menu,QAHKGUI_MenubarRunWait

if $Toolbar_RunButtonList
    Loop Parse,$Toolbar_RunButtonList,`,
        Toolbar_SetButton($hToolbar,A_LoopField,"Disabled")

Control Disable,,,ahk_id %$QAHKGUI_hEdit%

;-- Run and wait
$Running:=True
$StartTime:=A_TickCount

$RunPID=0
SetTimer QAHKGUI_AddRunPID,250
RunWait
    ,"%$AHKRunPath%" "%$RunFile%" %$CLParms%
    ,%$RunDir%
    ,UseErrorLevel
    ,$RunPID

;-- Run error?
if A_LastError
    {
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Run Error
        ,% SystemMessage(A_LastError)

    return
    }

;[==================]
;[  Post-Run stuff  ]
;[==================]
SetTimer QAHKGUI_AddRunPID,Off

$Running      :=False
$RunPID       :=0
$RunErrorLevel:=ErrorLevel
$RunTime      :=(A_TickCount-$StartTime)/1000


;-- Format run time
$FormattedRunTime:=SecondsToHHMMSS(floor($RunTime),5) . SubStr($RunTime,-6,4)
    ;-- Programming note: This statement assumes that the script is using the
    ;   default AutoHotkey format: Float 0.6.  This statement will produce
    ;   different results if the default format is changed.

;-- Update status bar
$Message=
   (ltrim join`s
    Run complete.   ErrorLevel:
    %$RunErrorLevel%    Run time:
    %$FormattedRunTime%
   )

SB_SetText($Message)

;-- Update menus, toolbars, and GUI objects
if $ShowMenubar
    gui Menu,QAHKGUI_Menubar

if $Toolbar_RunButtonList
    Loop Parse,$Toolbar_RunButtonList,`,
        Toolbar_SetButton($hToolbar,A_LoopField,"-Disabled")

Control Enable,,,ahk_id %$QAHKGUI_hEdit%

;-- If there are no running scripts, disable "Stop" menu and toolbar items
$RunPIDList:=RebuildRunPIDList($RunPIDList)
if StrLen($RunPIDList)=0
    {
    Menu QAHKGUI_FileMenu
        ,Disable
        ,%s_File_Stop_MI%

    Menu QAHKGUI_Menubar
        ,Disable
        ,%s_Menubar_Stop_MI%
    }

;-- Reset focus
ControlFocus,,ahk_id %$QAHKGUI_hEdit%
return



;*********************
;*                   *
;*    Add Run PID    *
;*     (QAHKGUI)     *
;*                   *
;*********************
QAHKGUI_AddRunPID:
SetTimer %A_ThisLabel%,Off

if $RunPID
    if StrLen($RunPIDList)=0
        $RunPIDList:=$RunPID
     else
        $RunPIDList:=$RunPIDList . "," . $RunPID

return


;******************************
;*                            *
;*    Stop running scripts    *
;*          (QAHKGUI)         *
;*                            *
;******************************
QAHKGUI_Stop:
SetTimer %A_ThisLabel%,Off

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- Attach messages to the current GUI
gui +OwnDialogs

;[======================]
;[  Anything to close?  ]
;[======================]
$RunPIDList:=RebuildRunPIDList($RunPIDList)
if StrLen($RunPIDList)=0
    {
    ;-- Status bar showing?
    if $ShowStatusBar
        {
        ;-- Update status bar
        SB_SetText("There are no running scripts.")
        SetTimer QAHKGUI_ClearStatusBar,8000

        ;-- Make a "There is nothing to do" noise
        SoundPlay *16  ;-- System error sound
        }
     else
        MsgBox
            ,16  ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,Stop Error
            ,There are no running scripts.  %A_Space%

    ;-- Bounce
    return
    }

;[===========]
;[  Confirm  ]
;[===========]
;-- Create display list
$RunPIDListDisplay:="     " . $RunPIDList
StringReplace $RunPIDListDisplay,$RunPIDListDisplay,`,,`n    %A_Space%,All

;-- Prompt
if InStr($RunPIDList,",")=0
    MsgBox
        ,49     ;-- 49 = 1 (OK/Cancel buttons) + 48 ("!" icon)
        ,Confirm Stop,
           (ltrim join`s
            This request will terminate the script that is currently
            running.  Press OK to proceed.  %A_Space%
           )
 else
    MsgBox
        ,49     ;-- 49 = 1 (OK/Cancel buttons) + 48 ("!" icon)
        ,Confirm Stop,
           (ltrim join`s
            The following %$ScriptName% processes will be terminated:  %A_Space%
            `n`n%$RunPIDListDisplay%
            `n`nPress OK to proceed.  %A_Space%
           )

IfMsgBox Cancel
    return

;[=============]
;[  Close 'em  ]
;[=============]
$CloseCount=0
$ErrorCount=0
Loop Parse,$RunPIDList,`,
    {
    ;-- Ignore if already closed
    Process Exist,%A_LoopField%
    if not ErrorLevel
        Continue


    ;-- Close it
    Process Close,%A_LoopField%
    if ErrorLevel
        $CloseCount++
     else
        $ErrorCount++
    }

;-- Errors?
if $ErrorCount
    MsgBox
        ,48     ;-- 48 = 0 (OK button) + 48 ("!" icon)
        ,Stop Error,
           (ltrim join`s
            %$ErrorCount% %$ScriptName% process(es) could not be
            terminated.  %A_Space%
           )
 else
    if $CloseCount
        {
        if InStr($RunPIDList,",")=0
            MsgBox
                ,64     ;-- 64 = 0 (OK button) + 64 (Info icon)
                ,Stop
                ,Script terminated.  %A_Space%
                ,20     ;-- Timeout
         else
            MsgBox
                ,64     ;-- 64 = 0 (OK button) + 64 (Info icon)
                ,Stop
                ,%$CloseCount% %$ScriptName% processes terminated.  %A_Space%
        }
     else
        MsgBox
            ,48     ;-- 48 = 0 (OK button) + 48 ("!" icon)
            ,Nothing to Stop
            ,All active scripts already stopped.  %A_Space%

;-- Clear $RunPIDList
$RunPIDList:=""

;-- Disable "Stop" menu and toolbar items
Menu QAHKGUI_FileMenu
    ,Disable
    ,%s_File_Stop_MI%

Menu QAHKGUI_Menubar
    ,Disable
    ,%s_Menubar_Stop_MI%

return


;******************************
;*                            *
;*    Create restore point    *
;*         (QAHKGUI)          *
;*                            *
;******************************
QAHKGUI_CreateRestorePoint:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Set GUI default
gui %$QAHKGUI%:Default


;-- Workspace empty?
if HE_GetTextLength($QAHKGUI_hEdit)=0
    {
    ;-- Update status bar
    SB_SetText("Workspace empty.  Restore point NOT created.")
    SetTimer QAHKGUI_ClearStatusBar,8000

    ;-- Make a "Didn't happen" noise
    SoundPlay *16  ;-- System error sound
    }
else
    {
    ;-- Create restore point
    RPCreate(False)

    ;-- Update status bar
    SB_SetText("Restore point created.")
    SetTimer QAHKGUI_ClearStatusBar,10000

    ;-- Make a "OK, I did it" noise
    SoundPlay *64: ;-- System Info sound
    }

return


;***********************
;*                     *
;*    Edit commands    *
;*      (QAHKGUI)      *
;*                     *
;***********************
QAHKGUI_EditCopy:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

HE_Copy($QAHKGUI_hEdit)
return


QAHKGUI_EditCut:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

HE_Cut($QAHKGUI_hEdit)
return


QAHKGUI_EditPaste:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

HE_Paste($QAHKGUI_hEdit)
return


QAHKGUI_Editclear:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

HE_Clear($QAHKGUI_hEdit)
return


QAHKGUI_EditSelectAll:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

HE_SetSel($QAHKGUI_hEdit,0,-1)
return


QAHKGUI_Redo:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }


;-- Reset GUI default
gui %$QAHKGUI%:Default


;-- Redo
if HE_Redo($QAHKGUI_hEdit)
    SB_SetText("Redo requested.")
 else
    {
    SB_SetText("Nothing to redo.")
    SoundPlay *-1  ;-- System default sound
    }

SetTimer QAHKGUI_ClearStatusBar,6000
return



QAHKGUI_Undo:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }


;-- Reset GUI default
gui %$QAHKGUI%:Default

;-- Undo
if HE_Undo($QAHKGUI_hEdit)
    SB_SetText("Undo requested.")
 else
    {
    SB_SetText("Nothing to undo.")
    SoundPlay *-1  ;-- System default sound
    }

SetTimer QAHKGUI_ClearStatusBar,6000
return


;********************
;*                  *
;*    Capitalize    *
;*    Lowercase     *
;*    ToggleCase    *
;*    Uppercase     *
;*                  *
;*     (QAHKGUI)    *
;*                  *
;********************
QAHKGUI_Capitalize:
QAHKGUI_Lowercase:
QAHKGUI_InvertCase:
QAHKGUI_ToggleCase:
QAHKGUI_Uppercase:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Convert
QAHKGUI_ConvertCase($QAHKGUI_hEdit,SubStr(A_ThisLabel,9))
return


;***********************
;*                     *
;*    Block Comment    *
;*      (QAHKGUI)      *
;*                     *
;***********************
QAHKGUI_BlockComment:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Block comment
Critical
HE_BlockComment($QAHKGUI_hEdit,"Insert",$BlockComment)
Critical Off
return


;*************************
;*                       *
;*    Block Uncomment    *
;*       (QAHKGUI)       *
;*                       *
;*************************
QAHKGUI_BlockUncomment:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Block uncomment
Critical
HE_BlockComment($QAHKGUI_hEdit,"Delete",$BlockComment)
Critical Off
return


;********************
;*                  *
;*    Page Setup    *
;*     (QAHKGUI)    *
;*                  *
;********************
QAHKGUI_Toolbar_PageSetup:
SetTimer %A_ThisLabel%,Off
SetTimer QAHKGUI_PageSetup,0
return


QAHKGUI_PageSetup:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Update printer settings to user defaults
gosub UpdatePrinterSettings

;[==============]
;[  Page setup  ]
;[==============]
;-- Create/Define PAGESETUPDLG Structure
VarSetCapacity(PAGESETUPDLG_Structure,84,0)
NumPut(84,PAGESETUPDLG_Structure,0,"UInt")                      ;-- lStructSize
NumPut($QAHKGUI_hWnd,PAGESETUPDLG_Structure,4,"UInt")           ;-- hwndOwner

if hDevMode is Integer
    NumPut(hDevMode,PAGESETUPDLG_Structure,8,"UInt")            ;-- hDevMode

if hDevNames is Integer
    NumPut(hDevNames,PAGESETUPDLG_Structure,12,"UInt")          ;-- hDevMode

;-- Flags
NumPut(PSD_MARGINS,PAGESETUPDLG_Structure,16,"UInt")

;-- Set default margins
NumPut($PrintMarginLeft  ,PAGESETUPDLG_Structure,44,"UInt")     ;-- rtMargin.left
NumPut($PrintMarginTop   ,PAGESETUPDLG_Structure,48,"UInt")     ;-- rtMargin.top
NumPut($PrintMarginRight ,PAGESETUPDLG_Structure,52,"UInt")     ;-- rtMargin.right
NumPut($PrintMarginBottom,PAGESETUPDLG_Structure,56,"UInt")     ;-- rtMargin.bottom


;-- Show Page Setup dialog.  Bounce if user cancels.
if not DllCall("comdlg32\PageSetupDlgA","UInt",&PAGESETUPDLG_Structure)
    return

;-- Collect handles
hDevMode :=NumGet(PAGESETUPDLG_Structure,8,"UInt")
    ;-- Handle to a global memory object that contains a DEVMODE structure

hDevNames :=NumGet(PAGESETUPDLG_Structure,12,"UInt")
    ;-- Handle to a movable global memory object that contains a DEVNAMES
    ;   structure

;[===========================]
;[  Collect user selections  ]
;[===========================]
;-- Margins
$PrintMarginLeft  :=NumGet(PAGESETUPDLG_Structure,44,"UInt")    ;-- rtMargin.left
$PrintMarginTop   :=NumGet(PAGESETUPDLG_Structure,48,"UInt")    ;-- rtMargin.top
$PrintMarginRight :=NumGet(PAGESETUPDLG_Structure,52,"UInt")    ;-- rtMargin.right
$PrintMarginBottom:=NumGet(PAGESETUPDLG_Structure,56,"UInt")    ;-- rtMargin.bottom

;-- Lock the moveable memory, retrieving a pointer to it
pDevMode :=DllCall("GlobalLock","UInt",hDevMode)

;-- Collet orientation
$PrintOrientation:=NumGet(pDevMode+0,44,"Short")

;-- Save configuration
gosub SaveConfiguration
return



;*******************
;*                 *
;*      Print      *
;*    (QAHKGUI)    *
;*                 *
;*******************
QAHKGUI_Toolbar_Print:
SetTimer %A_ThisLabel%,Off
SetTimer QAHKGUI_Print,0
return


QAHKGUI_Print:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }


;-- Anything to print?
if HE_GetTextLength($QAHKGUI_hEdit)=0
    {
    gui +OwnDialogs
    MsgBox
        ,48     ;-- 16 = 0 (OK button) + 48 ("!" icon)
        ,Print Error
        ,The workspace is empty.  There is nothing to print.  %A_Space%

    return
    }

;-- Update printer setting to user defaults
gosub UpdatePrinterSettings

;-- Print it
HE_Print($QAHKGUI_hEdit
        ,$QAHKGUI_hWnd
        ,$PrintMarginLeft
        ,$PrintMarginTop
        ,$PrintMarginRight
        ,$PrintMarginBottom)

return


;*******************
;*                 *
;*       Help      *
;*    (QAHKGUI)    *
;*                 *
;*******************
QAHKGUI_Help:
SetTimer %A_ThisLabel%,Off

;-- Help file already open?
IfWinExist %$ScriptName% Help
    WinActivate
 else
    {
    ;-- Open Help file
    Run %$HelpFile%,,UseErrorLevel
    if ErrorLevel
        {
        gui +OwnDialogs
        MsgBox
            ,16  ;-- 16=0 (OK button) + 16 (Stop icon)
            ,Help Error
            ,Unable to find the Help file.  %A_Space%
        }
    }

return


;*******************
;*                 *
;*      About      *
;*    (QAHKGUI)    *
;*                 *
;*******************
QAHKGUI_Toolbar_About:
SetTimer %A_ThisLabel%,Off
SetTimer QAHKGUI_About,0
return


QAHKGUI_About:
SetTimer %A_ThisLabel%,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Collect current HiEdit version
FileGetVersion,$HiEditVersion,%$LibDir%\HiEdit.dll

;-- Build display text
$Text:="`n" . $ScriptName . "`nv" . $Version . "`n`nHiEdit v" . $HiEditVersion

;-- About window
InfoGUI($QAHKGUI                                            ;-- Owner
    ,$Text                                                  ;-- Text
    ,"About..."                                             ;-- Title
    ,""                                                     ;-- GUI options
    ,"Text"                                                 ;-- Object type
    ,"r6 w200 Center"                                       ;-- Object options
    ,"Black"                                                ;-- Background color
    ,"Arial"                                                ;-- Font
    ,"cLime s16")                                           ;-- Font options

return


;**************************
;*                        *
;*    Clear status bar    *
;*        (QAHKGUI)       *
;*                        *
;**************************
QAHKGUI_ClearStatusBar:

;-- Set GUI default
gui %$QAHKGUI%:Default

SetTimer QAHKGUI_ClearStatusBar,Off
SB_SetText("")
return


;***********************
;*                     *
;*    Close up shop    *
;*      (QAHKGUI)      *
;*                     *
;***********************
;;; QAHKGUI_Escape:
    ;-- Programming note: The Escape key trap that this label provides cannot be
    ;   used because of the HiEdit control.  If the HiEdit control is in focus,
    ;   any Escape key from any pop-up window will pass control to this label.
    ;   To get around this bug, a context-sensitive Escape hotkey has been added
    ;   to emulate the function that this label provided.


QAHKGUI_Close:
QAHKGUI_Exit:
SetTimer %A_ThisLabel%,Off

;-- Set GUI default
gui %$QAHKGUI%:Default

;-- OK to exit?
if $ConfirmExitIfRunning
    if not QAHKGUI_ConfirmExit()
        return

;-- Close RPViewerGUI?
IfWinExist ahk_id %$RPViewerGUI_hWnd%
    gosub RPViewerGUI_Close

;-- Save workspace
gosub SaveWorkspace

;-- Create resore point?
if $CreateRPOnExit
    RPCreate()

;-- Clear run workspace?
if $ClearRunWorkspaceOnExit
    gosub DeleteRunFolder

;-- Minimized or maximized?
if $WindowMinimized or $WindowMaximized
    {
    ;-- Turn off sizing
    $Resize:=False

    ;-- Make the window invisible
    DetectHiddenWindows On
    WinSet Transparent,0,ahk_id %$QAHKGUI_hWnd%
    DetectHiddenWindows Off

    ;-- Restore the window so that the final X/Y/W/H can be captured
    if $WindowMinimized
        gui Show,Restore  ;-- Un-minimize
            ;-- Note: This action can restore the window into a maximized window

    if $WindowMaximized
        {
        gui Show,Restore
        $WindowMaximized:=True  ;-- Restore $WindowMaximized flag
        }
    }

;-- Save configuration
gosub SaveConfiguration

;-- Destroy toolbar ILs
IL_Destroy($hToolbarSmallIL)
IL_Destroy($hToolbarLargeIL)

;-- Free global structures created by PageSetupDlg or PrintDlg
if hDevMode
    DllCall("GlobalFree","UInt",hDevMode)

if hDevNames
    DllCall("GlobalFree","UInt",hDevNames)

;-- Shut it down
ExitApp
return


;***************************
;*                         *
;*                         *
;*         Hotkeys         *
;*        (QAHKGUI)        *
;*                         *
;*                         *
;***************************
;-- Begin #IfWinActive directive
#IfWinActive ahk_group $QAHKGUI_Group

;[==========]
;[  Escape  ]
;[==========]
~Escape::
if $EscapeToExit
    {
    ;-- Bounce if Find or Replace dialog is showing
    IfWinExist ahk_id %Dlg_hWnd%
        {
        SoundPlay *-1  ;-- System default sound
        return
        }

    ;-- We're outta here!
    gosub QAHKGUI_Exit
    }

return

;[===========]
;[  AppsKey  ]
;[===========]
AppsKey::

;-- Get coordinates of end selection position
HE_GetSel($QAHKGUI_hEdit,$StartSelPos,$EndSelPos)
HE_PosFromChar($QAHKGUI_hEdit,$EndSelPos,$EndSelX,$EndSelY)


;-- Show context menu
Menu QAHKGUI_ContextMenu
    ,Show
    ,% $EndSelX+10
    ,% $EndSelY+SM_CYSIZEFRAME+SM_CYCAPTION+($ShowMenuBar ? SM_CYMENU:0)+($ShowToolBar ? $ToolbarH:0)
        ;-- Programming note: Additions to the X and Y positions are to allow
        ;   the caret to be visible (X) and to account for the height of the
        ;   horizontal border, title bar, menu bar, and toolbar. (Y).  These
        ;   calculations are only accurate if menu bar and the toolbar are not
        ;   wrapped.

return


;[================]
;[  Ctrl+WheelUp  ]
;[================]
^WheelUp::
gosub QAHKGUI_IncreaseFontSize
return


;[==================]
;[  Ctrl+WheelDown  ]
;[==================]
^WheelDown::
gosub QAHKGUI_DecreaseFontSize
return


;[=======]
;[  Tab  ]
;[=======]
Tab::

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Shift right
Critical
HE_ShiftLine($QAHKGUI_hEdit,"Insert",$Tab)
return


;[=============]
;[  Shift+Tab  ]
;[=============]
+Tab::

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Shift left
Critical
HE_ShiftLine($QAHKGUI_hEdit,"Delete",$Tab)
return


;[==========]
;[  Ctrl+[  ]
;[==========]
^[::
gosub QAHKGUI_DecreaseFontSize
return


;[==========]
;[  Ctrl+]  ]
;[==========]
^]::
gosub QAHKGUI_IncreaseFontSize
return


;[==================]
;[  Ctrl+NumpadAdd  ]
;[==================]
^NumpadAdd::
gosub QAHKGUI_IncreaseFontSize
return


;[==================]
;[  Ctrl+NumpadSub  ]
;[==================]
^NumpadSub::
gosub QAHKGUI_DecreaseFontSize
return


;[==================]
;[  Ctrl+Numpad0    ]
;[  Ctrl+NumpadIns  ]
;[==================]
^Numpad0::
^NumpadIns::
^NumpadDiv::
gosub QAHKGUI_DefaultFontSize
return


;[======]
;[  F1  ]
;[======]
F1::
gosub QAHKGUI_Help
return


;[======]
;[  F2  ]
;[======]
F2::
gosub OptionsGUI
return


;[======]
;[  F3  ]
;[======]
F3::
gosub QAHKGUI_FindNext
return


;[============]
;[  Shift+F3  ]
;[============]
+F3::
gosub QAHKGUI_FindPrevious
return


;[======]
;[  F4  ]
;[======]
F4::
gosub RPViewerGUI  ;-- Restore
return


;[======]
;[  F5  ]
;[======]
F5::
gosub QAHKGUI_PasteClipboard  ;-- PasteC
return


;[======]
;[  F8  ]
;[======]
F8::
gosub QAHKGUI_ExternalEditor
return


;[======]
;[  F9  ]
;[======]
F9::
gosub QAHKGUI_Run
return


;[===========]
;[  Ctrl+F9  ]
;[===========]
^F9::
gosub QAHKGUI_RunSelected
return


;[=================]
;[  Ctrl+Shift+F9  ]
;[=================]
^+F9::
gosub QAHKGUI_ExploreRunWorkspace
return


;[===============]
;[  Ctrl+Alt+F9  ]
;[===============]
^!F9::
gosub QAHKGUI_ClearRunWorkspace
return


;[=======]
;[  F10  ]
;[=======]
F10::
gosub QAHKGUI_Stop
return


;[=======]
;[  F12  ]
;[=======]
F12::
gosub QAHKGUI_SaveTo
return


;[================]
;[  Ctrl+Shift+A  ]
;[================]
^+a::
gosub QAHKGUI_ToggleAlwaysOnTop
return


;[================]
;[  Ctrl+Shift+C  ]
;[================]
^+c::
gosub QAHKGUI_Capitalize
return


;[==========]
;[  Ctrl+F  ]
;[==========]
^f::
gosub QAHKGUI_Find
return


;[==========]
;[  Ctrl+G  ]
;[==========]
^g::
gosub QAHKGUI_Goto
return


;[==========]
;[  Ctrl+H  ]
;[==========]
^h::
gosub QAHKGUI_Replace
return


;[==========]
;[  Ctrl+Shift+I  ]
;[==========]
^+i::
gosub QAHKGUI_ToggleToolbarIconSize
return


;[==========]
;[  Ctrl+L  ]
;[==========]
^l::
gosub QAHKGUI_ToggleLineNumbersBar
return


;[================]
;[  Ctrl+Shift+L  ]
;[================]
^+l::
gosub QAHKGUI_Lowercase
return


;[================]
;[  Ctrl+Shift+M  ]
;[================]
^+m::
gosub QAHKGUI_ToggleMenubar
return


;[==========]
;[  Ctrl+N  ]
;[==========]
^n::
gosub QAHKGUI_New
return


;[================]
;[  Ctrl+Shift+N  ]
;[================]
^+n::
gosub QAHKGUI_PrependNew
return


;[==========]
;[  Ctrl+O  ]
;[==========]
^o::
gosub QAHKGUI_CopyFrom
return


;[==========]
;[  Ctrl+P  ]
;[==========]
^p::
gosub QAHKGUI_Print
return


;[================]
;[  Ctrl+Shift+P  ]
;[================]
^+p::
gosub QAHKGUI_PageSetup
return


;[==========]
;[  Ctrl+Q  ]
;[==========]
^q::
gosub QAHKGUI_BlockComment
return


;[================]
;[  Ctrl+Shift+Q  ]
;[================]
^+q::
gosub QAHKGUI_BlockUncomment
return



;[==========]
;[  Ctrl+R  ]
;[==========]
^r::
gosub QAHKGUI_Run
return


;[================]
;[  Ctrl+Shift+R  ]
;[================]
^+r::
gosub QAHKGUI_CreateRestorePoint
return


;[==========]
;[  Ctrl+S  ]
;[==========]
^s::
gosub QAHKGUI_Save
return


;[================]
;[  Ctrl+Shift+S  ]
;[================]
^+s::
gosub QAHKGUI_ToggleStatusbar
return


;[==========]
;[  Ctrl+T  ]
;[==========]
^t::
gosub QAHKGUI_ToggleToolbar
return


;[================]
;[  Ctrl+Shift+T  ]
;[================]
^+t::
gosub QAHKGUI_ToggleCase
return


;[================]
;[  Ctrl+Shift+U  ]
;[================]
^+u::
gosub QAHKGUI_Uppercase
return


;[==========]
;[  Ctrl+Y  ]
;[==========]
^y::  ;-- Note: Native is not used for this hotkey
gosub QAHKGUI_Redo
return


;[==========]
;[  Ctrl+Z  ]
;[==========]
^z::  ;-- Note: Native is not used for this hotkey
gosub QAHKGUI_Undo
return


;[================]
;[  Ctrl+Shift+Z  ]
;[================]
^+z::
gosub QAHKGUI_Revert
return

;-- End #IfWinActive directive
#IfWinActive


;-------------------------------------------------------------------------------
;------------------------------ End QAHKGUI Stuff ------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------





;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;---------------------------- Begin OptionsGUI Stuff ---------------------------
;-------------------------------------------------------------------------------
;*****************************
;*                           *
;*                           *
;*        Options GUI        *
;*                           *
;*                           *
;*****************************
OptionsGUI:
SetTimer OptionsGUI,Off

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;[==============]
;[  Initialize  ]
;[==============]
$OptionsGUI:=21

;---------------------
;-- Toolbar icon size
;---------------------
$OptionsGUI_ToolbarLargeIcons:=False
$OptionsGUI_ToolbarSmallIcons:=False
if $ToolbarIconSize=Large
    $OptionsGUI_ToolbarLargeIcons:=True
 else
    $OptionsGUI_ToolbarSmallIcons:=True

;----------------------
;-- Shell context menu
;----------------------
$OptionsGUI_ShellContextMenu:=False

;-- Compiled?
if A_IsCompiled
    {
    ;-- Is .ahk registered?
    RegRead
        ,$DocumentType
        ,HKEY_CLASSES_ROOT
        ,.ahk\

    if not ErrorLevel
        {
        ;-- Look for custom command
        RegRead
            ,$Dummy
            ,HKEY_CLASSES_ROOT
            ,%$DocumentType%\shell\Open with %$ScriptName%\command

        if not ErrorLevel
            $OptionsGUI_ShellContextMenu:=True
        }
    }

;[=============]
;[  Build GUI  ]
;[=============]
;-- Set GUI default
gui %$OptionsGUI%:Default

;-- Disable parent GUI, give ownership to parent GUI
gui %$QAHKGUI%:+Disabled
gui +Owner%$QAHKGUI%
    ;-- Note: Ownership assignment must be be performed before any other GUI
    ;   commands.

;-- Identify window handle
gui %$OptionsGUI%:+LastFound
WinGet $OptionsGUI_hWnd,ID

;-- GUI options
gui Margin,6,6
gui +LabelOptionsGUI_
    || +Resize
    || -MinimizeBox
    || -MaximizeBox
    || +MinSize

;-- Tab
gui Add
   ,Tab2
   ,xm y10 w420 h440
        || hWnd$OptionsGUI_Tab_hWnd
        || v$OptionsGUI_Tab
        || gOptionsGUI_Tab
   ,General|Editor|Run|Restore|New|Debug

;----------------
;-- Tab: General
;----------------
gui Tab,General
gui Add
   ,GroupBox
   ,xm+10 y40 w400 h10
        || hWnd$OptionsGUI_GeneralGB_hWnd
        || v$OptionsGUI_GeneralGB
   ,General

gui Add
   ,Edit
   ,xp+10 yp+20
        || Hidden
   ,Dummy
        ;-- Used to establish height for the rest of the controls on group box

gui Add
   ,CheckBox
   ,xp hp
        || Checked%$OptionsGUI_ShellContextMenu%
        || v$OptionsGUI_ShellContextMenu
   ,Integrate %$ScriptName% Into Shell Context Menu

;-- Disable if running script
if not A_IsCompiled
    GUIControl Disable,$OptionsGUI_ShellContextMenu

gui Add
   ,CheckBox
   ,y+0 hp
        || Checked%$AlwaysOnTop%
        || v$OptionsGUI_AlwaysOnTop
   ,Always On Top

gui Add
   ,CheckBox
   ,y+0 hp
        || Section
        || Checked%$ShowMenubar%
        || v$OptionsGUI_ShowMenubar
   ,Show Menu Bar

gui Add
   ,CheckBox
   ,y+0 hp
        || Checked%$ShowToolbar%
        || v$OptionsGUI_ShowToolbar
   ,Show Toolbar.    Icons:%A_Space%

gui Add
   ,Radio
   ,x+0 hp
        || Checked%$OptionsGUI_ToolbarLargeIcons%
        || v$OptionsGUI_ToolbarLargeIcons
   ,Large %A_Space%

gui Add
   ,Radio
   ,x+0 hp
        || Checked%$OptionsGUI_ToolbarSmallIcons%
        || v$OptionsGUI_ToolbarSmallIcons
   ,Small

gui Add
   ,CheckBox
   ,xs y+0 hp
        || Checked%$ShowStatusbar%
        || v$OptionsGUI_ShowStatusbar
   ,Show Status Bar

gui Add
   ,CheckBox
   ,y+0 hp
        || Checked%$EscapeToExit%
        || v$OptionsGUI_EscapeToExit
   ,Escape to Exit

;-- Resize the General group box
GUIControlGet $Group1Pos,Pos,$OptionsGUI_GeneralGB
GUIControlGet $Group2Pos,Pos,$OptionsGUI_EscapeToExit
outputdebug $Group2PosY=%$Group2PosY%, $Group2PosH=%$Group2PosH%
GUIControl
    ,Move
    ,$OptionsGUI_GeneralGB
    ,% "h" . ($Group2PosY-$Group1PosY)+$Group2PosH+10

;---------------
;-- Tab: Editor
;---------------
gui Tab,Editor
gui Add
   ,GroupBox
   ,xm+10 y40 w400 h10
        || hWnd$OptionsGUI_EditorGB_hWnd
        || v$OptionsGUI_EditorGB
   ,Editor

gui Add
   ,Edit
   ,xp+10 yp+20
        || Section
        || Hidden
   ,Dummy
        ;-- Used to establish height for the rest of the controls on group box

gui Add
   ,Text
   ,xp w100 hp
   ,Font:

gui Add
   ,Edit
   ,x+0 w250 r1
        || +ReadOnly
        || v$OptionsGUI_Font
   ,%$Font%

gui Add
   ,Button
   ,x+0 hp
        || v$OptionsGUI_SelectFont
        || gOptionsGUI_SelectFont
   ,...

gui Add
   ,Text
   ,xs y+0 w100 hp
   ,Font Size:

gui Add
   ,Edit
   ,x+0 w50 hp
        || v$OptionsGUI_FontSize

gui Add
   ,UpDown
   ,Range%$MinimumFontSize%-%$MaximumFontSize%
   ,%$FontSize%

gui Add
   ,Text
   ,xs y+0 w100 hp
   ,Tab Width:

gui Add
   ,Edit
   ,x+0 w50 hp
        || v$OptionsGUI_TabWidth

gui Add
   ,UpDown
   ,Range1-50
   ,%$TabWidth%


gui Add
   ,CheckBox
   ,x+10 hp
        || Checked%$RealTabs%
        || v$OptionsGUI_RealTabs
   ,Real Tabs

gui Add
   ,Text
   ,xs y+0 w100 hp
   ,Blk Comment:

gui Add
   ,Edit
   ,x+0 w100 hp
        || v$OptionsGUI_BlockComment
   ,%$BlockComment%

gui Add
   ,CheckBox
   ,xs y+2 hp
        || Checked%$AutoIndent%
        || v$OptionsGUI_AutoIndent
   ,Auto Indent

gui Add
   ,CheckBox
   ,y+0 hp
        || Checked%$LineNumbersBar%
        || v$OptionsGUI_LineNumbersBar
   ,Line Numbers Bar

gui Add
   ,CheckBox
   ,y+0 hp
        || Checked%$AllowUndoAfterSave%
        || v$OptionsGUI_AllowUndoAfterSave
   ,Allow Undo After Save

;-- Resize the Editor group box
GUIControlGet $Group1Pos,Pos,$OptionsGUI_EditorGB
GUIControlGet $Group2Pos,Pos,$OptionsGUI_AllowUndoAfterSave
GUIControl
    ,Move
    ,$OptionsGUI_EditorGB
    ,% "h" . ($Group2PosY-$Group1PosY)+$Group2PosH+10

;-- External Editor
gui Add
   ,GroupBox
   ,xm+10 y+10 w400 h10
        || hWnd$OptionsGUI_ExtEditorGB_hWnd
        || v$OptionsGUI_ExtEditorGB
   ,External Editor

gui Add
   ,Edit
   ,xp+10 yp+20
        || Section
        || Hidden
   ,Dummy
        ;-- Used to establish height for the rest of the controls on group box

gui Add
   ,Text
   ,xp w50 hp
   ,Name:

gui Add
   ,Edit
   ,x+0 w300 hp
        || hWnd$OptionsGUI_ExtEditorName_hWnd
        || v$OptionsGUI_ExtEditorName
   ,%$ExtEditorName%

gui Add
   ,Text
   ,xs y+0 w50 hp
   ,Path:

gui Add
   ,Edit
   ,x+0 w300 hp
        || hWnd$OptionsGUI_ExtEditorPath_hWnd
        || v$OptionsGUI_ExtEditorPath
   ,%$ExtEditorPath%

gui Add
   ,Button
   ,x+0 hp
        || hWnd$OptionsGUI_BrowseEditorPath_hWnd
        || v$OptionsGUI_BrowseEditorPath
        || gOptionsGUI_BrowseEditorPath
   ,...

;-- Resize the External Editor group box
GUIControlGet $Group1Pos,Pos,$OptionsGUI_ExtEditorGB
GUIControlGet $Group2Pos,Pos,$OptionsGUI_BrowseEditorPath
GUIControl
    ,Move
    ,$OptionsGUI_ExtEditorGB
    ,% "h" . ($Group2PosY-$Group1PosY)+$Group2PosH+10

;------------
;-- Tab: Run
;------------
gui Tab,Run
gui Add
   ,GroupBox
   ,xm+10 y40 w400 h10
        || hWnd$OptionsGUI_RunGB_hWnd
        || v$OptionsGUI_RunGB
   ,Run

gui Add
   ,Text
   ,xp+10 yp+20
   ,AutoHotkey Path`n(Leave blank to use registered path)

gui Add
   ,Edit
   ,xm+20 y+0 w350
        || Section
        || hWnd$OptionsGUI_AutoHotkeyPath_hWnd
        || v$OptionsGUI_AutoHotkeyPath
   ,%$AutoHotkeyPath%
        ;-- This control is used to establish height for the rest of the
        ;   controls on group box

gui Add
   ,Button
   ,x+0 hp
        || hWnd$OptionsGUI_BrowseAutoHotkeyPath_hWnd
        || v$OptionsGUI_BrowseAutoHotkeyPath
        || gOptionsGUI_BrowseAutoHotkeyPath
   ,...

gui Add
   ,CheckBox
   ,xs y+0 hp
        || Checked%$RunPrompt%
        || v$OptionsGUI_RunPrompt
   ,%s_RunPrompt_MI%

gui Add
   ,CheckBox
   ,y+0 hp
        || Checked%$RunDebug%
        || v$OptionsGUI_RunDebug
   ,%s_RunDebug_MI%

gui Add
   ,CheckBox
   ,y+0 hp
        || Checked%$RunWait%
        || v$OptionsGUI_RunWait
   ,%s_RunWait_MI%

gui Add
   ,CheckBox
   ,y+0 hp
        || Checked%$ConfirmExitIfRunning%
        || v$OptionsGUI_ConfirmExitIfRunning
   ,Confirm Exit if Script(s) Are Still Running

;-- Resize the group box
GUIControlGet $Group1Pos,Pos,$OptionsGUI_RunGB
GUIControlGet $Group2Pos,Pos,$OptionsGUI_ConfirmExitIfRunning
GUIControl
    ,Move
    ,$OptionsGUI_RunGB
    ,% "h" . ($Group2PosY-$Group1PosY)+$Group2PosH+10

gui Add
   ,GroupBox
   ,xs-10 y+10 w400 h10
        || hWnd$OptionsGUI_RunFolderGB_hWnd
        || v$OptionsGUI_RunFolderGB
   ,Run Workspace

gui Add
   ,Edit
   ,xp+10 yp+20
        || Section
        || Hidden
   ,Dummy
        ;-- Used to establish height for the rest of the controls on group box

gui Add
   ,CheckBox
   ,xp hp
        || Checked%$ClearRunWorkspaceOnRun%
        || v$OptionsGUI_ClearRunWorkspaceOnRun
   ,Clear Run Workspace Before Every Run

gui Add
   ,CheckBox
   ,y+0 hp
        || Checked%$ClearRunWorkspaceOnExit%
        || v$OptionsGUI_ClearRunWorkspaceOnExit
   ,Clear Run Workspace on Exit

gui Add
   ,Button
   ,y+5 w90 hp
        || Disabled
        || v$OptionsGUI_ClearRunWorkspace
        || gOptionsGUI_ClearRunWorkspace
   ,Clear Now

gui Add
   ,Button
   ,x+5 wp hp
        || Disabled
        || v$OptionsGUI_ExploreRunFolder
        || gOptionsGUI_ExploreRunFolder
   ,Explore

;-- Enable if "Run" folder exists
IfExist %$RunDir%\.
    {
    GUIControl Enable,$OptionsGUI_ClearRunWorkspace
    GUIControl Enable,$OptionsGUI_ExploreRunFolder
    }

;-- Resize the Run Folder group box
GUIControlGet $Group1Pos,Pos,$OptionsGUI_RunFolderGB
GUIControlGet $Group2Pos,Pos,$OptionsGUI_ExploreRunFolder
GUIControl
    ,Move
    ,$OptionsGUI_RunFolderGB
    ,% "h" . ($Group2PosY-$Group1PosY)+$Group2PosH+10

;----------------
;-- Tab: Restore
;----------------
gui Tab,Restore
gui Add
   ,GroupBox
   ,xm+10 y40 w400 h10
        || hWnd$OptionsGUI_RPViewerGB_hWnd
        || v$OptionsGUI_RPViewerGB
   ,Restore Point Viewer

gui Add
   ,Edit
   ,xp+10 yp+20
        || Section
        || Hidden
   ,Dummy
        ;-- Used to establish height for the rest of the controls on group box

gui Add
   ,Text
   ,xp w80 hp
   ,Font:

gui Add
   ,Edit
   ,x+0 w250 hp
        || +ReadOnly
        || v$OptionsGUI_RPViewerFont
   ,%$RPViewerFont%

gui Add
   ,Button
   ,x+0 hp
        || v$OptionsGUI_SelectRPViewerFont
        || gOptionsGUI_SelectRPViewerFont
   ,...

gui Add
   ,Text
   ,xs y+0 w80 hp
   ,Font size:

gui Add
   ,Edit
   ,x+0 w50 hp
        || v$OptionsGUI_RPViewerFontSize

gui Add
   ,UpDown
   ,Range%$MinimumFontSize%-%$MaximumFontSize%
   ,%$RPViewerFontSize%

gui Add
   ,CheckBox
   ,xs y+0 hp
        || Checked%$RPViewerLineNumbersBar%
        || v$OptionsGUI_RPViewerLineNumbersBar
   ,Line Numbers Bar

gui Add
   ,Checkbox
   ,xs y+0 hp
        || Checked%$RPViewerSaveWindowPos%
        || v$OptionsGUI_RPViewerSaveWindowPos
   ,Save Window Position

gui Add
   ,Checkbox
   ,xs y+0 hp
        || Checked%$RPViewerCloseOnRestore%
        || v$OptionsGUI_RPViewerCloseOnRestore
   ,Close Window on Restore

gui Add
   ,Checkbox
   ,xs y+0 hp
        || Checked%$RPViewerEscapeToClose%
        || v$OptionsGUI_RPViewerEscapeToClose
   ,Escape to Close

;-- Resize the RPViewer group box
GUIControlGet $Group1Pos,Pos,$OptionsGUI_RPViewerGB
GUIControlGet $Group2Pos,Pos,$OptionsGUI_RPViewerEscapeToClose
GUIControl
    ,Move
    ,$OptionsGUI_RPViewerGB
    ,% "h" . ($Group2PosY-$Group1PosY)+$Group2PosH+10

gui Add
   ,GroupBox
   ,xs-10 y+10 w400 h10
        || hWnd$OptionsGUI_RestoreGB_hWnd
        || v$OptionsGUI_RestoreGB
   ,Restore Options

gui Add
   ,Edit
   ,xp+10 yp+20
        || Section
        || Hidden
   ,Dummy
        ;-- Used to establish height for the rest of the controls on group box

gui Add
   ,Text
   ,xp hp
   ,Maximum restore points:

gui Add
   ,Edit
   ,x+5 w50 hp ; r5
        || v$OptionsGUI_MaxRestorePoints
gui Add
   ,UpDown
   ,Range1-999
   ,%$MaxRestorePoints%

$RPCount:=0
Loop %$RPDir%\*.ahk
    $RPCount++

gui Add
   ,Text
   ,x+5 w50 hp
   ,%$RPCount%

gui Add
   ,CheckBox
   ,xs y+0 hp
        || Checked%$CreateRPOnCopyfromDrop%
        || v$OptionsGUI_CreateRPOnCopyfromDrop
   ,Create Restore Point on "Copy From..." or Drop File

gui Add
   ,CheckBox
   ,y+0 hp
        || Checked%$CreateRPOnRun%
        || v$OptionsGUI_CreateRPOnRun
   ,Create Restore Point on Run

gui Add
   ,CheckBox
   ,y+0 hp
        || Checked%$CreateRPOnSave%
        || v$OptionsGUI_CreateRPOnSave
   ,Create Restore Point on Save

gui Add
   ,CheckBox
   ,y+0 hp
        || Checked%$CreateRPOnExit%
        || v$OptionsGUI_CreateRPOnExit
   ,Create Restore Point on Exit

gui Add
   ,Button
   ,y+5 w90 hp
        || v$OptionsGUI_ClearRestoreFolder
        || gOptionsGUI_ClearRestoreFolder
   ,Clear Now

gui Add
   ,Button
   ,x+5 wp hp
        || v$OptionsGUI_ExploreRestoreFolder
        || gOptionsGUI_ExploreRestoreFolder
   ,Explore


;-- Disable buttons if "Restore" folder does not exist
IfNotExist %$RPDir%\.
    {
    GUIControl Disable,$OptionsGUI_ClearRestoreFolder
    GUIControl Disable,$OptionsGUI_ExploreRestoreFolder
    }

;-- Resize the Restore group box
GUIControlGet $Group1Pos,Pos,$OptionsGUI_RestoreGB
GUIControlGet $Group2Pos,Pos,$OptionsGUI_ExploreRestoreFolder
GUIControl
    ,Move
    ,$OptionsGUI_RestoreGB
    ,% "h" . ($Group2PosY-$Group1PosY)+$Group2PosH+10

;------------
;-- Tab: New
;------------
gui Tab,New
gui Add
   ,CheckBox
   ,xm+10 y40
        || Checked%$NewScriptSystemDefault%
        || v$OptionsGUI_NewScriptSystemDefault
        || gOptionsGUI_NewScriptSystemDefault_Action
   ,Use System Default (Template.ahk)

gui Add
   ,GroupBox
   ,xm+10 y70 w400 h370
        || hWnd$OptionsGUI_NewScriptGB_hWnd
        || v$OptionsGUI_NewScriptGB
   ,New Script

;-- Set font/size
if $Font
    gui Font,,%$Font%

if $FontSize
    gui Font,s%$FontSize%

;-- Edit field
gui Add
   ,Edit
   ,xp+10 yp+20 w380 h340
        || +0x100000    ;-- WS_HSCROLL
        || -Wrap
        || hWnd$OptionsGUI_NewScript_hWnd
        || v$OptionsGUI_NewScript
   ,%$NewScript%

;-- Reset font/size
gui Font

;-- Disable new script?
if $NewScriptSystemDefault
    GUIControl Disable,$OptionsGUI_NewScript

;--------------
;-- Tab: Debug
;--------------
gui Tab,Debug
gui Add
   ,GroupBox
   ,xm+10 y40 w400 h400
        || hWnd$OptionsGUI_DebugScriptGB_hWnd
        || v$OptionsGUI_DebugScriptGB
   ,Debug Script

;-- Set font/size
if $Font
    gui Font,,%$Font%

if $FontSize
    gui Font,s%$FontSize%

;-- Edit field
gui Add
   ,Edit
   ,xp+10 yp+20 w380 h370
        || +0x100000    ;-- WS_HSCROLL
        || -Wrap
        || hWnd$OptionsGUI_DebugScript_hWnd
        || v$OptionsGUI_DebugScript
   ,%$DebugScript%

;-- Reset font/size
gui Font

;-- End of tabs
gui Tab

;-- Select last-used tab
if $OptionsGUI_Tab is not Space
    GUIControl Choose,$OptionsGUI_Tab,%$OptionsGUI_Tab%

;-----------
;-- Buttons
;-----------
gui Add
   ,Button
   ,xm y460 w70 h30
        || hWnd$OptionsGUI_SaveButton_hWnd
        || v$OptionsGUI_SaveButton
        || gOptionsGUI_SaveButton
   ,&Save

gui Add
   ,Button
   ,x+05 wp hp
        || hWnd$OptionsGUI_CancelButton_hWnd
        || v$OptionsGUI_CancelButton
        || gOptionsGUI_Close
   ,Cancel

;-- Set focus
GUIControl Focus,$OptionsGUI_CancelButton

;[==========]
;[  Attach  ]
;[==========]
Attach($OptionsGUI_Tab_hWnd                 ,"w h")
Attach($OptionsGUI_GeneralGB_hWnd           ,"w h")
Attach($OptionsGUI_EditorGB_hWnd            ,"w")
Attach($OptionsGUI_ExtEditorGB_hWnd         ,"w")
Attach($OptionsGUI_ExtEditorName_hWnd       ,"w")
Attach($OptionsGUI_ExtEditorPath_hWnd       ,"w")
Attach($OptionsGUI_BrowseEditorPath_hWnd    ,"x")
Attach($OptionsGUI_RunGB_hWnd               ,"w")
Attach($OptionsGUI_AutoHotkeyPath_hWnd      ,"w")
Attach($OptionsGUI_BrowseAutoHotkeyPath_hWnd,"x")
Attach($OptionsGUI_RunFolderGB_hWnd         ,"w")
Attach($OptionsGUI_RPViewerGB_hWnd          ,"w")
Attach($OptionsGUI_RestoreGB_hWnd           ,"w")
Attach($OptionsGUI_SaveButton_hWnd          ,"y")
Attach($OptionsGUI_CancelButton_hWnd        ,"y")
Attach($OptionsGUI_NewScriptGB_hWnd         ,"w h")
Attach($OptionsGUI_NewScript_hWnd           ,"w h")
Attach($OptionsGUI_DebugScriptGB_hWnd       ,"w h")
Attach($OptionsGUI_DebugScript_hWnd         ,"w h")

;[============]
;[  Show it!  ]
;[============]
;-- Render but don't display
gui Show,Hide,Options

;-- Calculate X/Y and Show it
PopupXY($QAHKGUI,$OptionsGUI,$PosX,$PosY)
gui Show,x%$PosX% y%$PosY%
return


;**********************
;*                    *
;*         Tab        *
;*    (OptionsGUI)    *
;*                    *
;**********************
OptionsGUI_Tab:
GUIControlGet $OptionsGUI_Tab,,$OptionsGUI_Tab  ;-- Collect the current tab
return


;**********************
;*                    *
;*     Select font    *
;*    (OptionsGUI)    *
;*                    *
;**********************
OptionsGUI_SelectFont:

;-- Collect form data
gui Submit,NoHide

;[==============]
;[  Initialize  ]
;[==============]
$OptionsGUI_FontStyle:="s" . $OptionsGUI_FontSize . A_Space . $FontStyle

;[==========]
;[  Select  ]
;[==========]
if not Dlg_Font($OptionsGUI_Font,$OptionsGUI_FontStyle,Dummy,False,$OptionsGUI_hWnd)
    return

;-- Extract font size, rebuild $OptionsGUI_FontStyle
t_FontStyle :=""
Loop Parse,$OptionsGUI_FontStyle,%A_Space%
    {
    if A_LoopField is Space
        Continue

    ;-- Font size
    if SubStr(A_LoopField,1,1)="s"
        {
        StringTrimLeft $OptionsGUI_FontSize,A_LoopField,1
        Continue
        }

    if t_FontStyle is Space
        t_FontStyle:=A_LoopField
     else
        t_FontStyle:=t_FontStyle . A_Space . A_LoopField
    }

$OptionsGUI_FontStyle:=t_FontStyle

;[========================]
;[  Refresh GUI controls  ]
;[========================]
GUIControl,,$OptionsGUI_Font,%$OptionsGUI_Font%
GUIControl,,$OptionsGUI_FontSize,%$OptionsGUI_FontSize%
return


;****************************
;*                          *
;*    Browse editor path    *
;*       (OptionsGUI)       *
;*                          *
;****************************
OptionsGUI_BrowseEditorPath:

;-- Attach dialogs and messages to the current GUI
gui +OwnDialogs

;-- Collect form data
gui Submit,NoHide

;[==============]
;[  Initialize  ]
;[==============]
;-- AutoTrim
$OptionsGUI_ExtEditorPath=%$OptionsGUI_ExtEditorPath%


;-- Remove leading and trailing double quotes (if they both exist)
 if SubStr($OptionsGUI_ExtEditorPath,1,1)=""""
and SubStr($OptionsGUI_ExtEditorPath,0)=""""
    $OptionsGUI_ExtEditorPath:=SubStr($OptionsGUI_ExtEditorPath,2,-1)

;-- If empty, set to A_ProgramFiles
if $OptionsGUI_ExtEditorPath is Space
    $OptionsGUI_ExtEditorPath:=A_ProgramFiles . "\"
 else
    {
    ;-- Else if the program doesn't exist, set to A_ProgramFiles
    IfNotExist %$OptionsGUI_ExtEditorPath%
        $OptionsGUI_ExtEditorPath:=A_ProgramFiles . "\"
    }

;[=================]
;[  Browse for it  ]
;[=================]
FileSelectFile
    ,$OptionsGUI_ExtEditorPath                  ;-- OutputVar
    ,1                                          ;-- Options. 1=File Must Exist
    ,%$OptionsGUI_ExtEditorPath%                ;-- RootDir\Filename
    ,Select Editor Program:                     ;-- Prompt
    ,Program (*.exe)                            ;-- Filter

;-- Anything selected?
if ErrorLevel
    return

;[=======================]
;[  Refresh GUI control  ]
;[=======================]
GUIControl,,$OptionsGUI_ExtEditorPath,%$OptionsGUI_ExtEditorPath%
return


;***************************************
;*                                     *
;*    NewScriptSystemDefault action    *
;*             (OptionsGUI)            *
;*                                     *
;***************************************
OptionsGUI_NewScriptSystemDefault_Action:

;-- Get current value
GUIControlGet
    ,$OptionsGUI_NewScriptSystemDefault
    ,
    ,$OptionsGUI_NewScriptSystemDefault


;-- Enable/Disable "New Script" control
if $OptionsGUI_NewScriptSystemDefault
    GUIControl Disable,$OptionsGUI_NewScript
 else
    GUIControl Enable,$OptionsGUI_NewScript

return


;********************************
;*                              *
;*    Browse AutoHotkey path    *
;*         (OptionsGUI)         *
;*                              *
;********************************
OptionsGUI_BrowseAutoHotkeyPath:

;-- Attach dialogs and messages to the current GUI
gui +OwnDialogs

;-- Collect form data
gui Submit,NoHide

;[==============]
;[  Initialize  ]
;[==============]
;-- AutoTrim
$OptionsGUI_AutoHotkeyPath=%$OptionsGUI_AutoHotkeyPath%

;-- Remove leading and trailing double quotes (if they both exist)
 if SubStr($OptionsGUI_AutoHotkeyPath,1,1)=""""
and SubStr($OptionsGUI_AutoHotkeyPath,0)=""""
    $OptionsGUI_AutoHotkeyPath:=SubStr($OptionsGUI_AutoHotkeyPath,2,-1)

;-- If empty, set to A_ProgramFiles
if $OptionsGUI_AutoHotkeyPath is Space
    $OptionsGUI_AutoHotkeyPath:=A_ProgramFiles . "\"
 else
    {
    ;-- Else if the program doesn't exist, set to A_ProgramFiles
    IfNotExist %$OptionsGUI_AutoHotkeyPath%
        $OptionsGUI_AutoHotkeyPath:=A_ProgramFiles . "\"
    }

;[=================]
;[  Browse for it  ]
;[=================]
FileSelectFile
    ,$OptionsGUI_AutoHotkeyPath                 ;-- OutputVar
    ,1                                          ;-- Options. 1=File Must Exist
    ,%$OptionsGUI_AutoHotkeyPath%               ;-- RootDir\Filename
    ,Select AutoHotkey Program:                 ;-- Prompt
    ,Program (*.exe)                            ;-- Filter

;-- Anything selected?
if ErrorLevel
    return

;[=======================]
;[  Refresh GUI control  ]
;[=======================]
GUIControl,,$OptionsGUI_AutoHotkeyPath,%$OptionsGUI_AutoHotkeyPath%
return


;*****************************
;*                           *
;*    Clear Run workspace    *
;*        (OptionsGUI)       *
;*                           *
;*****************************
OptionsGUI_ClearRunWorkspace:

;-- Attach messages to the current GUI
gui +OwnDialogs

;--  Script(s) running?
$RunPIDList:=RebuildRunPIDList($RunPIDList)
if StrLen($RunPIDList)
    {
    MsgBox
        ,16  ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Clear Run Workspace Error,
           (ltrim join`s
            One or more scripts are still running.  Please stop all running
            scripts before attempting to clear the Run workspace.  %A_Space%
           )

    ;-- Bounce
    return
    }

;-- Confirm
MsgBox
    ,49     ;-- 49 = 1 (OK/Cancel buttons) + 48 ("!" icon)
    ,Clear Run Workspace,
       (ltrim join`s
        All files and folders in the Run workspace will be deleted.  Press OK to
        proceed.  %A_Space%
       )

IfMsgBox Cancel
    return

;-- Delete "Run" Folder
gosub DeleteRunFolder

;-- Disable buttons if "Run" folder has been deleted
IfNotExist %$RunDir%\.
    {
    GUIControl Disable,$OptionsGUI_ClearRunWorkspace
    GUIControl Disable,$OptionsGUI_ExploreRunFolder
    }

return


;****************************
;*                          *
;*    Explore Run folder    *
;*       (OptionsGUI)       *
;*                          *
;****************************
OptionsGUI_ExploreRunFolder:

;-- Attach messages to current GUI
gui +OwnDialogs

;-- Run folder exists?
IfNotExist %$RunDir%\.  ;-- Test s/b redundant but remains as a fail-safe.
    {
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Explore Error
        ,The Run workspace does not exist:  `n%$RunDir%\  %A_Space%

    return
    }

;-- Open Windows Explorer to the "Run" folder
Run explorer.exe /e`,"%$RunDir%",,UseErrorLevel
if ErrorLevel
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Explore Error
        ,% SystemMessage(A_LastError)

return


;************************************
;*                                  *
;*    Select Restore Viewer font    *
;*           (OptionsGUI)           *
;*                                  *
;************************************
OptionsGUI_SelectRPViewerFont:

;-- Collect form data
gui Submit,NoHide

;[==============]
;[  Initialize  ]
;[==============]
$OptionsGUI_RPViewerFontStyle:="s" . $OptionsGUI_RPViewerFontSize . A_Space . $RPViewerFontStyle

;[==========]
;[  Select  ]
;[==========]
if not Dlg_Font($OptionsGUI_RPViewerFont,$OptionsGUI_RPViewerFontStyle,Dummy,0,$OptionsGUI_hWnd)
    return

;-- Extract font size, rebuild $OptionsGUI_RPViewerFontStyle
t_FontStyle :=""
Loop Parse,$OptionsGUI_RPViewerFontStyle,%A_Space%
    {
    if A_LoopField is Space
        Continue

    ;-- Font size
    if SubStr(A_LoopField,1,1)="s"
        {
        StringTrimLeft $OptionsGUI_RPViewerFontSize,A_LoopField,1
        Continue
        }

    if t_FontStyle is Space
        t_FontStyle:=A_LoopField
     else
        t_FontStyle:=t_FontStyle . A_Space . A_LoopField
    }

$OptionsGUI_RPViewerFontStyle:=t_FontStyle

;[========================]
;[  Refresh GUI controls  ]
;[========================]
GUIControl,,$OptionsGUI_RPViewerFont,%$OptionsGUI_RPViewerFont%
GUIControl,,$OptionsGUI_RPViewerFontSize,%$OptionsGUI_RPViewerFontSize%
return


;******************************
;*                            *
;*    Clear Restore folder    *
;*        (OptionsGUI)        *
;*                            *
;******************************
OptionsGUI_ClearRestoreFolder:

;-- Attach messages to current GUI
gui +OwnDialogs

;-- Confirm
MsgBox
    ,49     ;-- 49 = 1 (OK/Cancel buttons) + 48 ("!" icon)
    ,Confirm Delete
    ,All restore points will be deleted.  Press OK to proceed.  %A_Space%

IfMsgBox Cancel
    return

;-- Delete "Restore" folder
gosub DeleteRestoreFolder

;-- Disable buttons if "Restore" folder has been deleted
IfNotExist %$RPDir%\.
    {
    GUIControl Disable,$OptionsGUI_ClearRestoreFolder
    GUIControl Disable,$OptionsGUI_ExploreRestoreFolder
    }

;-- RPViewerGUI window open?
IfWinExist ahk_id %$RPViewerGUI_hWnd%
    {
    ;-- Change default GUI
    gui %$RPViewerGUI%:Default

    ;-- Update RPViewerGUI
    LV_Delete()                                     ;-- Clear ListView
    GUIControl Disable,$RPViewerGUI_RestoreButton   ;-- Disable Restore button
    HE_CloseFile($RPViewerGUI_hEdit)                ;-- Close last opened file

    ;-- Reset default GUI
    gui %$OptionsGUI%:Default
    }

return


;********************************
;*                              *
;*    Explore Restore folder    *
;*         (OptionsGUI)         *
;*                              *
;*********************************
OptionsGUI_ExploreRestoreFolder:

;-- Attach messages to current GUI
gui +OwnDialogs

;-- Restore folder exists?
IfNotExist %$RPDir%\.  ;-- Test s/b redundant but remains as a fail-safe.
    {
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Explore Error
        ,The "Restore" folder does not exist:  `n%$RPDir%\  %A_Space%

    return
    }

;-- Open Windows Explorer to the "Restore" folder
Run explorer.exe /e`,"%$RPDir%",,UseErrorLevel
if ErrorLevel
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Explore Error
        ,% SystemMessage(A_LastError)

return


;**********************
;*                    *
;*     Save button    *
;*    (OptionsGUI)    *
;*                    *
;**********************
OptionsGUI_SaveButton:

;-- Attach any messages to the current GUI
gui +OwnDialogs

;-- Collect form variables
gui Submit,NoHide

;[====================]
;[  Check for errors  ]
;[====================]
;-- Editor path
$OptionsGUI_ExtEditorPath=%$OptionsGUI_ExtEditorPath%  ;-- AutoTrim
if $OptionsGUI_ExtEditorPath is not Space
    {
    ;-- Remove leading and trailing double quotes (if they both exist)
    if SubStr($OptionsGUI_ExtEditorPath,1,1)=""""
   and SubStr($OptionsGUI_ExtEditorPath,0)=""""
        $OptionsGUI_ExtEditorPath:=SubStr($OptionsGUI_ExtEditorPath,2,-1)

    ;-- Program exist?
    IfNotExist %$OptionsGUI_ExtEditorPath%
        {
        ;-- Set to Editor tab
        GUIControl Choose,$OptionsGUI_Tab,Editor

        ;-- Error message
        MsgBox
            ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,Options Error
            ,External editor program not found.  Please redefine.  %A_Space%

        return
        }
    }

;-- AutoHotkey path
$OptionsGUI_AutoHotkeyPath=%$OptionsGUI_AutoHotkeyPath%  ;-- AutoTrim
if $OptionsGUI_AutoHotkeyPath is not Space
    {
    ;-- Remove leading and trailing double quotes (if they both exist)
    if SubStr($OptionsGUI_AutoHotkeyPath,1,1)=""""
   and SubStr($OptionsGUI_AutoHotkeyPath,0)=""""
        $OptionsGUI_AutoHotkeyPath:=SubStr($OptionsGUI_AutoHotkeyPath,2,-1)

    ;-- Program exist?
    IfNotExist %$OptionsGUI_AutoHotkeyPath%
        {
        ;-- Set to Run tab
        GUIControl Choose,$OptionsGUI_Tab,Run

        ;-- Error message
        MsgBox
            ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,Options Error
            ,Autohotkey program not found.  %A_Space%

        return
        }
    }

;[======================]
;[  Shell context menu  ]
;[======================]
if A_IsCompiled
    {
    ;-- Only proceed if .ahk is registered
    RegRead
        ,$DocumentType
        ,HKEY_CLASSES_ROOT
        ,.ahk

    if not ErrorLevel
        {
        ;-- Create shell context menu item if it doesn't already exist
        if $OptionsGUI_ShellContextMenu
            {
            ;-- Look for custom command
            RegRead
                ,$Dummy
                ,HKEY_CLASSES_ROOT
                ,%$DocumentType%\shell\Open with %$ScriptName%\command

            ;-- Does not exist: Create it!
            if ErrorLevel
                {
                ;-- Parent key
                RegWrite
                    ,REG_SZ
                    ,HKEY_CLASSES_ROOT
                    ,%$DocumentType%\shell\Open with %$ScriptName%
                    ,
                    ,Open with %$ScriptName%...

                ;-- Command
                RegWrite
                    ,REG_SZ
                    ,HKEY_CLASSES_ROOT
                    ,%$DocumentType%\shell\Open with %$ScriptName%\command
                    ,
                    ,"%A_ScriptFullPath%" "`%1"

                if ErrorLevel
                    {
                    MsgBox
                        ,262160
                            ;-- 262208=0 (OK button) + 16 (Error icon) + 262144 (AOT)
                        ,Shell Context Menu Error
                        ,Shell context menu NOT created.  %A_Space%
                    }
                }
            }
         else
            {
            ;-- Exists?
            RegRead
                ,$Dummy
                ,HKEY_CLASSES_ROOT
                ,%$DocumentType%\shell\Open with %$ScriptName%

            if not ErrorLevel
                {
                ;-- Remove custom command (only need to delete parent key)
                RegDelete
                    ,HKEY_CLASSES_ROOT
                    ,%$DocumentType%\shell\Open with %$ScriptName%

                if ErrorLevel
                    MsgBox
                        ,262160
                            ;-- 262208=0 (OK button) + 16 (Error icon) + 262144 (AOT)
                        ,Shell Context Menu Error
                        ,Shell context menu NOT deleted.  %A_Space%
                }
            }
        }
    }

;[===========================]
;[  Update general settings  ]
;[===========================]
;-- AOT
if ($OptionsGUI_AlwaysOnTop<>$AlwaysOnTop)
    {
    gosub QAHKGUI_ToggleAlwaysOnTop

    ;-- Reset GUI default
    gui %$OptionsGUI%:Default
        ;-- Programming note:  Resetting the GUI default is necessary because
        ;   the QAHKGUI_ToggleAlwaysOnTop routine sets the GUI default to the
        ;   primary GUI so that the status bar for the primary GUI can be
        ;   updated.
    }

;-- Menu bar
if ($OptionsGUI_ShowMenubar<>$ShowMenuBar)
    gosub QAHKGUI_ToggleMenubar

;-- Toolbar
if ($OptionsGUI_ShowToolbar<>$ShowToolbar)
    gosub QAHKGUI_ToggleToolbar

;-- Menu
if ($OptionsGUI_ClearRunWorkspaceOnRun<>$ClearRunWorkspaceOnRun)
    Menu QAHKGUI_RunMenu,ToggleCheck,%s_ClearRunWorkspaceOnRun_MI%

if ($OptionsGUI_ClearRunWorkspaceOnExit<>$ClearRunWorkspaceOnExit)
    Menu QAHKGUI_RunMenu,ToggleCheck,%s_ClearRunWorkspaceOnExit_MI%

;-- Toolbar icon size
if $OptionsGUI_ToolbarLargeIcons
    $OptionsGUI_ToolbarIconSize=Large
 else
    $OptionsGUI_ToolbarIconSize=Small

if ($OptionsGUI_ToolbarIconSize<>$ToolbarIconSize)
    gosub QAHKGUI_ToggleToolbarIconSize

;-- Status bar
if ($OptionsGUI_ShowStatusbar<>$ShowStatusbar)
    gosub QAHKGUI_ToggleStatusbar

;-- Line numbers bar
if ($OptionsGUI_LineNumbersBar<>$LineNumbersBar)
    gosub QAHKGUI_ToggleLineNumbersBar

;-- RunPrompt
if ($OptionsGUI_RunPrompt<>$RunPrompt)
    gosub QAHKGUI_ToggleRunPrompt

;-- RunDebug
if ($OptionsGUI_RunDebug<>$RunDebug)
    gosub QAHKGUI_ToggleRunDebug

;-- RunWait
if ($OptionsGUI_RunWait<>$RunWait)
    gosub QAHKGUI_ToggleRunWait

;[==========================]
;[  Update window settings  ]
;[==========================]
;--------
;-- Font
;--------
if ($OptionsGUI_Font<>$Font
or  $OptionsGUI_FontSize<>$FontSize
or  $OptionsGUI_FontStyle<>$FontStyle)
    HE_SetFont($QAHKGUI_hEdit,"s" . $OptionsGUI_FontSize . A_Space . $OptionsGUI_FontStyle . "," . $OptionsGUI_Font)

;-------------
;-- Tab width
;-------------
if ($OptionsGUI_TabWidth<>$TabWidth)
    HE_SetTabWidth($QAHKGUI_hEdit,$OptionsGUI_TabWidth)

;---------------
;-- Auto indent
;---------------
if ($OptionsGUI_AutoIndent<>$AutoIndent)
    HE_AutoIndent($QAHKGUI_hEdit,$OptionsGUI_AutoIndent)

;------------------------------
;-- RPViewer: Line numbers bar
;------------------------------
if ($OptionsGUI_RPViewerLineNumbersBar<>$RPViewerLineNumbersBar)
    IfWinExist ahk_id %$RPViewerGUI_hWnd%  ;-- RPViewerGUI window open?
        gosub RPViewerGUI_ToggleLineNumbersBar

;----------------------
;-- Max Restore Points
;----------------------
;;;;;if ($OptionsGUI_MaxRestorePoints<>$MaxRestorePoints)
;;;;;    RPTrim($OptionsGUI_MaxRestorePoints)

;-- Programming note: The request to cleanup the RP files here is commented out
;   for now.  This allows to user to make a change, save the change, and then
;   change their mind and change it back.  Superfluous RP files will
;   automatically be purged when a new RP is requested.

;[===========================]
;[  Update global variables  ]
;[===========================]
;-- General
$AlwaysOnTop             :=$OptionsGUI_AlwaysOnTop
$ShowMenubar             :=$OptionsGUI_ShowMenubar
$ShowToolbar             :=$OptionsGUI_ShowToolbar
$ShowStatusbar           :=$OptionsGUI_Showstatusbar

if $OptionsGUI_ToolbarLargeIcons
    $ToolbarIconSize=Large
 else
    $ToolbarIconSize=Small

$EscapeToExit            :=$OptionsGUI_EscapeToExit

;-- Editor
$Font                    :=$OptionsGUI_Font
$FontSize                :=$OptionsGUI_FontSize
$FontStyle               :=$OptionsGUI_FontStyle
$TabWidth                :=$OptionsGUI_TabWidth
$RealTabs                :=$OptionsGUI_RealTabs
$BlockComment            :=$OptionsGUI_BlockComment
$AutoIndent              :=$OptionsGUI_AutoIndent
$LineNumbersBar          :=$OptionsGUI_LineNumbersBar
$AllowUndoAfterSave      :=$OptionsGUI_AllowUndoAfterSave
$ExtEditorName           :=$OptionsGUI_ExtEditorName
$ExtEditorPath           :=$OptionsGUI_ExtEditorPath

;-- Run
$AutoHotkeyPath          :=$OptionsGUI_AutoHotkeyPath
$RunPrompt               :=$OptionsGUI_RunPrompt
$RunDebug                :=$OptionsGUI_RunDebug
$RunWait                 :=$OptionsGUI_RunWait
$ConfirmExitIfRunning    :=$OptionsGUI_ConfirmExitIfRunning
$ClearRunWorkspaceOnRun  :=$OptionsGUI_ClearRunWorkspaceOnRun
$ClearRunWorkspaceOnExit :=$OptionsGUI_ClearRunWorkspaceOnExit

;-- Restore
$RPViewerFont            :=$OptionsGUI_RPViewerFont
$RPViewerFontSize        :=$OptionsGUI_RPViewerFontSize
$RPViewerFontStyle       :=$OptionsGUI_RPViewerFontStyle
$RPViewerLineNumbersBar  :=$OptionsGUI_RPViewerLineNumbersBar
$RPViewerSaveWindowPos   :=$OptionsGUI_RPViewerSaveWindowPos
$RPViewerCloseOnRestore  :=$OptionsGUI_RPViewerCloseOnRestore
$RPViewerEscapeToClose   :=$OptionsGUI_RPViewerEscapeToClose
$MaxRestorePoints        :=$OptionsGUI_MaxRestorePoints
$CreateRPOnCopyfromDrop  :=$OptionsGUI_CreateRPOnCopyfromDrop
$CreateRPOnRun           :=$OptionsGUI_CreateRPOnRun
$CreateRPOnSave          :=$OptionsGUI_CreateRPOnSave
$CreateRPOnExit          :=$OptionsGUI_CreateRPOnExit

;-- New
$NewScriptSystemDefault  :=$OptionsGUI_NewScriptSystemDefault
$NewScript               :=$OptionsGUI_NewScript

;-- Debug
$DebugScript             :=$OptionsGUI_DebugScript

;-- Rebuild $Tab variable
$Tab=
if $RealTabs
    $Tab:="`t"
 else
    Loop % $TabWidth
        $Tab.=A_Space

;-- Return to sender
gosub OptionsGUI_Exit
return


;***********************
;*                     *
;*    Close up shop    *
;*    (OptionsGUI)     *
;*                     *
;***********************
OptionsGUI_Escape:
OptionsGUI_Close:
OptionsGUI_Exit:

;-- Enable parent window
gui %$QAHKGUI%:-Disabled

;-- Destroy window so that it can be used again
gui Destroy
return

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;----------------------------- End OptionsGUI Stuff ----------------------------
;-------------------------------------------------------------------------------





;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;--------------------------- Begin RPViewerGUI stuff ---------------------------
;-------------------------------------------------------------------------------
;*****************************
;*                           *
;*                           *
;*        RPViewerGUI        *
;*                           *
;*                           *
;*****************************
RPViewerGUI:
SetTimer %A_ThisLabel%,Off

;-- Initialize
$RPViewerGUI:=22

;-- Already open?
IfWinExist ahk_id %$RPViewerGUI_hWnd%
    {
    gui %$RPViewerGUI%:Show
    return
    }

;-- Set to full speed just to get started
SetBatchLines -1

;[=============]
;[  Build GUI  ]
;[=============]
;-- Set GUI default
gui %$RPViewerGUI%:Default

;-- Give ownership to parent GUI
gui +Owner%$QAHKGUI%
    ;-- Programming note: Ownership assignment must be be performed before any
    ;   other GUI commands.

;-- Identify window handle
gui %$RPViewerGUI%:+LastFound
WinGet $RPViewerGUI_hWnd,ID
GroupAdd $RPViewerGUI_Group,ahk_id %$RPViewerGUI_hWnd%

;-- GUI options
gui Margin,6,6
gui +LabelRPViewerGUI_
    || +Resize
    || -MinimizeBox
    || -MaximizeBox

;-------------------
;-- Primary objects
;-------------------
gui Add
   ,GroupBox
   ,xm ym w290 h170
        || hWnd$RPViewerGUI_RPListGB_hWnd
        || v$RPViewerGUI_RPListGB
   ,Restore Point

gui Add
   ,Edit
   ,xp+10 yp+20
        || Section
        || Hidden
   ,8888-88-88 88:88:88  8,888.88 KBXXXX
        ;-- Template used to establish the width of the ListView control

gui Add
   ,ListView
   ,xp wp h140
        || Section
        || +AltSubmit
        || Count999  ;-- 999=Maximum number of restore points
        || -Hdr
        || -Multi
        || hWnd$RPViewerGUI_RPList_hWnd
        || v$RPViewerGUI_RPList
        || gRPViewerGUI_RPList
   ,Display Name|Path

;-- Initialize column size
LV_ModifyCol(1,0)
LV_ModifyCol(2,0)

;-- Resize the RPList group box
GUIControlGet $Group1Pos,Pos,$RPViewerGUI_RPListGB
GUIControlGet $Group2Pos,Pos,$RPViewerGUI_RPList
GUIControl
    ,Move
    ,$RPViewerGUI_RPListGB
    ,% "w" . $Group2PosW+20

gui Add
   ,GroupBox
   ,ym w330 h200
        || hWnd$RPViewerGUI_ViewerGB_hWnd
        || v$RPViewerGUI_ViewerGB
   ,Viewer

;-- Move the Viewer group box
GUIControlGet $Group1Pos,Pos,$RPViewerGUI_RPListGB
GUIControl
    ,Move
    ,$RPViewerGUI_ViewerGB
    ,% "x" . $Group1PosX+$Group1PosW

;-- HiEdit control
$RPViewerGUI_hEdit:=HE_Add($RPViewerGUI_hWnd,0,0,310,170,"HSCROLL VSCROLL HILIGHT",$LibDir . "\HiEdit.dll")

;-- Font, font size, font style
HE_SetFont($RPViewerGUI_hEdit,"s" . $RPViewerFontSize . A_Space . $RPViewerFontStyle . "," . $RPViewerFont)

;-- Line numbers bar?
if $RPViewerLineNumbersBar
    HE_LineNumbersBar($RPViewerGUI_hEdit,"autosize",30,10)

;-- Move the HiEdit control to the Viewer group box
ControlGetPos $Group1PosX, $Group1PosY,,,,ahk_id %$RPViewerGUI_ViewerGB_hWnd%
ControlMove,,% $Group1PosX+10,% $Group1PosY+20,,,ahk_id %$RPViewerGUI_hEdit%

;-----------
;-- Buttons
;-----------
gui Add
   ,Button
   ,xm y180 w80 h30
        || +Disabled
        || hWnd$RPViewerGUI_RestoreButton_hWnd
        || v$RPViewerGUI_RestoreButton
        || gRPViewerGUI_RestoreButton
   ,&Restore

gui Add
   ,Button
   ,x+5 wp hp
        || hWnd$RPViewerGUI_CloseButton_hWnd
        || v$RPViewerGUI_CloseButton
        || gRPViewerGUI_Close
   ,Close

;[=================]
;[  Load ListView  ]
;[=================]
Loop %$RPDir%\*.ahk
    {
    ;-- Derive restore time stamp
    StringTrimRight $RPTimeStamp,A_LoopFileName,4

    ;-- Convert timestamp into readable date/time format
    FormatTime
        ,$RPDisplayField
        ,%$RPTimeStamp%
        ,yyyy-MM-dd HH:mm:ss

    ;-- Format size display
    if A_LoopFileSize<1024
        $FileSize:=AddCommas(A_LoopFileSize) . " bytes"
     else
        if A_LoopFileSize<1048576
            $FileSize:=AddCommas(Round(A_LoopFileSize/1024,2)) . " KB"
         else
            $FileSize:=AddCommas(Round(A_LoopFileSize/1048576,2)) . " MB"

    $RPDisplayField:=$RPDisplayField . "   " . $FileSize
    LV_Add("",$RPDisplayField,A_LoopFileFullPath)
    }

;-- Size/Sort column
LV_ModifyCol(1,"Auto SortDesc")

;-- Attach GUI objects
Attach($RPViewerGUI_RPListGB_hWnd     ,"h")
Attach($RPViewerGUI_RPList_hWnd       ,"h")
Attach($RPViewerGUI_ViewerGB_hWnd     ,"w h")
Attach($RPViewerGUI_hEdit             ,"w h")
Attach($RPViewerGUI_RestoreButton_hWnd,"y")
Attach($RPViewerGUI_CloseButton_hWnd  ,"y")

;[============]
;[  Show it!  ]
;[============]
;-- Render but don't display
gui Show,Hide AutoSize,Restore

;-- Set/Restore window position
if $RPViewerSaveWindowPos and $RPViewerX
    {
    DetectHiddenWindows On
    WinMove
        ,ahk_id %$RPViewerGUI_hWnd%
        ,
        ,%$RPViewerX%
        ,%$RPViewerY%
        ,%$RPViewerW%
        ,%$RPViewerH%

    DetectHiddenWindows Off
    gui Show
    }
 else
    {
    ;-- Calculate X/Y and Show it
    PopupXY($QAHKGUI,$RPViewerGUI,$PosX,$PosY)
    gui Show,x%$PosX% y%$PosY%
    }

;-- Reset speed to program default
SetBatchLines %$BatchLines%
return


;***************************
;*                         *
;*    Default font size    *
;*      (RPViewerGUI)      *
;*                         *
;***************************
RPViewerGUI_DefaultFontSize:
$RPViewerFontSize:=$RPViewerDefaultFontSize
HE_SetFont($RPViewerGUI_hEdit,"s" . $RPViewerFontSize . A_Space . $RPViewerFontStyle . "," . $RPViewerFont)
return


;****************************
;*                          *
;*    Decrease font size    *
;*      (RPViewerGUI)       *
;*                          *
;****************************
RPViewerGUI_DecreaseFontSize:
if ($RPViewerFontSize>$MinimumFontSize)
    {
    $RPViewerFontSize--
    HE_SetFont($RPViewerGUI_hEdit,"s" . $RPViewerFontSize . A_Space . $RPViewerFontStyle . "," . $RPViewerFont)
    }
 else
    SoundPlay *-1  ;-- System default sound

return


;****************************
;*                          *
;*    Increase font size    *
;*      (RPViewerGUI)       *
;*                          *
;****************************
RPViewerGUI_IncreaseFontSize:
if ($RPViewerFontSize<$MaximumFontSize)
    {
    $RPViewerFontSize++
    HE_SetFont($RPViewerGUI_hEdit,"s" . $RPViewerFontSize . A_Space . $RPViewerFontStyle . "," . $RPViewerFont)
    }
 else
    SoundPlay *-1  ;-- System default sound

return


;*********************************
;*                               *
;*    Toggle line numbers bar    *
;*         (RPViewerGUI)         *
;*                               *
;*********************************
RPViewerGUI_ToggleLineNumbersBar:
if $RPViewerLineNumbersBar
    {
    HE_LineNumbersBar($RPViewerGUI_hEdit,"hide",0,0)
    $RPViewerLineNumbersBar:=False
    }
 else
    {
    HE_LineNumbersBar($RPViewerGUI_hEdit,"autosize")
    $RPViewerLineNumbersBar:=True
    }

return


;***********************
;*                     *
;*       RPList        *
;*    (RPViewerGUI)    *
;*                     *
;***********************
RPViewerGUI_RPList:
Critical  ;-- Added because routine was dropping critical codes on occasion

;-- Doubleclick?
if A_GuiEvent=DoubleClick
    {
    ;-- Anything selected? (Seems redundant for a double-click, but it's not)
    if LV_GetCount("Selected")
        gosub RPViewerGUI_RestoreButton

    return
    }

;-- Bounce if not selecting a new item
if (A_GUIEvent<>"I") or InStr(ErrorLevel,"S",True)=0
    return

;-- Enable Restore button
GUIControl Enable,$RPViewerGUI_RestoreButton

;-- Collect RP file name
LV_GetText($RPFile,A_EventInfo,2)

;-- Close current file
HE_CloseFile($RPViewerGUI_hEdit)

;-- Get file size
FileGetSize $FileSize,%$RPFile%

;-- Open/Display file
if $FileSize<=10485760  ;-- 10 MB
    {
    HE_OpenFile($RPViewerGUI_hEdit,$RPFile)
    if not ErrorLevel
        {
        ;-- Disable Restore button
        GUIControl Disable,$RPViewerGUI_RestoreButton

        ;-- Notify the user
        gui +OwnDialogs
        MsgBox
            ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,Select Restore Point Error
            ,Could not find/open:   `n%$RPFile%  %A_Space%

        return
        }
    }
 else
    {
    ;-- Read RPFile
    FileRead $RPViewerGUI_Viewer,*m524288 %$RPFile%  ;-- 524288=512K
    if ErrorLevel
        {
        ;-- Disable Restore button
        GUIControl Disable,$RPViewerGUI_RestoreButton

        ;-- Notify the user
        gui +OwnDialogs
        MsgBox
            ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
            ,Select Restore Point Error
            ,Could not find/open:   `n%$RPFile%  %A_Space%

    	return
        }

    ;-- Load to Viewer
    HE_SetSel($RPViewerGUI_hEdit,0,-1)
    HE_ReplaceSel($RPViewerGUI_hEdit,$RPViewerGUI_Viewer)

    ;-- Empty undo buffer
    HE_EmptyUndoBuffer($RPViewerGUI_hEdit)

    ;-- Scroll to the top/left
    HE_LineScroll($RPViewerGUI_hEdit,-9999999,-9999999)
    }

return


;************************
;*                      *
;*    Restore button    *
;*    (RPViewerGUI)     *
;*                      *
;************************
RPViewerGUI_RestoreButton:

;-- Running?
if $Running
    {
    SoundPlay *-1  ;-- System default sound
    return
    }

;-- Anything selected?
if LV_GetCount("Selected")=0  ;-- Test s/b redundant but remains as a fail-safe
    return

;-- Collect full restore file name
LV_GetText($RPFile,LV_GetNext(0),2)

;-- Close RPViewerGUI?
if $RPViewerCloseOnRestore
    gosub RPViewerGUI_Close

;-- Reset GUI default
gui %$QAHKGUI%:Default

;-- Copy selected restore point file over workspace file
FileCopy %$RPFile%,%$EditFile%,1  ;-- 1=overwrite
If ErrorLevel
    {
    ;-- Notify the user
    gui +OwnDialogs
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Restore Error
        ,Unable to copy the selected restore point to the workspace.  %A_Space%

    return
    }

;-- Reset file attributes
FileSetAttrib -RSH,%$EditFile%

;-- Reload workspace
gosub LoadWorkspace

;-- Update status bar
SB_SetText("Workspace restored from " . CompressFileName($RPFile,40))
SetTimer QAHKGUI_ClearStatusBar,25000
return


;***********************
;*                     *
;*       Delete        *
;*    (RPViewerGUI)    *
;*                     *
;***********************
RPViewerGUI_Delete:

;-- Anything selected?
if LV_GetCount("Selected")=0
    return

;-- Attach messages to the current GUI
gui +OwnDialogs

;[===========]
;[  Confirm  ]
;[===========]
MsgBox
    ,49     ;-- 49 = 1 (OK/Cancel buttons) + 48 ("!" icon)
    ,Confirm Delete,
       (ltrim join`s
        The selected restore point file will be deleted.  Press OK to
        proceed.  %A_Space%
       )

IfMsgBox Cancel
    return

;[==========]
;[  Delete  ]
;[==========]
;-- Identify selected row
$Row:=LV_GetNext(0)

;-- Collect full restore file name
LV_GetText($RPFile,$Row,2)

;-- Delete it
FileDelete %$RPFile%
if ErrorLevel
    {
    MsgBox
        ,16     ;-- 16 = 0 (OK button) + 16 (Error icon)
        ,Delete Error,
           (ltrim
            Unable to delete the selected restore point file:  %A_Space%
            %$RPFile%  %A_Space%
            `nThis file may be in use by another program.  %A_Space%
           )

    return
    }

;-- Delete row
LV_Delete($Row)

;-- Anything left?
if LV_GetCount()
    {
    if ($Row>LV_GetCount())
        $Row:=LV_GetCount()

    ;-- Select next logical row
    LV_Modify($Row,"+Select +Vis")
        ;-- Programming note: This statement will automatically trigger the
        ;   RPViewerGUI_RPList routine which will populate the RP viewer with
        ;   the contents of the selected restore point.
    }
 else
    {
    ;-- Disable Restore button
    GUIControl Disable,$RPViewerGUI_RestoreButton

    ;-- Close last opened file
    HE_CloseFile($RPViewerGUI_hEdit)
    }

return


;***********************
;*                     *
;*    Close up shop    *
;*    (RPViewerGUI)    *
;*                     *
;***********************
RPViewerGUI_Escape:
if not $RPViewerEscapeToClose
    return


RPViewerGUI_Close:
;-- Save window statistics
gosub SaveRPViewerConfiguration

;-- Destroy window so that it can be used again
gui %$RPViewerGUI%:Destroy
    ;-- Programming note: The GUI is specified here because this routine is
    ;   sometimes called from the main GUI.

return


;*******************************
;*                             *
;*                             *
;*           Hotkeys           *
;*        (RPViewerGUI)        *
;*                             *
;*                             *
;*******************************
;-- Begin #IfWinActive directive
#IfWinActive ahk_group $RPViewerGUI_Group

;[==========]
;[  Delete  ]
;[==========]
~Delete::

;-- Set GUI default
gui %$RPViewerGUI%:Default

;-- Ignore if Listview is not in focus
GUIControlGet $Control,FocusV
if $Control<>$RPViewerGUI_RPList
    return

;-- Delete it
gosub RPViewerGUI_Delete
return


;[================]
;[  Ctrl+WheelUp  ]
;[================]
^WheelUp::

;-- Increase font size
gosub RPViewerGUI_IncreaseFontSize
return


;[==================]
;[  Ctrl+WheelDown  ]
;[==================]
^WheelDown::

;-- Increase font size
gosub RPViewerGUI_DecreaseFontSize
return


;[==========]
;[  Ctrl+[  ]
;[==========]
^[::

;-- Decrease font size
gosub RPViewerGUI_DecreaseFontSize
return


;[==========]
;[  Ctrl+]  ]
;[==========]
^]::
;-- Increase font size
gosub RPViewerGUI_IncreaseFontSize
return


;[==================]
;[  Ctrl+NumpadAdd  ]
;[==================]
^NumpadAdd::

;-- Increase font size
gosub RPViewerGUI_IncreaseFontSize
return


;[==================]
;[  Ctrl+NumpadSub  ]
;[==================]
^NumpadSub::

;-- Decrease font size
gosub RPViewerGUI_DecreaseFontSize
return


;[==================]
;[  Ctrl+Numpad0    ]
;[  Ctrl+NumpadIns  ]
;[==================]
^Numpad0::
^NumpadIns::
;-- Default font size
gosub RPViewerGUI_DefaultFontSize
return


;[==========]
;[  Ctrl+L  ]
;[==========]
^l::
;-- Toggle
gosub RPViewerGUI_ToggleLineNumbersBar
return


;-- End #IfWinActive directive
#IfWinActive

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;---------------------------- End RPViewerGUI Stuff ----------------------------
;-------------------------------------------------------------------------------





;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;---------------------------- Begin RunPrompt stuff ----------------------------
;-------------------------------------------------------------------------------
;*******************************
;*                             *
;*                             *
;*        RunPrompt GUI        *
;*                             *
;*                             *
;*******************************
RunPromptGUI:
SetTimer %A_ThisLabel%,Off


;[==============]
;[  Initialize  ]
;[==============]
$RunPromptGUI:=23
$CLParms     :=""

;[=============]
;[  Build GUI  ]
;[=============]
;-- Set GUI default
gui %$RunPromptGUI%:Default

;-- Disable parent GUI, give ownership to parent GUI
gui %$QAHKGUI%:+Disabled
gui +Owner%$QAHKGUI%
    ;-- Note: Ownership assignment must be be performed before any other GUI
    ;   commands.

;-- Identify window handle
gui %$RunPromptGUI%:+LastFound
WinGet $RunPromptGUI_hWnd,ID
GroupAdd $RunPromptGUI_Group,ahk_id %$RunPromptGUI_hWnd%

;---------------
;-- GUI options
;---------------
gui Margin,6,6
gui +LabelRunPromptGUI_
    || +Delimiter`n
    || +Resize
    || -MinimizeBox
    || -MaximizeBox
    || +MinSize

;-------------------
;-- Primary objects
;-------------------
gui Add
   ,GroupBox
   ,xm y10 w370 h170
        || hWnd$RunPromptGUI_RunParmsGB_hWnd
   ,Parameters (separated by space and/or by line)

gui Add
   ,Edit
   ,xp+10 yp+20 w350 h140
        || +0x100000    ;-- Horizontal scroll bar
        || -Wrap
        || hWnd$RunPromptGUI_RunParms_hWnd
        || v$RunPromptGUI_RunParms
   ,%$RunParms%

gui Add
   ,GroupBox
   ,xm y+10 w370 h50
        || hWnd$RunPromptGUI_RUSelectGB_hWnd
   ,Recently-used parameters

gui Add
   ,DropDownList
   ,xp+10 yp+20 w310 r7 Choose1
        || hWnd$RunPromptGUI_RUSelect_hWnd
        || v$RunPromptGUI_RUSelect
   ,%$RunParmsDDL%

gui Add
   ,Button
   ,x+1 hp
        || hWnd$RunPromptGUI_AddButton_hWnd
        || v$RunPromptGUI_AddButton
        || gRunPromptGUI_Add
   ,&Add

if $RunParmsDDL is Space
    {
    GUIControl Disable,$RunPromptGUI_RUSelect
    GUIControl Disable,$RunPromptGUI_AddButton
    }

;-----------
;-- Buttons
;-----------
gui Add
   ,Button
   ,xm y+15 w70 h30
        || hWnd$RunPromptGUI_SubmitButton_hWnd
        || v$RunPromptGUI_SubmitButton
        || gRunPromptGUI_Submit
   ,&Submit

gui Add
   ,Button
   ,x+5 wp hp
        || hWnd$RunPromptGUI_SkipButton_hWnd
        || gRunPromptGUI_Skip
   ,S&kip

gui Add,Button
   ,x+5 wp hp
        || hWnd$RunPromptGUI_CancelButton_hWnd
        || gRunPromptGUI_Close
   ,Cancel

;-- Set focus
GUIControl Focus,$RunPromptGUI_SubmitButton

;[==========]
;[  Attach  ]
;[==========]
Attach($RunPromptGUI_RunParmsGB_hWnd  ,"w h")
Attach($RunPromptGUI_RunParms_hWnd    ,"w h")
Attach($RunPromptGUI_RUSelectGB_hWnd  ,"y w")
Attach($RunPromptGUI_RUSelect_hWnd    ,"y w")
Attach($RunPromptGUI_AddButton_hWnd   ,"x y r")
Attach($RunPromptGUI_SubmitButton_hWnd,"y r")
Attach($RunPromptGUI_SkipButton_hWnd  ,"y r")
Attach($RunPromptGUI_CancelButton_hWnd,"y r")

;[============]
;[  Show it!  ]
;[============]
;-- Render but don't display
gui Show,Hide,Script Parameters

;-- Calculate X/Y and Show it
PopupXY($QAHKGUI,$RunPromptGUI,$PosX,$PosY)
gui Show,x%$PosX% y%$PosY%

;-- Prompt sound
SoundPlay *32  ;-- System "Question" sound
return


;************************
;*                      *
;*          Add         *
;*    (RunPromptGUI)    *
;*                      *
;************************
RunPromptGUI_Add:

;-- Collect form variables
gui Submit,NoHide

;-- Update/Refresh Parameters field
if $RunPromptGUI_RunParms is Space
    $RunPromptGUI_RunParms:=$RunPromptGUI_RUSelect
 else
    $RunPromptGUI_RunParms:=$RunPromptGUI_RunParms . "`n" . $RunPromptGUI_RUSelect

GUIControl,,$RunPromptGUI_RunParms,%$RunPromptGUI_RunParms%

;-- Scroll to the bottom
SendMessage
    ,EM_LINESCROLL
    ,0                     ;-- Number of characters to scroll horizontally
    ,999999999             ;-- Number of characters to scroll vertically
    ,Edit1
    ,ahk_id %$RunPromptGUI_hWnd%

return


;************************
;*                      *
;*        Submit        *
;*    (RunPromptGUI)    *
;*                      *
;************************
RunPromptGUI_Submit:

;-- Set GUI default
gui %$RunPromptGUI%:Default
    ;-- Needed to support hotkeys

;-- Collect form variables
gui Submit,NoHide

;-- Update $RunParms (Leave intact. Pimples and all)
$RunParms:=$RunPromptGUI_RunParms

;-- Build parameters list
t_RunParms :=""
Loop Parse,$RunPromptGUI_RunParms,`n
    {
    ;-- Skip empty
    if A_LoopField is Space
        Continue

    ;-- AutoTrim
    l_LoopField=%A_LoopField%

    ;-- Populate $CLParms and t_RunParms
    if StrLen($CLParms)=0
        {
        $CLParms:=l_LoopField
        t_RunParms:=A_LoopField
        }
     else
        {
        $CLParms:=$CLParms . A_Space . l_LoopField      ;-- FIFO (left to right)
        t_RunParms:=l_LoopField . "`n" . t_RunParms     ;-- LIFO (reverse) order
        }
    }

;-- Push parameters to $RunParmsDDL
Loop Parse,t_RunParms,`n
    DDLManager("Push",1,$RunParmsDDL,"`n",A_LoopField,30)


RunPromptGUI_Skip:

;-- Shut down GUI
gosub RunPromptGUI_Close
Sleep 50  ;-- Allow for the GUI to respond

;-- Continue running
gosub QAHKGUI_Run_AfterPrompt
return


;************************
;*                      *
;*     Close up shop    *
;*    (RunPromptGUI)    *
;*                      *
;************************
RunPromptGUI_Escape:
RunPromptGUI_Close:
RunPromptGUI_Exit:

;-- Enable parent window
gui %$QAHKGUI%:-Disabled

;-- Destroy window so that it can be used again
gui Destroy
return


;********************************
;*                              *
;*                              *
;*            Hotkeys           *
;*        (RunPromptGUI)        *
;*                              *
;*                              *
;********************************
;-- Begin #IfWinActive directive
#IfWinActive ahk_group $RunPromptGUI_Group

;[==========]
;[  F9      ]
;[  Ctrl+S  ]
;[==========]
F9::
^s::
gosub RunPromptGUI_Submit
return


;-- End #IfWinActive directive
#IfWinActive



;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;--------------------------- End RunPromptGUI Stuff ----------------------------
;-------------------------------------------------------------------------------
