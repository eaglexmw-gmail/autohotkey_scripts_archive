/*
    In this example, the width and/or height of the control is determined by the
    content provided by the user.

    The width of the control is set to widest line of text plus a small amount
    of padding which will ensure (usually) that the horizontal scroll bar is not
    shown.

    The height of the control is determined by the height and external leading
    of the font, the number of lines as determined by the user, and by constants
    and calculations extracted from the AutoHotkey source.
*/

#NoEnv
#SingleInstance Force
ListLines Off

;-- Constants 
GUI_CTL_VERTICAL_DEADSPACE :=8
SysGet CXVSCROLL,2
    ;-- Width of a vertical scroll bar, in pixels

SysGet,CXEDGE,45
    ;-- Width of a 3-D border, in pixels.

WS_VSCROLL :=0x200000

;-- Initialize
FileRead ListOfFontNames,%A_ScriptDir%\_Example Files\GUIFonts.txt

TotalNumberOfFontNames :=0
Loop Parse,ListOfFontNames,`n,`r
    if A_LoopField  ;-- Skip last blank line (if any)
        TotalNumberOfFontNames++

Random FontNameIndex,1,%TotalNumberOfFontNames%
Loop Parse,ListOfFontNames,`n,`r
    if (A_Index=FontNameIndex)
        {
        $FontName:=A_LoopField
        Break
        }

Random $FontSize,8,36
$FontOptions:="s" . $FontSize

;-- Build GUI
gui -MinimizeBox
gui Add,Button,gChooseFont,%A_Space%  Choose Font...  %A_Space%
;;;;;gui Add,Button,x+5 wp gTestButton,Test
gui Add,Button,x+5 wp gReload,Rebuild...
gui Add,Text,xm wp,Control:
gui Add,Radio,xm+15     gTestButton vButtonRB,Button
gui Add,Radio,xm+15 y+2 gTestButton vComboBoxRB,ComboBox
gui Add,Radio,xm+15 y+2 gTestButton vDDLRB,Drop-down List
gui Add,Radio,xm+15 y+2 gTestButton vEditRB,Edit
gui Add,Radio,xm+15 y+2 gTestButton vListBoxRB,ListBox
gui Add,Radio,xm+15 y+2 gTestButton vTextRB,Text
gui Add,Radio,xm+15 y+2 gTestButton vTooltipRB,Tooltip
;;;;;gui Add,Button,xm wp  gButtonControl,Button
;;;;;gui Add,Button,x+5 wp gDDLControl,DropDownList
;;;;;gui Add,Button,x+5 wp gEditControl,Edit
;;;;;gui Add,Button,x+5 wp gListBoxControl,ListBox
;;;;;gui Add,Button,x+5 wp gTextControl,Text

gui Font,%$FontOptions%,%$FontName%
gui Add,Edit,xm w800 r9 vMyEdit hWndhEdit -Wrap vMyEdit,
   (ltrim
    Enter one or more lines of text in this control.
    If desired, change the font and/or font size.
    Choose a control to test.
   )
    
gui Font

;-- Get the handle of the current font
hFont :=Fnt_GetFont(hEdit)

;-- Collect window handle
gui +LastFound
WinGet hWindow,ID

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,y0,%$ScriptTitle%
return


GUIClose:
GUIEscape:
ExitApp


/*
    For the Button control, the Ftn library can be used to set the correct width
    and/or height of the control.  This example calculates a "minimum" size that
    can be used by the control.

    Note 1: AutoHotkey does an excellent job of automatically calculating the
    width and/or height of the button control based upon the text that is
    included in the "gui Add,Button" command.  Personally, I think that the
    height calculated by AutoHotkey is excellent.  The width is very acceptable
    but I think that a some additional width is desired because it improves the
    look of the button and it makes the text a bit more readable.

    Note 2: By default, an ampersand (&) may be used in the button text to
    underline one of its letters.  To correctly calculate the width, be sure to
    exclude this character, when appropriate, from the calculation.
*/
ButtonControl:

;-- Initial calculations
gosub CalculateSize

;-- Adjust the width
OptWidth+=2*CXEDGE+Fnt_GetFontSize(hFont)

;-- Adjust the height
;   Note: For buttons, AutoHotkey does not use the GUI_CTL_VERTICAL_DEADSPACE
;   constant.  However, to ensure that the button text is readable with very
;   small and very large fonts, additional height is needed.  AutoHotkey uses a
;   calculation based on the font size to determine the additional height that
;   is needed.  IMHO, this calculation is dead on.
;
OptHeight+=Fnt_GetFontSize(hFont)+2

;-- Create/Show GUI
gui 2:Default
gui +Owner1
gui 1:+Disabled    ;-- Disable owner

