/*
    Background
    ----------
    By default, the tooltips created by AutoHotkey can show multiple lines.  If
    the the text is longer than the screen width, the tooltip control will break
    the tooltip text into multiple lines.  This occurs automatically because
    when the tooltip control is created, AutoHotkey sets the maximum tip width
    to the width of the primary monitor.  In addition, the developer can force
    multiple lines by including a newline character (i.e. "`n") within the
    tooltip text.

    The Problem
    -----------
    Tooltips with a large amount of a text can be difficult to read because the
    text is displayed across the entire screen.  The developer can improve
    readability by adding newline characters within the text but the workaround
    is hit-and-miss and can be problematic if the text is dynamic.

    Solution
    --------
    In this example, the Fnt library is used to calculate a new "maximum tip
    width" for a tooltip based upon a "maximum number of characters" per line.
    This technique will show the same number of characters per line regardless
    of the current font or font size.

    Observations and Notes
    ----------------------
    This example uses the Fnt_GetFontAvgCharWidth function to calculate the
    "maximum tip width" for the tooltip.  As you might imagine, the calculation
    is dead-on when using a monospaced font.  For proportional fonts, this
    technique is fairly accurate but the content can cause deviations.  Ex:
    Using text with all uppercase characters.  If the text has unique
    characteristics, use Fnt_GetStringWidth for improved accuracy.
*/

#NoEnv
#SingleInstance Force
;;;;;#Persistent
ListLines Off

;-- Initialize
CoordMode Tooltip,Screen

hFont :=0
    ;-- If not zero, this variable contains the handle to the current font.

hTT :=0
    ;-- If the tooltip is showing, this variable contains the handle to the
    ;   tooltip control

NumberOfCharacters :=0
    ;-- This variable contains the user-requested width of the tooltip window,
    ;   in characters.

TipWidth :=0
    ;-- This variable contains the calculated width of the tooltip window, in
    ;   pixels.

TTM_SETMAXTIPWIDTH :=0x418                              ;-- WM_USER + 24

;-- Identify window handle
gui +LastFound
WinGet hWindow,ID

;-- GUI Options and Objects
gui -MinimizeBox
gui Add
   ,Button
   ,% "xm w250 "
        . "gChooseFont "
   ,Choose font`n(Optional)

gui Add
   ,Button
   ,% "xm y+0 wp hp "
        . "gSetMaxTipWidth "
   ,Set maximum tip width`n(in characters)

;;;;;gui Add
;;;;;   ,Button
;;;;;   ,% "xm y+0 wp hp "
;;;;;        . "gShowTooltip "
;;;;;   ,Show the tooltip
;;;;;
;;;;;gui Add
;;;;;   ,Button
;;;;;   ,% "xm y+0 wp hp "
;;;;;        . "gHideTooltip "
;;;;;   ,Hide the tooltip

gui Add
   ,Button
   ,% "xm y+0 wp hp "
        . "hWndhButton4 "
        . "gReload "
   ,Reload...

;-- Show window
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show
    ,% "x" . Round(A_ScreenWidth*0.65) . " y" . Round(A_ScreenHeight*0.65)
    ,%$ScriptTitle%

;-- Show tooltip
gosub ShowTooltip
return


ChooseFont:
FontName    :=Fnt_GetFontName(Fnt_GetFont(hTT))
FontOptions :=Fnt_GetFontOptions(Fnt_GetFont(hTT))
if not Fnt_ChooseFont(hWindow,FontName,FontOptions,False)
    Return

;-- Delete previous font (if any)
Fnt_DeleteFont(hFont)

;-- Create new font
hFont :=Fnt_CreateFont(FontName,FontOptions)

;-- Bounce if the tooltip is not showing
if not hTT
    return

;-- Set/Show changes
gosub ShowTooltip

;-- If the number of characters has not been set, we're done here
if not NumberOfCharacters
    return

Message=
   (ltrim join`s
    Based on the font selection, the maximum tip width has been set to
    %TipWidth% pixels.  This width will show ~%NumberOfCharacters% characters on
    every tooltip line.
   )

;-- Inform the user
if (TipWidth<=A_ScreenWidth)
    MsgBox 0x40,Maximum Tip Width,%Message%
 else
    MsgBox
        ,0x30
        ,Maximum Tip Width,
           (ltrim join`s
            %Message%

            `n`nWarning: The maximum tip width is wider than screen width.  Not
            all of the text in tooltip may be shown.
           )

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


