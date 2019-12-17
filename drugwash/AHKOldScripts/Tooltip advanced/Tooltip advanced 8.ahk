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
v1      - show ToolTip when pointing mouse on a control even if Parent window is not active
l1      - Parse links, links have to be enclosed in <a></a>, e.g. <a>http://www.autohotkey.com</a> (no linkclick yet :( )
phwnd   - Parent window hwnd (necessary for addtool below)
ahwnd   - ControlId to show ToolTip for, can be class=(Static1,Edit1), can be empty=(If P="" show for parent window only)

;~  Please note some options like Close Button will require Win2000++
;~  AutoHotKey Version 1.0.48++ is required because of assume static mode.
;~  D option can be used to avoid hiding of ToolTip when mouse stays longer on a control.
;~  - This is necessary when you have 1 ToolTip for 1 control only.
;~  - Otherwise when ToolTip is gone, it will not be shown again!
;~  - Maximum for D option is 1800
;~  If you use 1 ToolTip for several controls, the only difference between those can be the text.
;~  - Rest, like Title, color and so on, will be valid globally
*/
#NoEnv
#SingleInstance Force


ToolTip(99,"`nJust an example ToolTip following mouse movements"
   ,"This ToolTip will be destroyed in " . 4 . " Seconds","o1 I" . GetAssociatedIcon(A_AhkPath) . " B0000FF FFFFFFF")
Start:=A_TickCount
While, end < 3
{
   ToolTip(99,"","This ToolTip will be destroyed in " .  4 - Round(end:=(A_TickCount-Start)/1000) . " Seconds","I" . GetAssociatedIcon(A_AhkPath))
}
ToolTip(99,"")
Sleep, 500
ToolTip(99,"`nJust an example ToolTip following mouse movements"
   ,"This ToolTip will be destroyed in " . 4 . " Seconds","o1 I" . GetAssociatedIcon(A_AhkPath) . " B0000FF FFFFFFF")
Start:=A_TickCount
end=
While, end < 3
{
   ToolTip(99,"test","This ToolTip will be destroyed in " .  4 - Round(end:=(A_TickCount-Start)/1000) . " Seconds","I" . GetAssociatedIcon(A_AhkPath))
}
ToolTip(99,"")
Sleep, 500
ToolTip(99,"test","This ToolTip will be destroyed in " .  4 . " Seconds","D3 o1 I" . GetAssociatedIcon(A_AhkPath) . " B0000FF FFFFFFF")

ToolTip(99,"<a>AutoHotkey</a>","Link example","O1 L1 C1 I" . GetAssociatedIcon(A_ProgramFiles . "\Internet Explorer\iexplore.exe"))



;-- Collect hWnd for GUI
Gui,+LastFound
GuiHwnd:=WinExist()

ToolTip(98,"This ToolTip is shown when you point on GUI with mouse","Associated with Gui","P" . GuiHwnd)
;-- Build GUI
gui -MinimizeBox

gui Add,Button,w150 hwndButton1_hWnd gButton1,Test Button 1
Tip:="Button 1: Press me to change my tooltip"
ToolTip(1,Tip,"","D1800 A" . Button1_hWnd . " P" . GuiHwnd)


gui Add,Button,y+0 w150 hwndButton2_hWnd gButton2,Test Button 2
Tip:="Button 2: Press me to turn off the tooltip for this button"
ToolTip(2,Tip,"","A" . Button2_hWnd . " P" . GuiHwnd)


gui Add,Button,y+0 w150 hwndButton3_hWnd gButton3,Test Button 3
Tip=
   (ltrim
    A Multiline Test Tooltip
    2nd line
    3rd line
    4th line.

    Press me to turn off all tooltips
   )
ToolTip(3,Tip,"","A" . Button3_hWnd . " P" . GuiHwnd)


gui Add,Checkbox,w150 hwndCheckbox_hWnd,Checkbox Control
Tip:="Tooltip for the Checkbox control"
ToolTip(4,Tip,"","A" . Checkbox_hWnd . " P" . GuiHwnd)


gui Add,Radio,w150 hwndRadio_hWnd,Radio Control
Tip:="Tooltip for the Radio control"
ToolTip(5,Tip,"","A" . Radio_hWnd . " P" . GuiHwnd)


gui Add,Edit,w150 hwndEdit_hWnd,Edit Control
Tip:="Tooltip for the Edit control"
ToolTip(6,Tip,"","A" . Edit_hWnd . " P" . GuiHwnd)


gui Add,Text,w150 hwndText_hWnd gNull,Text Control
Tip=
   (ltrim join`s
    Tooltip for the Text control.`nNote that the Tooltip for a Text control does
    not show unless a g-label for the control is defined.
   )
ToolTip(7,Tip,"","A" . Text_hWnd . " P" . GuiHwnd)


gui Add,Picture,w150 h100 hwndPicture_hWnd gnull,Picture.bmp
Tip=
   (ltrim join`s
    Tooltip for the Picture control.`nNote that the Tooltip for a Picture
    control does not show unless a g-label for the control is defined.   
   )
ToolTip(9,Tip,"","A" . Picture_hWnd . " P" . GuiHwnd)


