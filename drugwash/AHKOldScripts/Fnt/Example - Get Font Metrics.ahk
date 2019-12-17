#NoEnv
#SingleInstance Force
ListLines Off

;-- Initialize
PtrType   :=(A_PtrSize=8) ? "Ptr":"UInt"
TCharSize :=A_IsUnicode ? 2:1

TMPF_FIXED_PITCH :=0x1
TMPF_VECTOR      :=0x2
TMPF_TRUETYPE    :=0x4
TMPF_DEVICE      :=0x8

;-- Establish random font name/size
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

;-- Calculate button width
ButtonW:=Fnt_GetStringWidth(0,"Font Metrics GUI")+(Fnt_GetFontAvgCharWidth(0)*6)

;-- Buttons
gui Add
   ,Button
   ,xm w%ButtonW% gChooseFont
   ,%A_Space%  Choose Font...  %A_Space%

gui Add,Button,x+5  wp gShowFontMetrics,Font Metrics
gui Add,Button,x+5  wp gFontMetricsGUI,Font Metrics GUI
gui Add,Button,x+40 wp Default vReload gReload,Rebuild...
GUIControl Focus,Reload

gui Font,%$FontOptions%,%$FontName%
gui Add,Edit,xm w900 h500 hWndhEdit vMyEdit,%$FontName%`nSize: %$FontSize%
gui Font

;-- Collect window handle
gui +LastFound
WinGet hWindow,ID

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,y0,%$ScriptTitle%

;;;;;gosub ShowFontMetrics
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

;-- Update text on the Edit control.  To show that the correct font with
;   the specified options has been created, collect the font name/size using
;   library functions.
GUIControl
    ,
    ,MyEdit
    ,% Fnt_GetFontName(hFont)
        . "`nSize: " . Fnt_GetFontSize(hFont)
;;;;;        . "`nOptions: " . $FontOptions

;-- Adjust windows size
gui Show,AutoSize
return


GetFontMetrics:
;-- Get metrics for the font attached to the Edit control
pTM :=Fnt_GetFontMetrics(Fnt_GetFont(hEdit))

;-- Extract values from the TEXTMETRIC structure
Height           :=NumGet(pTM+0,0,"Int")
Ascent           :=NumGet(pTM+0,4,"Int")
Descent          :=NumGet(pTM+0,8,"Int")
InternalLeading  :=NumGet(pTM+0,12,"Int")
ExternalLeading  :=NumGet(pTM+0,16,"Int")
AveCharWidth     :=NumGet(pTM+0,20,"Int")
MaxCharWidth     :=NumGet(pTM+0,24,"Int")
Weight           :=NumGet(pTM+0,28,"Int")
Overhang         :=NumGet(pTM+0,32,"Int")
DigitizedAspectX :=NumGet(pTM+0,36,"Int")
DigitizedAspectY :=NumGet(pTM+0,40,"Int")

VarSetCapacity(FirstChar,A_IsUniCode ? 2:1,0)
DllCall("lstrcpyn" . (A_IsUnicode ? "W":"A"),"Str",FirstChar,PtrType,pTM+44,"Int",2)
VarSetCapacity(FirstChar,-1)

FirstCharVal    :=NumGet(pTM+0,44,A_IsUnicode ? "UShort":"UChar")
if (FirstCharVal=32)
    FirstCharVal:="32 - space"

if (FirstCharVal=30)
    FirstCharVal:="30 - record separator"

VarSetCapacity(LastChar,A_IsUniCode ? 2:1,0)
DllCall("lstrcpyn" . (A_IsUnicode ? "W":"A"),"Str",LastChar,PtrType,pTM+44+TCharSize,"Int",2)
VarSetCapacity(LastChar,-1)

LastCharVal     :=NumGet(pTM+0,44+TCharSize,A_IsUnicode ? "UShort":"UChar")
if (LastCharVal=31)
    LastCharVal:="31 - unit separator"

VarSetCapacity(DefaultChar,A_IsUniCode ? 2:1,0)
DllCall("lstrcpyn" . (A_IsUnicode ? "W":"A"),"Str",DefaultChar,PtrType,pTM+44+(TCharSize*2),"Int",2)
VarSetCapacity(DefaultChar,-1)

DefaultCharVal :=NumGet(pTM+0,44+(TCharSize*2),A_IsUnicode ? "UShort":"UChar")
if (DefaultCharVal=31)
    DefaultCharVal:="31 - unit separator"

VarSetCapacity(BreakChar,A_IsUniCode ? 2:1,0)
DllCall("lstrcpyn" . (A_IsUnicode ? "W":"A"),"Str",BreakChar,PtrType,pTM+44+(TCharSize*3),"Int",2)
VarSetCapacity(BreakChar,-1)

BreakCharVal   :=NumGet(pTM+0,44+(TCharSize*3),A_IsUnicode ? "UShort":"UChar")
if (BreakCharVal=32)
    BreakCharVal:="32 - space"

Italic         :=NumGet(pTM+0,44+(TCharSize*4),"UChar") ? "Yes":"No"
Underline      :=NumGet(pTM+0,44+(TCharSize*4)+1,"UChar") ? "Yes":"No"
Strikeout      :=NumGet(pTM+0,44+(TCharSize*4)+2,"UChar") ? "Yes":"No"
PitchAndFamily :=NumGet(pTM+0,44+(TCharSize*4)+3,"UChar")

