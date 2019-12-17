  Gui, +LastFound
  hColorPreferences := WinExist()
  CurrentColor := 0x000000  ; default color

  Gui, Add, Text,, Click to change color..
   Gui, Add, Text,   h20   border    vBgColor gOnChangeColor,  ggggggggggggggg
   Gui, Font, c%CurrentColor% s32 bold, Webdings
   GuiControl, Font, BgColor
   Gui, Show,
return

OnChangeColor:
  If CmnDlg_Color(CurrentColor, hColorPreferences) {
     Gui, Font, c%CurrentColor% s32 bold, Webdings
     GuiControl, Font, BgColor
  }
return

#include CmnDlg.ahk