gui Add,DropDownList,w150 r3 hwndDropDownList_hWnd,DropDownList Control||2|3
Tip:="Tooltip for the DropDownList control"
ToolTip(10,Tip,"","A" . DropDownList_hWnd . " P" . GuiHwnd)


gui Add,ComboBox,w150 r3 hwndComboBox_hWnd,ComboBox Control||2|3
    ;-- A ComboBox is actually two controls:  An Edit control and a Drop-down
    ;   button. Note that handle returned for this control is for the
    ;   drop-down button, not for the Edit control.
Tip=
   (ltrim join`s
    Tooltip for the drop-down button piece of the ComboBox control.`nNote that
    this tip is different than the Edit piece of the control.
   )
ToolTip(11,Tip,"","A" . ComboBox_hWnd . " P" . GuiHwnd)


gui Add,ListBox,w150 r3 hwndListBox_hWnd,ListBox Control||2|3
Tip:="Tooltip for the ListBox control"
ToolTip(12,Tip,"","A" . ListBox_hWnd . " P" . GuiHwnd)


gui Add,ListView,w150 h50 hwndListView_hWnd,ListView Control
Tip=
   (ltrim join`s
    Tooltip for the ListView control.`nNote that this tip is different than
    the header piece of the control.
   )
ToolTip(13,Tip,"","A" . ListView_hWnd . " P" . GuiHwnd)


gui Add,DateTime,w150 hwndDateTime_hWnd  ;,DateTime Control
Tip:="Tooltip for the DateTime control"
ToolTip(14,Tip,"","A" . DateTime_hWnd . " P" . GuiHwnd)


;-- Uncomment this if you want to see the MonthCal control.  Works the same as DateTime
;;;;;gui Add,MonthCal,w150 hwndMonthCal_hWnd  ;,MonthCal Control
;;;;;Tip:="Tooltip for the MonthCal control"
;;;;;ToolTip(15,Tip,"","A" . MonthCal_hWnd . " P" . GuiHwnd)


gui Add,Progress,w150 hwndProgress_hWnd,65  ;Progress Control
Tip:="Tooltip for the Progress control"
ToolTip(16,Tip,"","A" . Progress_hWnd . " P" . GuiHwnd)


gui Add,Slider,w150 hwndSlider_hWnd,45  ;Slider Control
Tip:="Tooltip for the Slider control"
ToolTip(17,Tip,"","A" . Slider_hWnd . " P" . GuiHwnd)


gui Add,Hotkey,w150 hwndHotkey_hWnd,45  ;Hotkey Control
Tip:="Tooltip for the Hotkey control"
ToolTip(18,Tip,"","A" . Hotkey_hWnd . " P" . GuiHwnd)


