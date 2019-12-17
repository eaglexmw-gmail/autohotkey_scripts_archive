/*
    In this example, the height of an Edit control is determined by the height
    and external leading of the font, the number of lines as determined by the
    user, and by constants and calculations extracted from the AutoHotkey
    source.
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

;-- Build GUI
gui -MinimizeBox
gui Add,Button,gChooseFont,%A_Space%  Choose Font...  %A_Space%
gui Add,Text,x+10,Number of lines:
gui Add,Edit,x+5 w50 vNumberOfLines
gui Add,UpDown,gAdjust Range1-30,9
gui Add,Button,x+5 gAdjust Default,%A_Space%  Adjust  %A_Space%
gui Add,Button,x+40 gReload,%A_Space%    Rebuild...    %A_Space%

gui Font,%$FontOptions%,%$FontName%
gui Add,Edit,xm w800 r9 hWndhEdit vMyEdit,
   (ltrim
    This is the text for line 1
    This is the text for line 2
    This is the text for line 3
    This is the text for line 4
    This is the text for line 5
    This is the text for line 6
    This is the text for line 7
    This is the text for line 8
    This is the text for line 9
   )
    
gui Font

;-- Get the handle of the current font.  Not used unless the Adjust button is
;   pressed.
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


Adjust:
gui Submit,NoHide

if NumberOfLines is not Integer
    return

;-- Collect font values
Height          :=Fnt_GetFontHeight(hFont)
ExternalLeading :=Fnt_GetFontExternalLeading(hFont)

;-- Calcuate the height by adding up the font height for each row, and including
;   the space between lines (ExternalLeading) if there is more than one line.
OptHeight :=Floor((Height*NumberOfLines)+(ExternalLeading*(Floor(NumberOfLines+0.5)-1))+0.5)
OptHeight+=GUI_CTL_VERTICAL_DEADSPACE

;-- Adjust the height of the Edit control
GUIControl,Move,MyEdit,% "h" . OptHeight
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
