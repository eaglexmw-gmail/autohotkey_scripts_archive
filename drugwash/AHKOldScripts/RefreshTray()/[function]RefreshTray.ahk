http://www.autohotkey.com/forum/topic36966.html

#__REFRESH_TRAY()
{
   ControlGetPos, ,,w,h,ToolbarWindow321, AHK_class Shell_TrayWnd
   w //=4
   h //=4
   Loop %w%
   {
      x := A_Index
      Loop %h%
         PostMessage, 0x200,%x%,%A_Index%,ToolbarWindow321, AHK_class Shell_TrayWnd
   }   
}
