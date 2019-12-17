/*
    With the exception of the first font that is automatically created when a
    GUI is created, this script creates and sets all fonts selected by user
    using library functions.
*/

#NoEnv
#SingleInstance Force
ListLines Off

;-- Initialize
$FontName   :="Arial"
$FontOptions:="s48"

;-- Create GUI using default font
gui Margin,10,10
gui -MinimizeBox

gui Add
   ,Button
   ,xm Default vChooseFont gChooseFont
   ,%A_Space%    Choose Font...    %A_Space%

gui Add
   ,Edit
   ,xm w800 h500 hWndhEdit vMyEdit

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
if not Fnt_ChooseFont(hWindow,$FontName,$FontOptions,False)
    return

;-- Delete old font, if it exists
Fnt_DeleteFont(hFont)

;-- Create and set font
hFont :=Fnt_CreateFont($FontName,$FontOptions)
Fnt_SetFont(hEdit,hFont)

;-- Update text on the Edit control.  To show that the correct font with
;   the specified options has been created, collect the font name/size using
;   library functions.
GUIControl
    ,
    ,MyEdit
    ,% Fnt_GetFontName(hFont)
        . "`nSize: " . Fnt_GetFontSize(hFont)
        . "`nOptions: " . $FontOptions

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
