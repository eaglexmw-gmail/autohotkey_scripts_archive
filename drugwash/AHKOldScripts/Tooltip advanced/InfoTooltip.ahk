UseBalloon=0
HideOnClick=0
ExitOnClick=0
Hotkey=#q

#NoEnv
#SingleInstance Force
CoordMode, Mouse, Relative
Hotkey, %Hotkey%,Restart
Menu, Tray, NoStandard
OnMessage(0x4e,"WM_NOTIFY") ;Will make LinkClick and ToolTipClose possible
OnMessage(0x404,"AHK_NotifyTrayIcon") ;Will pop up the ToolTip when you click on Tray Icon

MainText=
(
Hold CTRL or ALT and click onto the link to copy it to Clipboard

Visit ToolTip() control at <a http://www.autohotkey.com/forum/viewtopic.php?t=40165>www.autohotkey.com</a> or <a http://de.autohotkey.com/forum/topic4556.html>de.autohotkey.com</a>
<a>Hide ToolTip</a> - To show this ToolTip again click onto Tray Icon
<a>ExitApp</a>`n
)
Sleep, 10 ;requiered, otherwise first tooltip will appear at wrong position

Restart:
ToolTip(99,MainText
      , "Welcome by InfoToolTip"
      , "L1 R350 C1 I1 P99" . (UseBalloon ? " O1" : "") . (HideOnClick ? " H1" : ""))
Gosub, UpdateText
SetTimer, UpdateText,300
SetTimer, UpdatePos, 30
Return

UpdateText:
MouseGetPos, X, Y, WinId, ControlClass
WinGetPos,WX,WY,WW,WH,ahk_id %winId%
ControlGet,ControlId,Hwnd,,%ControlClass%,ahk_id %WinId%
ControlGetPos,CX,CY,CW,CH,%ControlClass%,ahk_id %WinId%
VarSetCapacity(xc, 20, 0), xc := Chr(20)
DllCall("GetCursorInfo", "Uint", &xc)
yc := NumGet(xc,16), xc := NumGet(xc,12)
WinGetClass, class,ahk_id %winId%
If class = tooltips_class32
   Return
WinGetTitle, title,ahk_id %winId%
titleshort:=SubStr(title,1,10)
PixelGetColor,BGRColor,%xc%,%yc%
PixelGetColor,RGBColor,%xc%,%yc%,RGB
wininfo=
(
Info at mouse coordinates:
 - WinTitle:`t`t<a copy %title%>%title%</a>
 - WinId:`t`t<a copy ahk_id %winid%>ahk_id %winid%</a>
 - WinClass:`t`t<a copy ahk_class %class%>ahk_class %class%</a>
`t`t`t<a copy %title% ahk_class %class%>%titleshort%_ahk_class_%class%</a>
 - WinPos:`t`t<a copy %WX%, %WY%>X: %WX%, Y: %WY%</a>  Size (<a copy %WW%, %WH%>W: %WW%, H: %WH%</a>)
 - Control:`t`t<a copy %controlClass%>%controlClass%</a>  <a copy %ControlId%>%ControlId%</a>
 - ControlPos:`t`t<a copy %CX%, %CY%>X: %CX%, Y: %CY%</a>  Size (<a copy %CW%, %CH%>W: %CW%, H: %CH%</a>)

Other Information:
 - MousePos:`t`tScreen (<a copy %xc%,  %yc%>%xc%,  %yc%</a>)  Window (<a copy %x%,  %y%>%x%,  %y%</a>)
 - Color:`t`t`tRGB: <a copy %RGBColor%>%RGBColor%</a>  BGR: <a copy %BGRColor%>%BGRColor%</a>


)
If !(GetKeyState("CTRL","P") or GetKeyState("Alt","P")){
   ToolTip(99,wininfo . MainText,"","L1 G1")
}
Return

UpdatePos:
If !(GetKeyState("CTRL","P") or GetKeyState("Alt","P"))
   ToolTip(99,"","","gTTM_UPDATE")
Return

99ToolTip:
If InStr(ErrorLevel,"copy "){
   Clipboard:= SubStr(ErrorLevel,6)
} else if InStr(link:=ErrorLevel,"http://")
   Run iexplore.exe %link%
else if IsLabel(label:=RegExReplace(link,"[^\w\.]","_"))
   SetTimer % label,-10
If ExitOnClick
   SetTimer, ExitApp, -100
Return

99ToolTipClose:
SetTimer, UpdatePos, Off
SetTimer, UpdateText, Off
ToolTip(100,"<a>Hide ToolTip</a>`t<a>ExitApp</a>`n`nTo show ToolTip Again click onto Tray Icon","Do you want to exit InfoToolTip","BFF0000 FFFFFFF H1 p99 L1 C1")
Return

100ToolTip:
100ToolTipClose:
If ErrorLevel=Exit
   ExitApp
Return


WM_NOTIFY(wParam, lParam){
   ToolTip("",lParam,"")
}

AHK_NotifyTrayIcon(wParam, lParam) {
   If (lparam = 0x201 or lparam = 0x202)
      SetTimer, Restart, -10
}


Hide_ToolTip:
ToolTip(99)
Return
ExitApp:
ExitApp



ToolTip(ID="", text="", title="",options=""){
   ;____  Assume Static Mode for internal variables and structures  ____
   
   static
   ;________________________  ToolTip Messages  ________________________
   
   TTM_POPUP:=0x422,         TTM_ADDTOOL:=0x404,        TTM_UPDATETIPTEXT:=0x40c
   TTM_POP:=0x41C,           TTM_DELTOOL:=0x405,        TTM_GETBUBBLESIZE:=0x41e
   TTM_UPDATE:=0x41D,        TTM_SETTOOLINFO:=0x409,      TTN_FIRST:=0xfffffdf8
   TTM_TRACKPOSITION:=0x412,    TTM_SETTIPBKCOLOR:=0x413,   TTM_SETTIPTEXTCOLOR:=0x414
   TTM_SETTITLEA:=0x420,      TTM_SETTITLEW:=0x421
   
   ;________________________  ToolTip colors  ________________________
   
   Black:=0x000000,    Green:=0x008000,      Silver:=0xC0C0C0
   Lime:=0x00FF00,      Gray:=0x808080,          Olive:=0x808000
   White:=0xFFFFFF,    Yellow:=0xFFFF00,      Maroon:=0x800000
    Navy:=0x000080,      Red:=0xFF0000,          Blue:=0x0000FF
   Purple:=0x800080,   Teal:=0x008080,         Fuchsia:=0xFF00FF
    Aqua:=0x00FFFF

   ;________________________  Local variables for options ________________________
   
   local option, a, b, c, d, f, g, h, i, l, m, o, p, r, t, v, w, x, y, xc, yc, xw, yw, update
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
                        ToolTip(A_LoopField)
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
   If (G){
      If (Title){
         Gosub, TTM_SETTITLEA
         Gosub, TTM_UPDATE
      }
      If (Text){
         If (InStr(text,"<a") and L){
            TOOLTEXT_%TT_ID%:=text
            text:=RegExReplace(text,"<a\K[^<]*?>",">")
         } else
            TOOLTEXT_%TT_ID%:=
         NumPut(&text,TOOLINFO_%TT_ID%,36)
         Gosub, TTM_UPDATETIPTEXT
      }
      Loop, Parse,G,.
         If IsLabel(A_LoopField)
            Gosub, %A_LoopField%
      DetectHiddenWindows,%#_DetectHiddenWindows%
      Return
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
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 1048, "Uint", 0, "Uint", R ? R : A_ScreenWidth) ;TTM_SETMAXTIPWIDTH
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x403, "Uint", 2, "Uint", (D ? D*1000 : -1)) ;TTDT_AUTOPOP
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x403, "Uint", 3, "Uint", (W ? W*1000 : -1)) ;TTDT_INITIAL
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x403, "Uint", 1, "Uint", (W ? W*1000 : -1)) ;TTDT_RESHOW
   } else if (!text and !options){
      DllCall("DestroyWindow","Uint",TT_HWND)
      TT_HWND_%TT_ID%=
      Gosub, TT_DESTROY
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
      ID :=Abs(A)
   } else {
      If !TOOLINFO_%ID%
         VarSetCapacity(TOOLINFO_%ID%, 40, 0),TOOLINFO_%ID%:=Chr(40)
      else update:=True
      If InStr(text,"<a"){
         TOOLTEXT_%ID%:=text
         text:=RegExReplace(text,"<a\K[^<]*?>",">")
      } else
         TOOLTEXT_%ID%:=
      NumPut((!(x . y) ? 0 : 0x20)|(S ? 0x80 : 0)|(L ? 0x1000 : 0),TOOLINFO_%ID%,4), Numput(P,TOOLINFO_%ID%,8), Numput(P,TOOLINFO_%ID%,12), NumPut(&text,TOOLINFO_%ID%,36)
      Gosub, TTM_ADDTOOL
   }

   If F
      Gosub, TTM_SETTIPTEXTCOLOR
   If B
      Gosub, TTM_SETTIPBKCOLOR
   
   If title
      Gosub, TTM_SETTITLEA
   
   If (!A){
      Gosub, TTM_UPDATETIPTEXT
      Gosub, TTM_UPDATE
      ;Gosub, TTM_POPUP
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
   TTM_SETTITLEA:
   TTM_SETTITLEW:
      title := (StrLen(title) < 96) ? title : ("…" . SubStr(title, -97))
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", I, "Uint", &Title)
   Return
   TTM_TRACKPOSITION:
      VarSetCapacity(xc, 20, 0), xc := Chr(20)
      DllCall("GetCursorInfo", "Uint", &xc)
      yc := NumGet(xc,16), xc := NumGet(xc,12)
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
      If (!x and !y)
         Gosub, TTM_UPDATE
      else if !WinActive("ahk_id " . TT_HWND)
         DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", 0, "Uint", ((x and x!="caret") ? x : xc & 0xFFFF)|((y and y!="caret") ? y : yc & 0xFFFF)<<16)
   Return
   TTM_SETTIPBKCOLOR:
      If B is alpha
         If (%b%)
            B:=%b%
      B := (StrLen(B) < 8 ? "0x" : "") . B
      B := ((B&255)<<16)+(((B>>8)&255)<<8)+(B>>16) ; rgb -> bgr
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint", B, "Uint", 0)
   Return
   TTM_SETTIPTEXTCOLOR:
      If F is alpha
         If (%F%)
            F:=%f%
      F := (StrLen(F) < 8 ? "0x" : "") . F
      F := ((F&255)<<16)+(((F>>8)&255)<<8)+(F>>16) ; rgb -> bgr
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", %A_ThisLabel%, "Uint",F & 0xFFFFFF, "Uint", 0)
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
