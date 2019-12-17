; by SKAN and Solar http://www.autohotkey.com/forum/viewtopic.php?t=35472

#NoTrayIcon                       ; MinimizeGUItoTray() by Skan   --   created 18-Aug-2008
                                  ; www.autohotkey.com/forum/viewtopic.php?p=214612#214612

Menu("Tray","Nostandard"), Menu("Tray","Add","Restore","GuiShow"), Menu("Tray","Add")
Menu("Tray","Default","Restore"), Menu("Tray","Click",1), Menu("Tray","Standard")
;Menu("Tray","Icon","User32.dll",4) ; can't find the icon in Win9x
Menu("Tray","Icon","shell32.dll",4)

Gui +LastFound +Owner
Gui1 := WinExist()
OnMessage(0x112, "WM_SYSCOMMAND")
Gui, Show, w250 h100, Minimize/Restore to/from Tray - Demo

Return                                                 ; // end of auto-execute section //

WM_SYSCOMMAND(wParam)
{
   If ( wParam = 61472 ) {
   SetTimer, OnMinimizeButton, -1
   Return 0
   }
}

GuiClose:
 ExitApp
Return

OnMinimizeButton:
  MinimizeGuiToTray( R, Gui1 )
  Menu("Tray","Icon")
Return

GuiShow:
  DllCall("DrawAnimatedRects", UInt,Gui1, Int,3, UInt,&R+16, UInt,&R )
  Menu("Tray","NoIcon")
  Gui, Show
Return


MinimizeGuiToTray( ByRef R, hGui ) {
  WinGetPos, X0,Y0,W0,H0, % "ahk_id " (Tray:=WinExist("ahk_class Shell_TrayWnd"))
  ControlGetPos, X1,Y1,W1,H1, TrayNotifyWnd1,ahk_id %Tray%
  SW:=A_ScreenWidth,SH:=A_ScreenHeight,X:=SW-W1,Y:=SH-H1,P:=((Y0>(SH/3))?("B"):(X0>(SW/3))
  ? ("R"):((X0<(SW/3))&&(H0<(SH/3)))?("T"):("L")),((P="L")?(X:=X1+W0):(P="T")?(Y:=Y1+H0):)
  VarSetCapacity(R,32,0), DllCall( "GetWindowRect",UInt,hGui,UInt,&R)
  NumPut(X,R,16), NumPut(Y,R,20), DllCall("RtlMoveMemory",UInt,&R+24,UInt,&R+16,UInt,8 )
  DllCall("DrawAnimatedRects", UInt,hGui, Int,3, UInt,&R, UInt,&R+16 )
  WinHide, ahk_id %hGui%
}

Menu( MenuName, Cmd, P3="", P4="", P5="" ) {
  Menu, %MenuName%, %Cmd%, %P3%, %P4%, %P5%
Return errorLevel
}
