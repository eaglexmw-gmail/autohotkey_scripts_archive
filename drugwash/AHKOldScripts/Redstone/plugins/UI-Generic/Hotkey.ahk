#InstallKeybdHook

Gui( p_command, p_param2="", p_param3="", p_param4="" )
{
   ; -- identify window number --
   StringGetPos, ix, p_command, :
   if ( ix = -1 )
      gui_num = 1
   else
   {
      StringLeft, gui_num, p_command, ix
      StringTrimLeft, p_command, p_command, ix+1
   }
   
   if ( p_command = "Add" )
   {
      if ( p_param2 = "Hotkey" )
      {
         ctrl_num := QueryComponent( gui_num ":Hotkey_Control" )
         
         if ( ! ctrl_num )
            RegisterComponent( gui_num ":Hotkey_Control" )

         hw_script := FindWindowEx( 0, 0, "AutoHotkeyGUI", a_ScriptName )
         
         loop,
         {
            ctrl_num++

            if ( ! FindWindow( hw_script, "Edit", ctrl_num ) )
               break
         }
         
         UpdateComponent( gui_num ":Hotkey_Control", ctrl_num )
         
         ; -- identify associated g(oSubroutine) --
         StringGetPos, ix, p_param3, %a_Space%g
         if ( ix = -1 )
            StringGetPos, ix, p_param3, `,g
            
         if ( ix != -1 )
         {
            pName := &p_param3+( ix+2-1 )
            subName=
            
            loop,
            {
               temp := *( pName+a_Index )
               
               if ( temp = 0 or temp = 32 or temp = 44 )
                  break
                  
               subName := subName Chr( temp )  
            }
         }

         ; -- identify associated v(ariable) --
         StringGetPos, ix, p_param3, %a_Space%v
         if ( ix = -1 )
            StringGetPos, ix, p_param3, `,v
            
         if ( ix != -1 )
         {
            pName := &p_param3+( ix+2-1 )
            varName=
            
            loop,
            {
               temp := *( pName+a_Index )
               
               if ( temp = 0 or temp = 32 or temp = 44 )
                  break
                  
               varName := varName Chr( temp )  
            }
         }

         if p_param4=
            Gui, %gui_num%:Add, Edit, %p_param3% -VScroll, None
         else
            Gui, %gui_num%:Add, Edit, %p_param3% -VScroll, %p_param4%
         
         hw_control := FindWindow( hw_script, "Edit", QueryComponent( gui_num ":Hotkey_Control" ) )
         
         RegisterControl( hw_control, "Hotkey_Control", subName, varName )
         RegisterComponent( varName "@name" )
         
         RegisterComponent( "WM_CONTEXTMENU", 0x7B )
         RegisterComponent( "WM_KEYDOWN", 0x100 )
         RegisterComponent( "WM_SYSKEYDOWN", 0x104 )

         OnMessage( QueryComponent( "WM_CONTEXTMENU" ), "HandleMessage" )
         OnMessage( QueryComponent( "WM_KEYDOWN" ), "HandleMessage" )
         OnMessage( QueryComponent( "WM_SYSKEYDOWN" ), "HandleMessage" )
      }
   }
}