HideTooltip:
Tooltip
hTT :=0
return


Reload:
Reload
return


SetMaxTipWidth:
gui +OwnDialogs
Loop
    {
    t_NumberOfCharacters:=NumberOfCharacters ? NumberOfCharacters:100
    InputBox
        ,t_NumberOfCharacters
        ,Maximum ToolTip Width
        ,Enter the maximum tooltip width (in characters):
        ,
        ,300
        ,150
        ,
        ,
        ,
        ,
        ,%t_NumberOfCharacters%

    if ErrorLevel
        return

    if t_NumberOfCharacters is Integer
        if (t_NumberOfCharacters>0)
            Break

    SoundPlay *16  ;-- System error sound
    }

NumberOfCharacters :=t_NumberOfCharacters

;-- Show changes
gosub ShowTooltip

Message=
   (ltrim join`s
    The maximum tip width has been set to %TipWidth% pixels.  This width will
    show ~%NumberOfCharacters% characters on every tooltip line.

    `n`nNote: This value was calculated based on the current font and font
    size.  If the font and/or font size changes, the maximum tip width will be
    recalculated.
   )

;-- Inform the user
if (TipWidth<=A_ScreenWidth)
    MsgBox 0x40,Maximum Tip Width,%Message%
 else
    MsgBox
        ,0x30
        ,Maximum Tip Width,
           (ltrim join`s
            %Message%

            `n`nWarning: The maximum tip width is wider than screen width.  Not
            all of the text in tooltip may be shown.
           )
return


ShowTooltip:

;;;;;;-- Clear out the old Tooltip (if needed)
;;;;;gosub HideTooltip

;-- Build/Show the new tooltip
TooltipText=
   (ltrim join`s
    Four score and seven years ago our fathers brought forth on this continent a
    new nation, conceived in Liberty, and dedicated to the proposition that all
    men are created equal.

    `n`nNow we are engaged in a great civil war, testing whether that nation, or
    any nation, so conceived and so dedicated, can long endure.  We are met on a
    great battle-field of that war.  We have come to dedicate a portion of that
    field, as a final resting place for those who here gave their lives that
    that nation might live.  It is altogether fitting and proper that we should
    do this.

    `n`nBut, in a larger sense, we can not dedicate... we can not consecrate...
    we can not hallow this ground.  The brave men, living and dead, who
    struggled here, have consecrated it, far above our poor power to add or
    detract.  The world will little note, nor long remember what we say here,
    but it can never forget what they did here.  It is for us the living,
    rather, to be dedicated here to the unfinished work which they who fought
    here have thus far so nobly advanced.  It is rather for us to be here
    dedicated to the great task remaining before us — that from these honored
    dead we take increased devotion to that cause for which they gave the last
    full measure of devotion — that we here highly resolve that these dead shall
    not have died in vain — that this nation, under God, shall have a new birth
    of freedom — and that government: of the people, by the people, for the
    people, shall not perish from the earth.
   )

Tooltip %TooltipText%,0,30

;-- Collect the tooltip handle
gosub GetToolTipHandle

;-- If not previously selected/collected, collect the current font and create a
;   new font with the same characteristics.
if not hFont
    {
    hFont:=Fnt_GetFont(hTT)
    hFont:=Fnt_CreateFont(Fnt_GetFontName(hFont),Fnt_GetFontOptions(hFont))
    }

;-- If set by the user, calculate and set the maximum tip width
if NumberOfCharacters
    {
    TipWidth:=Fnt_GetFontAvgCharWidth(hFont)*NumberOfCharacters
    SendMessage TTM_SETMAXTIPWIDTH,0,TipWidth,,ahk_id %hTT%
    }

;-- Set font - Force redraw
Fnt_SetFont(hTT,hFont,True)
return


GUIClose:
GUIEscape:
Fnt_DeleteFont(hFont)
ExitApp


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%
#include Fnt.ahk
