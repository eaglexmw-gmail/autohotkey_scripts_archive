; http://www.autohotkey.com/forum/viewtopic.php?t=41756&start=0&postdays=0&postorder=asc&highlight=
; from:
; http://www.autohotkey.com/forum/topic7378.html
; Shimanov, Metaxal
; IF Shimanov agrees:
; GNU General Public License 3.0 or higher <http://www.gnu.org/licenses/gpl-3.0.txt>

CoordMode, Mouse, Screen

Process, Exist
pid_this := ErrorLevel

hdc_screen := DllCall( "GetDC", "uint", 0 )

hdc_buffer := DllCall( "CreateCompatibleDC", "uint", hdc_screen )
hbm_buffer := DllCall( "CreateCompatibleBitmap", "uint", hdc_screen, "int", A_ScreenWidth, "int", A_ScreenHeight )
DllCall( "SelectObject", "uint", hdc_buffer, "uint", hbm_buffer )

DllCall( "BitBlt", "uint", hdc_buffer, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "uint", hdc_screen, "int", 0, "int", 0, "uint", 0x00CC0020 )

Gui, +AlwaysOnTop -Caption
Gui, Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%

WinGet, hw_canvas, ID, ahk_class AutoHotkeyGUI ahk_pid %pid_this%

hdc_canvas := DllCall( "GetDC", "uint", hw_canvas )

DllCall( "BitBlt", "uint", hdc_canvas, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "uint", hdc_buffer, "int", 0, "int", 0, "uint", 0x00CC0020 )

color_names=0x000000,0xC0C0C0,0x808080,0xFFFFFF,0x800000,0xFF0000,0x800080,0xFF00FF,0x008000,0x00FF00,0x808000,0xFFFF00,0x000080,0x0000FF,0x008080,0x00FFFF
;Black,Silver,Gray,White,Maroon,Red,Purple,Fuchsia,Green,Lime,Olive,Yellow,Navy,Blue,Teal,Aqua
; not exactly because colors are reverse in SetPixel...
StringSplit colors, color_names, `,
color_index := 14
color := colors%color_index%

width := 4
x_last := 0
y_last := 0

SetBatchLines, -1

log := "CoordMode, Mouse, Screen`n"
log .= "SetMouseDelay 2`n"
log .= "Run, MSPaint,,, pid_var`n"
log .= "WinWait ahk_pid %pid_var%,, 3`n"

left_down := false
right_down := false

/*
http://msdn.microsoft.com/en-us/library/ms645616(VS.85).aspx
wParam:
*/
WM_MOUSEMOVE = 0x0200
/*
; numbers
MK_CONTROL  := 0x0008
MK_LBUTTON  := 0x0001
MK_MBUTTON  := 0x0010
MK_RBUTTON  := 0x0002
MK_SHIFT    := 0x0004
MK_XBUTTON1 := 0x0020
MK_XBUTTON2 := 0x0040
*/

OnMessage( WM_MOUSEMOVE, "HandleMessage" )
return

HandleMessage( p_w, p_l )
{
   global hdc_canvas, hdc_buffer, x_last, y_last, width, color, left_down, right_down, log

   x := p_l & 0xFFFF
   y := p_l >> 16

   lbutton := p_w & 0x0001 ; MK_LBUTTON
   rbutton := p_w & 0x0002 ; MK_RBUTTON

   if (lbutton) {
      log .= "`nMouseMove " . x . ", " . y
      if not left_down {
         left_down := true
         log .= "`nMouseClick, Left, ,,,, D"
      } else
         drawLine(x_last, y_last, x, y, color, width)
   } else if (rbutton) {
      log .= "`nMouseMove " . x . ", " . y
      if not right_down {
         right_down := true
         log .= "`nMouseClick, Right, ,,,, D"
      } else
         drawLine(x_last, y_last, x, y, "ERASE", width)
   } else {
      if (left_down) {
         left_down := false
         log .= "`nMouseClick, Left, ,,,, U"
      }
      if (right_down) {
         right_down := false
         log .= "`nMouseClick, Right, ,,,, U"
      }
   }
     
   x_last := x
   y_last := y
}

/*
Bresenham algorithm
From:
http://www.cs.unc.edu/~mcmillan/comp136/Lecture6/Lines.html
*/
drawLine(x0, y0, x1, y1, color_ini=0, width=1)
{
   global hdc_canvas, hdc_buffer
   
   color := color_ini
   erase := false
   if color_ini=ERASE
      erase := true
   
   dx := x1 - x0
   dy := y1 - y0
   stepx := 0
   stepy := 0
   if (dx < 0) {
      dx := -dx
      stepx := -1
   } else
      stepx := 1
   if (dy < 0) {
      dy := -dy
      stepy := -1
   } else
      stepy := 1
   
   Loop %width%
   {
      x := x0+A_Index-1
      y := y0
      if erase
         color := DllCall( "GetPixel", "uint", hdc_buffer, "int", x, "int", y )
      DllCall( "SetPixel", "uint", hdc_canvas, "int", x, "int", y, "uint", color )
   }
   if (dx > dy) {
      fraction := dy - (dx >> 1)
      Loop
      {
         if (x0 = x1)
            break
         if (fraction >= 0) {
            y0 += stepy
            fraction -= dx
         }
         x0 += stepx
         fraction += dy
         Loop %width%
         {
            x := x0+A_Index-1
            y := y0
            if erase
               color := DllCall( "GetPixel", "uint", hdc_buffer, "int", x, "int", y )
            DllCall( "SetPixel", "uint", hdc_canvas, "int", x, "int", y, "uint", color )
         }
      }
   } else {
      fraction = dx - (dy >> 1)
      Loop
      {
         if (y0 = y1)
            break
         if (fraction >= 0) {
            x0 += stepx
            fraction -= dy
         }
         y0 += stepy
         fraction += dx
         Loop %width%
         {
            x := x0+A_Index-1
            y := y0
            if erase
               color := DllCall( "GetPixel", "uint", hdc_buffer, "int", x, "int", y )
            DllCall( "SetPixel", "uint", hdc_canvas, "int", x, "int", y, "uint", color )
         }
      }
   }

}

F1::
   color_index++
   if(color_index > 16)
      color_index := 1
   color := colors%color_index%
return
   

F2::
   DllCall( "BitBlt", "uint", hdc_canvas, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "uint", hdc_buffer, "int", 0, "int", 0, "uint", 0x00CC0020 )
return

F3::
   if width > 1
      width--
return

F4::
   if width < 20
      width++
return

Escape::
FileDelete, painting.ahk
FileAppend, %log%, painting.ahk
ExitApp