PFInfo :=""
if PitchAndFamily & TMPF_FIXED_PITCH
   PFInfo.=(StrLen(PFInfo) ? ", ":"") . "variable pitch"
 else
   PFInfo.=(StrLen(PFInfo) ? ", ":"") . "fixed pitch"

if PitchAndFamily & TMPF_VECTOR
   PFInfo.=(StrLen(PFInfo) ? ", ":"") . "vector"

if PitchAndFamily & TMPF_TRUETYPE
   PFInfo.=(StrLen(PFInfo) ? ", ":"") . "TrueType"

if PitchAndFamily & TMPF_DEVICE
   PFInfo.=(StrLen(PFInfo) ? ", ":"") . "device font"

;-- Get misc. font information
FontName :=Fnt_GetFontName(Fnt_GetFont(hEdit))
return


ShowFontMetrics:
gosub GetFontMetrics

;-- Display results
gui +OwnDialogs
MsgBox,
   (ltrim
    Typeface name:`t`t%FontName%
    Height:`t`t`t%Height%
    Ascent:`t`t`t%Ascent%
    Descent:`t`t`t%Descent%
    Internal Leading:`t`t%InternalLeading%
    External Leading:`t`t%ExternalLeading%
    Average Char Width:`t%AveCharWidth%
    Maximum Char Width:`t%MaxCharWidth%
    Weight:`t`t`t%Weight%
    Overhang:`t`t%Overhang%
    Digitized Aspect X:`t`t%DigitizedAspectX%
    Digitized Aspect Y:`t`t%DigitizedAspectY%
    First Char:`t`t%FirstChar%`t(%FirstCharVal%)
    Last Char:`t`t%LastChar%`t(%LastCharVal%)
    Default Char:`t`t%DefaultChar%`t(%DefaultCharVal%)
    Break Char:`t`t%BreakChar%`t(%BreakCharVal%)
    Italic:`t`t`t%Italic%
    Underline:`t`t%Underline%
    Strikeout:`t`t`t%Strikeout%
    Pitch and Family:`t`t%PitchAndFamily% (%PFInfo%)  %A_Space%
   )

return


FontMetricsGUI:
gosub GetFontMetrics

;-- Build GUI
gui 2:Default
gui +Owner1
gui 1:+Disabled    ;-- Disable owner
gui -MinimizeBox
gui Margin,10,0

;-- Use same font name as the Edit control with fixed s12 size but use no other options
$FontOptions2:="s12"
gui Font,%$FontOptions2%,%$FontName%
hFont2 :=Fnt_CreateFont($FontName,$FontOptions2)

;-- Calculate the width of the prompts
Fnt_GetStringSize(hFont2,"Maximum Char Width:",PromptW)
PromptW+=Fnt_GetFontAvgCharWidth(hFont2)

gui Add,Text,xm Hidden,Dummy Filler
gui Add,Text,xm w%PromptW%,Typeface name:
gui Add,Text,x+0,%FontName%
gui Add,Text,xm w%PromptW%,Height:
gui Add,Text,x+0,%Height%
gui Add,Text,xm w%PromptW%,Ascent:
gui Add,Text,x+0,%Ascent%
gui Add,Text,xm w%PromptW%,Descent:
gui Add,Text,x+0,%Descent%
gui Add,Text,xm w%PromptW%,Internal Leading:
gui Add,Text,x+0,%InternalLeading%
gui Add,Text,xm w%PromptW%,External Leading:
gui Add,Text,x+0,%ExternalLeading%
gui Add,Text,xm w%PromptW%,Average Char Width:
gui Add,Text,x+0,%AveCharWidth%
gui Add,Text,xm w%PromptW%,Maximum Char Width:
gui Add,Text,x+0,%MaxCharWidth%
gui Add,Text,xm w%PromptW%,Weight:
gui Add,Text,x+0,%Weight%
gui Add,Text,xm w%PromptW%,Overhang:
gui Add,Text,x+0,%Overhang%
gui Add,Text,xm w%PromptW%,Digitized Aspect X:
gui Add,Text,x+0,%DigitizedAspectX%
gui Add,Text,xm w%PromptW%,Digitized Aspect Y:
gui Add,Text,x+0,%DigitizedAspectY%
gui Add,Text,xm w%PromptW%,First Char:
gui Add,Text,x+0,%FirstChar%`t(%FirstCharVal%)
gui Add,Text,xm w%PromptW%,Last Char:
gui Add,Text,x+0,%LastChar%`t(%LastCharVal%)
gui Add,Text,xm w%PromptW%,Default Char:
gui Add,Text,x+0,%DefaultChar%`t(%DefaultCharVal%)
gui Add,Text,xm w%PromptW%,Break Char:
gui Add,Text,x+0,%BreakChar%`t(%BreakCharVal%)
gui Add,Text,xm w%PromptW%,Italic:
gui Add,Text,x+0,%Italic%
gui Add,Text,xm w%PromptW%,Underline:
gui Add,Text,x+0,%Underline%
gui Add,Text,xm w%PromptW%,Strikeout:
gui Add,Text,x+0,%Strikeout%
gui Add,Text,xm w%PromptW%,Pitch and Family:
gui Add,Text,x+0,%PitchAndFamily% (%PFInfo%)
gui Add,Text,xm Hidden,Dummy Filler
gui Font
gui Add,Button,Default g2GUIClose,%A_Space%      OK      %A_Space%
gui Add,Text,xm Hidden,Dummy Filler

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%


return

2GUIClose:
2GUIEscape:
gui 1:-Disabled  ;-- Enable owner
gui Destroy
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
