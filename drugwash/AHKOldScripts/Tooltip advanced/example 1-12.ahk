
OnMessage(0x4e,"WM_NOTIFY")
Gui,Add,Button,,Time
Gui,Add,Button,,Username
Gui,Add,Button,,User is Admin?
Gui,Add,Button,,IP addresses
Loop 4
   ToolTip("Button1"," ","","p1 aButton" . A_Index)
gui,show
Return

WM_NOTIFY(wParam,lParam){
   If (control:=ToolTip("",lparam)){
      Tool:=ErrorLevel
      MouseGetPos,,,,ClassNN
      If (ClassNN="Button1"){
         FormatTime,text,%A_Now%,HH:mm:ss
         Title:="Time"
      } else if (ClassNN="Button2"){
         text:=A_UserName,title:="UserName"
      } else if (ClassNN="Button3"){
         text:=(A_ISAdmin ? "Yes" : "No"),title:="User is Admin?"
      } else if (ClassNN="Button4"){
         text:= "1: " A_IPAddress1 "`n2: " A_IPAddress2 "`n3: " A_IPAddress3 "`n4: " A_IPAddress4
         title:="IP Addresses"
      }
      ToolTip(control,text,title,"G1 A" . Tool . " I" (InStr("Button1Button2",ClassNN) ? "2" : "1"))
   }
}

GuiClose:
ExitApp

#include Tooltip advanced 12.ahk