HandleMessage( p_w, p_l, p_m, p_hw )
{
   if ( QueryControl( p_hw ) = "Hotkey_Control" )
   {
      if ( p_m = QueryComponent( "WM_CONTEXTMENU" ) )
         return, 0
      else if ( p_m = QueryComponent( "WM_KEYDOWN" )
            or p_m = QueryComponent( "WM_SYSKEYDOWN" ) )
      {
         VarSetCapacity( key_name, 100 )
      
         VarSetCapacity( kb_state, 256, 0 )
         DllCall( "GetKeyboardState", "uint", &kb_state )

         old_FormatInteger := a_FormatInteger
         SetFormat, Integer, hex
         
         kb_state_text=
         loop, 256
            if ( *( &kb_state+a_Index ) & 0x80 )
               kb_state_text := kb_state_text "|" a_Index
         
         SetFormat, Integer, %old_FormatInteger%
         
         extended := p_l & 0x1000000
         if ( extended )
            kb_state_text = %kb_state_text%`nextended

         if ( *( &kb_state+0x14 ) & 0x1 )
            kb_state_text = %kb_state_text%`ncaps lock
         
         if ( *( &kb_state+0x90 ) & 0x1 )
            kb_state_text = %kb_state_text%`nnum lock
            
         if ( *( &kb_state+0x91 ) & 0x1 )
            kb_state_text = %kb_state_text%`nscroll lock

;         CoordMode, ToolTip, relative
 ;        ToolTip, %kb_state_text% , 320, 0, 6

         hk_name=
         hkc_var=
         hkc_var_name=
         
         ; -- identify modifiers --
         if ( *( &kb_state+0x5B ) & 0x80 )
         {
            hk_name = +Left Windows 
            hkc_var = <#
            hkc_var_name = +LWin
            
            Hotkey, LWin Up, hk_LWin_Up, on
         }
         else if ( *( &kb_state+0x5C ) & 0x80 )
         {
            hk_name = +Right Windows
            hkc_var = >#
            hkc_var_name = +RWin
            
            Hotkey, RWin Up, hk_RWin_Up, on
         }
         
         if ( *( &kb_state+0x12 ) & 0x80 )
         {
            if ( *( &kb_state+0xA4 ) & 0x80 )
            {
               hk_name = %hk_name%+Left Alt
               hkc_var = %hkc_var%<!
               hkc_var_name = %hkc_var_name%+LAlt
            }
            else if ( *( &kb_state+0xA5 ) & 0x80 )
            {
               hk_name = %hk_name%+Right Alt
               hkc_var = %hkc_var%>!
               hkc_var_name = %hkc_var_name%+RAlt
            }
            else
            {
               hk_name = %hk_name%+Alt
               hkc_var = %hkc_var%!
               hkc_var_name = %hkc_var_name%+Alt
            }
         }
         
         if ( ( *( &kb_state+0x11 ) & 0x80 )
               and GetKeyState( "Control" ,"P" ) )
         {
            if ( *( &kb_state+0xA2 ) & 0x80 )
            {
               hk_name = %hk_name%+Left Ctrl
               hkc_var = %hkc_var%<^
               hkc_var_name = %hkc_var_name%+LControl
            }
            else if ( *( &kb_state+0xA3 ) & 0x80 )
            {
               hk_name = %hk_name%+Right Ctrl
               hkc_var = %hkc_var%>^
               hkc_var_name = %hkc_var_name%+RControl
            }
            else
            {
               hk_name = %hk_name%+Ctrl
               hkc_var = %hkc_var%^
               hkc_var_name := %hkc_var_name% "+Control"
            }
         }

         if ( *( &kb_state+0x10 ) & 0x80 )
         {
            if ( *( &kb_state+0xA0 ) & 0x80 )
            {
               hk_name = %hk_name%+Left Shift
               hkc_var = %hkc_var%<+
               hkc_var_name = %hkc_var_name%+LShift
            }
            else if ( *( &kb_state+0xA1 ) & 0x80 )
            {
               hk_name = %hk_name%+Right Shift
               hkc_var = %hkc_var%>+
               hkc_var_name = %hkc_var_name%+RShift
            }
            else
            {
               hk_name = %hk_name%+Left Shift
               hkc_var = %hkc_var%+
               hkc_var_name = %hkc_var_name%+Shift
            }
         }

         ; -- identify key --
         if ( *( &kb_state+0x3 ) & 0x80 )
         {
            hk_name = %hk_name%+Break
            hkc_var = %hkc_var%CtrlBreak
            hkc_var_name = %hkc_var_name%+CtrlBreak 
         }
         else if ( *( &kb_state+0x90 ) & 0x80 )
         {
            hk_name = %hk_name%+Num Lock
            hkc_var = %hkc_var%NumLock
            hkc_var_name = %hkc_var_name%+NumLock 
         }
         else if ( *( &kb_state+0x1B ) & 0x80 )
         {
            hk_name = %hk_name%+Esc
            hkc_var = %hkc_var%Escape
            hkc_var_name = %hkc_var_name%+Escape 
         }
         else if ( *( &kb_state+0x14 ) & 0x80 )
         {
            hk_name = %hk_name%+Caps Lock
            hkc_var = %hkc_var%CapsLock
            hkc_var_name = %hkc_var_name%+CapsLock 
         }
         else if ( *( &kb_state+0x5D ) & 0x80 )
         {
            hk_name = %hk_name%+Application
            hkc_var = %hkc_var%AppsKey
            hkc_var_name = %hkc_var_name%+AppsKey 
         }
         else if ( *( &kb_state+0x91 ) & 0x80 )
         {
            hk_name = %hk_name%+Scroll Lock
            hkc_var = %hkc_var%ScrollLock
            hkc_var_name = %hkc_var_name%+ScrollLock 
         }
         else if ( extended and *( &kb_state+0x21 ) & 0x80 )
         {
            hk_name = %hk_name%+Page Up
            hkc_var = %hkc_var%PgUp
            hkc_var_name = %hkc_var_name%+PgUp 
         }
         else if ( extended and *( &kb_state+0x22 ) & 0x80 )
         {
            hk_name = %hk_name%+Page Down
            hkc_var = %hkc_var%PgDn
            hkc_var_name = %hkc_var_name%+PgDn 
         }
         else if ( *( &kb_state+0x6F ) & 0x80 )
         {
            hk_name = %hk_name%+Num /
            hkc_var = %hkc_var%NumpadDiv
            hkc_var_name = %hkc_var_name%+NumpadDiv
         }
         else if ( *( &kb_state+0x6A ) & 0x80 )
         {
            hk_name = %hk_name%+Num *
            hkc_var = %hkc_var%NumpadMult
            hkc_var_name = %hkc_var_name%+NumpadMult
         }
         else if ( *( &kb_state+0x6B ) & 0x80 )
         {
            hk_name = %hk_name%+Num +
            hkc_var = %hkc_var%NumpadAdd
            hkc_var_name = %hkc_var_name%+NumpadAdd
         }
         else if ( *( &kb_state+0x6D ) & 0x80 )
         {
            hk_name = %hk_name%+Num -
            hkc_var = %hkc_var%NumpadSub
            hkc_var_name = %hkc_var_name%+NumpadSub
         }
         else if ( extended and *( &kb_state+0xD ) & 0x80 )
         {
            hk_name = %hk_name%+Num Enter
            hkc_var = %hkc_var%NumpadEnter
            hkc_var_name = %hkc_var_name%+NumpadEnter
         }
         else if ( ! extended and *( &kb_state+0x2E ) & 0x80 )
         {
            hk_name = %hk_name%+Num Del
            hkc_var = %hkc_var%NumpadDel
            hkc_var_name = %hkc_var_name%+NumpadDel
         }
         else if ( *( &kb_state+0x6E ) & 0x80 )
         {
            hk_name = %hk_name%+Num Dot
            hkc_var = %hkc_var%NumpadDot
            hkc_var_name = %hkc_var_name%+NumpadDot
         }
         else if ( ! extended and *( &kb_state+0x2D ) & 0x80 )
         {
            hk_name = %hk_name%+Num Ins
            hkc_var = %hkc_var%NumpadIns
            hkc_var_name = %hkc_var_name%+NumpadIns
         }
         else if ( *( &kb_state+0x60 ) & 0x80 )
         {
            hk_name = %hk_name%+Num 0
            hkc_var = %hkc_var%Numpad0
            hkc_var_name = %hkc_var_name%+Numpad0
         }
         else if ( ! extended and *( &kb_state+0x23 ) & 0x80 )
         {
            hk_name = %hk_name%+Num End
            hkc_var = %hkc_var%NumpadEnd
            hkc_var_name = %hkc_var_name%+NumpadEnd
         }
         else if ( *( &kb_state+0x61 ) & 0x80 )
         {
            hk_name = %hk_name%+Num 1
            hkc_var = %hkc_var%Numpad1
            hkc_var_name = %hkc_var_name%+Numpad1
         }
         else if ( ! extended and *( &kb_state+0x28 ) & 0x80 )
         {
            hk_name = %hk_name%+Num Down
            hkc_var = %hkc_var%NumpadDown
            hkc_var_name = %hkc_var_name%+NumpadDown
         }
         else if ( *( &kb_state+0x62 ) & 0x80 )
         {
            hk_name = %hk_name%+Num 2
            hkc_var = %hkc_var%Numpad2
            hkc_var_name = %hkc_var_name%+Numpad2
         }
         else if ( *( &kb_state+0x22 ) & 0x80 )
         {
            hk_name = %hk_name%+Num Page Down
            hkc_var = %hkc_var%NumpadPgDn
            hkc_var_name = %hkc_var_name%+NumpadPgDn
         }
         else if ( *( &kb_state+0x63 ) & 0x80 )
         {
            hk_name = %hk_name%+Num 3
            hkc_var = %hkc_var%Numpad3
            hkc_var_name = %hkc_var_name%+Numpad3
         }
         else if ( ! extended and *( &kb_state+0x25 ) & 0x80 )
         {
            hk_name = %hk_name%+Num Left
            hkc_var = %hkc_var%NumpadLeft
            hkc_var_name = %hkc_var_name%+NumpadLeft
         }
         else if ( *( &kb_state+0x64 ) & 0x80 )
         {
            hk_name = %hk_name%+Num 4
            hkc_var = %hkc_var%Numpad4
            hkc_var_name = %hkc_var_name%+Numpad4
         }
         else if ( *( &kb_state+0xC ) & 0x80 )
         {
            hk_name = %hk_name%+Num Clear
            hkc_var = %hkc_var%NumpadClear
            hkc_var_name = %hkc_var_name%+NumpadClear
         }
         else if ( *( &kb_state+0x65 ) & 0x80 )
         {
            hk_name = %hk_name%+Num 5
            hkc_var = %hkc_var%Numpad5
            hkc_var_name = %hkc_var_name%+Numpad5
         }
         else if ( ! extended and *( &kb_state+0x27 ) & 0x80 )
         {
            hk_name = %hk_name%+Num Right
            hkc_var = %hkc_var%NumpadRight
            hkc_var_name = %hkc_var_name%+NumpadRight
         }
         else if ( *( &kb_state+0x66 ) & 0x80 )
         {
            hk_name = %hk_name%+Num 6
            hkc_var = %hkc_var%Numpad6
            hkc_var_name = %hkc_var_name%+Numpad6
         }
         else if ( ! extended and *( &kb_state+0x24 ) & 0x80 )
         {
            hk_name = %hk_name%+Num Home
            hkc_var = %hkc_var%NumpadHome
            hkc_var_name = %hkc_var_name%+NumpadHome
         }
         else if ( *( &kb_state+0x67 ) & 0x80 )
         {
            hk_name = %hk_name%+Num 7
            hkc_var = %hkc_var%Numpad7
            hkc_var_name = %hkc_var_name%+Numpad7
         }
         else if ( ! extended and *( &kb_state+0x26 ) & 0x80 )
         {
            hk_name = %hk_name%+Num Up
            hkc_var = %hkc_var%NumpadUp
            hkc_var_name = %hkc_var_name%+NumpadUp
         }
         else if ( *( &kb_state+0x68 ) & 0x80 )
         {
            hk_name = %hk_name%+Num 8
            hkc_var = %hkc_var%Numpad8
            hkc_var_name = %hkc_var_name%+Numpad8
         }
         else if ( *( &kb_state+0x21 ) & 0x80 )
         {
            hk_name = %hk_name%+Num Page Up
            hkc_var = %hkc_var%NumpadPgUp
            hkc_var_name = %hkc_var_name%+NumpadPgUp
         }
         else if ( *( &kb_state+0x69 ) & 0x80 )
         {
            hk_name = %hk_name%+Num 9
            hkc_var = %hkc_var%Numpad9
            hkc_var_name = %hkc_var_name%+Numpad9
         }
         else if ( *( &kb_state+0xA6 ) & 0x80 )
         {
            hk_name = %hk_name%+Browser Back
            hkc_var = %hkc_var%Browser_Back
            hkc_var_name = %hkc_var_name%+Browser_Back
         }
         else if ( *( &kb_state+0xA7 ) & 0x80 )
         {
            hk_name = %hk_name%+Browser Forward
            hkc_var = %hkc_var%Browser_Forward
            hkc_var_name = %hkc_var_name%+Browser_Forward
         }
         else
         {
            sc := ( p_l >> 16 ) & 0xFF
         
            if ( ! ( extended and ( sc = 0x5B or sc = 0x5C ) ) )
            {
               old_FormatInteger := a_FormatInteger
               SetFormat, Integer, hex
         
               vk := DllCall( "MapVirtualKey", "uint", sc, "uint", 1 )
               
               SetFormat, Integer, %old_FormatInteger%
               
               if vk not in 0x12,0xA4,0xA5,0x11,0xA2,0xA3,0x10,0xA0,0xA1
               {
                  DllCall( "GetKeyNameText"
                           , "int", p_l
                           , "str", key_name
                           , "int", 100 )
                           
                  hk_name = %hk_name%+%key_name%
                  hkc_var = %hkc_var%%key_name%
                  hkc_var_name = %hkc_var_name%+%key_name%
               }
            }
         }
         
         StringTrimLeft, hk_name, hk_name, 1
         StringTrimLeft, hkc_var_name, hkc_var_name, 1
         
         temp := QueryControl( p_hw, "var" )

         GuiControl,, %temp%, %hk_name%
         
         %temp% := hkc_var
         
         UpdateComponent( temp "@name", hkc_var_name )

         if ( ! RegisterComponent( "timer_HandleMessage#sub", QueryControl( p_hw, "sub" ) ) )
            UpdateComponent( "timer_HandleMessage#sub", QueryControl( p_hw, "sub" ) )
            
         SetTimer, timer_HandleMessage, 10

         return, 0   
      }
   }
   return
   
   timer_HandleMessage:
      SetTimer, timer_HandleMessage, off
      
      sub := QueryComponent( "timer_HandleMessage#sub" )
      
      Gosub, %sub%
   return

   hk_LWin_Up:
      Hotkey, LWin Up, off
      Send, {Esc}
   return
   
   hk_RWin_Up:
      Hotkey, RWin Up, off
      Send, {Esc}
   return
}

