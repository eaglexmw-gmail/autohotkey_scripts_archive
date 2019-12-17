/*
ToolTip() by HotKeyIt http://www.autohotkey.com/forum/viewtopic.php?t=40165

Syntax: ToolTip([Number,Text,Title,Options])

Return Value: ToolTip returns hWnd of the ToolTip

|--------------------------------------------------------------------------------------------------------|
|         Options can include any of following parameters separated by space
|--------------------------------------------------------------------------------------------------------|
| Option      |      Meaning                                                                             |
|--------------------------------------------------------------------------------------------------------|
| A            |   Aim ControlId or ClassNN (Button1, Edit2, ListBox1, SysListView321...)
|            |   - using this, ToolTip will be shown when you point mouse on a control
|            |   - D (delay) can be used to change how long ToolTip is shown
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
|         - ToolTip("",lParam[,Label])
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

; ### Example Code #####
OnMessage(0x4e,"WM_NOTIFY") ;Will make LinkClick and ToolTipClose possible
OnMessage(0x404,"AHK_NotifyTrayIcon") ;Will pop up the ToolTip when you click on Tray Icon
CoordMode,Mouse,Screen ;Requi
#NoEnv
#SingleInstance Force


;-- Collect hWnd for GUI
Restart:
ToolTip(99,"Please click on a link:`n`n"
      . "<a>My Favorite Websites</a>`n`n"
      . "<a>ToolTip Examples</a>`n`n"
      . "<a notepad.exe >Notepad</a>`n"
      . "<a explorer.exe >Explorer</a>`n"
      . "<a calc.exe >Calculator</a>`n"
      . "`n<a>Hide ToolTip</a>`n  - To show this ToolTip again click onto Tray Icon"
      . "`n<a>ExitApp</a>`n"
      , "Welcome to ToolTip Control"
      , "L1 O1 H1 C1 T220 BLime FBlue I" . GetAssociatedIcon(A_ProgramFiles . "\Internet Explorer\iexplore.exe")
      . " P99 X" A_ScreenWidth . " Y" . A_ScreenHeight)
Return

My_Favorite_Websites:
ToolTip(98,"<a http://www.autohotkey.com >AutoHotkey</a> - <a http://de.autohotkey.com>DE</a>"
      . " - <a http://autohotkey.free.fr/docs/>FR</a> - <a http://www.autohotkey.it/>IT</a>"
      . " - <a http://www.script-coding.info/AutoHotkeyTranslation.html>RU</a>"
      . " - <a http://lukewarm.s101.xrea.com/>JP</a>"
      . " - <a http://lukewarm.s101.xrea.com/>GR</a>"
      . " - <a http://www.autohotkey.com/docs/Tutorial-Portuguese.html>PT</a>"
      . " - <a http://cafe.naver.com/AutoHotKey>KR</a>"
      . " - <a http://forum.ahkbbs.cn/bbs.php>CN</a>"
      . "`n<a http://www.google.com>Google</a> - <a http://www.maps.google.com>Maps</a>`n"
      . "<a http://social.msdn.microsoft.com/Search/en-US/?Refinement=86&Query=>MSDN</a>`n"
      , "My Websites"
      , "L1 O1 C1 BSilver FBlue I" . GetAssociatedIcon(A_ProgramFiles . "\Internet Explorer\iexplore.exe")
      . " P99")
Return

ToolTip_Examples:
ToolTip(97, "<a>Message Box ToolTip</a>`n"
      . "<a>Change ToolTip</a>`n"
      . "<a>GUI Controls by jballi</a>`n"
      . "<a>ToolTip Loop #1</a>`n"
      . "<a>ToolTip Loop #2</a>`n"
      . "<a>ToolTip Loop #3</a>`n`nClose to return to previous ToolTip"
      , "ToolTip Examples"
      , "L1 O1 C1 BYellow FBlue I" . GetAssociatedIcon(A_ProgramFiles . "\Internet Explorer\iexplore.exe")
      . " P99")
Return

99ToolTip:
If InStr(link:=ErrorLevel,"http://")
   Run iexplore.exe %link%
else if IsLabel(link:=RegExReplace(link,"[^\w]","_"))
   SetTimer % link,-150
else if link
{
   Run % link
   SetTimer, Restart, -100
}
Return

98ToolTip:
Run iexplore.exe %ErrorLevel%
Return

97ToolTip:
IsLabel(ErrorLevel:=RegExReplace(ErrorLevel,"[^\w]","_"))
   SetTimer % ErrorLevel,-100
Return

99ToolTipClose:
MsgBox,262148,Closing ToolTip..., ToolTip is about to close`nClick no to disable ToolTip`n -You can show it again by clicking onto the Tray Icon`nDo you want to exit script?
IfMsgBox Yes
   ExitApp
Return

97ToolTipClose:
98ToolTipClose:
SetTimer, Restart, -100
Return

WM_NOTIFY(wParam, lParam, msg, hWnd){
   ToolTip("",lParam,"")
}

AHK_NotifyTrayIcon(wParam, lParam) {
   If (lparam = 0x201 or lparam = 0x202)
      SetTimer, Restart, -250
}


Hide_ToolTip:
ToolTip(99)
Return
ExitApp:
ExitApp
Execute:
Run %ErrorLevel%.exe
SetTimer, Restart, -100
Return

ToolTip_Loop__1:
ToolTip(100,"`nJust an example ToolTip following mouse movements"
   ,"This ToolTip will be destroyed in " . 4 . " Seconds","o1 I" . GetAssociatedIcon(A_AhkPath) . " B0000FF FFFFFFF")
Start:=A_TickCount
end=
While, end < 10
{
   ToolTip(100,"In this example text and Title are updated continuously.`nTickCount:" . A_TickCount,"This ToolTip will be destroyed in " .  11 - Round(end:=(A_TickCount-Start)/1000) . " Seconds","I" . GetAssociatedIcon(A_AhkPath))
}
ToolTip(100)
Return
ToolTip_Loop__2:
end=
ToolTip(100,"In this example only position is tracked.","This ToolTip will be destroyed in 10 Seconds","D10 I" . GetAssociatedIcon(A_AhkPath) . " B0000FF FFFFFFF")
ToolTip(100)
Return

ToolTip_Loop__3:
end=
ToolTip(100,"`nHere only title is being changed"
   ,"This ToolTip will be destroyed in 10 Seconds","o1 I" . GetAssociatedIcon(A_AhkPath) . " B0000FF FFFFFFF")
Start:=A_TickCount
While, end < 10
{
   ToolTip(100,"","This ToolTip will be destroyed in " .  11 - Round(end:=(A_TickCount-Start)/1000) . " Seconds","I" . GetAssociatedIcon(A_AhkPath))
}
ToolTip(100)
Return

Message_Box_Tooltip:
SetTimer,proceed, -200
MsgBox,4,Test,Hallo,`nPoint onto yes or no
proceed:
hwnd:=WinExist("Test ahk_class #32770")
ToolTip(101,"Click here to accept and proceed.","Here you see an example how to assign a ToolTip to MsgBox controls","I1 B00FF00 AButton1 P" . hwnd)
ToolTip(101,"Click here to refuse and proceed","","AButton2 P" . hwnd)
IfWinExist Test ahk_class #32770
{
   WinWaitClose, Test ahk_class #32770
   Return
}
ToolTip(101)
Return

Change_ToolTip:
Gui, Add,Button,,Point your mouse cursor here
Gui,+LastFound
ToolTip(1,"Test deleting and creating same Tooltip","TEST","Abutton1 P" . WinExist())
Gui,Show
Sleep, 5000
ToolTip(1)
Gui,Destroy
Sleep, 1000
Gui, Add,Button,,Move your mouse cursor a little
Gui,+LastFound
ToolTip(1,"Test deleting and creating same Tooltip`nTooltips were destroyed and recreated.","New Tooltip with different text and title.","Abutton1 P" . WinExist())
Gui,Show
Sleep, 5000
Gui,Destroy
ToolTip(1)
Return

Gui_Controls_by_jballi:
;-- Build GUI
gui -MinimizeBox

gui Add,Button,w150 hwndButton1_hWnd gButton1,Test Button 1
Tip:="Button 1: Press me to change my tooltip"
ToolTip(1,Tip,"","A" . Button1_hWnd . " P" . GuiHwnd)


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


gui Add,Picture,w150 h100 hwndPicture_hWnd gNull,Picture.bmp
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


gui Add,UpDown,hwndUpDown_hWnd Range 1-100,5
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
Gui,Destroy
Return



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
                  ToolTip(A_LoopField)
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
      If (p<100)
         Gui,%p%:+LastFound
         P:=WinExist()
      If !InStr(TT_ALL_%TT_ID%,Chr(2) . Abs(P) . Chr(2))
         TT_ALL_%TT_ID% .= Chr(2) . Abs(P) . Chr(2)
      If A
         If !InStr(TT_ALL_%TT_ID%,Chr(2) . Abs(A) . Chr(2))
            TT_ALL_%TT_ID% .= Chr(2) . Abs(A) . Chr(2) . Abs(A)*Abs(P) . Chr(2)
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
   
;~    If P
;~    {
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
            Numput((A ? 0 : 1)|16,TOOLINFO_%ID%,4), Numput(P,TOOLINFO_%ID%,8), Numput(P,TOOLINFO_%ID%,12)
         }
         Gosub, TTM_ADDTOOL
         DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x403, "Uint", 2, "Uint", (D ? D*1000 : -1))
         DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x403, "Uint", 3, "Uint", (W ? W*1000 : -1))
         DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x403, "Uint", 1, "Uint", (W ? W*1000 : -1))
         ID :=Abs(A)
;~       } else {
;~          ID :=Abs(P)
;~          If !TOOLINFO_%ID%
;~          {
;~             VarSetCapacity(TOOLINFO_%ID%, 40, 0),TOOLINFO_%ID%:=Chr(40)
;~             Numput((A ? 0 : 1)|16,TOOLINFO_%ID%,4), Numput(P,TOOLINFO_%ID%,8), Numput(P,TOOLINFO_%ID%,12), NumPut(&text,TOOLINFO_%ID%,36)
;~          }
;~          Gosub, TTM_ADDTOOL
;~          DllCall("SendMessage", "Uint", TT_HWND, "Uint", 0x403, "Uint", 2, "Uint", (D ? D*1000 : -1))
;~       }
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
