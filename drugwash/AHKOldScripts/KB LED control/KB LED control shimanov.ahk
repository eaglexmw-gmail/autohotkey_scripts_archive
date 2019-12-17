; replace with "device instance id" from details page of keyboard device properties
;device_instance_id = ACPI\PNP0303\4&61F3B4B&0
device_instance_id = ACPI\PNP0303\4&61F3B4B&0

loop, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Control\DeviceClasses, 1, 1
{
   if ( A_LoopRegName = "DeviceInstance" )
   {
      RegRead, value
      
      if ( InStr( value, device_instance_id, false ) )
      {
         StringGetPos, ix, A_LoopRegSubKey, \##?#, R
         StringTrimLeft, device, A_LoopRegSubKey, ix+5
         device = \\.\%device%

         break
      }
   }
}

if device =
{
   MsgBox, %device_instance_id% not found!
   ExitApp
}

h_device := DllCall( "CreateFile"
                  , "str", device
                  , "uint", 0
                  , "uint", 1                                    ; FILE_SHARE_READ
                  , "uint", 0
                  , "uint", 3                                    ; OPEN_EXISTING
                  , "uint", 0
                  , "uint", 0 )
MsgBox, [CreateFile] %A_Index% EL = %ErrorLevel%, LE = %A_LastError%, h_device = %h_device%

VarSetCapacity( output_actual, 4, 0 )

; -- input bit pattern --
; bit 0   = scroll lock
; bit 1   = num lock
; bit 2   = caps lock
input_size = 4
VarSetCapacity( input, input_size, 0 )

; -- EncodeInteger( 7, 1, &input, 2 ) --
input := Chr(1) Chr(1) Chr(7)
input := Chr(1)
input=
success := DllCall( "DeviceIoControl"
                  , "uint", h_device
                  , "uint", CTL_CODE( 0x0000000b                     ; FILE_DEVICE_KEYBOARD
                                 , 2
                                 , 0                           ; METHOD_BUFFERED
                                 , 0   )                        ; FILE_ANY_ACCESS
                  , "uint", &input
                  , "uint", input_size
                  , "uint", 0
                  , "uint", 0
                  , "uint", &output_actual
                  , "uint", 0 )
MsgBox, [DeviceIoControl] EL = %ErrorLevel%, LE = %A_LastError%, success = %success%

VarSetCapacity( input, input_size, 0 )
success := DllCall( "DeviceIoControl"
                  , "uint", h_device
                  , "uint", CTL_CODE( 0x0000000b                     ; FILE_DEVICE_KEYBOARD
                                 , 2
                                 , 0                           ; METHOD_BUFFERED
                                 , 0   )                        ; FILE_ANY_ACCESS
                  , "uint", &input
                  , "uint", input_size
                  , "uint", 0
                  , "uint", 0
                  , "uint", &output_actual
                  , "uint", 0 )
return

CTL_CODE( p_device_type, p_function, p_method, p_access )
{
   return, ( p_device_type << 16 ) | ( p_access << 14 ) | ( p_function << 2 ) | p_method
}
