; http://www.autohotkey.com/forum/viewtopic.php?p=114024#114024
; _= 2007 04 03 Ver 1.0.46.10
; _= ESC to exit program !
 ; add ini to remember last screen pos
 #NoEnv
 #Persistent
 #SingleInstance, Force
 SetBatchLines, -1

 Gui,Color,0x0
 Gui -Caption +Owner +AlwaysOnTop
 Gui,Font,s10 w700, Courier New

 OnMessage(0x219, "NotifyChange")
 ;; include code to re-evaluate when
 ;; hidden drive is activated during
 ;; Pseudo raid !

/*
 Run, diskperf.exe -y   ; Execute it once to enable Disk Performance monitoring.
 Not required for Xp +
 In Windows 2000 this IOCTL is handled by the filter driver diskperf.
 In Windows XP and later operating systems,
 the partition manager handles this request for disks and
 ftdisk.sys and dmio.sys handle this request for volumes.
*/

 SetTimer,ScanDrv,50

 _= Enumerate Available Drives (Fixed)

 DriveGet,aDrives,List,FIXED
   Loop,Parse,aDrives
   {
   DrvCount ++
   Drv%A_Index% := a_Loopfield
   CurDrv:= "\\.\" Drv%A_Index% ":"
   hDrv%A_Index% := DllCall("CreateFile",Str,CurDrv,Uint,0,Uint,3,Uint,0,Uint,3,Uint,0,Uint,0)
   }

 _= Build Quick+Dirty Gui to fit

 x=2
   Loop,% DrvCount
   {
   Gui,Add,Text,x%x% y-5 w09 h12 c0x00FF00 vx%A_Index%,
   Gui,Add,Text,x%x% y6  w09 h12 c0xFFFFFF ,% Drv%A_Index%
   Gui,Add,Text,x%x% y18 w09 h10 c0xFF8800 vy%A_Index%,
   x+=17
   }

 x-=8
 Gui,Show, x100 y100 w%x% h30 ,win
 ; WinSet, TransColor,0x0 225 ,win
 Return

 GuiEscape:
 GuiClose:
 ExitApp

 Return

 ScanDrv:
 SetTimer,ScanDrv,Off
   Loop,% DrvCount
   {
   VarSetCapacity(dp%A_Index%,88)
   DllCall("DeviceIoControl",Uint,hDrv%A_Index%,Uint,0x00070020,Uint,0,Uint,0
                            ,Uint,&dp%A_Index%,Uint,88,UintP,nReturn,Uint,0)

   nReadCount%A_Index%  := DecodeInteger(&dp%A_Index% + 40)
   nWriteCount%A_Index% := DecodeInteger(&dp%A_Index% + 44)

 _= Case Writing @ y%A_Index%
     If (nWriteCount%A_Index% <> _nWriteCount_%A_Index%)
     {
     _nWriteCount_%A_Index% := nWriteCount%A_Index%
     GuiControl,,y%A_Index%,=
     }
     Else  guicontrol,,y%A_Index%,

 _= Case Reading @ x%A_Index%
     If (nReadCount%A_Index% <> _nReadCount_%A_Index%)
     {
     _nReadCount_%A_Index%  := nReadCount%A_Index%
     GuiControl,,x%A_Index%,=     
     }
     Else  guicontrol,,x%A_Index%,
   }

 SetTimer,ScanDrv,On
 Return

 DecodeInteger(ptr)
 {
   Return *ptr | *++ptr << 8 | *++ptr << 16 | *++ptr << 24
 }

 ~LButton::DragGui("win")

 _=========================================================================
 _== FUNCTION :     DragGui(WinTitle)                                    ==
 _== Author   :     Chris Mallett                                        ==
 _== Updated  :     Converted to FUNCTION By Dave Perrée Jun 2006        ==
 _== Usage    :     ~LButton::DragScreen("WinTitle")                     ==
 _=========================================================================

 DragGui(_WinTitlePart)
 {
 STATIC _GuiID,_MouseStartX,_MouseStartY
 WinGet,_GuiID, ID,% _WinTitlePart
 CoordMode,Mouse
 MouseGetPos,_MouseStartX,_MouseStartY,_MouseWin
    If _MouseWin <> %_GuiID%
    Return
 SetTimer,_WatchMouse,5
 Return
 _WatchMouse:
 GetKeyState,_LButtonState,LButton,P
    If _LButtonState=U
    {
    SetTimer,_WatchMouse,Off
    Return
    }
 CoordMode,Mouse
 MouseGetPos,_MouseX,_MouseY
 _DeltaX:=_MouseX
 _DeltaX-=%_MouseStartX%
 _DeltaY:=_MouseY
 _DeltaY-=%_MouseStartY%
 _MouseStartX:=_MouseX
 _MouseStartY:=_MouseY
 WinGetPos,_GuiX,_GuiY,,,ahk_id%_GuiID%
 _GuiX+=%_DeltaX%
 _GuiY+=%_DeltaY%
 SetWinDelay,-1
 WinMove,ahk_id %_GuiID%,,%_GuiX%,%_GuiY%
 RETURN
 }

 NotifyChange()
 {
 ; do nothing yet
 Return
 }
