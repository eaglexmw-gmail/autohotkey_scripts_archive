;========================+
; Auto-Execution Section |
;==============================================================================
#NoEnv
#SingleInstance force
Sendmode Input

CreateMainGUI()
Return
;==============================================================================


;=========+
; HotKeys |
;==============================================================================
#IfWinActive AHK Regex Sandbox
!c::
   Gui, Submit, NoHide
   clipboard := (tabselection = "RegExMatch") ? mahkcode : rahkcode
return
;==============================================================================


;========================+
; RegExMatch Subroutines |
;==============================================================================
RegExMatchEval:
   Gui, Submit, NoHide
   ; Clear all variables prefixed with "mre_"
   ClearArray("mre_")
   ; Set non-empty defaults
   mstartpos := mstartpos ? mstartpos : 1
   ; Do RegExMatch
   mfoundpos := RegExMatch(mhaystack, mneedle, mre_, mstartpos)
   Gosub, DisplayRegExMatchResults
   Gosub, DisplayRegExMatchCode
return

DisplayRegExMatchResults:
   moutput := "ErrorLevel: " . ErrorLevel . "`n"
           . "FoundPos: " . mfoundpos . "`n"
   mre_list := GetNonEmptyArrayVars("mre_")
   If moutputvar
   {
      Loop, parse, mre_list, `,
      {
         moutput .= moutputvar . Substr(A_LoopField, 5) . ": """ . %A_LoopField% . """`n"
      }
   }
   GuiControl, , mresults, %moutput%
return

