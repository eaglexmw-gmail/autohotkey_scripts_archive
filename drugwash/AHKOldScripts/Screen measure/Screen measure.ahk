; http://www.autohotkey.com/forum/viewtopic.php?t=45336


lx := A_ScreenWidth/2-75
Gui, +AlwaysOnTop +ToolWindow -caption
Gui +LastFound
WinSet, Transparent, 200
gui, font, s12 w600
Gui, Show,NoActivate W150 H50 X%lx% Y0 ,
color := 0x0000FF
width := 4
hdc_screen := DllCall( "GetDC", "uint", 0 )
hdc_buffer := DllCall( "CreateCompatibleDC", "uint", hdc_screen )
hdc_canvas := DllCall( "GetDC", "uint", 0)

return



f4:: ;?????????? ,start to measure width and height.
CoordMode, Mouse, Screen
MouseGetPos,,, win_id2, ctrl_id2
WinGetTitle, win_title, ahk_id %win_id2%
Loop
{
  Sleep,100
  KeyIsDown := GetKeyState("LButton")
  if (KeyIsDown = 1)
  {
    MouseGetPos, xpos, ypos
    px = %xpos%
    py = %ypos%
    Sleep,10
    Loop
    {
      Sleep,100
      KeyIsDown := GetKeyState("LButton")
      if (KeyIsDown = 1)
      {
      drawline(px, py, px1, py, color, width)
      drawline(px1, py, px1, py1, color, width)
      drawline(px, py1, px1, py1, color, width)
      drawline(px, py, px, py1, color, width)
      gui,2:destroy

        Exit
      }
      MouseGetPos, px1, py1
     Sleep,10
     MouseGetPos, px2, py2
      pw = % px1 - px
      ph = % py1 - py
      
     gui,2:color,00FF00
      Gui, 2:+LastFound
     WinSet, Transparent,150
     Gui, 2:-Caption
     Gui, 2:Show, x%px% y%py% h%ph% w%pw% 
     if px2!=%px1%
     {   
     Gui, Add, Text, x40 y10 r4 cMaroon,W:%pw% px`r`nH:%ph% px
    
     }
    }
  }
}
return

F2:: ;??????????????.reset width and height ,clear screen
   px=
   py=
   px1=
   py1=
   px2=
   py2=
   WinHide,%win_title%
   WinShow,%win_title%
   reload
return

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

Escape::
ExitApp
