/*
    In this example, the font options are collected directly from the logical
    font that is attached to the Edit control.  Under most circumstances, the
    options reflect original options that were selected but on occasion, the
    information will differ.

    Note: When choosing a font via the Fnt_ChooseFont function, an option to
    choose a text color is offered.  However, this script does not set the color
    selected. This is intentional because the Fnt_GetFontOptions function does
    not (read: is not able to) collect the text color.
*/

#NoEnv
#SingleInstance Force
ListLines Off

;-- Establish random font name and options
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

Random $FontSize,8,72
$FontOptions:="s" . $FontSize . A_Space

Random Bold,1,3         ;-- One in three chance
if (Bold=1)
   $FontOptions.="bold "

Random Italic,1,3       ;-- One in three chance       
if (Italic=1)
   $FontOptions.="italic "

Random Strike,1,3       ;-- One in three chance
if (Strike=1)
   $FontOptions.="strike "

Random Underline,1,3    ;-- One in three chance
if (Underline=1)
   $FontOptions.="underline "

;-- Build GUI
gui Margin,10,6
gui -MinimizeBox

;-- Buttons
gui Add,Button,gChooseFont,%A_Space%  Choose Font...  %A_Space%
gui Add,Button,x+40 wp Default vReload gReload,Rebuild...
gui Add,Edit,xm w900 h500 hWndhEdit vMyEdit
GUIControl Focus,Reload

;-- Create and set font
hFont :=Fnt_CreateFont($FontName,$FontOptions)
Fnt_SetFont(hEdit,hFont)

;-- Populdate/Update Edit control
gosub UpdateEdit

;-- Collect window handle
gui +LastFound
WinGet hWindow,ID

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,y0,%$ScriptTitle%
return


GUIEscape:
GUIClose:
ExitApp


ChooseFont:
if not Fnt_ChooseFont(hWindow,$FontName,$FontOptions)
    return

;-- Delete previous font (if any)
Fnt_DeleteFont(hFont)

;-- Create new font
hFont :=Fnt_CreateFont($FontName,$FontOptions)

;-- Attach the new font to the Edit control
Fnt_SetFont(hEdit,hFont,True)

;-- Update text on the Edit control
gosub UpdateEdit

;-- Adjust windows size
gui Show,AutoSize
return


Reload:
Reload
return


UpdateEdit:
;-- Update text on the Edit control.  To show that the correct font and font
;   options have been created, collect the information directly from the logical
;   font using library functions.
GUIControl
    ,
    ,MyEdit
    ,% Fnt_GetFontName(hFont)
        . "`nOptions: "  . Fnt_GetFontOptions(hFont)

return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%
#include Fnt.ahk