DisplayRegExMatchCode:
   regexmatchcode := "FoundPos := RegExMatch(""" . mhaystack . """, """ . mneedle . """"
   If moutputvar
      regexmatchcode .= ", " . moutputvar
   If mstartpos != 1
      regexmatchcode .= (moutputvar ? "" : ", ") . ", " . mstartpos
   regexmatchcode .= ")"
   GuiControl, , mahkcode, %regexmatchcode%
return
;==============================================================================

;==========================+
; RegExReplace Subroutines |
;==============================================================================
RegExReplaceEval:
   Gui, Submit, NoHide
   ; Set non-empty defaults
   rstartpos := rstartpos ? rstartpos : 1
   rlimit := rlimit ? rlimit : -1
   ; Do RegExReplace
   rnewstr := RegExReplace(rhaystack, rneedle, rreplacementtext, rcount, rlimit, rstartpos)
   Gosub, DisplayRegExReplaceResults
   Gosub, DisplayRegExReplaceCode
return

DisplayRegExReplaceResults:
   routput := "ErrorLevel: " . ErrorLevel . "`n"           
   If routputvar
      routput .= routputvar . ": " . rcount . "`n"
   routput .= "NewStr: " . rnewstr . "`n"
   GuiControl, , rresults, %routput%
return

DisplayRegExReplaceCode:
   regexreplacecode := "NewStr := RegExReplace(""" . rhaystack . """, """ . rneedle . """"
   If (rreplacementtext) or (routputvar) or (rlimit != -1) or (rstartpos != 1)
      regexreplacecode .= ", " . ( rreplacementtext ? """" . rreplacementtext . """" : "" )
   If routputvar or (rlimit != -1) or (rstartpos != 1)
      regexreplacecode .= ", " . ( routputvar ? routputvar : "" )
   If (rlimit != -1) or (rstartpos != 1)
      regexreplacecode .= ", " . ( (rlimit != -1) ? rlimit : "" )
   If (rstartpos != 1)
      regexreplacecode .= ", " . rstartpos
   regexreplacecode .= ")"
   GuiControl, , rahkcode, %regexreplacecode%
return
;==============================================================================


;========================+
; Array-helper functions |
;==============================================================================
ClearArray(prefix)
{
   global
   lgv := ListGlobalVars()
   Loop, parse, lgv, |
   {
      If (InStr(A_LoopField, prefix) = 1)
         %A_LoopField% = ©Y®©Y®©Y®©Y®
   }
}

GetNonEmptyArrayVars(prefix)
{
   global
   local varlist =
   lgv := ListGlobalVars()
   Loop, parse, lgv, |
   {
      If (InStr(A_LoopField, prefix) = 1) and (%A_LoopField% != ©Y®©Y®©Y®©Y®)
         varlist .= A_LoopField . ","
   }
   StringTrimRight, varlist, varlist, 1
   return varlist
}
;==============================================================================


;===========+
; GUI Stuff |
;==============================================================================
CreateMainGUI()
{
   global
   
   Gui, Add, Tab, x2 y2 w500 h500 +Theme vtabselection -background, RegExMatch|RegExReplace
   
   Gui, Tab, RegExMatch
   Gui, Font
   Gui, Add, Text, x12 y42 w480 h15 +Backgroundtrans, Regular Expression (the "needle"):
   Gui, Add, Text, x12 y97 w235 h15 +Backgroundtrans, Output Variable (defaults to ""):
   Gui, Add, Text, x257 y97 w235 h15 +Backgroundtrans, Starting Position (defaults to 1):
   Gui, Add, Text, x12 y152 w480 h15 +Backgroundtrans, Text to be searched (the "haystack"):
   Gui, Add, Text, x12 y257 w480 h15 +Backgroundtrans, Results:
   Gui, Add, Text, x12 y457 w480 h15 +Backgroundtrans, AHK Code:
   Gui, Font, s10, courier new
   Gui, Add, Edit, x12 y57 w480 h30 -VScroll vmneedle gRegExMatchEval,
   Gui, Add, Edit, x12 y112 w230 h30 -VScroll vmoutputvar gRegExMatchEval, match
   Gui, Add, Edit, x257 y112 w235 h30 -VScroll vmstartpos gRegExMatchEval,
   Gui, Add, Edit, x12 y167 w480 h80 vmhaystack gRegExMatchEval,
   Gui, Add, Edit, x12 y272 w480 h175 vmresults +readonly,
   Gui, Font, s8, courier new
   Gui, Add, Edit, x12 y472 w480 h20 vmahkcode +readonly

   Gui, Tab, RegExReplace
   Gui, Font
   Gui, Add, Text, x12 y42 w480 h15 +Backgroundtrans, Regular Expression (the "needle"):
   Gui, Add, Text, x12 y97 w150 h15 +Backgroundtrans, Replacement Text (""):
   Gui, Add, Text, x172 y97 w150 h15 +Backgroundtrans, Output Variable (""):
   Gui, Add, Text, x332 y97 w75 h15 +Backgroundtrans, Limit (-1):
   Gui, Add, Text, x417 y97 w75 h15 +Backgroundtrans, Startpos (1):
   Gui, Add, Text, x12 y152 w480 h15 +Backgroundtrans, Text to be searched (the "haystack"):
   Gui, Add, Text, x12 y257 w480 h15 +Backgroundtrans, Results:
   Gui, Add, Text, x12 y457 w480 h15 +Backgroundtrans, AHK Code:

   Gui, Font, s10, courier new
   Gui, Add, Edit, x12 y57 w480 h30 -VScroll vrneedle gRegExReplaceEval, 
   Gui, Add, Edit, x12 y112 w150 h30 -VScroll vrreplacementtext gRegExReplaceEval,
   Gui, Add, Edit, x172 y112 w150 h30 -VScroll vroutputvar gRegExReplaceEval, count
   Gui, Add, Edit, x332 y112 w75 h30 -VScroll vrlimit gRegExReplaceEval,
   Gui, Add, Edit, x417 y112 w75 h30 -VScroll vrstartpos gRegExReplaceEval,
   Gui, Add, Edit, x12 y167 w480 h80 vrhaystack gRegExReplaceEval,
   Gui, Add, Edit, x12 y272 w480 h175 vrresults +readonly,
   Gui, Font, s8, courier new
   Gui, Add, Edit, x12 y472 w480 h20 vrahkcode +readonly

   ; (mostly) generated using SmartGUI Creator 4.0
   Gui, Show, xCenter yCenter h504 w504, AHK Regex Sandbox
}

GuiEscape:
GuiClose:
ExitApp
;==============================================================================


;==================+
; ListGlobalVars() |
; by Lexikos       +====================================+
; http://www.autohotkey.com/forum/viewtopic.php?t=22692 |
;==============================================================================
ListGlobalVars()
{
   static hwnd, hwndEdit, pSFW, pSW, bkpSFW, bkpSW

   if !hwndEdit
   {
      dhw := A_DetectHiddenWindows
      DetectHiddenWindows, On
      Process, Exist
      hwnd := WinExist("ahk_class AutoHotkey ahk_pid " ErrorLevel)
      ControlGet, hwndEdit, Hwnd,, Edit1
      DetectHiddenWindows, %dhw%

      hmod := DllCall("GetModuleHandle", "str", "user32.dll")
      pSFW := DllCall("GetProcAddress", "uint", hmod, "str", "SetForegroundWindow")
      pSW := DllCall("GetProcAddress", "uint", hmod, "str", "ShowWindow")
      DllCall("VirtualProtect", "uint", pSFW, "uint", 8, "uint", 0x40, "uint*", 0)
      DllCall("VirtualProtect", "uint", pSW, "uint", 8, "uint", 0x40, "uint*", 0)
      bkpSFW := NumGet(pSFW+0, 0, "int64")
      bkpSW := NumGet(pSW+0, 0, "int64")
   }

      NumPut(0x0004C200000001B8, pSFW+0, 0, "int64")  ; return TRUE
   , NumPut(0x0008C200000001B8, pSW+0, 0, "int64")   ; return TRUE

   , DllCall("SendMessage", "uint", hwnd, "uint", 0x111, "uint", 65407, "uint", 0)

   , NumPut(bkpSFW, pSFW+0, 0, "int64")
   , NumPut(bkpSW, pSW+0, 0, "int64")

   ControlGetText, text,, ahk_id %hwndEdit%

   RegExMatch(text, "sm)(?<=^Global Variables \(alphabetical\)`r`n-{50}`r`n).*", text)
   pos = 1
   Loop {
      pos := RegExMatch(text, "m)^[\w#@$?\[\]]+(?=\[\d+ of \d+\]: )", var, pos)
      if ! pos
            break
      list .= var "|"
      pos += StrLen(var)
   }
   return SubStr(list, 1, -1)
}
;==============================================================================