RegisterComponent( p_id, p_data="", p_command="" )
{
   static   components
   
   if ( p_command = "query" )
   {
      loop, Parse, components, |
      {
         ix := InStr( a_LoopField, "," )
         
         StringLeft, id, a_LoopField, ix-1
      
         if ( id = p_id )
            return, a_LoopField
      }
      
      return, false
   }
   else if ( p_command = "update" )
   {
      ix_1 := InStr( components, "|" p_id )
      ix_2 := InStr( components, "|", false, ix_1+1 )
      if ( ! ix_2 )
         ix_2 := StrLen( components )+1
         
      StringMid, prefix, components, 1, ix_1-1
      StringMid, suffix, components, ix_2, StrLen( components )-ix_2+1
      
      components = %prefix%|%p_id%,%p_data%%suffix%
      
      return, true 
   }
   else if ( ! QueryComponent( p_id ) )
   {
      components = %components%|%p_id%,%p_data%
      
      return, true
   }
   
   return, false
}

UpdateComponent( p_id, p_data="" )
{
   RegisterComponent( p_id, p_data, "update" )
   
   QueryComponent( 0 )
}

QueryComponent( p_id )
{
   static   id, data
   
   if ( p_id = 0 )
      id = 0
   else if ( id != p_id )
   {
      component := RegisterComponent( p_id, 0, "query" )
      
      if ( ! component )
         return, false
      
      id := p_id

      ix_1 := InStr( component, "," )
      
      StringMid, data, component, ix_1+1, StrLen( component )-ix_1
   }
   
   return, data
}

