; http://www.autohotkey.com/forum/viewtopic.php?t=34639

#SingleInstance, Force
StringReplace, GPLfile, A_AhkPath, Autohotkey.exe, License.txt
FileRead, GPL, %GPLfile%
View()
View( GPL, "Title=Press <Esc> to dismiss this dialog" )
View( GPL, "Title=GP LICENSE, Wrap=True, W=320, H=240, Font=Arial, FHt=14, FWt=Bold" )

View( Text="", Options="" ) {
   if (text = "" && options = "")
      return View( "
      ; DOCUMENTATION:
      ( LTrim Join`n
      Function View( Text, Options="" ) by SKAN.
      (Slightly modified by infogulch)
      
      returns the milliseconds the view was shown
      sets errorlevel to 1 if the timout was reached
      sets errorlevel to 0 if the hotkey state was reached first
      leave all params blank to show this help message
      
      Text: The text to be displayed
      Options: string of options (format: option=default)
      `    W=640, H=480, X=[centered], Y=[centered]
      `    Title=A_ScriptFullPath, Wrap=False, ReadOnly=True
      `    Font=Courier New, FHt, FWt
      `    Key=Esc, KeyDir=Down
      `    Timeout=0 (0 means no timeout)
      )", "")
   ReadOnly := True, Title := A_ScriptFullPath, Key := "Esc", KeyDir := "Down"
   loop, Parse, Options,`,=, %A_Space%%A_Tab%`r`n
      A_Index & 1  ? ( Var := A_LoopField ) : ( %Var% := A_LoopField )
   W:=W ? W:640
   , H:=H ? H:480
   , X:=X+0!="" ? X:((A_ScreenWidth/2)-(W/2))
   , Y:=Y+0!="" ? Y:((A_ScreenHeight/2)-(H/2))
   , WS:=Wrap ? 0x50201044:0x503010C4
   , WS|=ReadOnly ? 0x800:0
   , Text := RegExReplace(Text, "(?<!\r)\n", "`r$0")
   , KeyDir := KeyDir = "down" || KeyDir = "d" ? "D" : ""
   , Timeout := Timeout+0 ? "T" Timeout : ""
   hWnd := DllCall( "CreateWindowEx",Int,0, Str,"#32770", Str, Title, UInt, 0x10400000
      , UInt,X, UInt,Y, UInt,W, UInt,H, Int,0,Int,0,Int,0,Int,0,Int,0 )
   VarSetCapacity( CR,16,0 ),  DllCall( "GetClientRect", UInt, hWnd, UInt,&CR )
   Edit := DllCall( "CreateWindowEx", Int, 0, Str, "Edit", Int, 0, UInt, WS, Int, 0,Int,0, UInt
      ,NumGet(CR,8), UInt, NumGet(CR,12), UInt,hWnd, Int,0,Int,0,Int,0 )
   hFnt := DllCall( "CreateFont", Int,FHT ? FHt:0, Int,0,Int,0,Int,0, Int,( FWt="Bold")? 700
      :0, Int,0,Int,0,Int,0,Int,0,Int,0,Int,0,Int,0,Int,0, Str,Font ? Font:"Courier New" )
   DllCall( "SendMessageA", UInt, Edit, UInt,0x30, UInt,hFnt, UInt,0 )       ; WM_SETFONT
   DllCall( "SendMessageA", UInt, Edit, UInt,0xD3, UInt,1   , UInt,5 )       ; EM_SETMARGINS
   DllCall( "SendMessageA", UInt, Edit, UInt,0x0C, UInt,0   , UInt,&Text )   ; WM_SETTEXT
   DllCall( "SendMessageA", UInt, Edit, UInt,0xB1, UInt,-1  , UInt,0 )       ; EM_SETSEL
   Start := A_TickCount
   WinActivate, ahk_id %hwnd%
   KeyWait, %Key%, %KeyDir% %Timeout%
   err := ErrorLevel, DllCall( "DestroyWindow", UInt, hWnd ), DllCall( "DeleteObject", UInt, hFnt )
   return A_TickCount - Start, ErrorLevel := err
}
