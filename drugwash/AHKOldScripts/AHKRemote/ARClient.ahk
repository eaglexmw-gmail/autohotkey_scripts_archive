;AHK Remote Client v1.2
; http://www.autohotkey.com/forum/viewtopic.php?t=28838
by ManaUser

#SingleInstance Force
#NoEnv
SendMode Input

NetworkAddress = 127.0.0.1 ;127.0.0.1 means local machine (so does blank).
NetworkPort    = 8257
PromptForAddy  = 1         ;Allows the user to supply another address if desired.
TestTimout     = 1000      ;ms, Blank means don't pre-test the address.
MaxDataLength  = 4096      ;Longest message that can be recieved.
MaxGuiRows     = 10
ButtonSize     = 128       ;Blank means auto.

Menu TRAY, Tip, AHK Remote
Menu TRAY, Icon, SHELL32.DLL, 121
Menu TRAY, NoStandard
If (NOT A_IsCompiled)
{
   Menu TRAY, Add, &Edit, TrayEdit
   Menu TRAY, Add
}
Menu TRAY, Add, &Reload, TrayReload
Menu TRAY, Add, E&xit, TrayExit

If PromptForAddy
{
   Gui Add, Text, w64 Right, Address:
   Gui Add, Edit, w100 yp-4 x+8 vNetworkAddress, %NetworkAddress%
   Gui Add, Text, xm w64 Right, Port:
   Gui Add, Edit, w100 yp-4 x+8 vNetworkPort, %NetworkPort%
   Gui Add, Button, gGetStarted Default, Connect
   Gui Show,, Enter Address
   Return
}
GetStarted:
Gui Submit

if (NetworkAddress = "")
   NetworkAddress := "127.0.0.1"
If (NOT TestTimout)
   TestTimout := 0
NeedIP := !RegExMatch(NetworkAddress, "^(\d+\.){3}\d+$")

If (TestTimout OR NeedIP)
{
   ;Use Ping to check if the address is reachable, we can also get the IP address this way.
   RunWait %ComSpec% /C Ping -n 1 -w %TestTimout% %NetworkAddress% > getpingtestip.txt,, Hide
   If (ErrorLevel AND TestTimout)
   {
      MsgBox %NetworkAddress% cannot be reached.
      FileDelete getpingtestip.txt
      ExitApp
   }
   If NeedIP
   {
      Loop, Read, getpingtestip.txt
      {
         If RegExMatch(A_LoopReadLine, "(?<=\[)(\d+\.){3}\d+(?=\])", NetworkAddress)
           Break
      }
   }
   FileDelete getpingtestip.txt
}

Menu PopUp, Add, Dummy, HandleMenu ;So the menu exists.

If (ButtonSize != "")
   ButtonSize := "w" . ButtonSize

;v v v v v v v v v v v v v v v v v v v
OnExit DoExit

MainSocket := PrepareSocket(NetworkAddress, NetworkPort)
If (MainSocket = -1)
   ExitApp ;failed

DetectHiddenWindows On
Process Exist
MainWindow := WinExist("ahk_class AutoHotkey ahk_pid " . ErrorLevel)
DetectHiddenWindows Off

;^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^
;FD_READ + FD_CLOSE + FD_WRITE = 35
If DllCall("Ws2_32\WSAAsyncSelect", "UInt", MainSocket, "UInt", MainWindow, "UInt", 5555, "Int", 35)
;v v v v v v v v v v v v v v v v v v v
{
    MsgBox % "WSAAsyncSelect() indicated Winsock error " . DllCall("Ws2_32\WSAGetLastError")
    ExitApp
}

OnMessage(5555, "ReceiveData", 99) ;Allow 99 (i.e. lots of) threads.

Return

PrepareSocket(IPAddress, Port)
{
   VarSetCapacity(wsaData, 32)
   Result := DllCall("Ws2_32\WSAStartup", "UShort", 0x0002, "UInt", &wsaData)
   If ErrorLevel
   {
      MsgBox WSAStartup() could not be called due to error %ErrorLevel%. Winsock 2.0 or higher is required.
      return -1
   }
   If Result  ; Non-zero, which means it failed (most Winsock functions return 0 upon success).
   {
      MsgBox % "WSAStartup() indicated Winsock error " . DllCall("Ws2_32\WSAGetLastError")
      return -1
   }

   ;AF_INET = 2   SOCK_STREAM = 1   IPPROTO_TCP = 6
   Socket := DllCall("Ws2_32\socket", "Int", 2, "Int", 1, "Int", 6)
   If (Socket = -1)
   {
      MsgBox % "Socket() indicated Winsock error " . DllCall("Ws2_32\WSAGetLastError")
      return -1
   }

   VarSetCapacity(SocketAddress, 16)
   InsertInteger(2, SocketAddress, 0, 2) ; AF_INET = 2
   InsertInteger(DllCall("Ws2_32\htons", "UShort", Port), SocketAddress, 2, 2)   ; sin_port
   InsertInteger(DllCall("Ws2_32\inet_addr", "Str", IPAddress), SocketAddress, 4, 4)   ; sin_addr.s_addr
;^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^

   If DllCall("Ws2_32\connect", "UInt", Socket, "UInt", &SocketAddress, "Int", 16)
   {
      Result := DllCall("Ws2_32\WSAGetLastError")
      If (Result = 10061)
         MsgBox Connection Refused. That probably means the server script is not running.
      Else
         MsgBox % "Connect() indicated Winsock error " . Result
      return -1
   }
   
   Return Socket
}