RegisterControl( p_hw, p_type, p_sub="", p_var="", p_command="" )
{
   return, RegisterComponent( p_hw, p_type "," p_sub "," p_var, p_command )
}

QueryControl( p_hw, p_field="" )
{
   static   hw, type, sub, var
   
   if ( hw != p_hw )
   {
      control := RegisterControl( p_hw, 0, 0, 0, "query" )
      
      if ( ! control )
         return, false
      
      hw := p_hw

      ix_1 := InStr( control, "," )
      ix_2 := InStr( control, ",", false, ix_1+1 )
      ix_3 := InStr( control, ",", false, ix_2+1 )
      
      StringMid, type, control, ix_1+1, ix_2-ix_1-1
      StringMid, sub, control, ix_2+1, ix_3-ix_2-1
      StringMid, var, control, ix_3+1, StrLen( control )-ix_3
   }
   
   if ( p_field = "type" or p_field = "" )
      return, type
   else if ( p_field = "sub" )   
      return, sub
   else if ( p_field = "var" )
      return, var
}

FindWindow( p_hw_parent, p_class, p_num=1, p_title=0 )
{
   hw_child = 0
   loop, %p_num%
      hw_child := FindWindowEx( p_hw_parent, hw_child, p_class, p_title )

   return, hw_child
}

FindWindowEx( p_hw_parent, p_hw_child, p_class, p_title=0 )
{
   if ( p_title = 0 )
      type_title = uint
   else
      type_title = str

   return, DllCall( "FindWindowEx"
                  , "uint", p_hw_parent
                  , "uint", p_hw_child
                  , "str", p_class
                  , type_title, p_title )
}