gui Add,Edit,w150 h20 hwndEdit2_hWnd,Dummy Edit Control  ;-- Used by UpDown control
Tip=
   (ltrim join`s
    This Edit control was created so that the attached UpDown control could be
    demonstrated.
   )
ToolTip(19,Tip,"","A" . Edit2_hWnd . " P" . GuiHwnd)


gui Add,UpDown,hwndUpDown_hWnd Range 1-10,5
Tip:="Tooltip for the UpDown control"
ToolTip(20,Tip,"","A" . UpDown_hWnd . " P" . GuiHwnd)


gui Show,,Tooltip Test



;-- Note: The following information cannot be collected until after the window
;   has been rendered


;-- Get hWnd to the Edit control piece of the ComboBox
ControlGet EditComboBox_hWnd,hWnd,,Edit2,Tooltip Test
Tip=
   (ltrim join`s
    Tooltip for the Edit piece of the ComboBox control.`nNote that this tip is
    different than the drop-down button piece of this control.
   )
ToolTip(11,Tip,"","A" . EditComboBox_hWnd . " P" . GuiHwnd)


;-- Get hWnd to the Edit control piece of the ComboBox
ControlGet ListViewHeader_hWnd,hWnd,,SysHeader321,Tooltip Test
Tip=
   (ltrim join`s
    Tooltip for the header of the ListView control.`nNote that this tip is
    different than the rest of the ListView control.
   )
ToolTip(13,Tip,"","A" . ListViewHeader_hWnd . " P" . GuiHwnd)


return


Button1:
ToolTip(1,"Button 1: New Text","","AButton1 P" . GuiHwnd)
return


Button2:
ToolTip(2,"","","AButton2 P" . GuiHwnd)
return


Button3:
ToolTip()
MsgBox 64,ToolTips Cleared,All Tooltips destroyed.  %A_Space%
return



Null:
return

GUIClose:
GUIescape:
ExitApp










ToolTip(ID="", text=" ", title="",options=""){
   ;____  Assume Static Mode for internal variables and structures  ____
   
   static
   
   ;________________________  ToolTip Messages  ________________________
   
   TTM_POPUP:=0x422,   TTM_ADDTOOL:=0x404,     TTM_UPDATETIPTEXT:=0x40c
   TTM_POP:=0x41C,     TTM_DELTOOL:=0x405,     TTM_GETBUBBLESIZE:=0x41e
   TTM_UPDATE:=0x41D,  TTM_SETTOOLINFO:=0x409
   
   ;________________________  Local variables for options ________________________
   
   local option, a, b, c, d, f, i, m, o, p, l, v, t
   TT_ID:=ID
   TT_HWND:=TT_HWND_%TT_ID%
   If ((#_DetectHiddenWindows:=A_DetectHiddenWindows)="Off")
      DetectHiddenWindows, On
   
   ;____________________________  Delete all ToolTips ____________________________
   
   If !ID
   {
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
   
   ;___________________  Load Options Variables and Structures ___________________
   
   
   If (options){
      Loop,Parse,options,%A_Space%
         If (option:= SubStr(A_LoopField,1,1))
            %option%:= SubStr(A_LoopField,2)
   }
   
   ;__________________________  Save TOOLINFO Structures _________________________
   
   If P {
      If !InStr(TT_ALL_%TT_ID%,Chr(2) . Abs(P) . Chr(2))
         TT_ALL_%TT_ID% .= Chr(2) . Abs(P) . Chr(2)
      If A
         If !InStr(TT_ALL_%TT_ID%,Chr(2) . Abs(A) . Chr(2))
            TT_ALL_%TT_ID% .= Chr(2) . Abs(A) . Chr(2) . Abs(A)*Abs(P) . Chr(2)
   } else if !InStr(TT_ALL_%TT_ID%,Chr(2) . ID . Chr(2))
      TT_ALL_%TT_ID% .= Chr(2) . ID . Chr(2)

   ;__________________________  Create ToolTip Window  __________________________
   
   If (!TT_HWND)
   {
      TT_HWND := DllCall("CreateWindowEx", "Uint", 0x8, "str", "tooltips_class32", "str", "", "Uint", 0x02 + (v ? 0x1 : 0) + (l ? 0x100 : 0) + (C ? 0x80 : 0)+(O ? 0x40 : 0), "int", 0, "int", 0, "int", 0, "int", 0, "Uint", P, "Uint", 0, "Uint", 0, "Uint", 0)
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
   
   If P
   {
      If A {
         If A is not Xdigit
            ControlGet,A,Hwnd,,%A%,ahk_id %P%
         ID :=Abs(A)
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
            Numput((A ? 0 : 1)|16,TOOLINFO_%ID%,4), Numput(P,TOOLINFO_%ID%,8), Numput(P,TOOLINFO_%ID%,12), NumPut(&text,TOOLINFO_%ID%,36)
         }
         Gosub, TTM_ADDTOOL
      } else {
         ID :=Abs(P)
         If !TOOLINFO_%ID%
         {
            VarSetCapacity(TOOLINFO_%ID%, 40, 0),TOOLINFO_%ID%:=Chr(40)
            Numput((A ? 0 : 1)|16,TOOLINFO_%ID%,4), Numput(P,TOOLINFO_%ID%,8), Numput(P,TOOLINFO_%ID%,12), NumPut(&text,TOOLINFO_%ID%,36)
         }
         Gosub, TTM_ADDTOOL
         DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x403, "Uint", 2, "Uint", (D ? D*1000 : -1))
      }
   } else {
      If !TOOLINFO_%ID%
         VarSetCapacity(TOOLINFO_%ID%, 40, 0),TOOLINFO_%ID%:=Chr(40)
      else update:=True
      NumPut(0x20|(O ? 0x80 : 0)|(L ? 0x1000 : 0),TOOLINFO_%ID%,4), NumPut(&text,TOOLINFO_%ID%,36)
      Gosub, TTM_ADDTOOL
   }
   If B
      Gosub, TTM_SETTIPBKCOLOR
   If F
      Gosub, TTM_SETTIPTEXTCOLOR
   
   If title
      Gosub, TTM_SETTITLE
   
   If !P
   {
      Gosub, TTM_UPDATETIPTEXT
      If D {
         A_Timer := A_TickCount, D *= 1000
         Gosub, TTM_TRACKPOSITION
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
         If !C
            WinSet, Disable,,ahk_id %TT_HWND%
         If M
            WinSet,ExStyle,^0x20,ahk_id %TT_HWND%
         If T
            WinSet,Transparent,%T%,ahk_id %TT_HWND%
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
            DllCall("SendMessage", "Uint", TT_HWND, "Uint", 1041, "Uint", 1, "Uint", &TOOLINFO_%ID%)   ; TTM_TRACKACTIVATE
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
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 1042, "Uint", 0, "Uint", (xc & 0xFFFF)|(yc & 0xFFFF)<<16)
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 1041, "Uint", 1, "Uint", &TOOLINFO_%ID%)   ; TTM_TRACKACTIVATE
   Return
   TTM_SETTIPBKCOLOR:
      B := (StrLen(B) < 8 ? "0x" : "") . B
      B := ((B&255)<<16)+(((B>>8)&255)<<8)+(B>>16) ; rgb -> bgr
      DllCall("SendMessage", "Uint", TT_HWND, "Uint", 1043, "Uint", B, "Uint", 0)
   Return
   TTM_SETTIPTEXTCOLOR:
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
            TOOLINFO_%A_LoopField%:=""
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
