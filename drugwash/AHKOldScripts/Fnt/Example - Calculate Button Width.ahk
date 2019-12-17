/*
    In this example, the width of three buttons are created based on the width
    of the button with the widest button name.  Hint: When running the example,
    be sure to change the "Any string here" values to strings of varying
    lengths.
*/

#NoEnv
#SingleInstance Force
ListLines Off

;-- Collect names for 3 buttons.
AnyString:="One"
Loop 3
    {
    if (A_Index=2)
        AnyString.=" Two"

    if (A_Index=3)
        AnyString.=" Three"

    InputBox IB_String,Button Name,Enter any string for button %A_Index%:,,300,140,,,,,%AnyString%
    if ErrorLevel
        ExitApp
      
    IB_String=%IB_String%  ;-- Autotrim
    ButtonName%A_Index%:=IB_String
    }

;-- Build GUI
gui -MinimizeBox

;-- Large margins so the buttons will show prominently in the window
gui Margin,50,50

;-- Find the widest button name
ButtonW:=0
Loop 3
    {
    W:=Fnt_GetStringWidth(0,ButtonName%A_Index%)
    if (W>ButtonW)
        ButtonW:=W
    }

;-- Add appropriate padding
;   Note: This is the approximate minimum padding.  Additional padding will make
;   the buttons look better.
ButtonW+=Fnt_GetFontAvgCharWidth(0)*3

;-- Add buttons with fixed width
gui Add,Text,xm,The width of these buttons were calculated using the Fnt library.
gui Add,Button,xm y+5 w%ButtonW%,%ButtonName1%
gui Add,Button,xm y+0 w%ButtonW%,%ButtonName2%
gui Add,Button,xm y+0 w%ButtonW%,%ButtonName3%

;-- Add buttons using AHK defaults
gui Add,Text,xm,These buttons were created using the AutoHotkey defaults.
gui Add,Button,xm y+5,%ButtonName1%
gui Add,Button,xm y+0,%ButtonName2%
gui Add,Button,xm y+0,%ButtonName3%

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
