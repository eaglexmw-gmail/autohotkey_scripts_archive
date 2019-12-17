; <COMPILER: v1.0.48.3>

; http://www.autohotkey.com/forum/viewtopic.php?t=46217


#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#NoTrayIcon

SetTitleMatchMode, 3
Hotkey, IfWInActive, %A_Space%
{
Hotkey, !f, label
Hotkey, !v, label
Hotkey, !e, label
Hotkey, !t, label
Hotkey, !h, label
label:
return
}

Hotkey, IfWinNotActive

Start2:

Gui, Add, ListView , Grid 0x800000 -Hdr r17 w95 gMyListView, programs
Gui, Add, Button,, %A_Space%%A_Space%Edit%A_Space%%A_Space%
Gui, -SysMenu
Gui, +ToolWindow
Open = 0
Loop, %A_MyDocuments%\Launcher\*.lnk
{
StringTrimRight, Loop, A_LoopFileName, 4
LV_Add( "", Loop )
LV_ModifyCol(-1)
}
IfEqual, a, 1
Goto, Show
return




~MButton::
SetTitleMatchMode, 3
IfWinExist, %A_Space%
Goto, Start2
SoundPlay, click.wav
SetTitleMatchMode, 2
IfWInNotActive, Launcher2
{
MouseGetPos, mX, mY
Goto, Show
}
Return

Show:
Show1:
a = 0
AutoTrim, off
lau = Launcher2
Loop, 9
{
lau = %A_Space%%lau%
}
Gui, Show, X%mX% Y%mY%, %lau%
Return



~LButton::
IfEqual,m, 1
{
Goto, Start2
}
IfWinExist, %A_Space%
{
Goto, Start2
}
Else
{
SetTitleMatchMode, 2
IfWinNotActive, Launcher2
{
Gui, destroy
Goto, Start2
}
}
Return




~RButton::
SetTitleMatchMode, 3
IfWinExist, %A_Space%
{
Goto, Start2
}
Else
{
SetTitleMatchMode, 2
IfWinNotActive, Launcher2
{
Gui, destroy
Goto, Start2
}
}
Return


MyListView:
if A_GuiEvent = DoubleClick
    {
    SetTitleMatchMode, 3
    IfWinExist, %A_Space%
    Goto, Start2
    i = %A_EventInfo%
    IfGreater, i, 0
     {
      LV_GetText(RowText, i)
      SetTitleMatchMode, 2
       IfWinExist, %RowText%
       {
        IfEqual, Open, 1
         {
         a = 1
         }
        Else,
           {
             a = 0
            }
         SoundPlay, click.wav
         WinActivate, %RowText%
         Gui, Destroy
         Goto, Start2
         }
         IfWinNotExist, %RowText%
         {
          SoundPlay, click.wav
          Run, %A_MyDocuments%\Launcher\%RowText%.lnk
          IfEqual, Open, 1
          a = 1
          Gui, Destroy
          Goto, Start2
         }
        IfEqual, Open, 1
        a = 1
        Gui, Destroy
        Goto, Start2
       }
      }
Return


ButtonEdit:
SoundPlay, click.wav
SetTitleMatchMode, 3
IfWinExist, %A_Space%
{
WinClose, %A_Space%
a = 1
Gui, destroy
Goto, Start2
}
Else
 {
  DetectHiddenWindows, on
  Run, %A_MyDocuments%\Launcher, ,Hide
  SetTitleMatchMode, 2
  WinWait, Launcher,, Launcher2
  SetTitleMatchMode, 3
  IfWinExist, %A_MyDocuments%\Launcher
   {         
   WinMove, %A_MyDocuments%\Launcher,, mX + 70, mY + 60, 240, 570
   WinSet, AlwaysOnTop, ON, %A_MyDocuments%\Launcher
   WinSet, Style, 0xC00000, %A_MyDocuments%\Launcher
   WinSet, ExStyle, +0x80,  %A_MyDocuments%\Launcher
   ControlGet, Var, Hwnd,, ToolBarWindow323, %A_MyDocuments%\Launcher
   ControlGet, Var2, Hwnd,, WorkerW2, %A_MyDocuments%\Launcher
   ControlGet, Var3, Hwnd,, ReBarWindow321, %A_MyDocuments%\Launcher
   ControlGet, Var4, Hwnd,, WorkerW1, %A_MyDocuments%\Launcher

   ControlGet, Var6, Hwnd,, SysListView321, %A_MyDocuments%\Launcher
   Control, Disable,, ToolBarWindow323, %A_MyDocuments%\Launcher
   Control, Disable,, WorkerW2, Launcher
   Control, Disable,, ReBarWindow321, %A_MyDocuments%\Launcher
   Control, Disable,, WorkerW1, Launcher
   SendMessage, 0x410, 0, "   ", msctls_statusbar321, %A_MyDocuments%\Launcher

   Control, Hide,,, ahk_id%Var%
   Control, Hide,,, ahk_id%Var2%
   Control, Hide,,, ahk_id%Var3%
   Control, Hide,,, ahk_id%Var4%
   WinSet, Transparent, 233, %A_MyDocuments%\Launcher
   ControlMove, ReBarWindow321,,,,20, %A_MyDocuments%\Launcher
   WinSetTitle, %A_MyDocuments%\Launcher,, %A_Space%
 }
  Else

 {
  WinWait, Launcher
  WinMove, Launcher,, mX + 70, mY + 60, 240, 570
  WinSet, AlwaysOnTop, ON, Launcher
  WinSet, Style, 0xC00000, Launcher
  WinSet, ExStyle, +0x80,  Launcher
  ControlGet, Var, Hwnd,, ToolBarWindow323, Launcher
  ControlGet, Var2, Hwnd,, WorkerW2, Launcher
  ControlGet, Var3, Hwnd,, ReBarWindow321, Launcher
  ControlGet, Var4, Hwnd,, WorkerW1, Launcher

  ControlGet, Var6, Hwnd,, SysListView321, Launcher
  Control, Disable,, ToolBarWindow323, Launcher
  Control, Disable,, WorkerW2, Launcher
  Control, Disable,, ReBarWindow321, Launcher
  Control, Disable,, WorkerW1, Launcher
  SendMessage, 0x410, 0, "   ", msctls_statusbar321, Launcher

  Control, Hide,,, ahk_id%Var%
  Control, Hide,,, ahk_id%Var2%
  Control, Hide,,, ahk_id%Var3%
  Control, Hide,,, ahk_id%Var4%
  WinSet, Transparent, 233, Launcher
  ControlMove, ReBarWindow321,,,,20, Launcher
  WinSetTitle, Launcher,, %A_Space%
  }
 WinShow, %A_Space%
 }
return
