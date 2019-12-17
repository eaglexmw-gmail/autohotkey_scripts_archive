OnMessage(0x4e,"WM_NOTIFY")
Gui,Add,ListView,r20 AltSubmit Checked gFocus hwndLVhWnd vListView,Test
Gui,+LastFound
hwnd:=WinExist()
ToolTip("ListView","default","","P1 aSysListView321")
Loop 20
   LV_Add("",A_Index)
gui,show
Return

WM_NOTIFY(wParam,lParam){
   global
   If (control:=ToolTip("",lparam)){
      Tool:=ErrorLevel
      If (control="ListView" and row>0){
         LV_GetText(text,row,1)
         ToolTip(control,"Row Text: " text,action,"G1 A" . Tool)
      } else
         ToolTip(control,"check or select an item`nthen move mouse away and back to list","","G1 A" . Tool)
   }
}

Focus:
   If InStr(ErrorLevel,"F",1){
      row:=A_EventInfo
      action:="Focused"
   } else If InStr(ErrorLevel,"C",1){
      row:=A_EventInfo
      action:="Checked"
   }
SetTimer,PostMessage,-10
Return

PostMessage:
KeyWait,LButton
PostMessage,0x200,1,,,ahk_id %hwnd%
MouseGetPos,x,y
MouseMove,% x+1,% y
Return

GuiClose:
ExitApp

#include Tooltip advanced 12.ahk
