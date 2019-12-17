; http://www.autohotkey.com/forum/viewtopic.php?p=268291#268291

Loop 10
   ToolTip(99,"`nJust an example ToolTip following mouse movements"
   ,"This ToolTip will be destroyed in " . 11-A_Index . " Seconds","I2 B0000FF FFFFFFF D1")
ToolTip(99,"")
Gui,Add,Text,,Point here or anywhere (no control area)`nYou will see ToolTip assosiated with this window
Gui,Add,Button,gButton1,ToolTip 1
Gui,Add,Button,gButton1,ToolTip 1
Gui,Add,Button,,ToolTip 2
Gui,Add,Button,,ToolTip 2
Gui,Add,Button,,ToolTip 3
Gui,Add,Button,,ToolTip 3
Gui,Add,Button,x+10 ys+32,ToolTip 4
Gui,Add,Button,,ToolTip 4
Gui,Add,Button,,ToolTip 5
Gui,Add,Button,,ToolTip 5
Gui,Add,Button,,ToolTip 6
Gui,Add,Button,,ToolTip 6
Gui,Add,Button,x+10 ys+32,ToolTip 7
Gui,Add,Button,,ToolTip 7
Gui,Add,Button,,ToolTip 8
Gui,Add,Button,,ToolTip 8
Gui,Add,Button,,ToolTip 9
Gui,Add,Button,,ToolTip 9
Gui,+LastFound
GuiHwnd:=WinExist()
ToolTip(10,"This ToolTip belongs to no control.`nIt is shown when you point mouse onto window area."
      ,"Gui assosiated ToolTip","I1 P" . GuiHwnd)

ToolTip(1,"This is a usual tooltip`, click to change","","aButton1 P" . GuiHwnd)
ToolTip(1,"Same ToolTip with a different text`nYou can also click here to change it","","aButton2 P" . GuiHwnd)

ToolTip(2,"This is a colored ToolTip","","B0000FF aButton3 P" . GuiHwnd)
ToolTip(2,"Same colored ToolTip containing new text","","aButton4 P" . GuiHwnd)

ToolTip(3,"This is a colored ToolTip with Title","Welcome","BFFFF00 aButton5 P" . GuiHwnd)
ToolTip(3,"This is a colored ToolTip with Title`nand multilines`n`nanother line","","aButton6 P" . GuiHwnd)

ToolTip(4,"This is a BallonTip","","O1 aButton7 P" . GuiHwnd)
ToolTip(4,"This is a BallonTip","","aButton8 P" . GuiHwnd)

ToolTip(5,"This is a colored BallonTip with Title`nAdditionally its text is colored"
      ,"Welcome","BFF0000 FFFFFFF aButton9 P" . GuiHwnd)
ToolTip(5,"This is a colored BaloonTip with Title`nAdditionally its text is colored","","aButton10 P" . GuiHwnd)

ToolTip(6,"This is a ToolTip with Title and close button","Welcome","C1 aButton11 P" . GuiHwnd)
ToolTip(6,"This is a ToolTip with Title and close button","","aButton12 P" . GuiHwnd)

ToolTip(7,"This is a ToolTip with Title and Icon","Welcome","I1 aButton13 P" . GuiHwnd)
ToolTip(7,"This is a ToolTip with Title and Icon","","aButton14 P" . GuiHwnd)

ToolTip(8,"This is a colored BallonTip`nWith Title`, Icon and Close Button"
      ,"Welcome","BFF00FF F00FF00 C1 O1 I2 aButton15 P" . GuiHwnd)
ToolTip(8,"This is a colored BallonTip`nWith Title`, Icon and Close Button","","aButton16 P" . GuiHwnd)

ToolTip(9,"This is a colored ToolTip","","B000000 FFFFF00 aButton17 P" . GuiHwnd)
ToolTip(9,"This is a colored ToolTip","","aButton18 P" . GuiHwnd)

Gui,show,,Test Gui
OnMessage(0x4E,"test")
Return


Button1:
Loop 2
   ToolTip(1,"New Text","New Title","BFF00FF F00FF00 T200 Abutton" . A_Index . " P" . GuiHwnd)
REturn

GuiClose:
Guiescape:
ExitApp

; ### End Example Code #####







