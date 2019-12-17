; http://www.autohotkey.com/forum/viewtopic.php?p=114703#114703

#SingleInstance, Force
DetectHiddenWindows, OFF             ; OFF is default, but this script would err if set ON

Menu, Tray, NoStandard
Menu, Tray, Add, Show/Hide, ShowHide
Menu, Tray, Add
Menu, Tray, Standard
Menu, Tray, Default, Show/Hide
;Menu, Tray, Icon, NetShell.dll, 58
Menu, Tray, Icon, rasapi32.dll, 1

IfNotExist, %A_Temp%\NetStatus.bmp
UrlDownloadToFile, http://www.autohotkey.net/~goyyah/samples/grad001.bmp
, %A_Temp%\NetStatus.bmp

Gui -Caption +Border +ToolWindow +AlwaysOnTop +LastFound
GuiID := WinExist() , prv_iNo := 44
Gui, Color , FFFFEE
Gui, Margin, 0, 0
Gui, Font  , s8, Verdana
Gui, Add, Picture, x40   y0   w200 h40 vConn  GuiMove, %A_Temp%\NetStatus.bmp
;Gui, Add, Picture, x5    y6     Icon30 vIcon  GuiMove, NetShell.dll
Gui, Add, Picture, x5    y6     Icon4 vIcon  GuiMove, rasapi32.dll
Gui, Add, Text   , x+7   y3    w75  h16 +Border
Gui, Add, Text   , xp+1  yp+1  w70  h14 +0x200 c5B0000 +Right  HWNDSent
Gui, Add, Text   , xp-1  y+3   w75  h16 +Border
Gui, Add, Text   , xp+1  yp+1  w70  h14 +0x200 c5B0000 +Right  HWNDRecv
Gui, Add, Text   , x+7   y3    w80  h16 +Border   
Gui, Add, Text   , xp+4  yp+1  w75  h14 c003D00                HWNDkbps 
Gui, Font, Bold
Gui, Add, Text   , xp-4  y+3   w80  h16 +Border
Gui, Add, Text   , xp+4  yp+1  w75  h14 c003D00                HWNDband 

IniRead, X, %A_Temp%\%A_ScriptName%.INI, GuiPos, XPos, 20
IniRead, Y, %A_Temp%\%A_ScriptName%.INI, GuiPos, YPos, 20

Gui, Show, x%x% y%y% w205 h40, NetMeter

If GetIfTable(tb)
   ExitApp

Loop, % DecodeInteger(&tb) {
   If DecodeInteger(&tb + 4 + 860 * (A_Index - 1) + 544) < 4
   || DecodeInteger(&tb + 4 + 860 * (A_Index - 1) + 516) = 24
      Continue

   ptr := &tb + 4 + 860 * (A_Index - 1)
      Break
                           }
;IfLess, ptr, 1, ExitApp
SetTimer, NetMeter

Return ; ------------------------------------------------------- AutoExecute Section ends

NetMeter:
   SetTimer, NetMeter, Off
   DllCall("iphlpapi\GetIfEntry", "Uint", ptr)

   dnNew := DecodeInteger(ptr + 552)   ,    upNew  := DecodeInteger(ptr + 576)     
   dnRate := Round((dnNew - dnOld) )   ,    upRate := Round((upNew - upOld) )
   PollMs := (dnRate - upRate = 0) ? 1024 : 256

   Menu, Tray, Tip, % "Sent: " upNew " / Recv: " dnNew " / Total: "
                  . Round((((upNew+dnNew) /1024)/1024),1) . " MB"

   ; Determine & update GUI-Icon & Tray-Icon
/*
   IfGreater,dnRate,0,  IfGreater,upRate,0,  SetEnv,iNo,41     ;  Recv/Sent
   IfGreater,dnRate,0,  IfEqual  ,upRate,0,  SetEnv,iNo,42     ;  Recv
   IfEqual  ,dnRate,0,  IfGreater,upRate,0,  SetEnv,iNo,43     ;  Sent
   IfEqual  ,dnRate,0,  IfEqual  ,upRate,0,  SetEnv,iNo,44     ;  None
   IfNotEqual,iNo, %prv_iNo%,  Menu, Tray, Icon, NetShell.dll, % iNo+14
*/
   IfGreater,dnRate,0,  IfGreater,upRate,0,  SetEnv,iNo,1     ;  Recv/Sent
   IfGreater,dnRate,0,  IfEqual  ,upRate,0,  SetEnv,iNo,2     ;  Recv
   IfEqual  ,dnRate,0,  IfGreater,upRate,0,  SetEnv,iNo,3     ;  Sent
   IfEqual  ,dnRate,0,  IfEqual  ,upRate,0,  SetEnv,iNo,6     ;  None
   IfNotEqual,iNo, %prv_iNo%,  Menu, Tray, Icon, rasapi32.dll, 4

   If WinExist( "ahk_id " . GuiID )  {                ; Update the GUI Data
   ControlSetText,, %upNew%                                         , ahk_id %Sent%   
   ControlSetText,, %dnNew%                                         , ahk_id %Recv%
   ControlSetText,, % Round((dnrate+uprate)/PollMs) . " KBps"       , ahk_id %Kbps%
   ControlSetText,, % Round((((upNew+dnNew) /1024)/1024),1) . " MB" , ahk_id %Band%
;   IfNotEqual,iNo, %prv_iNo%,  GuiControl,, Icon, *Icon%iNo% NetShell.dll
   IfNotEqual,iNo, %prv_iNo%,  GuiControl,, Icon, *Icon%iNo% rasapi32.dll
                                     }

   prv_iNo := iNo , dnOld := dnNew , upOld := upNew
   SetTimer, NetMeter, %PollMs%
Return

uiMove:
   PostMessage, 0xA1, 2,,, A
   Sleep 200
   WinGetPos, X, Y
   IniWrite, %X%, %A_Temp%\%A_ScriptName%.INI, GuiPos, XPos
   IniWrite, %Y%, %A_Temp%\%A_ScriptName%.INI, GuiPos, YPos
Return

ShowHide:
;   GuiControl,, Icon, *Icon%iNo% NetShell.dll
   GuiControl,, Icon, *Icon%iNo% rasapi32.dll
   IfWinExist, ahk_id %GuiID%,,,, WinHide, ahk_id %GuiID%
   Else                           WinShow, ahk_id %GuiID%
Return

GuiContextMenu:
   Menu, Tray, Show
Return

GetIfTable(ByRef tb, bOrder = False) {
   nSize := 4 + 860 * GetNumberOfInterfaces() + 8
   VarSetCapacity(tb, nSize)
   Return DllCall("iphlpapi\GetIfTable", "Uint", &tb, "UintP", nSize, "int", bOrder)
                                     }

GetIfEntry(ByRef tb, idx)            {
   VarSetCapacity(tb, 860)
;   DllCall("ntdll\RtlFillMemoryUlong", "Uint", &tb + 512, "Uint", 4, "Uint", idx)
   DllCall("ntdll\RtlFillMemory", "Uint", &tb + 512, "Uint", 1, "Uint", idx)
   Return DllCall("iphlpapi\GetIfEntry", "Uint", &tb)
                                     }

GetNumberOfInterfaces()              {
   DllCall("iphlpapi\GetNumberOfInterfaces", "UintP", nIf)
   Return nIf
                                     }

DecodeInteger(ptr)                   {
   Return *ptr | *++ptr << 8 | *++ptr << 16 | *++ptr << 24
                                     }
