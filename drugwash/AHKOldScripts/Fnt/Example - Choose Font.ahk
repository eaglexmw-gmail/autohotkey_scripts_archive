/*
    This script uses the Fnt_ChooseFont function to choose the font but uses
    standard AutoHotkey commands to set and change the font on the Edit control.
*/

#NoEnv
#SingleInstance Force
ListLines Off

;-- ChooseFont flags
CF_SCRIPTSONLY:=0x400
    ;-- Allow selection of fonts for all non-OEM and Symbol character sets, as
    ;   well as the ANSI character set.

CF_NOOEMFONTS:=0x800
    ;-- (Despite what the documentation states, this flag is used to) prevent
    ;   the dialog box from displaying and selecting OEM fonts.  Ex: Terminal

CF_NOSIMULATIONS:=0x1000
    ;-- Prevent the dialog box from displaying or selecting font simulations.

CF_LIMITSIZE:=0x2000
    ;-- Select only font sizes within the range specified by the nSizeMin and
    ;   nSizeMax members.  This flag is automatically added if the SizeMin
    ;   and/or the SizeMax options (p_Options parameter) are used.

CF_FIXEDPITCHONLY:=0x4000
    ;-- Show and allow selection of only fixed-pitch fonts.

CF_FORCEFONTEXIST:=0x10000
    ;-- Display an error message if the user attempts to select a font or style
    ;   that is not listed in the dialog box.

CF_SCALABLEONLY:=0x20000
    ;-- Show and allow selection of only scalable fonts.  Scalable fonts include
    ;   vector fonts, scalable printer fonts, TrueType fonts, and fonts scaled
    ;   by other technologies.

CF_TTONLY:=0x40000
    ;-- Show and allow the selection of only TrueType fonts.

CF_NOFACESEL:=0x80000
    ;-- Prevent the dialog box from displaying an initial selection for the font
    ;   name combo box.

CF_NOSTYLESEL:=0x100000
    ;-- Prevent the dialog box from displaying an initial selection for the
    ;   Font Style combo box.

CF_NOSIZESEL:=0x200000
    ;-- Prevent the dialog box from displaying an initial selection for the Font
    ;   Size combo box.

CF_NOSCRIPTSEL:=0x800000
    ;-- Disables the Script combo box.

CF_NOVERTFONTS:=0x1000000
    ;-- Display only horizontally oriented fonts.

;-- Initialize
$FontName   :="Arial"
$FontOptions:="s48"

;-- Create GUI using the default GUI font
gui Margin,10,10
gui -MinimizeBox

gui Add
   ,Button
   ,Default vChooseFont gChooseFont
   ,%A_Space%    Choose Font...    %A_Space%

gui Add,CheckBox,xm         vGUI_Effects Checked,Show Effects options
gui Add,Text,    xm,SizeMin:   %A_Space%
gui Add,Edit,    x+0 w50    vGUI_SizeMin Number Section
gui Add,Text,    xm y+0,SizeMax:
gui Add,Edit,    x+0 xs w50 vGUI_SizeMax Number
gui Add,Text,    xm,Advanced options:                       
gui Add,CheckBox,xm+10      vGUI_FIXEDPITCHONLY, CF_FIXEDPITCHONLY
gui Add,CheckBox,xm+10 y+0  vGUI_NOFACESEL,      CF_NOFACESEL
gui Add,CheckBox,xm+10 y+0  vGUI_NOOEMFONTS,     CF_NOOEMFONTS
gui Add,CheckBox,xm+10 y+0  vGUI_NOSCRIPTSEL,    CF_NOSCRIPTSEL
gui Add,CheckBox,xm+10 y+0  vGUI_NOSIZESEL,      CF_NOSIZESEL
gui Add,CheckBox,xm+10 y+0  vGUI_NOSTYLESEL,     CF_NOSTYLESEL
gui Add,CheckBox,xm+10 y+0  vGUI_NOVERTFONTS,    CF_NOVERTFONTS
gui Add,CheckBox,xm+10 y+0  vGUI_SCALABLEONLY,   CF_SCALABLEONLY
gui Add,CheckBox,xm+10 y+0  vGUI_SCRIPTSONLY,    CF_SCRIPTSONLY
gui Add,CheckBox,xm+10 y+0  vGUI_TTONLY,         CF_TTONLY

gui Add,Edit,ym w800 h500 hWndhEdit vMyEdit

GUIControl Focus,ChooseFont

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
gui Submit,NoHide

;-- If needed, remove previous "input only" options
;   Note: This can occur if the user presses the "Cancel" button on the previous
;   request.
if IOPos:=InStr($FontOptions," Size")
    $FontOptions:=SubStr($FontOptions,1,IOPOS-1)

;-- Size
GUI_SizeMin=%GUI_SizeMin% ;-- AutoTrim
if GUI_SizeMin is Integer
    $FontOptions.=A_Space . "SizeMin" . GUI_SizeMin

GUI_SizeMax=%GUI_SizeMax% ;-- AutoTrim
if GUI_SizeMax is Integer
    $FontOptions.=A_Space . "SizeMax" . GUI_SizeMax

;-- Flags
$Flags :=0
if GUI_SCRIPTSONLY
    $Flags|=CF_SCRIPTSONLY

if GUI_NOOEMFONTS
    $Flags|=CF_NOOEMFONTS

if GUI_FIXEDPITCHONLY
    $Flags|=CF_FIXEDPITCHONLY

if GUI_SCALABLEONLY
    $Flags|=CF_SCALABLEONLY

if GUI_TTONLY
    $Flags|=CF_TTONLY

if GUI_NOFACESEL
    $Flags|=CF_NOFACESEL

if GUI_NOSTYLESEL
    $Flags|=CF_NOSTYLESEL

if GUI_NOSIZESEL
    $Flags|=CF_NOSIZESEL

if GUI_NOSCRIPTSEL
    $Flags|=CF_NOSCRIPTSEL

if GUI_NOVERTFONTS
    $Flags|=CF_NOVERTFONTS

;-- Choose font dialog
if not Fnt_ChooseFont(hWindow,$FontName,$FontOptions,GUI_Effects,$Flags)
    return

;-- Create and set font (via AutoHotkey)
gui Font,%$FontOptions%,%$FontName%
GUIControl Font,MyEdit

;-- Reset font to system default
gui Font

;-- Update text on the Edit control.  To show that the correct font with
;   the specified options has been created, collect the font name/size using
;   library functions.
GUIControl
    ,
    ,MyEdit
    ,% Fnt_GetFontName(Fnt_GetFont(hEdit))
        . "`nSize: " . Fnt_GetFontSize(Fnt_GetFont(hEdit))
        . "`nOptions: " . $FontOptions

return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%
#include Fnt.ahk
