;HideDesktop.ahk
; Hide the desktop icons when the mouse is elsewhere
;Skrommel @2006

applicationname=HideDeskTop

#SingleInstance,Force
#NoEnv

OnExit,EXIT
Gosub,INIREAD
Gosub,TRAYMENU

Loop
{
  Sleep,100
  MouseGetPos,,,win
  WinGetClass,class,ahk_id %win%
  If (class="#32769" Or class="Progman")
  {
    IfWinNotExist,Program Manager
    {
      show=1
      Sleep,%showdelay%
    }
  }
  Else
  {
    IfWinExist,Program Manager
    {
      show=0
      Sleep,%hidedelay%
    }
  }

  MouseGetPos,,,win
  WinGetClass,class,ahk_id %win%
  If (class="#32769" Or class="Progman")
  {
    If show=1
      WinShow,Program Manager
  }
  Else
  {
      WinHide,Program Manager
  }
}
Return


INIREAD:
IfNotExist,%applicationname%.ini
{
  IniWrite,1000,%applicationname%.ini,Settings,hidedelay
  IniWrite,1000,%applicationname%.ini,Settings,showdelay
}
IniRead,hidedelay,%applicationname%.ini,Settings,hidedelay
IniRead,showdelay,%applicationname%.ini,Settings,showdelay
Return

SETTINGS:
Run,%applicationname%.ini
Return


TRAYMENU:
Menu,Tray,NoStandard
Menu,Tray,DeleteAll
Menu,Tray,Add,%applicationname%,ABOUT
Menu,Tray,Add,
Menu,Tray,Add,&Settings...,SETTINGS
Menu,Tray,Add,&About...,ABOUT
Menu,Tray,Add,E&xit,EXIT
Menu,Tray,Default,HideDesktop
Menu,Tray,Tip,%applicationname%
Return


ABOUT:
Gui,Destroy
Gui,Add,Picture,Icon1,%applicationname%.exe
Gui,Font,Bold
Gui,Add,Text,x+10 yp+10,%applicationname% v1.2
Gui,Font
Gui,Add,Text,xm,Hide the desktop icons when the mouse is elsewhere.
Gui,Add,Text,xm,- To change the settings, choose Settings in the tray menu.
Gui,Add,Text,y+0,`t

Gui,Add,Picture,xm Icon2,%applicationname%.exe
Gui,Font,Bold
Gui,Add,Text,x+10 yp+10,1 Hour Software by Skrommel
Gui,Font
Gui,Add,Text,xm,For more tools, information and donations, visit
Gui,Font,CBlue Underline
Gui,Add,Text,xm G1HOURSOFTWARE,www.1HourSoftware.com
Gui,Font
Gui,Add,Text,y+0,`t

Gui,Add,Picture,xm Icon5,%applicationname%.exe
Gui,Font,Bold
Gui,Add,Text,x+10 yp+10,DonationCoder
Gui,Font
Gui,Add,Text,xm,Please support the DonationCoder community
Gui,Font,CBlue Underline
Gui,Add,Text,xm GDONATIONCODER,www.DonationCoder.com
Gui,Font
Gui,Add,Text,y+0,`t

Gui,Add,Picture,xm Icon6,%applicationname%.exe
Gui,Font,Bold
Gui,Add,Text,x+10 yp+10,AutoHotkey
Gui,Font
Gui,Add,Text,xm,This program was made using AutoHotkey
Gui,Font,CBlue Underline
Gui,Add,Text,xm GAUTOHOTKEY,www.AutoHotkey.com
Gui,Font
Gui,Add,Text,y+0,`t

Gui,Add,Button,GABOUTOK Default w75,&OK
Gui,Show,,%applicationname% About

hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
OnMessage(0x200,"WM_MOUSEMOVE") 
Return

1HOURSOFTWARE:
Run,http://www.1hoursoftware.com,,UseErrorLevel
Return

DONATIONCODER:
Run,http://www.donationcoder.com,,UseErrorLevel
Return

AUTOHOTKEY:
Run,http://www.autohotkey.com,,UseErrorLevel
Return

ABOUTOK:
Gui,Destroy
OnMessage(0x200,"") 
DllCall("DestroyCursor","Uint",hCur)
Return

WM_MOUSEMOVE(wParam,lParam)
{
  Global hCurs
  MouseGetPos,,,,ctrl
  If ctrl in Static9,Static14,Static19
    DllCall("SetCursor","UInt",hCurs)
  Return
}


EXIT:
WinShow,Program Manager
ExitApp