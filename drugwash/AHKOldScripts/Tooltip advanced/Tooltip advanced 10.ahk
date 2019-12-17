/*
ToolTip() by HotKeyIt http://www.autohotkey.com/forum/viewtopic.php?t=40165

Syntax: ToolTip(Number,Text,Title,Options)

Return Value: ToolTip returns hWnd of the ToolTip

|--------------------------------------------------------------------------------------------------------|
|         Options can include any of following parameters separated by space
|--------------------------------------------------------------------------------------------------------|
| Option      |      Meaning                                                                             |
|--------------------------------------------------------------------------------------------------------|
| A            |   Aim ConrolId or ClassNN (Button1, Edit2, ListBox1, SysListView321...)
|            |   - using this, ToolTip will be shown when you point mouse on a control
|            |   - D (delay) can be used to change how long ToolTip is shown
|            |   - Some controls like Static require a subroutine to have a ToolTip!!!
|--------------------------------------------------------------------------------------------------------|
| B and F      |   Specify here the color for ToolTip in 6-digit hexadecimal RGB code
|            |   - B = Background color, F = Foreground color (text color)
|            |   - this can be 0x00FF00 or 00FF00 or Blue, Lime, Black, White...
|--------------------------------------------------------------------------------------------------------|
| C            |   Close button for ToolTip/BalloonTip. See ToolTip actions how to use it
|--------------------------------------------------------------------------------------------------------|
| D            |   Delay. This option will determine how long ToolTip should be shown.1800 is maximum
|            |   - this option is also available when assigning the ToolTip to a control.
|--------------------------------------------------------------------------------------------------------|
| H            |   Hide/destroy ToolTip after a link is clicked.See L option
|--------------------------------------------------------------------------------------------------------|
| I            |   Icon 1-3, e.g. I1. If this option is missing no Icon will be used (same as I0)
|            |   - 1 = Info, 2 = Warning, 3 = Error, > 3 is meant to be a hIcon (handle to an Icon)
|--------------------------------------------------------------------------------------------------------|
| L            |   Links for ToolTips. See ToolTip actions how Links for ToolTip work.
|--------------------------------------------------------------------------------------------------------|
| M            |   Mouse click-trough. So a click will be forwarded to the window underneath ToolTip
|--------------------------------------------------------------------------------------------------------|
| O            |   Oval ToolTip (BalloonTip). Specify O1 to use a BalloonTip instead of ToolTip.
|--------------------------------------------------------------------------------------------------------|
| P            |   Parent window hWnd or GUI number. This will assign a ToolTip to a window.
|            |   - Reqiered to assign ToolTip to controls and actions.
|--------------------------------------------------------------------------------------------------------|
| S            |   Show at coordinates regardless of position. Specify S1 to use that feature
|            |   - normally it is fed automaticaly to show on screen
|--------------------------------------------------------------------------------------------------------|
| T            |   Transparency. This option will apply Transparency to a ToolTip.
|            |   - this option is not available to ToolTips assigned to a control.
|--------------------------------------------------------------------------------------------------------|
| V            |   Visible: even when the parent window is not active, a control-ToolTip will be shown
|--------------------------------------------------------------------------------------------------------|
| W            |   Wait time in seconds before displaying a ToolTip when pointing on one of controls
|--------------------------------------------------------------------------------------------------------|
| X and Y      |   Coordinates where ToolTip should be displayed, e.g. X100 Y200
|            |   - leave empty to display ToolTip near mouse
|            |   - you can specify Xcaret Ycaret to display at caret coordinates
|--------------------------------------------------------------------------------------------------------|
|
|          To destroy a ToolTip use ToolTip(Number), to destroy all ToolTip()
|
|--------------------------------------------------------------------------------------------------------|
|               ToolTip Actions (NOTE, OPTION P MUST BE PRESENT TO USE THAT FEATURE)
|--------------------------------------------------------------------------------------------------------|
|      Assigning an action to a ToolTip to works using OnMessage(0x4e,"Function") - WM_NOTIFY
|      Parameter/option P must be present so ToolTip will forward messages to script
|      All you need to do inside this OnMessage function is to include:
|         - If wParam=0
|            ToolTip("",lParam[,Label])
|
|      Additionally you need to have one or more of following labels in your script
|      - ToolTip: when clicking a link
|      - ToolTipClose: when closing ToolTip
|         - You can also have a diferent label for one or all ToolTips
|         - Therefore enter the number of ToolTip in front of the label
|            - e.g. 99ToolTip: or 1ToolTipClose:
|
|      - Those labels names can be customized as well
|         - e.g. ToolTip("",lParam,"MyTip") will use MyTip: and MyTipClose:
|         - you can enter the number of ToolTip in front of that label as well.
|
|      - Links have following syntax:
|         - <a>Link</a> or <a link>LinkName</a>
|         - When a Link is clicked, ToolTip() will jump to the label
|            - Variable ErrorLevel will contain clicked link
|
|         - So when only LinkName is given, e.g. <a>AutoHotkey</a> Errorlevel will be AutoHotkey
|         - When using Link is given as well, e.g. <a http://www.autohotkey.com>AutoHotkey</a>
|            - Errorlevel will be set to http://www.autohotkey.com
|
|--------------------------------------------------------------------------------------------------------|
|      Please note some options like Close Button will require Win2000++
|        AutoHotKey Version 1.0.48++ is required due to "assume static mode"
|        If you use 1 ToolTip for several controls, the only difference between those can be the text.
|           - Rest, like Title, color and so on, will be valid globally
|--------------------------------------------------------------------------------------------------------|
*/
ToolTip(ID="", text="", title="",options=""){
   ;____  Assume Static Mode for internal variables and structures  ____
   
   static
   ;________________________  ToolTip Messages  ________________________
   
   TTM_POPUP:=0x422,   TTM_ADDTOOL:=0x404,     TTM_UPDATETIPTEXT:=0x40c
   TTM_POP:=0x41C,     TTM_DELTOOL:=0x405,     TTM_GETBUBBLESIZE:=0x41e
   TTM_UPDATE:=0x41D,  TTM_SETTOOLINFO:=0x409   TTN_FIRST:=0xfffffdf8
   
   ;________________________  ToolTip colors  ________________________
   
   Black:=0x000000,    Green:=0x008000,      Silver:=0xC0C0C0
   Lime:=0x00FF00,      Gray:=0x808080,          Olive:=0x808000
   White:=0xFFFFFF,    Yellow:=0xFFFF00,      Maroon:=0x800000
    Navy:=0x000080,      Red:=0xFF0000,          Blue:=0x0000FF
   Purple:=0x800080,   Teal:=0x008080,         Fuchsia:=0xFF00FF
    Aqua:=0x00FFFF

   ;________________________  Local variables for options ________________________
   
   local option, a, b, c, d, f, h, i, l, m, o, p, t, v, w, x, y, xc, yc, xw, yw, update
   If ((#_DetectHiddenWindows:=A_DetectHiddenWindows)="Off")
      DetectHiddenWindows, On
   
   ;____________________________  Delete all ToolTips or return link _____________
   
   If !ID
   {
      If text
         If text is Xdigit
         {
            Loop 4
               m += *(text + 8 + A_Index-1) << 8*(A_Index-1)
            If !(TTN_FIRST-2=m or TTN_FIRST-3=m)
               Return
            Loop 4
               p += *(text + 0 + A_Index-1) << 8*(A_Index-1)
            If (TTN_FIRST-3=m)
               Loop 4
                  option += *(text + 16 + A_Index-1) << 8*(A_Index-1)
            Loop,Parse,hWndArray,% Chr(2)
               If (p=A_LoopField and i:=A_Index)
                  break
            Loop,Parse,idArray,% Chr(2)
            {
               If (i=A_Index){
                  text:=TOOLTEXT_%A_LoopField%
                  If (TTN_FIRST-2=m){
                     If Title
                     {
                        If IsLabel(A_LoopField . title . "Close")
                           Gosub % A_LoopField . title . "Close"
                        else If IsLabel(title . "Close")
                           Gosub % title . "Close"
                     } else {
                        If IsLabel(A_LoopField . A_ThisFunc . "Close")
                           Gosub % A_LoopField . A_ThisFunc . "Close"
                        else If IsLabel(A_ThisFunc . "Close")
                           Gosub % A_ThisFunc . "Close"
                     }
                  } else If (InStr(TOOLTEXT_%A_LoopField%,"<a")){
                     Loop % option+1
                        StringTrimLeft,text,text,% InStr(text,"<a")+1
                     If TT_HIDE_%A_LoopField%
                        ToolTip(A_LoopField,"")
                     If ((a:=A_AutoTrim)="Off")
                        AutoTrim, On
                     ErrorLevel:=SubStr(text,1,InStr(text,">")-1)
                     StringTrimLeft,text,text,% InStr(text,">")
                     text:=SubStr(text,1,InStr(text,"</a>")-1)
                     If !ErrorLevel
                        ErrorLevel:=text
                     ErrorLevel=%ErrorLevel%
                     AutoTrim, %a%
                     If Title
                     {
                        If IsFunc(f:=(A_LoopField . title))
                           %f%(ErrorLevel)
                        else if IsLabel(A_LoopField . title)
                           Gosub % A_LoopField . title
                        else if IsFunc(title)
                           %title%(ErrorLevel)
                        else If IsLabel(title)
                           Gosub, %title%
                     } else {
                        if IsFunc(f:=(A_LoopField . A_ThisFunc))
                           %f%(ErrorLevel)
                        else If IsLabel(A_LoopField . A_ThisFunc)
                           Gosub % A_LoopField . A_ThisFunc
                        else If IsLabel(A_ThisFunc)
                           Gosub % A_ThisFunc
                     }
                  }
                  break
               }
            }
            Return
         }
      Loop, Parse, hWndArray, % Chr(2)
      {
         If WinExist("ahk_id " . A_LoopField)
            DllCall("DestroyWindow","Uint",A_LoopField)
         hWndArray%A_LoopField%=
      }
      hWndArray=
      Loop, Parse, idArray, % Chr(2)
      {
         TT_ID:=A_LoopField
         If TT_ALL_%TT_ID%
            Gosub, TT_DESTROY
      }
      idArray=
      DetectHiddenWindows,%#_DetectHiddenWindows%
      Return
   }
   
   TT_ID:=ID
   TT_HWND:=TT_HWND_%TT_ID%

   ;___________________  Load Options Variables and Structures ___________________
   
   If (options){
      Loop,Parse,options,%A_Space%
         If (option:= SubStr(A_LoopField,1,1))
            %option%:= SubStr(A_LoopField,2)
   }
   
   ;__________________________  Save TOOLINFO Structures _________________________
   
   If P {
      If (p<100 and !WinExist("ahk_id " p)){
         Gui,%p%:+LastFound
         P:=WinExist()
      }
      If !InStr(TT_ALL_%TT_ID%,Chr(2) . Abs(P) . Chr(2))
         TT_ALL_%TT_ID% .= Chr(2) . Abs(P) . Chr(2)
   }
   If !InStr(TT_ALL_%TT_ID%,Chr(2) . ID . Chr(2))
      TT_ALL_%TT_ID% .= Chr(2) . ID . Chr(2)
   If H
      TT_HIDE_%TT_ID%:=1
   ;__________________________  Create ToolTip Window  __________________________
   
   If (!TT_HWND and text)
   {
      TT_HWND := DllCall("CreateWindowEx", "Uint", 0x8, "str", "tooltips_class32", "str", "", "Uint", 0x02 + (v ? 0x1 : 0) + (l ? 0x100 : 0) + (C ? 0x80 : 0)+(O ? 0x40 : 0), "int", 0x80000000, "int", 0x80000000, "int", 0x80000000, "int", 0x80000000, "Uint", P ? P : E, "Uint", 0, "Uint", 0, "Uint", 0)
      TT_HWND_%TT_ID%:=TT_HWND
      hWndArray.=(hWndArray ? Chr(2) : "") . TT_HWND
      idArray.=(idArray ? Chr(2) : "") . TT_ID
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 1048, "Uint", 0, "Uint", A_ScreenWidth) ;TTM_SETMAXTIPWIDTH
   } else if !(text){
      If (title){
         Gosub, TTM_SETTITLE
         Gosub, TTM_UPDATE
         Gosub, TTM_TRACKPOSITION
      } else {
         DllCall("DestroyWindow","Uint",TT_HWND)
         TT_HWND_%TT_ID%=
         Gosub, TT_DESTROY
      }
      DetectHiddenWindows,%#_DetectHiddenWindows%
      Return
   }
   ;______________________  Create TOOLINFO Structure  ______________________
   
   If A {
      If A is not Xdigit
         ControlGet,A,Hwnd,,%A%,ahk_id %P%
      ID :=Abs(A)
      If !InStr(TT_ALL_%TT_ID%,Chr(2) . ID . Chr(2))
         TT_ALL_%TT_ID% .= Chr(2) . ID . Chr(2) . ID+Abs(P) . Chr(2)
      If !TOOLINFO_%ID%
         VarSetCapacity(TOOLINFO_%ID%, 40, 0),TOOLINFO_%ID%:=Chr(40)
      else
         Gosub, TTM_DELTOOL
      Numput(1|16,TOOLINFO_%ID%,4),Numput(P,TOOLINFO_%ID%,8),Numput(ID,TOOLINFO_%ID%,12),NumPut(&text,TOOLINFO_%ID%,36)
      Gosub, TTM_ADDTOOL
      ID :=ID+Abs(P)
      If !TOOLINFO_%ID%
      {
         VarSetCapacity(TOOLINFO_%ID%, 40, 0),TOOLINFO_%ID%:=Chr(40)
         Numput(0|16,TOOLINFO_%ID%,4), Numput(P,TOOLINFO_%ID%,8), Numput(P,TOOLINFO_%ID%,12)
      }
      Gosub, TTM_ADDTOOL
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x403, "Uint", 2, "Uint", (D ? D*1000 : -1))
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x403, "Uint", 3, "Uint", (W ? W*1000 : -1))
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x403, "Uint", 1, "Uint", (W ? W*1000 : -1))
      ID :=Abs(A)
   } else {
      If !TOOLINFO_%ID%
         VarSetCapacity(TOOLINFO_%ID%, 40, 0),TOOLINFO_%ID%:=Chr(40)
      else update:=True
      If InStr(text,"<a"){
         TOOLTEXT_%ID%:=text
         text:=RegExReplace(text,"<a\K[^<]*?>",">")
      }
      NumPut((!(x . y) ? 0 : 0x20)|(S ? 0x80 : 0)|(L ? 0x1000 : 0),TOOLINFO_%ID%,4), Numput(P,TOOLINFO_%ID%,8), Numput(P,TOOLINFO_%ID%,12), NumPut(&text,TOOLINFO_%ID%,36)
      Gosub, TTM_ADDTOOL
   }
   
   If F
      Gosub, TTM_SETTIPTEXTCOLOR
   If B
      Gosub, TTM_SETTIPBKCOLOR
   
   If title
      Gosub, TTM_SETTITLE
   If !A
   {
      Gosub, TTM_UPDATETIPTEXT
      Gosub, TTM_UPDATE
      Gosub, TTM_POPUP
      If D {
         A_Timer := A_TickCount, D *= 1000
         Gosub, TTM_TRACKPOSITION
         Gosub, TTM_TRACKACTIVATE
         Loop
         {
            Gosub, TTM_TRACKPOSITION
            If (A_TickCount - A_Timer > D)
               Break
         }
         Gosub, TT_DESTROY
         DllCall("DestroyWindow","Uint",TT_HWND)
         TT_HWND_%TT_ID%=
      } else {
         Gosub, TTM_TRACKPOSITION
         Gosub, TTM_TRACKACTIVATE
         If T
            WinSet,Transparent,%T%,ahk_id %TT_HWND%
         If M
            WinSet,ExStyle,^0x20,ahk_id %TT_HWND%
      }
   }
   
   ;________  Restore DetectHiddenWindows and return HWND of ToolTip  ________

   DetectHiddenWindows, %#_DetectHiddenWindows%
   Return TT_HWND
   
   ;________________________  Internal Labels  ________________________
   
   TTM_POP:
   TTM_POPUP:
   TTM_UPDATE:
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", 0, "Uint", 0)
   Return
   TTM_TRACKACTIVATE:
   DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x411, "Uint", 1, "Uint", &TOOLINFO_%ID%)
   Return
   TTM_UPDATETIPTEXT:
   TTM_GETBUBBLESIZE:
   TTM_ADDTOOL:
   TTM_DELTOOL:
   TTM_SETTOOLINFO:
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", 0, "Uint", &TOOLINFO_%ID%)
   Return
   TTM_SETTITLE:
      title := (StrLen(title) < 96) ? title : ("…" . SubStr(title, -97))
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 1056, "Uint", I, "Uint", &Title)
   Return
   TTM_TRACKPOSITION:
      If x is integer
         If y is integer
         {
            DllCall("SendMessage", "Uint", TT_HWND, "Uint", 1042, "Uint", 0, "Uint", (x & 0xFFFF)|(y & 0xFFFF)<<16)
            Return
         }
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
      } else {
         VarSetCapacity(xc, 20, 0), xc := Chr(20)
         DllCall("GetCursorInfo", "Uint", &xc)
         yc := NumGet(xc,16), xc := NumGet(xc,12)
         xc+=15,yc+=15
      }
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 1042, "Uint", 0, "Uint", (xc & 0xFFFF)|(yc & 0xFFFF)<<16)
   Return
   TTM_SETTIPBKCOLOR:
      If B is alpha
         If (%b%)
            B:=%b%
      B := (StrLen(B) < 8 ? "0x" : "") . B
      B := ((B&255)<<16)+(((B>>8)&255)<<8)+(B>>16) ; rgb -> bgr
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 1043, "Uint", B, "Uint", 0)
   Return
   TTM_SETTIPTEXTCOLOR:
      If F is alpha
         If (%F%)
            F:=%f%
      F := (StrLen(F) < 8 ? "0x" : "") . F
      F := ((F&255)<<16)+(((F>>8)&255)<<8)+(F>>16) ; rgb -> bgr
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 1044, "Uint",F & 0xFFFFFF, "Uint", 0)
   Return
   TT_DESTROY:
      Loop, Parse, TT_ALL_%TT_ID%,% Chr(2)
         If A_LoopField
         {
            ID:=A_LoopField
            Gosub, TTM_DELTOOL
            TOOLINFO_%A_LoopField%:="", TT_HWND_%A_LoopField%:="", TOOLTEXT_%A_LoopField%:="", TT_HIDE_%A_LoopField%:=""
         }
      TT_ALL_%TT_ID%=
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
