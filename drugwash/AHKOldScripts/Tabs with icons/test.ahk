; created by DerRaphael
; updated by Drugwash

MyImageList := IL_Create()
Loop 10
   IL_Add(MyImageList, "shell32.dll", A_Index)

Gui, Add, Tab2, x16 y216 w440 h20 0x38 -Wrap +Bottom gShoutActiveTab vMyIconTab

Tab_AttachImageList( MyImageList, "MyIconTab" )

Gui +LastFound
Gui, Tab

Gui, Add, Edit, y17 w440 h200 x16, This Edit Control is not part of the Tab Structure :)
Gui, Add, Button, y240 x16 w440 gTestRun, Start the Test
Gui, Add, Button, y+2 x16 w80 gTestGetName, Get name

Tab_AppendWithIcon( "Berlin", 1 )
Tab_AppendWithIcon( "London", 2 )
Tab_AppendWithIcon( "New York", 3 )
Tab_AppendWithIcon( "Helsinki", 4 )
Tab_AppendWithIcon( "Bejing", 5 )
Tab_AppendWithIcon( "Rom", 6 )
Tab_AppendWithIcon( "Moskwa", 7 )

Gui, Show, x131 y91 h294 w477, Tabs with Icon Test
return

^l::
TestGetName:
Gui +LastFound
name := Tab_GetName( Tab_GetActiveIdx()-1 )
MsgBox, Selected tab's name is %name%
return

TestRun:
   MsgBox,1,Test #1, Press Enter to append a Tab with customized Label and Icon
   IfMsgBox, OK
   {
      InputBox, TabName, Enter Name for new Tab, Please Name a TabName to Add
      InputBox, IconNr, Enter IconNumber for new Tab, Please specify an Icon# from 1..10
      Tab_AppendWithIcon(TabName, IconNr)
   }

   MsgBox,1,Test #2, Press Enter to change Tab #1's Label and Icon
   IfMsgBox, OK
   {
      InputBox, TabName, Enter Name for new Tab, Please Name a TabName to Add
      InputBox, IconNr, Enter IconNumber for new Tab, Please specify an Icon# from 1..10
      Tab_Modify( TabName, IconNumber, 0 )
   }

   MsgBox,1,Test #3, Press Enter to Remove Tab #2
   IfMsgBox, OK
   {
      Tab_Delete(1)
   }

   Msg=
   Msg .= "There are " . Tab_Count() . " Tabs in this SysTabControl`n"
   Msg .= "Tab #" . Tab_GetActiveIdx() . " is the active Tab`n"
   Msg .= "Tab #" . Tab_GetFocus() . " is the focused Tab`n"

   MsgBox,,Status, %Msg%
   
return

ShoutActiveTab:
   GuiControlGet, label,, MyIconTab
   GuiControl,,Edit1, The Selected Tab is labeled with "%label%"
return

GuiEscape:
GuiClose:
   IL_Destroy(MyImageList)  ; Required for image lists used by tab controls.
   ExitApp
