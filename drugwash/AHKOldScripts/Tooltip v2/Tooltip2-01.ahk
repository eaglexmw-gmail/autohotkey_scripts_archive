;*************gui1*********************
Gui, Add, Button,,Click to do nothing
Gui, Add, DropDownList,vDDL,red|blue|green||
Gui, Add, Checkbox,, Click to enable
Gui, Add, Edit, HwndMYEdit,This is an edit box
Gui, Add, Button,, Ok
Gui, Add, Button, x+ yp, Cancel
Gui, Add, Button, x+ yp, Retry
Gui, Show,x200
;set tooltips for each button - supply text, variable, classnn, or hwnd
setTip("Button1", "This button does absolutely nothing.")   ;using the classnn
setTip("Ok", "Begin the Process")   ;using the caption
setTip("Cancel", "Cancel Whatever is Happening!")
setTip("Retry", "Do Over")
setTip("Click to enable", "Checkbox")
setTip(DDL, "Dropdownlist")   ;using the variable
setTip(MYEdit, "The infamous edit control")   ;using the hwnd

;*************gui2*********************
Gui, 2:Add, Button,,Click to do nothing
Gui, 2:Add, DropDownList,vDDL2,red|blue|green||
Gui, 2:Add, Checkbox,, Click to enable
Gui, 2:Add, Edit, HwndMYEdit2,This is edit box two
Gui, 2:Add, Button,, Ok
Gui, 2:Add, Button, x+ yp, Cancel
Gui, 2:Add, Button, x+ yp, Retry
Gui, 2:Show,x400
;set tooltips for each button - supply text, variable, classnn, or hwnd
setTip("Button1", "This button does absolutely nothing. gui2", 2)   ;using the classnn
setTip("Ok", "Begin the Process gui2", 2)   ;using the caption
setTip("Cancel", "Cancel Whatever is Happening! gui2", 2)
setTip("Retry", "Do Over gui2", 2)
setTip("Click to enable", "Checkbox gui2", 2)
setTip(DDL2, "Dropdownlist part two: This time it's personal", 2)   ;using the variable
setTip(MYEdit2, "The infamous edit control redeux", 2)   ;using the hwnd

TipsState(1)   ;enable tooltips
Return

2guiClose:
guiClose:
   ExitApp
Return

;*****************tooltip stuff - toolTips.ahk**************************
setTip(tipControl, tipText, guiNum=1)   ;tipControl - text,variable,hwnd,classnn ;   tipText - text to display ;   gui number, default is 1
{
   global
   local List_ClassNN, List_ControlID
   Gui,%guiNum%:Submit,NoHide
   Gui,%guiNum%:+LastFound
   WinGet, tipGui_guiID, ID
   WinGet, List_ClassNN, ControlList
   StringReplace, List_ClassNN, List_ClassNN, `n, `,, All
   WinGet, List_ControlID, ControlListHwnd
   StringReplace, List_ControlID, List_ControlID, `n, `,, All
   IfInString, tipControl, %List_ControlID%   ;it is an ID
   {   tipGui_ClassNN := tipGui_getClassNN(tipControl, guiNum)   ;get classnn using id
   }
   Else IfInString, tipControl, %List_ClassNN%   ;it is a classnn
   {   tipGui_ClassNN := tipClassNN   ;use it as is
   }
   Else   ;must be text/var
   {   tipGui_ClassNN := tipGui_getClassNN(tipControl, guiNum)   ;get the classnn
   }
   tipGui_%guiNum%_%tipGui_ClassNN% := tipText   ;set the tip   
}

TipsState(ShowToolTips)
{
   If(ShowToolTips)
   {   OnMessage(0x200, "WM_MOUSEMOVE")   ;enable tips
   }
   Else
   {   OnMessage(0x200, "")   ;disable tips
   }
}

WM_MOUSEMOVE()
{
   global
   Critical
   IfEqual, A_Gui,, Return
   MouseGetPos,,,tipGui_outW,tipGui_outC
   If(tipGui_outC != tipGui_OLDoutC)
   {   tipGui_OLDoutC := tipGui_outC
      Gui, %A_Gui%:+LastFound
      ToolTip,,,, 20
      tipGui_ID := WinExist()
      SetTimer, tipGui_killTip, 1000
      counter := A_TickCount + 500
      Loop
      {    MouseGetPos,,,, tipGui_newC
         IfNotEqual, tipGui_outC, %tipGui_newC%, Return
         looper := A_TickCount
         IfGreater, looper, %counter%, Break
         sleep,50
      }

      tooltip, % tipGui_%A_Gui%_%tipGui_outC%,,, 20
   }
   Return
   tipGui_killTip:
   MouseGetPos,,, tipGui_outWm
   If(tipGui_outWm != tipGui_ID) or (A_TimeIdle >= 4000)
   {   SetTimer, tipGui_killTip, Off
      ToolTip,,,, 20
   }
   Return
}

tipGui_getClassNN(tipControl, g=1)   ;tipControl = text/var,Hwnd   ;g = gui number, default=1
{
   Gui,%g%:+LastFound
   guiID := WinExist()   ;get the id for the gui
   WinGet, List_controls, ControlList
   StringReplace, List_controls, List_controls, `n, `,, All
   ;if id supplied do nothing special
   IfNotInString, tipControl, %List_controls%   ;must be the text/var - get the ID
   {   mm := A_TitleMatchMode
      SetTitleMatchMode, 3   ;exact match only
      ControlGet, o, hWnd,, %tipControl%   ;get the id
      SetTitleMatchMode, %mm%   ;restore previous setting
      If(o)   ;found match
      {   tipControl := o   ;set sought-after id
      }
   }
   Loop, Parse, List_controls, CSV
   {   ControlGet, o, hWnd,, %A_LoopField%   ;get the id of current classnn
      If(o = tipControl)   ;if it is the one we want
      {   Return A_Loopfield   ;return the classnn
      }
   }
}
;*****************end tooltip stuff**************************
