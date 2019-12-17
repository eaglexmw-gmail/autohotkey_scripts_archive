

;Syntax: ToasterPopup([Message, FontColor, FontSize, BackgroundColor, Lifetime, TP_CallBack]); Lifetime in MS (0 to persist until clicked)
;Example:
TP_ID := TP_Show("This is a Toaster Popup...`nClick to make it go away")
TP_Wait(TP_ID)

TP_Show("This one diappears automatically", 1000, "Blue", "12", "White")
TP_Wait()

TP_Show("This one calls another subroutine when clicked", 5000, "Blue", "12", "White","Wow")
Return


Wow:
Msgbox It called me!
Return

TP_Show(TP_Message="Hello, World", TP_Lifespan=0, TP_FontColor="Blue", TP_FontSize="12", TP_BGColor="White",  TP_CallBack="")
{
   Global TP_CallBackTarget, clicked
   TP_CallBackTarget := TP_CallBack
   DetectHiddenWindows, On
   SysGet, Workspace, MonitorWorkArea
   Gui, 89:-Caption +ToolWindow +LastFound +AlwaysOnTop +Border
   Gui, 89:Color, %TP_BGColor%
   Gui, 89:Font, s%TP_FontSize% c%TP_FontColor%
   Gui, 89:Add, Text, gTP_Fade vClicked, %TP_Message%
   Gui, 89:Show, Hide, TP_Gui
   TP_GUI_ID := WinExist("TP_Gui")
   WinGetPos, GUIX, GUIY, GUIWidth, GUIHeight, ahk_id %TP_GUI_ID%
   NewX := WorkSpaceRight-GUIWidth-5
   NewY := WorkspaceBottom-GUIHeight-5
   Gui, 89:Show, Hide x%NewX% y%NewY%

   DllCall("AnimateWindow","UInt",TP_GUI_ID,"Int",500,"UInt","0x00040008") ; TOAST!

   If (TP_Lifespan)
     SetTimer, TP_Fade, % "-" TP_Lifespan
   Return TP_GUI_ID

  TP_Fade:
     If (A_GuiControl="Clicked") and TP_CallBackTarget
    {
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
     TP_GUI_ID := WinExist("TP_Gui")
     DllCall("AnimateWindow","UInt",TP_GUI_ID,"Int",1000,"UInt","0x90000") ; Fade out when clicked
     Gui, 89:Destroy
  Return
}

TP_Wait(TP_GUI_ID="") {
  If not (TP_GUI_ID)
   TP_GUI_ID := WinExist("TP_Gui")
  WinWaitClose, ahk_id %TP_GUI_ID%
}
