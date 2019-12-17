
/*
ToolTip() by HotKeyIt http://www.autohotkey.com/forum/viewtopic.php?t=40165

Options can include any of following parameters separated by space
In    - Icon 1-3, e.g. I1
Xn Yn    - screen coordinates, can be empty to display near the mouse or caret to display near caret
        e.g. X200 Y300 or Xcaret Ycaret
bn    - background color, e.g. BFFFFFF or B0xFFFFFF
fn      - text color, e.g. F000000 or F0x000000
dn      - delay in seconds, e.g. d5
tn      - Transparency, e.g. t200
o1      - activate Balloontip, e.g. O1
c1      - display close button, e.g. C1
m1      - activate click trough effect, e.g. M1
phwnd   - Parent window hwnd (necessary for addtool below)
ahwnd   - ControlId to show ToolTip for, can be class=(Static1,Edit1), can be empty=(If P="" show for parent window only)
*/
; ### Example Code #####
Loop 3
{
   ToolTip(99,"`nJust an example ToolTip following mouse movements"
   ,"This ToolTip will be destroyed in " . 4-A_Index . " Seconds","o1 I" . GetAssociatedIcon(A_AhkPath) . " B0000FF FFFFFFF D1")
}
ToolTip(99,"")

Gui,Add,Text,,Point here or anywhere (no control area)`nYou will see ToolTip associated with this window
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
ToolTip(10,"This ToolTip belongs to no control.`nIt is shown when you point mouse onto window area.`nIts option T (timer) is set to a high value to keep it displaying!"
      ,"Gui associated ToolTip","B0000FF FFFFFFF D99999999999 I1 P" . GuiHwnd)

ToolTip(1,"This is a usual tooltip`, click to change","","aButton1 P" . GuiHwnd)
ToolTip(1,"Same ToolTip with a different text`nYou can also click here to change it","","aButton2 P" . GuiHwnd)

ToolTip(2,"This is a colored ToolTip","","B00FF00 aButton3 P" . GuiHwnd)
ToolTip(2,"Same colored ToolTip containing new text","","aButton4 P" . GuiHwnd)

ToolTip(3,"This is a colored ToolTip with Title","Welcome","B00FF00 aButton5 P" . GuiHwnd)
ToolTip(3,"This is a colored ToolTip with Title`nand multilines`n`nanother line","","aButton6 P" . GuiHwnd)

ToolTip(4,"This is a BalloonTip","","O1 aButton7 P" . GuiHwnd)
ToolTip(4,"This is a BalloonTip","","aButton8 P" . GuiHwnd)

ToolTip(5,"This is a colored BalloonTip with Title`nAdditionally its text is colored"
      ,"Welcome","B0000FF FFFFFFF O1 aButton9 P" . GuiHwnd)
ToolTip(5,"This is a colored BaloonTip with Title`nAdditionally its text is colored","","aButton10 P" . GuiHwnd)

ToolTip(6,"This is a ToolTip with Title and close button","Welcome","C1 aButton11 P" . GuiHwnd)
ToolTip(6,"This is a ToolTip with Title and close button","","aButton12 P" . GuiHwnd)

ToolTip(7,"This is a ToolTip with Title and Icon","Welcome","I1 aButton13 P" . GuiHwnd)
ToolTip(7,"This is a ToolTip with Title and Icon","","aButton14 P" . GuiHwnd)

ToolTip(8,"This is a colored BalloonTip`nWith Title`, Icon and Close Button"
      ,"Welcome","B0000FF FFFFFFF C1 O1 I2 aButton15 P" . GuiHwnd)
ToolTip(8,"This is a colored BalloonTip`nWith Title`, Icon and Close Button","","aButton16 P" . GuiHwnd)

ToolTip(9,"This is a colored ToolTip","","BFF00FF FFFFFFF aButton17 P" . GuiHwnd)
ToolTip(9,"This is a colored ToolTip","","aButton18 P" . GuiHwnd)

Gui,show,,Test Gui
Return


Button1:
Loop 2
   ToolTip(1,"New Text","New Title " A_Index,"B0000FF FFFFFFF T200 Abutton" . A_Index . " P" . GuiHwnd)
REturn

