Gui, Add, Edit, x5 y5 w400 h200 -Wrap ReadOnly HScroll
Gui, Add, Picture, x5 y210 +0x3
Gui, Add, Button, x315 y220 w90 h20 gShowNext, Show Next
Gui, Show, x10 y10 w410 h245

Process, Exist
WinGet, hw_this, ID, ahk_class AutoHotkeyGUI ahk_pid %ErrorLevel%

WS_EX_APPWINDOW = 0x40000
WS_EX_TOOLWINDOW = 0x80

GW_OWNER = 4

WinGet, list, List

loop, %list%
{
   wid := list%A_Index%
   
   WinGet, es, ExStyle, ahk_id %wid%
   
   if ( ( ! DllCall( "GetWindow", "uint", wid, "uint", GW_OWNER ) and ! ( es & WS_EX_TOOLWINDOW ) )
         or ( es & WS_EX_APPWINDOW ) )
   {
      WinGet, pid, PID, ahk_id %wid%
   
      WinGetClass, class, ahk_id %wid%
      WinGetTitle, title, ahk_id %wid%
      
      GuiControl,, Edit1, %
         ( Join
            "pid = " pid
            "`n`nwid = " wid
            "`nclass = " class
            "`ntitle = " title
            "`n`nfile name = " GetModuleFileNameEx( pid )
         )

      ;WM_GETICON
      ;   ICON_SMALL          0
      ;   ICON_BIG            1
      ;   ICON_SMALL2         2
      SendMessage, 0x7F, 1, 0,, ahk_id %wid%
      h_icon := ErrorLevel
      if ( ! h_icon )
      {
         SendMessage, 0x7F, 2, 0,, ahk_id %wid%
         h_icon := ErrorLevel
         if ( ! h_icon )
         {
            SendMessage, 0x7F, 0, 0,, ahk_id %wid%
            h_icon := ErrorLevel
            if ( ! h_icon )
            {
               ; GCL_HICON           (-14)
               h_icon := DllCall( "GetClassLong", "uint", wid, "int", -14 )
               
               if ( ! h_icon )
               {
                  ; GCL_HICONSM         (-34)
                  h_icon := DllCall( "GetClassLong", "uint", wid, "int", -34 )
                  
                  if ( ! h_icon )
                  {
                     ; IDI_APPLICATION     32512
                     h_icon := DllCall( "LoadIcon", "uint", 0, "uint", 32512 )
                  }
               }
            }
         }
      }

      ;STM_SETIMAGE        0x0172
      ;   IMAGE_ICON          1
      SendMessage, 0x172, 1, h_icon, Static1, ahk_id %hw_this%
      
      pause
   }
}
return

GuiClose:
ExitApp

ShowNext:
   pause, Off
return

GetModuleFileNameEx( p_pid )
{
   if A_OSVersion in WIN_95,WIN_98,WIN_ME
   {
      MsgBox, This Windows version (%A_OSVersion%) is not supported.
      return
   }

   /*
      #define PROCESS_VM_OPERATION      (0x0008) 
      #define PROCESS_VM_READ           (0x0010)
      #define PROCESS_QUERY_INFORMATION (0x0400) 
   */
   h_process := DllCall( "OpenProcess", "uint", 0x8|0x10|0x400, "int", false, "uint", p_pid )
   if ( ErrorLevel or h_process = 0 )
   {
      MsgBox, [OpenProcess] failed
      return
   }
   
   name_size = 255
   VarSetCapacity( name, name_size )
   
   result := DllCall( "psapi.dll\GetModuleFileNameExA", "uint", h_process, "uint", 0, "str", name, "uint", name_size )
   if ( ErrorLevel or result = 0 )
      MsgBox, [GetModuleFileNameExA] failed
   
   DllCall( "CloseHandle", h_process )
   
   return, name
}
