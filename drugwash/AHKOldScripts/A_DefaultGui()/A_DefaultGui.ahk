; http://www.autohotkey.com/forum/viewtopic.php?t=26884

A_DefaultGui() {
   if A_Gui !=
      return A_GUI

   Gui, +LastFound
   m := DllCall( "RegisterWindowMessage", Str, "GETDEFGUI")
   OnMessage(m, "A_DefaultGui")
   res := DllCall("SendMessageA", "uint",  WinExist(), "uint", m, "uint", 0, "uint", 0)
   OnMessage(m, "")
   return res
}