gui Margin,10,6
gui -MinimizeBox
gui Add,Text,xm,Button created using AutoHokey defaults:
gui Font,% Fnt_GetFontOptions(hFont),% Fnt_GetFontName(hFont)
gui Add,Button,,%MyEdit%
gui Font
gui Add,Text,xm +Hidden,Dummy filler
gui Add,Text,xm,Button created using the Fnt library:
gui Font,% Fnt_GetFontOptions(hFont),% Fnt_GetFontName(hFont)
gui Add,Button,w%OptWidth% h%OptHeight%,%MyEdit%
gui Show,,Button Control
return


CalculateSize:
gui Submit,NoHide

;-- Determine the number of lines
StringReplace MyEdit,MyEdit,`n,`n,UseErrorLevel
NumberOfLines :=ErrorLevel+1

;[=========]
;[  Width  ]
;[=========]
;-- Determine the maximum width of the text
OptWidth :=0
Loop Parse,MyEdit,`n,`r
    {
    Fnt_GetStringSize(hFont,A_LoopField,Width)
    if (Width>OptWidth)
        OptWidth:=Width
    }

;-- Adjust width value.
;   Note: This adjustment was extracted from AutoHotkey source.  It is accurate
;   for 90%+ of the fonts.  You can add a few more pixels for additional
;   security but any additional dead space may look extraneous for most fonts.
;
if not ButtonRB
    OptWidth+=4+Fnt_GetFontAvgCharWidth(hFont)

;[==========]
;[  Heidth  ]
;[==========]
;-- Collect font values
FntHeight :=Fnt_GetFontHeight(hFont)
FntEL     :=Fnt_GetFontExternalLeading(hFont)

;-- Calcuate the height by adding up the font height for each row, and including
;   the space between lines (ExternalLeading) if there is more than one line.
;
OptHeight :=Floor((FntHeight*NumberOfLines)+(FntEL*(Floor(NumberOfLines+0.5)-1))+0.5)

;-- If needed, add vertical dead space.
;   Note: The GUI_CTL_VERTICAL_DEADSPACE constant was extracted from the
;   AutoHotkey source.  It is accurate for many (but not all) GUI controls.
;
if not ButtonRB
    OptHeight+=GUI_CTL_VERTICAL_DEADSPACE

return


ChooseFont:
if not Fnt_ChooseFont(hWindow,$FontName,$FontOptions,False)
    return

;-- Delete previous font (if any)
Fnt_DeleteFont(hFont)

;-- Create new font
hFont :=Fnt_CreateFont($FontName,$FontOptions)

;-- Attach the new font to the main Edit control
Fnt_SetFont(hEdit,hFont,True)
return


/*
    For the ComboBox control, the Ftn library can be used to determine the
    correct width of control so that the widest option can be seen without
    scrolling the option.

    Note: The calculations for the ComboBox are the same as for the
    DropDownList.
*/
ComboBoxControl:

;-- Initial calculations
gosub CalculateSize

;-- Adjust for the drop-down button
OptWidth+=CXVSCROLL

;-- Create/Show GUI
gui 2:Default
gui +Owner1
gui 1:+Disabled    ;-- Disable owner

gui Margin,10,6
gui -MinimizeBox +Delimiter`n
gui Add,Text,xm,ComboBox created using AutoHokey defaults:
gui Font,% Fnt_GetFontOptions(hFont),% Fnt_GetFontName(hFont)
gui Add,ComboBox,r9 Choose1,%MyEdit%
gui Font
gui Add,Text,xm +Hidden,Dummy filler
gui Add,Text,xm,ComboBox created using the Fnt library:
gui Font,% Fnt_GetFontOptions(hFont),% Fnt_GetFontName(hFont)
gui Add,ComboBox,w%OptWidth% r9 Choose1,%MyEdit%
gui Show,,ComboBox Control
return


/*
    For the DropDownList control (a.k.a. DDL), the Ftn library can be used to
    determine the correct width of control so that the widest option can be seen
    without scrolling the option.

    Note: The calculations for the DropDownList are the same as for the
    ComboBox.
*/
DDLControl:

;-- Initial calculations
gosub CalculateSize

;-- Adjust for the drop-down button
OptWidth+=CXVSCROLL

;-- Create/Show GUI
gui 2:Default
gui +Owner1
gui 1:+Disabled    ;-- Disable owner

gui Margin,10,6
gui -MinimizeBox +Delimiter`n
gui Add,Text,xm,Drop-down list created using AutoHokey defaults:
gui Font,% Fnt_GetFontOptions(hFont),% Fnt_GetFontName(hFont)
gui Add,DropDownList,r9 Choose1,%MyEdit%
gui Font
gui Add,Text,xm +Hidden,Dummy filler
gui Add,Text,xm,Drop-down list created using the Fnt library:
gui Font,% Fnt_GetFontOptions(hFont),% Fnt_GetFontName(hFont)
gui Add,DropDownList,w%OptWidth% r9 Choose1,%MyEdit%
gui Show,,DropDownList Control
return


/*
    For the Edit control, the Ftn library can be used to set the correct width
    and/or height of the control.
*/
EditControl:

;-- Initial calculations
gosub CalculateSize

;-- Adjust for the vertical scroll bar
if (NumberOfLines>1)
    OptWidth+=CXVSCROLL