ReceiveData(wParam, lParam)
{
   Global MaxGuiRows, ButtonSize, MaxDataLength, MainSocket, MenuChoice

;v v v v v v v v v v v v v v v v v v v
   VarSetCapacity(ReceivedData, MaxDataLength, 0)
   ReceivedDataLength := DllCall("Ws2_32\recv", "UInt", wParam, "Str", ReceivedData, "Int", MaxDataLength, "Int", 0)
   If (ReceivedDataLength = 0)  ; The connection was gracefully closed
      Return NormalClose()
   if ReceivedDataLength = -1
   {
      WinsockError := DllCall("Ws2_32\WSAGetLastError")
      If (WinsockError = 10035)  ; No more data to be read
         Return 1
      If WinsockError = 10054 ; Connection closed
         Return NormalClose()
      MsgBox % "Recv() indicated Winsock error " . WinsockError
      ExitApp
   }

   Command := SubStr(ReceivedData, 1, 10)
   ReceivedData := SubStr(ReceivedData, 11)
;^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^

   If (Command = "ARCOMLIST:")
   {
      Gui Destroy
      Loop Parse, ReceivedData, %A_Space%
      {
         StringReplace ButtonName, A_Loopfield, _, %A_Space%, All
         If (Mod(A_Index, MaxGuiRows) = 0)
            Options .= "ym "
         Gui Add, Button, %ButtonSize% gHandleButton %Options%, %ButtonName%
         Options =
      }
      Gui Show,, AHK Remote
   }
   Else If (Command = "ARSHOWTXT:")
   {
      Gui 2:Destroy
      Gui 2:Add, Edit, Multi w500, %ReceivedData%
      Gui 2:+ToolWindow +Owner1
      Gui 2:Show,, AHK Remote
   }
   Else If (Command = "ARMESSAGE:")
   {
      Gui +OwnDialogs
      MsgBox,, AHK Remote, %ReceivedData%
   }
   Else If (Command = "ARYESORNO:")
   {
      Gui +OwnDialogs
      MsgBox 36, AHK Remote, %ReceivedData%
      IfMsgBox Yes
         SendData(MainSocket, "ARESPONSE:YES")
      Else
         SendData(MainSocket, "ARESPONSE:NO")
   }
   Else If (Command = "ARGETINFO:")
   {
      Gui +OwnDialogs
      InputBox Result, AHK Remote, %ReceivedData%,,, 130
      If (ErrorLevel OR Result = "")
         SendData(MainSocket, "ARESPONSE:CANCEL")
      Else
         SendData(MainSocket, "ARESPONSE:" . Result)
   }
   Else If (Command = "ARPASWORD:")
   {
      Gui +OwnDialogs
      InputBox Result, AHK Remote, Password required., Hide,, 110
      If ErrorLevel
         SendData(MainSocket, "ARESPONSE:CANCEL")
      Else
         SendData(MainSocket, "ARESPONSE:" . RC4txt2hex("OPENSESAME", Result . ReceivedData))
   }
   Else If (Command = "ARPOPMENU:")
   {
      Menu PopUp, DeleteAll
      Loop Parse, ReceivedData, |
         Menu PopUp, Add, %A_LoopField%, HandleMenu
      MenuChoice := 0
      Menu PopUp, Show
      SendData(MainSocket, "ARESPONSE:" . MenuChoice)
   }

   Return 1
}

NormalClose()
{
   ExitApp
   Return 1
}

;v v v v v v v v v v v v v v v v v v v
SendData(Socket, Data)
{
   SendRet := DllCall("Ws2_32\send", "UInt", Socket, "Str", Data, "Int", StrLen(Data), "Int", 0)
   If (SendRet = -1)
      MsgBox % "Send() indicated Winsock error " . DllCall("Ws2_32\WSAGetLastError")
   Return SendRet
}

;By Laszlo, used by the password function.
RC4txt2hex(Data,Pass) {
   Format := A_FormatInteger
   SetFormat Integer, Hex
   b := 0, j := 0
   VarSetCapacity(Result,StrLen(Data)*4)
   Loop 256 {
      a := A_Index - 1
      Key%a% := Asc(SubStr(Pass, Mod(a,StrLen(Pass))+1, 1))
      sBox%a% := a
   }
   Loop 256 {
      a := A_Index - 1
      b := b + sBox%a% + Key%a%  & 255
      T := sBox%a%
      sBox%a% := sBox%b%
      sBox%b% := T
   }
   Loop Parse, Data
   {
      i := A_Index & 255
      j := sBox%i% + j  & 255
      k := sBox%i% + sBox%j%  & 255
      Result .= Asc(A_LoopField)^sBox%k%
   }
   Result := RegExReplace(Result, "0x(.)(?=0x|$)", "0$1")
   StringReplace Result, Result, 0x,,All
   SetFormat Integer, %Format%
   Return Result
}

InsertInteger(pInteger, ByRef pDest, pOffset = 0, pSize = 4)
{
   Loop %pSize%  ; Copy each byte in the integer into the structure as raw binary data.
      DllCall("RtlFillMemory", "UInt", &pDest + pOffset + A_Index-1, "UInt", 1, "UChar", pInteger >> 8*(A_Index-1) & 0xFF)
}

GuiClose:
ExitApp

DoExit:
TrayExit:
DllCall("Ws2_32\WSACleanup")
ExitApp

TrayEdit:
Edit
Return

TrayReload:
Reload
Return

;^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^

HandleButton:
StringReplace CommandName, A_GuiControl, %A_Space%, _, All
SendData(MainSocket, "ARCOMMAND:" . CommandName)
Return

HandleMenu:
MenuChoice := A_ThisMenuItemPos
Return
