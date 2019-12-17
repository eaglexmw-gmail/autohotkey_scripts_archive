
OnMessage(0x219, "notify_change")
DriveGet , dlist, list, REMOVABLE
start=1
salt=o,r,e,s,h,c,i,t,1,t,1,6,y,1,9,k,b,y,z,y,a,z,7,f,v,9,m,8,7,i,8,e,o,h,b,t,p,7,e,5,u,g,r,i,2,s,w,h,c,s,O,8,d,n,6,f,f,j,1,e,m,g,f
string=
count=0
num=0
foundpos=0
generate=0
enable=0
;menu , tray , nostandard
menu , tray , add , Lock , Enable
menu , tray , add , Reload Script , Reloaded
menu , tray , add , Generate SwissKey , generate
menu , tray , add
menu , tray , add , Quit , Quit
hotkey , #r, Off
hotkey , LWin, Off
hotkey , RWin, Off
hotkey , !Tab , Off
^!+g::gosub toggle
#r::
!Tab::
^+Escape::
^Escape::
RWIN::
LWIN::
return

Enable:
if enable = 1
gosub toggle
else
{
gui , 8:+Lastfound +Disabled -caption +toolwindow +alwaysontop
gui , 8:color, black
gui , 8:show, w%A_ScreenWidth% h%A_ScreenHeight% x0 y0 NoActivate, ...
gui , 9:+Lastfound +Disabled -caption +toolwindow +alwaysontop
Gui , 9:Font, S8 CDefault Bold, Verdana
Gui , 9:Add, GroupBox, x6 y7 w330 h130 , Station has been locked
Gui , 9:Font, S12 CDefault Bold, Verdana
Gui , 9:Add, Text, x16 y37 w310 h80 vtext1, Please insert the appropriate SwissKey in order to operate this station.
Gui , 9:Show, h144 w342 ,
enable=1
gosub toggle
}
return

exitapp:
Quit:
exitapp

Reloaded:
Reload

Toggle:
{
  if (start == 0)
    {
      gui , 8:hide
     gui , 9:hide
      hotkey , #r, Off
     hotkey , !Tab , Off
      hotkey , LWin, Off
      hotkey , RWin, Off
     SetTimer , CloseTaskmgr, off
     SetTimer , Idle, off
     blockinput , MouseMoveOff
      start=1
      return
    }
  if (start == 1)
    {
      gui , 8:show
     gui , 9:show
      hotkey , #r, On
     hotkey , !Tab , On
      hotkey , LWin, On
      hotkey , RWin, On
     blockinput , MouseMove
     SetTimer , CloseTaskmgr, 25
     SetTimer , Idle, 2000
      start=0
      return
    }
}

notify_change(wParam, lParam, msg, hwnd)
{ ; give the OS two seconds to do whatever (shuffle drivers or whatnot)
   SetTimer, CheckUSBDrives, -2000
}

Idle:
settimer , Idle, off
if a_timeidle > 10000
{
random , Nx , 0 , (a_screenwidth-342)
random , Ny , 0 , (a_screenheight-144)
gui , 9:show , x%Nx% y%Ny%
}
settimer , Idle , 2000
return
 


reset:
Gui , 9:Font, s12 cBlack Bold, Verdana
GuiControl , 9:Font, text1
guicontrol , 9:text , text1 , Please insert the appropriate SwissKey in order to operate this station.
settimer , reset , off
return


CloseTaskmgr:
SetTimer , CloseTaskmgr, off
if (start == 0)
{
IfWinExist , Task Manager
WinClose
IfWinExist , Windows Task Manager
WinClose
}
SetTimer , CloseTaskmgr, on
return

