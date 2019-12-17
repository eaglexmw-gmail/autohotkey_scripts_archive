#Singleinstance, force
#NoEnv
   Gui, +LastFound
   hGui := WinExist()
   Gui, Add, Button, w100 y+10 gOnBtn ,Icon
   Gui, Add, Button, w100 y+10 gOnBtn ,Color
   Gui, Add, Button, w100 y+10 gOnBtn ,Font   
   Gui, Add, Button, w100 y+10 gOnBtn ,Open
   Gui, Add, Button, w100 y+10 gOnBtn ,Save
   Gui, Add, Button, w100 y+10 gOnBtn ,Find
   Gui, Add, Button, w100 y+10 gOnBtn ,Replace
   Gui, Add, Edit, ym+5 w300 h220,Input / Output
   Gui, Show, autosize
return

Set(txt){
   ControlSetText, Edit1, %txt%
}

OnBtn:
   if A_GuiControl = Icon
      if CmnDlg_Icon(icon, idx, hGui)
         Set("Path:  " icon "`r`nIndex:  " idx)

   if A_GuiControl = Color
       if CmnDlg_Color( color, hGui )
         Set("Color: " color)

   if A_GuiControl = Font
      if CmnDlg_Font( font, style, color, true, hGui)
         Set("Font:  " font "`r`nStyle:  " style "`r`nColor:  " color)

   if A_GuiControl = Open
   {
      res := CmnDlg_Open(hGui, "Select several files", "All Files (*.*)|Audio (*.wav; *.mp2; *.mp3)|Documents (*.txt)", "", "d:\", "", "ALLOWMULTISELECT FILEMUSTEXIST HIDEREADONLY")
      StringReplace, res, res, `n, `r`n, A
      Set(res)
   }

   if A_GuiControl = Save
      Set(CmnDlg_Save(hGui, "Select several files", "All Files (*.*)|Audio (*.wav; *.mp2; *.mp3)|Documents (*.txt)", "", "c:\"))
   
   if A_GuiControl = Find
      CmnDlg_Find(hGui, "OnFind", "d")

   if A_GuiControl = Replace
      CmnDlg_Replace(hGui, "OnFind", "d")
return

OnFind(Event, Flags, FindWhat, ReplaceWith){
   Set("Event: " event "`r`nFlags: " flags "`r`nFindWhat: " FindWhat (ReplaceWith != "" ? "`r`nReplaceWith: " ReplaceWith : "") )
}

#include CmnDlg.ahk
