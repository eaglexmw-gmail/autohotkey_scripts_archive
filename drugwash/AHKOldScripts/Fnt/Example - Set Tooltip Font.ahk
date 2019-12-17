/*
    In this example, the font of tooltips created by the AutoHotkey "Tooltip"
    command are changed.

    The idea for this example was gleaned from a post by uname.
    http://www.autohotkey.com/board/topic/91394-setting-tooltip-font-to-monospace/#entry576541
*/

#NoEnv
#SingleInstance Force
ListLines Off

CoordMode ToolTip,Screen

gui Margin,0,0
gui -MinimizeBox
gui Add,Button,w250 gExample1,Example 1
gui Add,Button,wp   gExample2,Example 2
gui Add,Button,wp   gExample3,Example 3
gui Add,Button,wp   gReload,Reload...

SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%
return


Example1:

;-- Disable the GUI while building/showing this example
gui 1:+Disabled

;-- Clear out the old Tooltip (if needed)
Tooltip

;-- Build/Show the new tooltip
TooltipText=
   (ltrim
    Example 1

    This is an ordinary AutoHotkey tooltip.  There is a short delay to show that
    the tooltip is created using the default font and font size.  The font is
    then changed to Verdana size 14.
   )

Tooltip %TooltipText%,100,100

;-- Let the user see the toolip in it's current format
Sleep 2000

;-- Collect the tooltip handle
gosub GetToolTipHandle

;-- Create/Set font
hFont :=Fnt_CreateFont("Verdana","s14")
Fnt_SetFont(hTT,hFont,True)

;-- Enable the GUI
gui 1:-Disabled
return


Example2:

;-- Disable the GUI while building/showing this example
gui 1:+Disabled

;-- Clear out the old Tooltip (if needed)
Tooltip

;-- Build/Show the new tooltip
TooltipText=
   (ltrim
    Example 2

    This example shows how changing the font
    can improve the display of some data.  In
    this example, the tooltip font is changed
    to a monspaced font so that the table data
    will align properly.

    
    Color   RGB Hex
    -----   -------
    Aqua    0x00FFFF
    Azure   0xF0FFFF
    Beige   0xF5F5DC
    Black   0x000000
    Blue    0x0000FF
    Brown   0xA52A2A
    Cyan    0x00FFFF
    Gold    0xFFD700
    Gray    0x808080
    Green   0x008000
    Magenta 0xFF00FF
    Maroon  0x800000
    Navy    0x000080
    Orange  0xFFA500
    Pink    0xFFC0CB
    Violet  0xEE82EE
    Yellow  0xFFFF00
   )

Tooltip %TooltipText%,50,50
Sleep 2000

;-- Collect the tooltip handle
gosub GetToolTipHandle

;-- Create/Set font
hFont :=Fnt_CreateFont("Lucida Console")
Fnt_SetFont(hTT,hFont,True)

;-- Enable the GUI
gui 1:-Disabled
return


Example3:

;-- Clear out the old Tooltip (if needed)
Tooltip

;-- Build/Show the new tooltip
TooltipText=
   (ltrim
    Example 3

    This is the same as Example 1 except that there is no delay between the
    time the tooltip is created and when the new font is set.  It will give you
    an idea of what the end users will see.
   )

Tooltip %TooltipText%,100,100

;-- Collect the tooltip handle
gosub GetToolTipHandle

;-- Create/Set font
hFont :=Fnt_CreateFont("Verdana","s14")
Fnt_SetFont(hTT,hFont,True)
return


GetToolTipHandle:

;-- Initialize 
hTT :=0

;-- Get the current process ID
Process Exist
ScriptPID :=ErrorLevel

;-- Find the tooltip
WinGet IDList,List,ahk_pid %ScriptPID%
Loop %IDList%
    {
    WinGetClass Class,% "ahk_ID " . IDList%A_Index%
    if (Class="tooltips_class32")
        {
        hTT:=IDList%A_Index%
        Break
        }
    }

return


GUIClose:
GUIEscape:
ExitApp


Reload:
Reload
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%
#include Fnt.ahk