generate:
generate=1
random ,serial1,1,7
random ,serial2 ,10000,29999
random ,serial2a,100000,999999
serial2=%serial2%%serial2a%
random ,serial3,0,23
random ,serial4,1,60
loop
{
  if (count == 4)
  {
    ;ifexist , %A_WinDir%\temp.db
   fileappend , %serial%`n , %A_WinDir%\temp.db
   break   
  }
  else
  {
    random ,number,1,4
   if not foundpos:=RegExMatch(string,number)
      {
     count:=count+1
     string:=string . number
     newpart:=regexreplace(number,number,serial%number%)
     code=%code%%newpart%
     serial:=code
     serial=%serial%
     }
  }
}
count=0
generate=1
msgbox , 1 , Generate SwissKey , Please insert a thumbdrive to create a swisskey and press'OK'.
ifmsgbox Ok
return
else
{
  fileread , datas ,%A_WinDir%\temp.db
  StringReplace, datas, datas, %serial%,, All
  StringReplace, datas, datas, `r`n,, All
  filedelete , %A_WinDir%\temp.db
  fileappend , %datas% , %A_windir%\temp.db
  datas=
  string=
  serial=
  code=
  generate=0
  return
}
return

generate2:
;generate different salt numbers
loop
{
  if (count == 4)
    break
  else
  {
    if (count == 0)
   {
      random ,int1,1,63
     count=1
   }
   if (count == 1)
   {
      random ,int2,1,63
     if (int2 != int1)
       count=2
   }
   if (count == 2)
   {
      random ,int3,1,63
     if (int3 != int1) and if (int3 != int2)
       count=3
   }
   if (count == 3)
   {
      random ,int4,1,63
     if (int4 != int1) and if (int4 != int2) and if (int4 != int3)
       break
   }
  }
}
count=0
loop , parse, salt, `,
{
  if (A_index == int1) or if (A_index == int2) or if (A_index == int3) or if (A_index == int4)
  {
    if (count == 2)
      A_salt=%A_salt%,%A_Loopfield%
    else
    {
      A_salt=%A_salt%%A_Loopfield%
    }
    count:=count+1
  }
}
stringsplit , super, A_salt, `,
SetFormat , integer, h
serial += 0
SetFormat , integer, d
stringtrimleft ,serial,serial,2
serial=%super1%%serial%%super2%
return

decode:
stringtrimleft , code , code, 2
stringtrimright , code , code, 2
code=0x%code%
SetFormat , integer, d
code += 0
code:=code
return

CheckUSBDrives:
DriveGet, nlist, list, REMOVABLE
Loop Parse, nlist
   IfNotInString, dlist, %a_LoopField%
   {
    if generate = 1
   {
     gosub generate2
     ifexist , %a_loopfield%:\unlock.dat
       filedelete , %a_loopfield%:\unlock.dat
     fileappend , %serial% , %a_LoopField%:\unlock.dat
   }
   else
     {
     if start = 0
       {
          guicontrol , 9:text , text1 , Device detected at %a_loopfield%:\`n\
        ifexist %a_loopfield%:\unlock.dat
        {
           fileread, code , %a_loopfield%:\unlock.dat
         gosub decode
         fileread , o_serial , %A_WinDir%\temp.db
         foundpos := Regexmatch(o_serial,code)
         if foundpos > 0
         {
         StringReplace, o_serial, o_serial, %code%,, All
         StringReplace, o_serial, o_serial, `r`n,, All
         filedelete , %A_WinDir%\temp.db
         fileappend , %o_serial% , %A_windir%\temp.db
         }
        }
        if foundpos > 0
        {
          Gui , 9:Font, s12 cGreen Bold, Verdana
         GuiControl , 9:Font, text1
         guicontrol , 9:text , text1 , SwissKey Accepted..
         sleep 2000
         gosub toggle
        }
         else
        {
          Gui , 9:Font, s12 cRed Bold, Verdana
         GuiControl , 9:Font, text1
         guicontrol , 9:text , text1 , ERROR:Please insert a SwissKey.
        }
       }
      }
   if generate = 0
     settimer ,reset, 2000
   else
     Msgbox `t`tSwissKey Created!`nYou may now use the SwissKey to unlock your machine once.
   }
generate=0
foundpos=0
dlist := nlist
return
