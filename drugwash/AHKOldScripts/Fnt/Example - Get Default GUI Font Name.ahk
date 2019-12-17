#NoEnv
#SingleInstance Force
ListLines Off

MsgBox % "Default GUI font name:   `n`n`t" . Fnt_GetFontName()
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%
#include Fnt.ahk
