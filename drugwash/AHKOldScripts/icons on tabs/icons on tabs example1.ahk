
TabList = General|Interface|File
Gui, Add, ListBox, x16 y14 w100 h340 gListbox vMyListBox, %TabList%

MyImageList := IL_Create()
Loop 3  ; Load the ImageList with a series of icons from the DLL.
   IL_Add(MyImageList, "shell32.dll", A_Index)  ; Omits DLL path so that it works on Windows 9x too.

;Gui, Add, GroupBox, x136 y14 w610 h330 vGGroupBox , General
Gui, Add, GroupBox, x136 y44 w610 h330 vGGroupBox , General
Gui, Add, Tab, x136 y14 w610 h330 vGeneral,
AddTab(1, "General - Icon And Text","SysTabControl321")

Gui, Add, Text, x186 y54 w100 h30 , Inside General Tab
Gui, Add, Edit, x306 y54 w400 h30 , Edit
Gui, Add, Text, x186 y104 w100 h30 , Inside General Tab
Gui, Add, Edit, x306 y104 w400 h30 , Edit

Gui, Add, Tab, x136 y14 w610 h330 vInterface,
AddTab(0, "Interface - Text Only" , "SysTabControl322")

Gui, Add, Text, x186 y54 w100 h30 , Inside Interface Tab
Gui, Add, Edit, x316 y54 w320 h30 ,  Inside Interface Tab


Gui, Add, Tab, x136 y14 w610 h330 vFile,
AddTab(0, "" , "SysTabControl323")
Gui, Add, Text, x186 y54 w100 h30 , Inside File Tab

GuiControl, Hide, Interface
GuiControl, Hide, File
Gui, Show, x131 y91 h421 w817, New GUI Window
Return

listbox:
Gui, submit, NoHide
Loop, Parse, TabList, |
   {
      If (MyListBox = A_LoopField)
      {
         GuiControl, Show, %A_LoopField%
         GuiControl, Text, GGroupBox, %A_LoopField%
      }
      else
      {
         GuiControl, Hide, %A_LoopField%
      }
   }
return

GuiClose:
GuiEscape:
ExitApp
  ; Relies on caller having set the last found window for us.
 
AddTab(IconNumber, TabName, TabControl)
{
   global MyImageList
   Gui +LastFound
   SendMessage, 0x1303, 0, MyImageList, %TabControl%
   VarSetCapacity(TCITEM, 100, 0)
   InsertInteger(3, TCITEM, 0)  ; Mask (3) comes from TCIF_TEXT(1) + TCIF_IMAGE(2).
   InsertInteger(&TabName, TCITEM, 12)  ; pszText
   InsertInteger(IconNumber - 1, TCITEM, 20)  ; iImage: -1 to convert to zero-based.
   SendMessage, 0x1307, 999, &TCITEM, %TabControl%  ; 0x1307 is TCM_INSERTITEM
}

InsertInteger(pInteger, ByRef pDest, pOffset = 0, pSize = 4)
{
   Loop %pSize%  ; Copy each byte in the integer into the structure as raw binary data.
      DllCall("RtlFillMemory", "UInt", &pDest + pOffset + A_Index-1, "UInt", 1, "UChar", pInteger >> 8*(A_Index-1) & 0xFF)
}
