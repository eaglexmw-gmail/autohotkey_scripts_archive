;*****************
;*               *
;*    InfoGUI    *
;*               *
;*****************
;
;   Description
;   ===========
;   This function display a simple "informational" window.  See the "Processing
;   Notes" section for more information.
;
;
;   Parameters
;   ==========
;
;       Name                Description
;       ----                -----------
;       p_Owner             Owner of the InfoGUI window.  [Optional]  The
;                           default is 0 (No owner).
;
;                           If a valid Owner window number is derived, the Owner
;                           window is disabled and ownership of the InfoGUI
;                           window is assigned to the Owner window.  This makes
;                           the InfoGUI window modal which prevents the user
;                           from interacting with the Owner window until the
;                           InfoGUI window is closed.
;
;       p_Text              This parameter contains the text that is displayed
;                           in the information window.  [Optional].  The default
;                           is blank.
;
;       p_Title             Window title.  [Optional]  The default is the
;                           current script name sans the extention.
;
;       p_GUIOptions        GUI Options.  [Optional]  The default are the
;                           options in s_DefaultGUIOptions (if any).  Some
;                           common options include the the following:
;
;                             Option        Description
;                             ------        -----------
;                             Border        Also known as "+Border".  If used
;                                           with the"-Caption" option (see
;                                           below), creates a thin border around
;                                           the window.
;
;                             -Border       If used without the "-Caption"
;                                           option, removes the title bar from
;                                           the window and creates a thick
;                                           border around the window.
;
;                             -Caption      Removes the title bar from the
;                                           window.
;
;                             -MaximizeBox  Disables the maximize button in the
;                                           title bar (if it exists).  This
;                                           option is commonly used with the
;                                           +Resize option (see below).
;
;                             -MinimizeBox  Disables the minimize button in the
;                                           title bar (if it exists).  Note:
;                                           To insure that InfoGUI window is
;                                           modal, this option is always added
;                                           to this parameter.
;
;                             Resize        Also known as "+Resize".  Makes the
;                                           window resizable and enables the
;                                           maximize button (if it exists).  See
;                                           the "-MaximizeBox" option (above).
;                                           This option is best used with the
;                                           "Edit" option type and when the text
;                                           is long or dynamic.
;
;                             -SysMenu      This option removes the following
;                                           from the title bar: system menu,
;                                           icon, minimize button, maximize
;                                           button, and close button.
;
;                             ToolWindow    Also know as "+ToolWindow".  Creates
;                                           a narrow title bar and removes the
;                                           minimize and maximize buttons (if
;                                           they exist).
;
;                           To use more than one option, include a space between
;                           each option.  For example:
;
;                               "+Resize -MaximizeBox"
;
;                           For more information, see the AHK documentation
;                           (keyword: GUI, section: Options)
;
;
;       p_ObjectType        Object Type.  [Optional]  The default is "Edit".
;                           There are currently two object types supported:
;
;                               Edit
;                               Text
;
;                           The "Edit" object type (always created as "read
;                           only") is selectable (the users can mark and copy)
;                           and creates a scroll bar so the users can scroll
;                           through large amounts of text.  The "Resize" option
;                           is sometimed uses with this object type.
;
;                           The "Text" object type is not selectable and a
;                           scroll bar is not created.  In addition, the entire
;                           InfoGUI window can be moved by dragging anywhere
;                           inside of the text object (Goyyah trick).
;                           
;
;       p_ObjectOptions     Object options.  [Optional]  The default is
;                           "r15 w500".  The sizing options include the
;                           following (not case sensitive):
;
;                             Option        Description
;                             ------        -----------
;                             r{Row Count}  Determines the initial number of
;                                           rows displayed.
;
;                             w{pixels}     Determines the initial width (in
;                                           pixels) of the object.
;
;                             c{Color}      Font color.  "Color" is an HTML
;                                           color name or 6-digit hex RGB color
;                                           value.  If this option is used, it
;                                           will override the "color" option of
;                                           the p_FontOptions parameter (if
;                                           defined)
;
;                             Border        Also known as "+Border".  This
;                                           option creates a thin-line border
;                                           around the object.  Depending on
;                                           what other parameter values are
;                                           defined (or not defined), the border
;                                           may give the object the illusion
;                                           that it is indented (sunken).
;
;                             Center        Also known as "+Center".  Centers
;                                           the text within its available width.
;
;                             Left          Also known as "+Left".
;                                           Left-justifies the text (the
;                                           default) within its available width.
;
;                             Right         Also known as "+Right".
;                                           Right-justifies the text within its
;                                           available width.
;
;                           If either "Row" or "Width" option is not defined,
;                           the default for that option is automatically added
;                           to this parameter.
;
;                           To use more than one option, include a space between
;                           each option.  For example:
;
;                             "r20 Border"
;
;                           For more information, see the AutoHotkey
;                           documentation -- Keyword: GUI, section: Positioning
;                           and Sizing of Controls
;
;
;       p_BGColor           Sets the background color of the object. [Optional]
;                           The default is blank (uses the system default
;                           color).  To set, specify one of the 16 primary HTML
;                           color names or a 6-digit hex RGB color value.
;                           Example values: Blue, F0F0F0, EEAA99, Default.
;
;                           For more information, see the AHK documentation
;                           (keyword: color names)
;
;
;       p_Font              The text font.  [Optional]  The default is blank
;                           (uses the system default font).
;
;                           For a list of available font names, see the AHK
;                           documentation (keyword: Fonts)
;
;
;       p_FontOptions       Font Options.  [Options]  The default is blank (uses
;                           the system defaults).  At this writing, the
;                           following font options are currently available (not
;                           case sensitive):
;
;                             c{HTML color name or 6-digit hex RGB color value}
;                             s{Font size (in points)}
;                             Bold
;                             Italic
;                             Strike
;                             Underline
;
;                           To use more than one option, include a space between
;                           each option.  For example:
;
;                             "cBlue s10 bold underline"
;
;                           For more information, see the AHK documentation
;                           (keyword: GUI, section: Font).
;
;
;       p_Timeout           Window timeout (in seconds).  [Optional]  The
;                           default is blank (no timeout).
;
;
;   Processing Notes
;   ================
;    o  To improve usability, this function does not exit until the user closes
;       the the InfoGUI window.
;
;    o  Because of the large number of possible values, many of the function
;       parameters are not checked for integrity.  Most of the time, invalid
;       values are simply ignored.  However, invalid values may cause the script
;       to fail.  Be sure to carefully select the parameter values and test
;       your script thouroughly.
;
;   o   This function uses the first GUI window that is available in the s_GUI
;       to 99 range. If an available window cannot be found, an error message is
;       displayed.
;
;
;   Customizing
;   ===========
;   This function can be customized in an infinite number of ways.  The quickest
;   and most effective customization would be to change the default values for
;   the parameters.  Note that default values were purposely excluded from the
;   the function definition so that the default values would not have to be
;   changed twice -- once in the function definition and again in the
;   "Parameters" section of the code.
;
;
;   Return Codes
;   ============
;   The function returns 0 if the GUI was created and closed sucessfully.  The
;   function returns the word FAIL if the function was unable to create the GUI.
;
;
;   Calls To Other Functions
;   ========================
;   PopupXY
;
;
;-------------------------------------------------------------------------------
InfoGUI(p_Owner=""
       ,p_Text=""
       ,p_Title=""
       ,p_GUIOptions=""
       ,p_ObjectType=""
       ,p_ObjectOptions=""
       ,p_BGColor=""
       ,p_Font=""
       ,p_FontOptions=""
       ,p_Timeout="")
    {
    ;[====================]
    ;[  Static variables  ]
    ;[====================]
    Static s_GUI:=56
                ;-- Default starting GUI window number for InfoGUI window.
                ;   Change if desired.

          ,s_DefaultGUIOptions:=""
                ;-- Default GUI options.  Leave blank for no defaults.

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    SplitPath A_ScriptName,,,,l_ScriptName

    ;[==================]
    ;[    Parameters    ]
    ;[  (Set defaults)  ]
    ;[==================]
    ;---------
    ;-- Owner
    ;---------
    p_Owner=%p_Owner%  ;-- AutoTrim
    if p_Owner is not Integer
        p_Owner=0
     else
        if p_Owner not between 1 and 99
            p_Owner=0

    ;-- Owner window exist?
    if p_Owner
        {
        gui %p_Owner%:+LastFoundExist
        IfWinNotExist
            {
            outputdebug,
               (ltrim join`s
                Function: %A_ThisFunc% -
                Owner window does not exist.  p_Owner=%p_Owner%
               )
    
            p_Owner=0
            }
        }

    ;---------
    ;-- Title
    ;---------
    p_Title=%p_Title%  ;-- AutoTrim
    if StrLen(p_Title)=0
        p_Title:=l_ScriptName
     else
        {
        ;-- Append to script name if p_title begins with "++"?
        if SubStr(p_Title,1,2)="++"
            {
            StringTrimLeft p_Title,p_Title,2
            p_Title:=l_ScriptName . A_Space . p_Title
            }
        }

    ;---------------
    ;-- GUI Options
    ;---------------
    p_GUIOptions=%p_GUIOptions%  ;-- AutoTrim
    if p_GUIOptions is Space
        p_GUIOptions:=s_DefaultGUIOptions

    p_GUIOptions:=p_GUIOptions . " -MinimizeBox"

    ;---------------
    ;-- Object Type
    ;---------------
    p_ObjectType=%p_ObjectType%  ;-- AutoTrim
     if (p_ObjectType<>"Text")
    and (p_ObjectType<>"Edit")
        p_ObjectType=Edit

    ;-- Identify Move command and ClassNN
    l_MoveCmd=Move
    l_ClassNN=Edit1
    if p_ObjectType=Text
        {
        l_MoveCmd=MoveDraw
        l_ClassNN=Static1
        }
    
    ;------------------
    ;-- Object options
    ;------------------
    p_ObjectOptions=%p_ObjectOptions%  ;-- AutoTrim
    if p_ObjectOptions is Space
        p_ObjectOptions:="r15 w500"

    ;-- Add default row or width options if they don't exist
    if InStr(A_Space . p_ObjectOptions," r")=0
        p_ObjectOptions:=p_ObjectOptions . " r15"
    if InStr(A_Space . p_ObjectOptions," w")=0
        p_ObjectOptions:=p_ObjectOptions . " w500"

    ;--------------------
    ;-- Background color
    ;--------------------
    p_BGColor=%p_BGColor%  ;-- AutoTrim

    ;--------
    ;-- Font
    ;--------
    p_Font=%p_Font%  ;-- AutoTrim

    ;----------------
    ;-- Font options
    ;----------------
    p_FontOptions=%p_FontOptions%  ;-- AutoTrim

    ;-----------
    ;-- Timeout
    ;-----------
    p_Timeout=%p_Timeout%  ;-- Autotrim
    if p_Timeout is Number
        p_Timeout:=p_Timeout*1000
     else
        p_Timeout:=""

    ;[=========================]
    ;[  Find available window  ]
    ;[  (Starting with s_GUI)  ]
    ;[=========================]
    l_GUI:=s_GUI
    loop
        {
        ;-- Window available?
        gui %l_GUI%:+LastFoundExist
        IfWinNotExist
            break

        ;-- Nothing available?
        if l_GUI=99
            {
            MsgBox
                ,262160
                    ;-- 262160=0 (OK button) + 16 (Error icon) + 262144 (AOT)
                ,%A_ThisFunc% Error,
                   (ltrim join`s
                    Unable to create a %A_ThisFunc% window.  GUI windows
                    %s_StartGUI% to 99 are already in use.  %A_Space%
                   )

            return FAIL
            }

        ;-- Increment window number
        l_GUI++
        }

    ;[=============]
    ;[  Build GUI  ]
    ;[=============]
    ;----------
    ;-- Owner?
    ;----------
    if p_Owner
        {
        ;-- Disable Owner, give ownership of GUI to Owner
        gui %p_Owner%:+Disabled
        gui %l_GUI%:+Owner%p_Owner%
        }

    ;-- GUI Options
    gui %l_GUI%:Margin,2,2
    gui %l_GUI%:+LabelInfoGUI_
            || %p_GUIOptions%

    ;-- Set background color
    if p_BGColor is not Space
        gui %l_GUI%:Color,%p_BGColor%

    ;-- Set font and font options
    gui %l_GUI%:Font,%p_FontOptions%,%p_Font%

    ;-- Create object (Text or Edit)
    Static InfoGUI_Object
    gui %l_GUI%:Add
       ,%p_ObjectType%
       ,%p_ObjectOptions%
            || ReadOnly
            || vInfoGUI_Object
            || gInfoGUI_Move

    ;-- Reset font to system default
    gui %l_GUI%:Font

    ;-- Collect hWnd
    gui %l_GUI%:+LastFound
    WinGet l_InfoGUI_hWnd,ID

    ;-----------
    ;-- Show it
    ;-----------
    if p_Owner
        {
        ;-- Render but don't show
        gui %l_GUI%:Show,Hide,%p_Title%

        ;-- Calculate X/Y and Show it
        PopupXY(p_Owner,"ahk_id " . l_InfoGUI_hWnd,PosX,PosY)
        gui %l_GUI%:Show,x%PosX% y%PosY%
        }
     else
        gui %l_GUI%:Show,,%p_Title%


    ;-- Populate object
    GUIControl %l_GUI%:,InfoGUI_Object,%p_Text%
        ;-- Note: Object is populated after the window is displayed so that the
        ;   contents are not selected.

    ;[==============]
    ;[  Set timer?  ]
    ;[==============]
    if p_Timeout
        SetTimer InfoGUI_Timer,%p_Timeout%

    ;[=====================]
    ;[  Wait until window  ]
    ;[      is closed      ]
    ;[=====================]
    WinWaitClose ahk_id %l_InfoGUI_hWnd%
    return 0  ;-- End of function




    ;*****************************
    ;*                           *
    ;*                           *
    ;*        Subroutines        *
    ;*         (InfoGUI)         *
    ;*                           *
    ;*                           *
    ;*****************************
    ;**************
    ;*            *
    ;*    Move    *
    ;*            *
    ;**************
    InfoGUI_Move:
    PostMessage 0xA1,2  ;-- Goyyah trick.  Only works if object type is "Text"
    return 


    ;****************
    ;*              *
    ;*    Resize    *
    ;*              *
    ;****************
    InfoGUI_Size:

    ;-- Minimized?
    if ErrorLevel=1
        return

    ;-- Move it
    GUIControl
        ,%l_GUI%:%l_MoveCmd%
        ,%l_ClassNN%
        ,% "w" . A_GUIWidth-4 . " h" . A_GUIHeight-4

    return


    ;***********************
    ;*                     *
    ;*    Close up shop    *
    ;*                     *
    ;***********************
    ;-- These routines are used by mixed threads
    InfoGUI_Timer:
    InfoGUI_Escape:
    InfoGUI_Close:

    ;-- Turn off timer
    SetTimer InfoGUI_Timer,off

    ;-- Enable Owner window
    if p_Owner
        gui %p_Owner%:-Disabled

    ;-- Destroy the InfoGUI window so that the window can be reused
    gui %l_GUI%:Destroy
    return  ;-- End of subroutines
    }