GuiClose:
Guiescape:
ExitApp



   
ToolTip(ID="", text=" ", title="",options=""){ ;i x y b f d t o c m p a
   static
   local option, a, b, c, d, f, i, m, o, p, C_ID, hWnd
   C_ID:=ID
    If ((#_DetectHiddenWindows:=A_DetectHiddenWindows)="Off")
      DetectHiddenWindows, On
   If !ID
   {
      Loop, Parse, hWndArray, % Chr(2)
         If (hwnd:=WinExist("ahk_id " hWndArray%A_LoopField%))
            DllCall("DestroyWindow","Uint",hwnd)
      hWndArray=
      DetectHiddenWindows,%#_DetectHiddenWindows%
      Return
   }
   If options
      Loop,Parse,options,%A_Space%
         If (option:= SubStr(A_LoopField,1,1))
            %option%:= SubStr(A_LoopField,2)
   hwnd:=hWndArray%C_ID%
   If (!hwnd and text)
   {
      hWndArray.=(hWndArray ? Chr(2) : "") . ID
      hWnd := DllCall("CreateWindowEx", "Uint", 0x8, "str", "tooltips_class32", "str", "", "Uint", (C ? 80 : 0)+(O ? 115 : 50), "int", 0, "int", 0, "int", 0, "int", 0, "Uint", P, "Uint", 0, "Uint", 0, "Uint", 0) ;param4 0xc3 0x80
       hWndArray%C_ID%:=hwnd
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1048, "Uint", 0, "Uint", A_ScreenWidth) ;TTM_SETMAXTIPWIDTH
   } else If (text=""){
      DllCall("DestroyWindow","Uint",hwnd), hWndArray%C_ID%:=""
      Return
   }
   
   If P
   {
      ID := Abs(P)
      If A {
         If A is not Xdigit
            ControlGet,A,Hwnd,,%A%,ahk_id %P%
         ID :=Abs(A)
      }
      If !TOOLINFO_%ID%
         VarSetCapacity(TOOLINFO_%ID%, 40, 0),TOOLINFO_%ID%:=Chr(40)
      else
         DllCall("SendMessage", "Uint", hWnd, "Uint", 0x405, "Uint", 0, "Uint", &TOOLINFO_%ID%)   ; TTM_DELTOOL
      Numput(ID,TOOLINFO_%ID%,12)
      Numput(1|16,TOOLINFO_%ID%,4)
      Numput(P,TOOLINFO_%ID%,8)
      DllCall("SendMessage", "Uint", hWnd, "Uint", 0x403, "Uint", 2, "Uint", (D ? D*1000 : -1))   ; TTDT_INITIAL
      DllCall("SendMessage", "Uint", hWnd, "Uint", 0x404, "Uint", 0, "Uint", &TOOLINFO_%ID%)   ; TTM_ADDTOOL
   } else {
      If !TOOLINFO_%ID%
         VarSetCapacity(TOOLINFO_%ID%, 40, 0),TOOLINFO_%ID%:=Chr(40)
      If O
         NumPut(0x20,TOOLINFO_%ID%,4)
      else
         NumPut(0x20|0x80,TOOLINFO_%ID%,4)
      DllCall("SendMessage", "Uint", hWnd, "Uint", 0x403, "Uint", 2, "Uint", (D ? D*1000 : -1))   ; TTDT_INITIAL
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1028, "Uint", 0, "Uint", &TOOLINFO_%ID%)   ; TTM_ADDTOOL
   }
   If B
      Gosub, TTM_SETTIPBKCOLOR
   If F
      Gosub, TTM_SETTIPTEXTCOLOR

   NumPut(&text,TOOLINFO_%ID%,36)
   If title
      Gosub, TTM_SETTITLE
   Gosub, TTM_UPDATETIPTEXT
   If (D and !P)
   {
      A_Timer := A_TickCount, D *= 1000
      Loop
      {
         Gosub, TTM_TRACKPOSITION
         Gosub, TTM_UPDATETIPTEXT
         If (A_TickCount - A_Timer > D)
            Break
      }
      DllCall("DestroyWindow","Uint",hwnd), hWndArray%C_ID%:=""
   }
   If !P
   {
      Gosub, TTM_TRACKPOSITION
      If !C
         WinSet, Disable,,ahk_id %hwnd%
      If M
         WinSet,ExStyle,^0x20,ahk_id %hwnd%
      If T
         WinSet,Transparent,%T%,ahk_id %hwnd%
   }
   Return hwnd
   
   TTM_SETTITLE:
      title := (StrLen(title) < 96) ? title : ("…" . SubStr(title, -97))
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1056, "Uint", I, "Uint", &Title)
   Return
   TTM_TRACKPOSITION:
      If x is integer
         If y is integer
         {
            DllCall("SendMessage", "Uint", hWnd, "Uint", 1042, "Uint", 0, "Uint", (x & 0xFFFF)|(y & 0xFFFF)<<16)
	DllCall("SendMessage", "Uint", hWnd, "Uint", 1041, "Uint", 1, "Uint", &TOOLINFO_%ID%)   ; TTM_TRACKACTIVATE
            Return
         }
      MouseGetPos, xc,yc
      xc+=15,yc+=15
      If (x="caret" or y="caret"){
         WinGetPos,xw,yw,,,A
         If x=caret
         {
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
      }
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1042, "Uint", 0, "Uint", (xc & 0xFFFF)|(yc & 0xFFFF)<<16)
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1041, "Uint", 1, "Uint", &TOOLINFO_%ID%)   ; TTM_TRACKACTIVATE
   Return
   TTM_SETTIPBKCOLOR:
      B := (StrLen(B) < 8 ? "0x" : "") . B
      B := ((B&255)<<16)+(((B>>8)&255)<<8)+(B>>16) ; rgb -> bgr
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1043, "Uint", B, "Uint", 0)
   Return
   TTM_SETTIPTEXTCOLOR:
      F := (StrLen(F) < 8 ? "0x" : "") . F
      F := ((F&255)<<16)+(((F>>8)&255)<<8)+(F>>16) ; rgb -> bgr
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1044, "Uint",F & 0xFFFFFF, "Uint", 0)
   Return
   TTM_UPDATETIPTEXT:
   DllCall("SendMessage", "Uint", hWnd, "Uint", 0x40c, "Uint", 0, "Uint", &TOOLINFO_%ID%)
   Return
}
MI_ExtractIcon(Filename, IconNumber, IconSize)
{
    If A_OSVersion in WIN_VISTA,WIN_2003,WIN_XP,WIN_2000
    {
      DllCall("PrivateExtractIcons", "Str", Filename, "Int", IconNumber-1, "Int", IconSize, "Int", IconSize, "UInt*", hIcon, "UInt*", 0, "UInt", 1, "UInt", 0, "Int")
        If !ErrorLevel
        Return hIcon
    }
    If DllCall("shell32.dll\ExtractIconExA", "Str", Filename, "Int", IconNumber-1, "UInt*", hIcon, "UInt*", hIcon_Small, "UInt", 1)
    {
        SysGet, SmallIconSize, 49
       
        If (IconSize <= SmallIconSize) {
         DllCall("DeStroyIcon", "UInt", hIcon)
         hIcon := hIcon_Small
        }
      Else
      DllCall("DeStroyIcon", "UInt", hIcon_Small)
       
        If (hIcon && IconSize)
         hIcon := DllCall("CopyImage", "UInt", hIcon, "UInt", 1, "Int", IconSize, "Int", IconSize, "UInt", 4|8)
    }
    Return, hIcon ? hIcon : 0
}
GetAssociatedIcon(File){
   static
   sfi_size:=352
   local Ext,Fileto,FileIcon,FileIcon#
   If not sfi
      VarSetCapacity(sfi, sfi_size)
   SplitPath, File,,, Ext
   if Ext in EXE,ICO,ANI,CUR,LNK
   {
      If ext=LNK
      {
         FileGetShortcut,%File%,Fileto,,,,FileIcon,FileIcon#
         File:=!FileIcon ? FileTo : FileIcon
      }
      SplitPath, File,,, Ext
      If !(hIcon%Ext%:=MI_ExtractIcon(InStr(File,"`n") ? SubStr(file,1,InStr(file,"`n")-1) : file,FileIcon# ? FileIcon# : 1,32))
         hIcon%Ext%:=#_hIcon_3
   }
   else If !(InStr(hIcons,"|" . Ext . "|")){
      If DllCall("Shell32\SHGetFileInfoA", "str", File, "uint", 0, "str", sfi, "uint", sfi_size, "uint", 0x101){
         Loop 4
            hIcon%Ext% += *(&sfi + A_Index-1) << 8*(A_Index-1)
      }
      hIcons.= "|" . Ext . "|"
   }
   return hIcon%Ext%
}
