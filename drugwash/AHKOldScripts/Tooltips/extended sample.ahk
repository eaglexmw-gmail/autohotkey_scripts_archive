;-- Note.  To get this script to work, you'll need to add (or include) the
;   AddTooltip and CreateTooltipControl functions from the first post to the
;   bottom of this script.  For the picture example, copy any picture file (jpg,
;   bmp, etc.) to the same directory as this script and name it "picture.bmp".


#NoEnv

gui -MinimizeBox
gui Add,Button,w150 hwndbutton1 gbut1,Test Button 1
AddTooltip(button1,"Button 1: Press me to change my tooltip")


gui Add,Button,y+0 w150 hwndbutton2 gbut2,Test Button 2
AddTooltip(button2,"Button 2: Press me to turn off the tooltip for this button")


gui Add,Button,y+0 w150 hwndbutton3,Test Button 3
AddTooltip(button3,"A Multiline Test Tooltip`n2nd line`n3rd line`n4th line")


gui Add,Checkbox,w150 hwndCheckbox_hWnd,Checkbox Control
AddTooltip(Checkbox_hWnd,"Tooltip for the Checkbox control")


gui Add,Radio,w150 hwndRadio_hWnd,Radio Control
AddTooltip(Radio_hWnd,"Tooltip for the Radio control")


gui Add,Edit,w150 hwndEdit_hWnd,Edit Control
AddTooltip(Edit_hWnd,"Tooltip for the Edit control")


gui Add,Text,w150 hwndText_hWnd gNull,Text Control
Tip=
   (ltrim join`s
    Tooltip for the Text control.  Note that the Tooltip for a Text control does
    not show unless a g-label for the control is defined.
   )
AddTooltip(Text_hWnd,Tip)


gui Add,Picture,w150 h100 hwndPicture_hWnd gnull,Picture.bmp
Tip=
   (ltrim join`s
    Tooltip for the Picture control.  Note that the Tooltip for a Picture
    control does not show unless a g-label for the control is defined.   
   )
AddTooltip(Picture_hWnd,Tip)


gui Add,DropDownList,w150 r3 hwndDropDownList_hWnd,DropDownList Control||2|3
AddTooltip(DropDownList_hWnd,"Tooltip for the DropDownList control")


gui Add,ComboBox,w150 r3 hwndComboBox_hWnd,ComboBox Control||2|3
    ;-- A ComboBox is actually two controls:  An Edit control and a Drop-down
    ;   button. Note that handle returned for this control is for the
    ;   drop-down button, not for the Edit control.
Tip=
   (ltrim join`s
    Tooltip for the drop-down button piece of the ComboBox control.  Note that
    this tip is different than the Edit piece of the control.
   )
AddTooltip(ComboBox_hWnd,Tip)

gui Add,ListBox,w150 r3 hwndListBox_hWnd,ListBox Control||2|3
AddTooltip(ListBox_hWnd,"Tooltip for the ListBox control")

gui Add,ListView,w150 h50 hwndListView_hWnd,ListView Control
Tip=
   (ltrim join`s
    Tooltip for the ListView control.  Note that this tip is different than
    the header piece of the control.
   )
AddTooltip(ListView_hWnd,Tip)

gui Add,DateTime,w150 hwndDateTime_hWnd  ;,DateTime Control
AddTooltip(DateTime_hWnd,"Tooltip for the DateTime control")


;-- Uncomment this if you want to see the MonthCal control.  Works the same as DateTime
;;;;;gui Add,MonthCal,w150 hwndMonthCal_hWnd  ;,MonthCal Control
;;;;;AddTooltip(MonthCal_hWnd,"Tooltip for the MonthCal control")


gui Add,Progress,w150 hwndProgress_hWnd,65  ;Progress Control
AddTooltip(Progress_hWnd,"Tooltip for the Progress control")


gui Add,Slider,w150 hwndSlider_hWnd,45  ;Slider Control
AddTooltip(Slider_hWnd,"Tooltip for the Slider control")


gui Add,Hotkey,w150 hwndHotkey_hWnd,45  ;Hotkey Control
AddTooltip(Hotkey_hWnd,"Tooltip for the Hotkey control")


gui Add,Edit,w150 h20 hwndEdit2_hWnd,Dummy Edit Control  ;-- Used by UpDown control
Tip=
   (ltrim join`s
    This Edit control was created so that the attached UpDown control could be
    demonstrated.
   )
AddTooltip(Edit2_hWnd,Tip)


gui Add,UpDown,hwndUpDown_hWnd Range 1-10,5
AddTooltip(UpDown_hWnd,"Tooltip for the UpDown control")

gui Show,,Tooltip Test


;-- Get hWnd to the Edit control piece of the ComboBox
ControlGet ListViewHeader_hWnd,hWnd,,SysHeader321,Tooltip Test
Tip=
   (ltrim join`s
    Tooltip for the header of the ListView control.  Note that this tip is
    different than the rest of the ListView control.
   )
AddTooltip(ListViewHeader_hWnd,Tip)


;-- Get hWnd to the Edit control piece of the ComboBox
ControlGet EditComboBox_hWnd,hWnd,,Edit2,Tooltip Test
Tip=
   (ltrim join`s
    Tooltip for the Edit piece of the ComboBox control.  Note that this tip is
    different than the drop-down button piece of this control.
   )
AddTooltip(EditComboBox_hWnd,Tip)

return


But1:
AddTooltip(button1,"Wasn't that easy `;)",true)
return

But2:
AddTooltip(button2,"",true)
return


Null:
return

GUIClose:
GUIescape:
ExitApp



;-- Copy the AddTooltip and CreateTooltipControl functions from the 1st post
;   here.  The original post can be found here:
;   http://www.autohotkey.com/forum/viewtopic.php?t=30300

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
l_DetectHiddenWindows:=A_DetectHiddenWindows
  Detecthiddenwindows,on
  If (Modify){
    SendMessage,1036,0,&TInfo,,ahk_id %TThwnd%
  }
  Else {
    Sendmessage,1028,0,&TInfo,,ahk_id %TThwnd%
    SendMessage,1048,0,300,,ahk_id %TThwnd%
  }
 DetectHiddenWindows %l_DetectHiddenWindows%
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