;-- Create/Show GUI
gui 2:Default
gui +Owner1
gui 1:+Disabled    ;-- Disable owner

gui Margin,10,6
gui -MinimizeBox
gui Add,Text,xm,Edit control created using AutoHokey defaults:
gui Font,% Fnt_GetFontOptions(hFont),% Fnt_GetFontName(hFont)
gui Add,Edit,-Wrap vMyEdit2,%MyEdit%
gui Font
gui Add,Text,xm +Hidden,Dummy filler
gui Add,Text,xm,Edit control created using the Fnt library:
gui Font,% Fnt_GetFontOptions(hFont),% Fnt_GetFontName(hFont)
gui Add,Edit,w%OptWidth% h%OptHeight% -Wrap vMyEdit3
gui Show,,Edit Control
GUIControl,2:,MyEdit2,%MyEdit%
GUIControl,2:,MyEdit3,%MyEdit%
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


/*
    For the ListBox control, the Ftn library can be used to set the correct
    width and/or height of the control.
*/
ListBoxControl:

;-- Initial calculations
gosub CalculateSize

;-- Create/Show GUI
gui 2:Default
gui +Owner1
gui 1:+Disabled    ;-- Disable owner

gui Margin,10,6
gui -MinimizeBox +Delimiter`n
gui Add,Text,xm,ListBox created using AutoHokey defaults:
gui Font,% Fnt_GetFontOptions(hFont),% Fnt_GetFontName(hFont)
gui Add,ListBox,Choose1,%MyEdit%
gui Font
gui Add,Text,xm +Hidden,Dummy filler
gui Add,Text,xm,ListBox created using the Fnt library:
gui Font,% Fnt_GetFontOptions(hFont),% Fnt_GetFontName(hFont)
gui Add,ListBox,w%OptWidth% h%OptHeight% Choose1,%MyEdit%
gui Show,,ListBox Control
return


Reload:
Reload
return


TestButton:
gui Submit,NoHide

;-- Bounce, with prejudice, if the control is empty
if MyEdit is Space
    {
    SoundPlay *16  ;-- Default system error sound
    return
    }

;-- Process
if ButtonRB
    gosub ButtonControl
 else if ComboBoxRB
    gosub ComboBoxControl
 else if DDLRB
    gosub DDLControl
 else if EditRB
    gosub EditControl
 else if ListBoxRB
    gosub ListBoxControl
 else if TextRB
    gosub TextControl
 else if TooltipRB
    gosub TooltipControl

return


/*
    For the Text control, the Ftn library can be used to set the correct width
    and/or height of the control.

    Note: Although it is difficult to tell when this example is run, the width
    calculated is a bit wider than the AutoHotkey default.  The additional space
    is useful if the +Border option is used.
*/
TextControl:

;-- Width and height calculations
gosub CalculateSize

;-- Create/Show GUI
gui 2:Default
gui +Owner1
gui 1:+Disabled    ;-- Disable owner

gui Margin,10,6
gui -MinimizeBox
gui Add,Text,xm,Text control created using AutoHokey defaults:
gui Font,% Fnt_GetFontOptions(hFont),% Fnt_GetFontName(hFont)
gui Add,Text,,%MyEdit%
gui Font
gui Add,Text,xm +Hidden,Dummy filler
gui Add,Text,xm,Text control created using the Fnt library:
gui Font,% Fnt_GetFontOptions(hFont),% Fnt_GetFontName(hFont)
gui Add,Text,w%OptWidth% h%OptHeight%,%MyEdit%
gui Show,,Text Control
return


/*
    For the Tooltip control, the Ftn library can be used to set the Font for the
    control.

    Note: Unlike most other controls, the Tooltip control automatically adjusts
    the size of the Tooltiop window based on the text that provided for the
    control.  For multi-line text, there is no need to adjust the width or
    height of the control except in special circumstances.  For other Tooltip
    examples, see the "See Tooltip Width" script that is published with this
    library.
*/
TooltipControl:

;-- Initialize
CoordMode ToolTip,Screen

;-- Size calculations
gosub CalculateSize

;-- Clear out the old Tooltip (if needed)
Tooltip

;-- Build/Show the tooltip
Tooltip %MyEdit%,10,% A_ScreenHeight/2

;-- Collect the tooltip handle
gosub GetToolTipHandle

;-- Create/Set font
hFont :=Fnt_CreateFont($FontName,$FontOptions)
Fnt_SetFont(hTT,hFont,True)


;-- Create/Show GUI
gui 2:Default
gui +Owner1
gui 1:+Disabled    ;-- Disable owner

gui Margin,20,12
gui -MinimizeBox
gui Add,Text,xm,Press Escape or close this window to end the example.
gui Show,y0,Tooltip Control
return


2GUIClose:
2GUIEscape:
gui 1:-Disabled  ;-- Enable owner
gui Destroy

;-- Destroy tooltip (if any)
Tooltip
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%
#include Fnt.ahk
