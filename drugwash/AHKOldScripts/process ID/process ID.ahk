Process, Exist
pid := ErrorLevel

MsgBox, % "pid = " pid "`n`nname = " GetModuleFileNameEx( pid )
return

GetModuleFileNameEx( p_pid )
{
   if A_OSVersion in WIN_95,WIN_98,WIN_ME
   {
      MsgBox, This Windows version (%A_OSVersion%) is not supported.
      return
   }

   /*
      #define PROCESS_VM_READ           (0x0010)
      #define PROCESS_QUERY_INFORMATION (0x0400)
   */
   h_process := DllCall( "OpenProcess", "uint", 0x10|0x400, "int", false, "uint", p_pid )
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
