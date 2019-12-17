Title = This Title is Bold and optional
Message = This is normal text. You can display a bunch of information here.
Lifespan = 8000 ;ms
FontSize = 8
FontColor = 0x00437e
BGColor = 0xE3F2FE
FontFace=Arial

;TP_Show(Title, Message, Lifespan, "Test", FontSize, FontColor, BGColor, FontFace)
;tempvar := TP_Show(Title, Message, Lifespan, "Test")
;tempvar := TP_Show(Title, Message, Lifespan)	; original
tempvar := Toast(Title, Message, Lifespan)
;TP_Wait(tempvar)
;TP_Wait()	; original
Toast_Wait()
MsgBox
return

Test:
   MsgBox, , TP Callback Test, Event received:  %TP_GuiEvent%      `
return



;Use: TP_Show([ Title, Message, Lifespan, FontSize, FontColor, BGColor, CallbackLabel ])   
Toast(TP_Title="", TP_Message="", TP_Lifespan=0, TP_CallBack="", TP_Speed="10", TP_TitleSize="9", TP_FontSize="8", TP_FontColor="0x00437e", TP_BGColor="0xE3F2FE",  TP_FontFace="")
{
   Global TP_GuiEvent
   Static TP_CallBackTarget, TP_GUI_ID
   TP_CallBackTarget := TP_CallBack
   
   DetectHiddenWindows, On
   SysGet, Workspace, MonitorWorkArea
   Gui, 89:Destroy
   Gui, 89:-Caption +ToolWindow +LastFound +AlwaysOnTop +Border
   Gui, 89:Color, %TP_BGColor%
   If (TP_Title) {
      TP_TitleSize := TP_FontSize + 1
      Gui, 89:Font, s%TP_TitleSize% c%TP_FontColor% w700, %TP_FontFace%
      Gui, 89:Add, Text, r1 gToast_Fade x5 y5, %TP_Title%
      Gui, 89:Margin, 0, 0
   }
   Gui, 89:Font, s%TP_FontSize% c%TP_FontColor% w400, %TP_FontFace%
   Gui, 89:Add, Text, gToast_Fade x5, %TP_Message%
   IfNotEqual, TP_Title,, Gui, 89:Margin, 5, 5
   Gui, 89:Show, Hide, TP_Gui
   TP_GUI_ID := WinExist("TP_Gui")
   WinGetPos, , , GUIWidth, GUIHeight, ahk_id %TP_GUI_ID%
   NewX := WorkSpaceRight-GUIWidth-5
   NewY := WorkspaceBottom-GUIHeight-5
   Gui, 89:Show, Hide x%NewX% y%NewY%
   WinGetPos,,,Width
   GuiControl, 89:Move, Static1, % "w" . GuiWidth-7
   GuiControl, 89:Move, Static2, % "w" . GuiWidth-7
   DllCall("AnimateWindow","UInt", TP_GUI_ID,"Int", GuiHeight*TP_Speed,"UInt", 0x40008)
   If (TP_Lifespan)
      SetTimer, Toast_Fade, -%TP_Lifespan%
Return TP_GUI_ID

89GuiContextMenu:
Toast_Fade:
   If (A_GuiEvent and TP_CallBackTarget)
   {
      TP_GuiEvent := A_GuiEvent
      If IsLabel(TP_CallBackTarget)
         Gosub, %TP_CallBackTarget%
      else
      {
         If InStr(TP_CallBackTarget, "(")
         Msgbox Cannot yet callback a function
         else
         Msgbox, not a valid CallBack
      }
   }
   DllCall("AnimateWindow","UInt", TP_GUI_ID,"Int", 600,"UInt", 0x90000)
   Gui, 89:Destroy
Return
}

Toast_Wait(TP_GUI_ID="") {
  If not (TP_GUI_ID)
   TP_GUI_ID := WinExist("TP_Gui")
  WinWaitClose, ahk_id %TP_GUI_ID%
}
