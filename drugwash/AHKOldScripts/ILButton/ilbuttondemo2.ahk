#SingleInstance force
#NoEnv


   Gui, +ToolWindow +AlwaysOnTop
   Loop 5 {
      Gui, Add, Button, w64 h32 xm hwndhBtn, %A_Index%
        hIL := ILButton(hBtn, "user32.dll:" A_Index-1, 16, 16, "right", "0 0 10")
      Gui, Add, Button, w100 h32 x+10 hwndhBtn, text
        ILButton(hBtn, hIL, 16, 16, "", 10)
      }
   Gui, Add, Button, xm h200 w200 vStates hwndhBtn, pushbuttonstates
      ILButton(hBtn, "user32.dll|:2|:1|||", 128, 128, "top", "0 5")
   Gui, Add, Button, w100 h26 xm+74 gToggle, Enable/disable

   Gui, Show, , ILButton demo
return

Toggle:
   GuiControlGet, s, Enabled, States
   GuiControl, Disable%s%, States
   return

GuiClose:
GuiEscape:
   ExitApp
return
