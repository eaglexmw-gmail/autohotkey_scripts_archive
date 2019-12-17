#SingleInstance, Force
SetFormat, integer, Hex

; MSDN: http://msdn.microsoft.com/en-us/library/ms632669(VS.85).aspx
;    DllCall("AnimateWindow","UInt",   WindowID   ,"Int",   TimeToFinish   ,"UInt",    Constants)

AW_HIDE         := 0x10000
AW_ACTIVATE         := 0x20000
AW_CENTER         := 0x10
AW_BLEND         := 0x80000
AW_SLIDE         := 0x40000
   AW_HOR_POSITIVE   := 0x1
   AW_HOR_NEGATIVE   := 0x2
   AW_VER_POSITIVE   := 0x4
   AW_VER_NEGATIVE   := 0x8

Menu, Tray, Add
Menu, Tray, Add, Show Test Windows, ShowWindows

ShowWindows:
   If Initiated
   {
      Gui, 2:Show
      Gui, Show
      return
   }
   Gui, Add, Text, x5, Animation 1:
   Gui, Add, Text, , PlayTime
   Gui, Add, Edit, xp+50 vPlayTime1, 500
   Gui, Add, CheckBox, v_HIDE1   x5      , AW_HIDE
   Gui, Add, CheckBox, v_ACTIVATE1      , AW_ACTIVATE
   Gui, Add, CheckBox, v_BLEND1      , AW_BLEND
   Gui, Add, CheckBox, v_CENTER1      , AW_CENTER
   Gui, Add, CheckBox, v_SLIDE1      , AW_SLIDE
   Gui, Add, CheckBox, v_HOR_POSITIVE1   , - AW_HOR_POSITIVE
   Gui, Add, CheckBox, v_HOR_NEGATIVE1   , - AW_HOR_NEGATIVE
   Gui, Add, CheckBox, v_VER_POSITIVE1   , - AW_VER_POSITIVE
   Gui, Add, CheckBox, v_VER_NEGATIVE1   , - AW_VER_NEGATIVE
   Gui, Add, Text, ys section, Animation 2:
   Gui, Add, Text, , PlayTime
   Gui, Add, Edit, xp+50 vPlayTime2, 500
   Gui, Add, CheckBox, v_HIDE2   xs       , AW_HIDE
   Gui, Add, CheckBox, v_ACTIVATE2      , AW_ACTIVATE
   Gui, Add, CheckBox, v_BLEND2      , AW_BLEND
   Gui, Add, CheckBox, v_CENTER2      , AW_CENTER
   Gui, Add, CheckBox, v_SLIDE2      , AW_SLIDE
   Gui, Add, CheckBox, v_HOR_POSITIVE2   , - AW_HOR_POSITIVE
   Gui, Add, CheckBox, v_HOR_NEGATIVE2   , - AW_HOR_NEGATIVE
   Gui, Add, CheckBox, v_VER_POSITIVE2   , - AW_VER_POSITIVE
   Gui, Add, CheckBox, v_VER_NEGATIVE2   , - AW_VER_NEGATIVE
   Gui, Add, Text, x5, Time Between Animations:
   Gui, Add, Edit, xp+130 vSleepTime, 1000
   Gui, Add, Button, x5 +Default, &Test
   Gui, Add, Button, xp+50 yp gShowWindows, &Show Windows
   Gui, Add, Text, x5, 1:
   Gui, Add, Edit, xp+20 +ReadOnly w250 vOutput
   Gui, Add, Text, x5, 2:
   Gui, Add, Edit, xp+20 +ReadOnly w250 vOutput2
   Gui, Show, , AnimateWindow Testing
   Gui, 2:+ToolWindow +AlwaysOnTop
   Gui, 2:Add, Text, , This is a test window. AnimateWindow will work on this`n`n`n`n`n`n`n`n`n
   Gui, 2:Show, x10 y500, Test window.
   Gui, 2:+LastFoundExist
   WindowID := WinExist()
   Initiated := True
return

GuiClose:
GuiEscape:
   Gui, Hide
return

2GuiClose:
2GuiEscape:
   Gui, 2:Hide
return

ButtonTest:
   Gui, Submit, NoHide
   Constants1 := 0x0 + 0
   Constants2 := 0x0 + 0
   If _HIDE1
      Constants1 := AW_HIDE
   If _ACTIVATE1      
      Constants1 |= AW_ACTIVATE   
   If _BLEND1         
      Constants1 |= AW_BLEND      
   If _SLIDE1         
      Constants1 |= AW_SLIDE      
   If _HOR_POSITIVE1
      Constants1 |= AW_HOR_POSITIVE
   If _HOR_NEGATIVE1
      Constants1 |= AW_HOR_NEGATIVE
   If _VER_POSITIVE1
      Constants1 |= AW_VER_POSITIVE
   If _VER_NEGATIVE1
      Constants1 |= AW_VER_NEGATIVE
   If _CENTER1
      Constants1 |= AW_CENTER

   If _HIDE2
      Constants2 := AW_HIDE
   If _ACTIVATE
      Constants2 |= AW_ACTIVATE   
   If _BLEND2
      Constants2 |= AW_BLEND
   If _SLIDE2
      Constants2 |= AW_SLIDE      
   If _HOR_POSITIVE2
      Constants2 |= AW_HOR_POSITIVE
   If _HOR_NEGATIVE2
      Constants2 |= AW_HOR_NEGATIVE
   If _VER_POSITIVE2
      Constants2 |= AW_VER_POSITIVE
   If _VER_NEGATIVE2
      Constants2 |= AW_VER_NEGATIVE
   If _CENTER2
      Constants2 |= AW_CENTER

   If Constants1
      DllCall("AnimateWindow", "UInt", WindowID, "Int", PlayTime1, "UInt", Constants1)
   Sleep %SleepTime%
   If Constants2
      DllCall("AnimateWindow", "UInt", WindowID, "Int", PlayTime2, "UInt", Constants2)

   Call1 = DllCall("AnimateWindow","UInt",  HWND  ,"Int", %PlayTime1%,"UInt", %Constants1%)
   Call2 = DllCall("AnimateWindow","UInt",  HWND  ,"Int", %PlayTime2%,"UInt", %Constants2%)
   GuiControl, , Output, %Call1%
   GuiControl, , Output2, %Call2%
return
