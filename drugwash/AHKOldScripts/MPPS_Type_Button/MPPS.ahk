; MPPS_Type_Button.ahk
;#InstallMouseHook

/*

- A Normal Click on the Graphical button will call Subroutine0
- A Long Click (Keep the "Left Mouse Button" down on the graphical button
  for 1 second) will trigger Subroutine1

*/

Gui, +Sysmenu +ToolWindow +AlwaysOnTop
Gui, Margin,12,12
Gui, Add , Picture, x13 y13 w32 h32 E0x200 vState1 icon1 gMPPS_Type_Button, %A_AhkPath%
Gui, Add , Picture, x13 y13 w34 h34 Border vState0 icon1 gMPPS_Type_Button, %A_AhkPath%
Gui, Show, x50 y50 AutoSize, MPPS

Return

MPPS_Type_Button:
  GuiControl Hide, State0
  TC := A_TickCount
  Loop, {
    MouseDown:=GetKeyState("LButton","P")
    If (!MouseDown) {
       LongClick=0
       Break
    }
    If (A_TickCount-TC) > 1000 {
       LongClick=1
       Break
        }
  }
  GuiControl Show, State0

  IfEqual,LongClick,1,GoSub,SubRoutine1
  else GoSub, SubRoutine0

Return

SubRoutine1:
 Msgbox,64, Subroutine1
,That was a Long Click..`n`nThis Subroutine may be used to execute a Special task, 10
Return

SubRoutine0:
 Msgbox,64, Subroutine0
,That was a Normal Click..`n`nThis Subroutine may be used to Toggle a Variable, 10
Return

GuiEscape:
GuiClose:
 ExitApp
Return
