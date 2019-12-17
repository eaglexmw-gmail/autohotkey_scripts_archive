#Include GDIPlusHelper.ahk
; see: http://www.autohotkey.com/forum/viewtopic.php?t=11860 for orignal

OnExit, handle_exit

main: 
  FileCreateDir, screens
  FileCreateDir, thumbs

  WinGet, hw_frame, id, "Program Manager"   ; Desktop ?
  hdc_frame := DllCall( "GetDC", "uint",  hw_frame )
  hdc_frame_full := DllCall( "GetDC", "uint",  hw_frame )
  counter:=0	; thumbnails
  counter_f:=0	; fullscreens
  thumb_w:= 200 
  thumb_h:= ceil( thumb_w * A_ScreenHeight / A_ScreenWidth ) ; keep screenratio
  use_antialize := 1
  

  ; buffer
  hdc_buffer := DllCall( "gdi32.dll\CreateCompatibleDC"     , "uint", hdc_frame )
  hbm_buffer := DllCall( "gdi32.dll\CreateCompatibleBitmap" , "uint", hdc_frame, "int", thumb_w, "int", thumb_h )
  r          := DllCall( "gdi32.dll\SelectObject"           , "uint", hdc_buffer, "uint", hbm_buffer )

  hdc_buffer_full := DllCall( "gdi32.dll\CreateCompatibleDC"     , "uint", hdc_frame_full )
  hbm_buffer_full := DllCall( "gdi32.dll\CreateCompatibleBitmap" , "uint", hdc_frame_full, "int", A_ScreenWidth, "int", A_ScreenHeight )
  r_full          := DllCall( "gdi32.dll\SelectObject"           , "uint", hdc_buffer_full, "uint", hbm_buffer_full )

  ; comment this line for speed but less quality
  if use_antialize = 1
    DllCall( "gdi32.dll\SetStretchBltMode", "uint", hdc_buffer, "int", 4 )  ; Halftone better quality with stretch

return

;#c::
^F12::
SaveImage:
  counter := counter +1
  FormatTime, myTime, , yyyyMMdd_hhmmss
  fileNameDestP = thumbs\T_%myTime%_%counter%_%thumb_w%x%thumb_h%.png

  If (GDIplus_Start() != 0)
     Goto GDIplusError

  ; Copy BMP from DC
  DllCall( "gdi32.dll\StretchBlt" 
          , "uint", hdc_buffer, "int", 0, "int", 0, "int", thumb_w, "int", thumb_h
          , "uint", hdc_frame,  "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "uint", 0x00CC0020 )

  DllCall( "GDIplus\GdipCreateBitmapFromHBITMAP", uint, hbm_buffer, uint, 0, uintp, bitmap )

  ; Save to PNG

  If (GDIplus_GetEncoderCLSID(pngEncoder, #GDIplus_mimeType_png) != 0)
     Goto GDIplusError

  noParams = NONE
  If (GDIplus_SaveImage(bitmap, fileNameDestP, pngEncoder, noParams) != 0)
     Goto GDIplusError
Return 

;#v::
F12::
SaveImage_Full:
  counter_f := counter_f +1
  FormatTime, myTime, , yyyyMMdd_hhmmss
  fileNameDestP = screens\S_%myTime%_%counter_f%_%A_ScreenWidth%x%A_ScreenHeight%.png

  If (GDIplus_Start() != 0)
     Goto GDIplusError

  ; Copy BMP from DC
  DllCall( "gdi32.dll\BitBlt" 
          , "uint", hdc_buffer_full, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight
          , "uint", hdc_frame_full,  "int", 0, "int", 0, "uint", 0x00CC0020 )

  DllCall( "GDIplus\GdipCreateBitmapFromHBITMAP", uint, hbm_buffer_full, uint, 0, uintp, bitmap )

  ; Save to PNG

  If (GDIplus_GetEncoderCLSID(pngEncoder, #GDIplus_mimeType_png) != 0)
     Goto GDIplusError

  noParams = NONE
  If (GDIplus_SaveImage(bitmap, fileNameDestP, pngEncoder, noParams) != 0)
     Goto GDIplusError
Return 

GDIplusError:
   If (#GDIplus_lastError != "")
      MsgBox 16, GDIplus Test, Error in %#GDIplus_lastError%
   GDIplus_Stop()
Return

;#x::
!F12::
handle_exit:
   DllCall( "gdi32.dll\DeleteObject", "uint", hbm_buffer )
   DllCall( "gdi32.dll\DeleteDC"    , "uint", hdc_frame )
   DllCall( "gdi32.dll\DeleteDC"    , "uint", hdc_buffer )
ExitApp
