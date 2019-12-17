; by HotkeyIt  http://www.autohotkey.com/forum/viewtopic.php?t=40165

ToolTip(_tool_tip_id_="", text=" ", title="", options=""){ ;i x y b f d t o c m
   static _tt_hwnd_list_,txt:=" "
   global #_ti_
   If !#_ti_
      VarSetCapacity(#_ti_, 40, 0),#_ti_:=Chr(40),NumPut(0x20,#_ti_,4)
   If !_tool_tip_id_
   {
      Loop,Parse,_tt_hwnd_list_,|
         If WinExist("ahk_id " RegExReplace(A_LoopField,"\d+\."))
            DllCall("DestroyWindow","Uint",hwnd1)
      _tt_hwnd_list_=
      Return
   }
   If options
      Loop,Parse,options,%A_Space%
      {
         option:= SubStr(A_LoopField,1,1)
         ;MsgBox % option "=" SubStr(A_LoopField,2)
         If option
            %option%:= SubStr(A_LoopField,2)
      }
   If RegExMatch(_tt_hwnd_list_,"\|" . _tool_tip_id_ . "\.([^\|]+)",hwnd)
         hwnd = %hwnd1%
   If (!WinExist("ahk_id " hwnd1) and text!="")
   {
      _tt_hwnd_list_:=RegExReplace(_tt_hwnd_list_,"\|" . _tool_tip_id_ . "\.[^\|]+\|")
      ;MsgBox % O "`n" C "`n" (C ? 80 : 0)+(O ? 115 : 50)
      hWnd := DllCall("CreateWindowEx", "Uint", 0x8, "str", "tooltips_class32", "str", "", "Uint", (C ? 80 : 0)+(O ? 115 : 50), "int", 0, "int", 0, "int", 0, "int", 0, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0) ;param4 0xc3 0x80
      _tt_hwnd_list_.= "|" . _tool_tip_id_ . "." . hWnd . "|"
      NumPut(&txt,#_ti_,36)
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1028, "Uint", 0, "Uint", &#_ti_)   ; TTM_ADDTOOL
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1041, "Uint", 1, "Uint", &#_ti_)   ; TTM_TRACKACTIVATE
      WinHide, ahk_id %hWnd%
      If !C
      WinSet, Disable,,ahk_id %hwnd%
      If M
       WinSet,ExStyle,^0x20,ahk_id %hwnd%
   }
   ;MsgBox % options "`n" i x y b f d t
   If ((B!="" ? SetToolTipColor(hwnd,B) :) or (F !="" ? SetToolTipTextColor(hwnd,F) :) and text="")
      DllCall("DestroyWindow","Uint",hwnd), _tt_hwnd_list_:=RegExReplace(_tt_hwnd_list_,"\|" . _tool_tip_id_ . "\.[^\|]+\|")
   else if !D
      ShowToolTip(hwnd,x,y,text,title,I,T)
   else
   {
      A_Timer = %A_TickCount%
      D *= 1000
      Loop
         If (A_TickCount - A_Timer > D or ShowToolTip(hwnd,x,y,text,title,I,T))
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
ShowToolTip(hwnd,x,y,text,title="",I="0",T=""){
   local xc,yc,xw,yw,xl,xr,yl,yr
   MouseGetPos, xc,yc
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
/*
myresx := x="" ? xc : (x="caret" ? xc : x)
myresy := y="" ? yc : (y="caret" ? yc : y)
msgbox, x=%myresx%, y=%myresy%
*/
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1042, "Uint", 0, "Uint", ((x="" ? xc : (x="caret" ? xc : x)) & 0xFFFF)|((y="" ? yc : (y="caret" ? yc : y)) & 0xFFFF)<<16)   ; TTM_TRACKPOSITION
   If (title!="")
      SetToolTipTitle(hwnd,title,I)
   NumPut(&text,#_ti_,36)
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1048, "Uint", 0, "Uint", A_ScreenWidth) ;TTM_SETMAXTIPWIDTH
   DllCall("SendMessage", "Uint", hWnd, "Uint", 0x40c, "Uint", 0, "Uint", &#_ti_)   ; TTM_UPDATETIPTEXT
   WinSet, Disable,,ahk_id %hwnd%
   If T
      WinSet,Transparent,%t%,ahk_id %hwnd%
}