; ### Functions ###
ToolTip(_tool_tip_id_="", text=" ", title="", options=""){ ;i x y b f d t o c m p a
   static _tt_hwnd_list_
   global #_ti_
   If !#_ti_
      VarSetCapacity(#_ti_, 40, 0),#_ti_:=Chr(40)
    If ((#_DetectHiddenWindows:=A_DetectHiddenWindows)="Off")
      DetectHiddenWindows, On
   If !_tool_tip_id_
   {
      Loop,Parse,_tt_hwnd_list_,|
         If (hwnd:=RegExReplace(A_LoopField,"\d+\."))
            DllCall("DestroyWindow","Uint",hwnd)
      _tt_hwnd_list_=
      DetectHiddenWindows,%#_DetectHiddenWindows%
      Return
   }
   If options
      Loop,Parse,options,%A_Space%
      {
         option:= SubStr(A_LoopField,1,1)
         If option
            %option%:= SubStr(A_LoopField,2)
      }
   If RegExMatch(_tt_hwnd_list_,"\|" . _tool_tip_id_ . "\.([^\|]+)",hwnd)
         hwnd := hwnd1
   If (!hwnd and text!="")
   {
      _tt_hwnd_list_:=RegExReplace(_tt_hwnd_list_,"\|" . _tool_tip_id_ . "\.[^\|]+\|")
      hWnd := DllCall("CreateWindowEx", "Uint", 0x8, "str", "tooltips_class32", "str", "", "Uint",  + (C ? 80 : 0)+(O ? 115 : 50), "int", 0, "int", 0, "int", 0, "int", 0, "Uint", P, "Uint", 0, "Uint", 0, "Uint", 0) ;param4 0xc3 0x80
      _tt_hwnd_list_.= "|" . _tool_tip_id_ . "." . hWnd . "|"
      NumPut(&_tool_tip_id_,#_ti_,36)
   }
   If P
   {
      Numput(1|16+0x100,#_ti_,4)
      Numput(P,#_ti_,8)
      If A {
         If A is not Xdigit
            ControlGet,A,Hwnd,,%A%,ahk_id %P%
         Numput(A,#_ti_,12)
      } else
         Numput(P,#_ti_,12)
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1028, "Uint", 0, "Uint", &#_ti_)   ; TTM_ADDTOOL
   }
   else
      NumPut(0x20,#_ti_,4)
      ,DllCall("SendMessage", "Uint", hWnd, "Uint", 1028, "Uint", 0, "Uint", &#_ti_)   ; TTM_ADDTOOL
      ,DllCall("SendMessage", "Uint", hWnd, "Uint", 1041, "Uint", 1, "Uint", &#_ti_)   ; TTM_TRACKACTIVATE
   If ((B!="" ? SetToolTipColor(hwnd,B) :) or (F !="" ? SetToolTipTextColor(hwnd,F) :) and text="")
      DllCall("DestroyWindow","Uint",hwnd), _tt_hwnd_list_:=RegExReplace(_tt_hwnd_list_,"\|" . _tool_tip_id_ . "\.[^\|]+\|")
   else if !D
      ShowToolTip(hwnd,x,y,text,title,I,T,P,A,C,M)
   else
   {
      A_Timer := A_TickCount, D *= 1000
      Loop
         If (A_TickCount - A_Timer > D or ShowToolTip(hwnd,x,y,text,title,I,T,P,A,C,M))
            Break
      DllCall("DestroyWindow","Uint",hwnd), _tt_hwnd_list_:=RegExReplace(_tt_hwnd_list_,"\|" . _tool_tip_id_ . "\.[^\|]+\|")
   }
   Return hwnd
}
SetToolTipTitle(hwnd,title,I="0"){
   title := (StrLen(title) < 96) ? title : ("…" . SubStr(title, -97))
   ; TTM_SETTITLE   ; 0: None, 1:Info, 2: Warning, 3: Error. n > 3: assumed to be an hIcon.
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1056, "Uint", I, "Uint", &Title)
}
SetToolTipColor(hwnd,B){
   B := (StrLen(B) < 8 ? "0x" : "") . B
   B := ((B&255)<<16)+(((B>>8)&255)<<8)+(B>>16) ; rgb -> bgr
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1043, "Uint", B, "Uint", 0)   ; TTM_SETTIPBKCOLOR   
}
SetToolTipTextColor(hwnd,F){
   F := (StrLen(F) < 8 ? "0x" : "") . F
   F := ((F&255)<<16)+(((F>>8)&255)<<8)+(F>>16) ; rgb -> bgr
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1044, "Uint",F & 0xFFFFFF, "Uint", 0)   ; TTM_SETTIPTEXTCOLOR
}
ShowToolTip(hwnd,x,y,text,title="",I="0",T="",P="",A="",C="",M=""){
   local xc,yc,xw,yw,xl,xr,yl,yr
   MouseGetPos, xc,yc
   xc+=15,yc+=15
   WinGetPos,xw,yw,,,A
   If (x="caret"){
      SysGet,xl,76
      SysGet,xr,78
      xc:=xw+A_CaretX +1
      xc:=(xl>xc ? xl : (xr<xc ? xr : xc))
   }
   If (y="caret"){
      SysGet,yl,77
      SysGet,yr,79
      yc:=yw+A_CaretY+15
      yc:=(yl>yc ? yl : (yr<yc ? yr : yc))
   }
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1042, "Uint", 0, "Uint", ((x="" ? xc : (x="caret" ? xc : x)) & 0xFFFF)|((y="" ? yc : (y="caret" ? yc : y)) & 0xFFFF)<<16)   ; TTM_TRACKPOSITION
   NumPut(&text,#_ti_,36)
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1048, "Uint", 0, "Uint", A_ScreenWidth) ;TTM_SETMAXTIPWIDTH
   If (title!="")
      SetToolTipTitle(hwnd,title,I)
   DllCall("SendMessage", "Uint", hWnd, "Uint", 0x40c, "Uint", 0, "Uint", &#_ti_)   ; TTM_UPDATETIPTEXT
   If !C
      WinSet, Disable,,ahk_id %hwnd%
    If M
      WinSet,ExStyle,^0x20,ahk_id %hwnd%
   If T
      WinSet,Transparent,%T%,ahk_id %hwnd%
}
