; http://www.autohotkey.com/forum/viewtopic.php?t=30300

; ### Example Code #####
Gui,Add,Button,hwndbutton1 Gbut1,Test Button 1
Gui,Add,Button,hwndbutton2,Test Button 2
Gui,Add,Button,hwndbutton3,Test Button 3
AddTooltip(button1,"Press me to change my tooltip")
AddTooltip(button2," Another Test Tooltip")
AddTooltip(button3,"A Multiline`nTest Tooltip")
Gui,show,,Test Gui
Return

But1:
AddTooltip(button1,"Wasn't that easy `;)",1)
REturn

GuiClose:
Guiescape:
Exitapp

; ### End Example Code #####

AddToolTip(con,text,Modify = 0){
  Static TThwnd,GuiHwnd
  If (!TThwnd){
    Gui,+LastFound
    GuiHwnd:=WinExist()
    TThwnd:=CreateTooltipControl(GuiHwnd)
  }
  Varsetcapacity(TInfo,44,0)
  Numput(44,TInfo)
  Numput(1|16,TInfo,4)
  Numput(GuiHwnd,TInfo,8)
  Numput(con,TInfo,12)
  Numput(&text,TInfo,36)
  Detecthiddenwindows,on
  If (Modify){
    SendMessage,1036,0,&TInfo,,ahk_id %TThwnd%
  }
  Else {
    Sendmessage,1028,0,&TInfo,,ahk_id %TThwnd%
    SendMessage,1048,0,300,,ahk_id %TThwnd%
  }
 
}

CreateTooltipControl(hwind){
  Ret:=DllCall("CreateWindowEx"
          ,"Uint",0
          ,"Str","TOOLTIPS_CLASS32"
          ,"Uint",0
          ,"Uint",2147483648 | 3
          ,"Uint",-2147483648
          ,"Uint",-2147483648
          ,"Uint",-2147483648
          ,"Uint",-2147483648
          ,"Uint",hwind
          ,"Uint",0
          ,"Uint",0
          ,"Uint",0)
         
  Return Ret
}
