/*
    This example will generate a list of uniquely-named typeface font names for
    this computer.
*/

#NoEnv
#SingleInstance Force
;;;;;#Persistent
ListLines Off

;-------------
;-- Constants
;-------------
;-- Character sets
ANSI_CHARSET        :=0
DEFAULT_CHARSET     :=1
SYMBOL_CHARSET      :=2
MAC_CHARSET         :=77
SHIFTJIS_CHARSET    :=128
HANGUL_CHARSET      :=129
GB2312_CHARSET      :=134
CHINESEBIG5_CHARSET :=136
GREEK_CHARSET       :=161
TURKISH_CHARSET     :=162
VIETNAMESE_CHARSET  :=163
BALTIC_CHARSET      :=186
RUSSIAN_CHARSET     :=204
EASTEUROPE_CHARSET  :=238
OEM_CHARSET         :=255

;-----------
;-- Process
;-----------
;-- Collect a list of fonts using default parameters
FontList:=Fnt_GetListOfFonts()

;-------------
;-- Build GUI
;-------------
gui Margin,0,0
gui Add,ListView,r20 vMyListVIew hWndhLV,Font

Count:=0
Loop Parse,FontList,`n,`r
    {
    Count++
    LV_Add("",A_LoopField)
    }

LV_ModifyCol(1,"AutoHdr")
gui Add,StatusBar

if Count
    SB_SetText(Count . " unique fonts found")
 else
    SB_SetText("No fonts found")

gui Show,,List of Fonts
return


GUIClose:
GUIEscape:
ExitApp


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%
#include Fnt.ahk
