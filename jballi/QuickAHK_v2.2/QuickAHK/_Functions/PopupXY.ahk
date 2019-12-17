;*****************
;*               *
;*    PopupXY    *
;*               *
;*****************
;
;   Description
;   ===========
;   When passed a parent and child window, this function calculates the center
;   position for the child window relative to the parent window.  If necessary,
;   the calculated window positions are adjusted so that the child window will
;   fit within the primary monitor work area.
;
;
;   Parameters
;   ==========
;
;       Parameter           Description
;       ---------           -----------
;       p_Parent            For the parent window, this parameter can contain
;                           either the GUI window number (from 1 to 99) or the
;                           window title. [Required]
;
;                           From the AHK documentation...
;                           The title or partial title of the window (the
;                           matching behavior is determined by
;                           SetTitleMatchMode). To use a window class, specify
;                           ahk_class ExactClassName (shown by Window Spy). To
;                           use a process identifier (PID), specify ahk_pid
;                           %VarContainingPID%. To use a window's unique
;                           ID number, specify ahk_id %VarContainingID%.
;
;       p_Child             For the child (pop-up) window, this parameter can
;                           contain either the GUI window number (from 1 to 99)
;                           or the window title. [Required]  See the
;                           p_Parent description for more information.
;
;       r_ChildX            The calculated "X" position for the child window is
;                           returned in this variable. [Required]  This
;                           parameter must contain a variable name.
;
;       r_ChildY            The calculated "Y" position for the child window is
;                           returned in this variable. [Required]  This
;                           parameter must contain a variable name.
;
;
;   Return Codes
;   ============
;   The function does not return a value but the r_ChildX and r_ChildY variables
;   are updated to contain the calculated X/Y values.  If the parent or child
;   windows cannot be found, these variables are set to 0.
;
;-------------------------------------------------------------------------------
PopupXY(p_Parent,p_Child,ByRef r_ChildX,ByRef r_ChildY)
    {
    ;[===============]
    ;[  Environment  ]
    ;[===============]
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On
    SysGet l_MonitorWorkArea,MonitorWorkArea
    r_ChildX=0
    r_ChildY=0


    ;[=================]
    ;[  Parent window  ]
    ;[=================]
    ;-- If necessary, collect hWnd
    if p_Parent is Integer
        if p_Parent between 1 and 99
            {
            gui %p_Parent%:+LastFoundExist
            IfWinExist
                {
                gui %p_Parent%:+LastFound
                p_Parent:="ahk_id " . WinExist()
                }
            }

    ;-- Collect position/size
    WinGetPos l_ParentX,l_ParentY,l_ParentW,l_ParentH,%p_Parent%

    ;-- Anything found?
    if l_ParentX is Space
        return


    ;[================]
    ;[  Child window  ]
    ;[================]
    ;-- If necessary, collect hWnd
    if p_Child is Integer
        if p_Child between 1 and 99
            {
            gui %p_Child%:+LastFoundExist
            IfWinExist
                {
                gui %p_Child%:+LastFound
                p_Child:="ahk_id " . WinExist()
                }
            }


    ;-- Collect position/size
    WinGetPos,,,l_ChildW,l_ChildH,%p_Child%

    ;-- Anything found?
    if l_ChildW is Space
        return


    ;[=======================]
    ;[  Calculate child X/Y  ]
    ;[=======================]
    r_ChildX:=round(l_ParentX+((l_ParentW-l_ChildW)/2))
    r_ChildY:=round(l_ParentY+((l_ParentH-l_ChildH)/2))

    ;-- Adjust if necessary
    if (r_ChildX<l_MonitorWorkAreaLeft)
        r_ChildX:=l_MonitorWorkAreaLeft

    if (r_ChildY<l_MonitorWorkAreaTop)
        r_ChildY:=l_MonitorWorkAreaTop

    l_MaximumX:=l_MonitorWorkAreaRight-l_ChildW
    if (r_ChildX>l_MaximumX)
        r_ChildX:=l_MaximumX

    l_MaximumY:=l_MonitorWorkAreaBottom-l_ChildH
    if (r_ChildY>l_MaximumY)
        r_ChildY:=l_MaximumY


    ;[=====================]
    ;[  Reset environment  ]
    ;[=====================]
    DetectHiddenWindows %l_DetectHiddenWindows%
    return
    }
