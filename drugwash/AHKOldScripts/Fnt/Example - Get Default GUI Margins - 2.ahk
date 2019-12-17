#NoEnv
#SingleInstance Force
ListLines Off

;-- Initialize
FileRead ListOfFontNames,%A_ScriptDir%\_Example Files\GUIFonts.txt

TotalNumberOfFontNames :=0
Loop Parse,ListOfFontNames,`n,`r
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
gui Font,%$FontOptions%,%$FontName%
gui Add,Edit,w800 hWndhEdit vMyEdit,%$FontName%`nSize: %$FontSize%
GUIControlGet MyEditPos,Pos,MyEdit
gui Font
gui Add,Button,Default vReload gReload,%A_Space%    Rebuild...    %A_Space%
GUIControl Focus,Reload

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,y0,%$ScriptTitle%

;-- Collect/Show default margins
RC:=Fnt_GetDefaultGUIMargins(Fnt_GetFont(hEdit))
gui +OwnDialogs
MsgBox,
   (ltrim
    Calculated default X/Y margins using the font that was used when the Edit control was added:  %A_Space%

    `t%RC%

    Actual X/Y position of the Edit control:

    `t%MyEditPosX%,%MyEditPosY%
   )

return


GUIEscape:
GUIClose:
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
