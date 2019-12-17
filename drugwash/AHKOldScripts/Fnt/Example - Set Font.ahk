/*
    In this example, a ListView control is created using a random font size.
    Two edit controls are then created and set to the same font as list ListView
    control using two different methods.

    Programming note: Although the "gui Font" command is used twice to create
    a font, AutoHotkey only creates one logical font since both fonts have the
    exact same characteristics.
*/

#NoEnv
#SingleInstance Force
ListLines Off

;-- Build/Show GUI
gui Margin,0,0
gui -MinimizeBox

;-- Explanation for ListView control
gui Add,Text,,This ListView control was created using Verdana and a random font size.

;[====================]
;[  ListView control  ]
;[====================]
;-- Create new font using Verdana and a random font size
Random RandomFontSize,6,20
gui Font,s%RandomFontSize%,Verdana

;-- ListView control
gui Add,ListView,w800 r6 hWndhLV,Column 1|Column 2|Column 3

;-- Reset font to system default
gui Font

;-- Populate ListView
Loop 5
    {
    Row:=A_Index
    LV_Add("")
    Loop 3
        {
        Random RandomNumber,100000,999999
        LV_Modify(Row,"Col" . A_Index,RandomNumber)
        }
    }

Loop 3
    LV_ModifyCol(A_Index,"AutoHdr")


;[==================]
;[  Edit Control 1  ]
;[==================]
;-- Create using default font
gui Add,Edit,w400 h300 hWndhEdit,
   (ltrim join`s
    This Edit control was created using the system default font and size.  The
    font was then changed to match the ListView control by using the Fnt_SetFont
    function.
   )

;-- Set the font using the font from the ListView control
Fnt_SetFont(hEdit,Fnt_GetFont(hLV))

;[==================]
;[  Edit Control 2  ]
;[==================]
;-- Create new font using the AutoHokey "gui Font" command but use the 
;   Fnt_GetFontName and Fnt_GetFontOptions library function to determine the
;   font characteristics.  This method has it's drawbacks but it is useful when
;   you want AutoHotkey to automatically determine some of the characteristics
;   of the control(s) that are subsequently created.  Ex: Width, height, number
;   of rows, etc.
gui Font
   ,% Fnt_GetFontOptions(Fnt_GetFont(hLV))
   ,% Fnt_GetFontName(Fnt_GetFont(hLV))

;-- Edit control 2
gui Add,Edit,x+0 w400 h300 hWndhEdit2,
   (ltrim join`s
    Using the "gui Font" command with the Fnt_GetFontName and Fnt_GetFontOptions
    functions, this Edit control was created using the same font as the ListView
    control.
   )

;-- Reset font to system default
gui Font

;-- Buttons
gui Add,Button,xm Default gReload,%A_Space%     Rebuild example...     %A_Space%

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%
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
