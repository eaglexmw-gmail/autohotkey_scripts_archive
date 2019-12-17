/*
    In this example, the Edit control is automatically adjusted (width and
    height) to accommodate the font and the contents of the Edit field.  The
    primary size (width and height) is returned from the Fnt_GetStringSize
    function.  Values added to the width and the height were collected from
    values and calculations found in the AutoHotkey source.


    Observations:

    The value for height (when added to the GUI_CTL_VERTICAL_DEADSPACE constant
    provided by the AutoHotkey source) is always dead-on.  This value is
    accurate because it is collected directly from the font.

    The calculations for width (along with the constants and values extracted
    from the AutoHotkey source) are amazingly accurate for 97%+ of the fonts.
    For the fonts that miss the mark, the calculations are only off by a few
    pixels at most.
*/

#NoEnv
#SingleInstance Force
ListLines Off

;-- Constants 
GUI_CTL_VERTICAL_DEADSPACE :=8

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

;-- GUI
gui Margin,6,6
gui -MinimizeBox
gui Add,Button,gChooseFont,%A_Space%  Choose Font...  %A_Space%
gui Add,Button,x+30 wp gReload,Rebuild...

gui Font,%$FontOptions%,%$FontName%
gui Add,Edit,xm hWndhEdit vMyEdit gAdjust,Put whatever you want in this field.
gui Font

;-- Get the handle of the current font.  Not used unless the Adjust button is
;   pressed.
hFont :=Fnt_GetFont(hEdit)

;-- Collect the window handle
gui +LastFound
WinGet hWindow,ID

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,x0 y0,%$ScriptTitle%
return


GUIClose:
GUIEscape:
ExitApp


Adjust:
gui Submit,NoHide

;-- Bounce (with prejudice) if the Edit control is completely empty.
if not StrLen(MyEdit)
    {
    SoundPlay *16  ;-- System error
    return
    }

;-- Calculate size (width and height) of the contents of the Edit control
Fnt_GetStringSize(hFont,MyEdit,Width,Height)

;-- Adjust width and height values
Width +=4+Fnt_GetFontAvgCharWidth(hFont)
Height+=GUI_CTL_VERTICAL_DEADSPACE

;-- Adjust width and height of the Edit control
GUIControl,Move,MyEdit,% "w" . Width . " h" . Height
gui Show,AutoSize
return


ChooseFont:
if not Fnt_ChooseFont(hWindow,$FontName,$FontOptions,False)
    return

;-- Delete previous font (if any)
Fnt_DeleteFont(hFont)

;-- Create new font
hFont :=Fnt_CreateFont($FontName,$FontOptions)

;-- Attach the new font to the Edit control
Fnt_SetFont(hEdit,hFont,True)

gosub Adjust
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
