; http://www.autohotkey.com/forum/viewtopic.php?t=23303

;Syntax: ToasterPopup([Message, FontColor, FontSize, BackgroundColor, Lifetime]); Lifetime in MS (0 to persist until clicked)
;Example:
TP_Show("This is a Toaster Popup...`nClick to make it go away")
TP_Wait()

TP_Show("This one diappears automatically", "Blue", "12", "White", 1000)

Return


TP_Show(TP_Message="Hello, World", TP_FontColor="Blue", TP_FontSize="12", TP_BGColor="White", TP_Lifespan=0)
{
   Global TP_GUI_ID
   DetectHiddenWindows, On
   SysGet, Workspace, MonitorWorkArea
   Gui, 89:-Caption +ToolWindow +LastFound +AlwaysOnTop +Border
   Gui, 89:Color, %TP_BGColor%
   Gui, 89:Font, s%TP_FontSize% c%TP_FontColor%
   Gui, 89:Add, Text, gTP_Fade, %TP_Message%
   Gui, 89:Show, Hide
   TP_GUI_ID := WinExist()
   WinGetPos, GUIX, GUIY, GUIWidth, GUIHeight, ahk_id %TP_GUI_ID%
   NewX := WorkSpaceRight-GUIWidth-5
   NewY := WorkspaceBottom-GUIHeight-5
   Gui, 89:Show, Hide x%NewX% y%NewY%

   DllCall("AnimateWindow","UInt",TP_GUI_ID,"Int",500,"UInt","0x00040008") ; TOAST!
   If (TP_Lifespan)
     SetTimer, TP_Fade, % "-" TP_Lifespan
   Return
}

TP_Wait() {
  Global TP_GUI_ID
  WinWaitClose, ahk_id %TP_GUI_ID%
}

TP_Fade:
   DllCall("AnimateWindow","UInt",TP_GUI_ID,"Int",1000,"UInt","0x90000") ; Fade out when clicked
   Gui, 89:Destroy
Return
