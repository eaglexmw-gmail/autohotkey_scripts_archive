/*
    This script attempts to use as many Fnt library functions as
    possible/practical.
*/

#NoEnv
#SingleInstance Force
ListLines Off

;-- Initialize
$FontName     :="Arial"
$FontOptions  :="s12"
$PreviousColor:="c000000"  ;-- Black

;-- Create GUI using default font
gui Margin,10,10
gui -MinimizeBox

gui Add
   ,Button
   ,xm Default vChooseFont gChooseFont
   ,%A_Space%    Choose Font...    %A_Space%

gui Add
   ,Edit
   ,xm w900 h500 hWndhEdit vMyEdit

GUIControl Focus,ChooseFont

;-- Collect window handle
gui +LastFound
WinGet hWindow,ID

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,y0,%$ScriptTitle%

;-- Create and set font
gosub ChooseFont
return


GUIEscape:
GUIClose:
Fnt_DeleteFont(hFont)
ExitApp


ChooseFont:

;-- Bounce if user cancels
if not Fnt_ChooseFont(hWindow,$FontName,$FontOptions)
    return

;-- If needed, set color
/*
Programming notes:

Setting and changing a control's text and/or background color can be a complex
subject and the method may be different for each control.  For the Edit control
used by this script, color is set/updated via the WM_CTLCOLOREDIT message.
Since the standard Edit control is supported by AutoHotkey and was created using
a standard AutoHotkey command, the WM_CTLCOLOREDIT message triggered by this
control is automatically handled by AutoHotkey.

A logical font has many attributes (height, weight, etc.) but color is not one
of them.  When the Color option of the "gui font" command is used (Ex: cRed),
AutoHotkey doesn't do anything with specified color until a control is created
(Example 1) or until the attributes of the font (including the color) are
assigned to the control via the GUIControl command (Example 2).

    Example 1
    ---------
    gui Font,s12 cGreen
    gui Add,Edit,vMyEdit


    Example 2
    ---------
    gui Font,cBlue
    GUIControl Font,MyEdit


To set the text color chosen by the user via the Fnt_ChooseFont function, this
script uses the "gui Font" command followed by the "GUIControl Font" command
(Example 2).  Setting the text color by other means is possible (hint: big pain
in the butt) but it would override the default behavior of an Edit control
created by AutoHotkey.

In addition to changing the color, the "GUIControl Font" command, by default,
will temporarily attach the current (and only) AutoHotkey-created font to the
Edit control.  The word "temporarily" is used because the Edit control is
immediately set to the font created by the Fnt_CreateFont function.  The user
should not see the first change since the control is not redrawn until after
the last command is executed.

The "gui Font" command doesn't create a new font if only the color option is
specified (Ex: "gui Font,cNavy") so calling this command repeatedly will not
raise the "Too many fonts" script error.
*/
Loop Parse,$FontOptions,%A_Space%
    if (SubStr(A_LoopField,1,1)="c")
        {
        if (A_LoopField<>$PreviousColor)
            {
            gui Font,%A_LoopField%
            GUIControl Font,MyEdit
            $PreviousColor:=A_LoopField
            }

        Break
        }

;-- Delete old font, if it exists
Fnt_DeleteFont(hFont)

;-- Create and set font
hFont:=Fnt_CreateFont($FontName,$FontOptions)
Fnt_SetFont(hEdit,hFont)

;-- Update text on the Edit control
GUIControl
    ,
    ,MyEdit
    ,% "Fnt_GetFontName:`t`t" . Fnt_GetFontName(hFont)
        . "`nFnt_GetFontSize:`t`t" . Fnt_GetFontSize(hFont)
        . "`nFnt_GetFontHeight:`t`t" . Fnt_GetFontHeight(hFont)
        . "`nFnt_GetFontWeight:`t`t" . Fnt_GetFontWeight(hFont)
        . "`nFnt_GetFontInternalLeading:`t" . Fnt_GetFontInternalLeading(hFont)
        . "`nFnt_GetFontExternalLeading:`t" . Fnt_GetFontExternalLeading(hFont)
        . "`nFnt_GetFontAvgCharWidth:`t" . Fnt_GetFontAvgCharWidth(hFont)
        . "`nFnt_GetFontMaxCharWidth:`t" . Fnt_GetFontMaxCharWidth(hFont)
        . "`nFnt_GetFontOptions:`t" . Fnt_GetFontOptions(hFont)
        . "`nFnt_IsFixedPitchFont:`t" . (Fnt_IsFixedPitchFont(hFont) ? "Yes":"No")
        . "`nFnt_IsTrueTypeFont:`t`t" . (Fnt_IsTrueTypeFont(hFont) ? "Yes":"No")
        . "`nFnt_IsVectorFont:`t`t" . (Fnt_IsVectorFont(hFont) ? "Yes":"No")

return


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
