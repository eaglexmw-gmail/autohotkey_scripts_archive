;v1.20090914 -- expose.ahk - Thumbnails of windows over the working area, active thumbnails when no zoom,                                            ;zoomed window means redraw only zoomed window
; new minimized windows

OnExit handle_exit
#SingleInstance Force
#NoEnv
SetBatchLines -1
SetWinDelay 0               ; larger values also fail under heavy load, changing windows
Process Priority,,Above Normal
CoordMode Mouse, Relative

Main:
  Gosub, Read_Keymapping
  Gosub, Read_Config
  Gosub, Detect_Screensize
  Gosub, Create_Gui
  Gosub, Create_Buffers
  ; wait for key/mouse
Return

Read_Keymapping:
   Hotkey, #TAB,      Window_Choose
   Hotkey, ^q,     Window_Choose
   ;Hotkey, ^+q,   Current_App_Choose
   Hotkey ^!q,   Window_Choose_No_Minimize
   ;Hotkey ^!+q,   Current_App_No_Minimize

   Hotkey, IfWinActive, »Expose«
      Hotkey, #TAB    ,      Window_Activate
      Hotkey, MButton ,     Window_Activate
      Hotkey, LButton ,      Window_Activate
      HotKey, RButton ,     Window_Preview
      Hotkey, Esc     ,        hide_gui
      Hotkey, WheelUp ,    Handle_Zoom
      Hotkey, WheelDown, Handle_Zoom
      Hotkey, +MButton ,   handle_exit ; panik-key
      Hotkey, #F12 ,          Debug_Info
Return

Read_Config:
   min_w                        = 110  ; min width of windows to be shown
   min_h                        = 110  ; min height of windows to be shown (hides taskbar etc)
   scale_thumb_space    = 1    ; scale thumbnails to best fit to box?
   live_redraw                 = 1   ; 1/0 = Yes/No
   time_gap                   = 100   ; ms, time left for others after each thumbnail draw
   thumb_border             = 1   ; 1 for gap between thumbnail  s
   animate_in_delay       = 5
   animate_in_steps       = 5
   animate_out_delay     = 5
   animate_out_steps     = 5
   show_taskbar             = 1
   main_monitor   = 1 ; or 2 or 3 if you like
   ;fade_in_steps           = 5
   ;fade_in_delay           = 5
   ;fade_out_steps         = 5
   ;fade_out_delay         = 50
   quality_low                = 3 ; allowed: 1 (terrible) , 3 (accepatable) 4 (good = slow)
   quality_high               = 4 ; allowed: 1 (terrible) , 3 (accepatable) 4 (good = slow)
   BackGroundColor       = 004E98
   count := 0
   counter := 0
   zoom_preview = 0.8
   zoom_maximized = 1 ; // 1=on ; 0=off ; allow to zoom more than real size
   do_zoom := 0  ; // off at first
   old_ids_count =  -1 ;
   show_minimized := 1 ;
   minimized_counter := 0 ;
Return

Debug_Info:
ListLines

Window_Hidden() {
   global
   Return w < min_w or h < min_h or title ="»Expose«" or title =""
}

Handle_Zoom:
   If (do_zoom = 0 and ( A_ThisHotKey = "WheelUp" or A_ThisHotKey = "^+Up" ))
   {
      zoom_preview = 0 ; start at 100% to make it look seemless
      gosub Window_Preview ; activate Preview by Scrolling , eg. zooming
   }

   If (do_zoom = 1 and zoom_preview =0 and ( A_ThisHotKey = "WheelDown" or A_ThisHotKey = "^+Down" ))
      gosub Window_Preview ; deactivate zoom


   If (zoom_preview < 4 and ( A_ThisHotKey = "WheelUp" or A_ThisHotKey = "^+Up" ))
      zoom_preview += 0.05         ; sqrt(sqrt(2))
   If (zoom_preview >  0 and ( A_ThisHotKey = "WheelDown" or A_ThisHotKey = "^+Down" ))
      zoom_preview -= 0.05
   TrayTip,,% "Zoom = " Round(100*(1+zoom_preview)) "%"
Return

In(x,a,b) {                      ; closest number to x in [a,b]
   IfLess x,%a%, Return a
   IfLess b,%x%, Return b
   Return x
}


Detect_ScreenSize:

    ; Copy bounds of all monitors to an array.
    SysGet, mc, MonitorCount
    Loop, %mc%
        SysGet, mon%A_Index%, MonitorWorkArea, %A_Index%
   
  Th=0
  Tw=0
  Ty=0
  Tx=0

 
  if show_taskbar and mc = 1
  {   
   WinGetPos,Tx,Ty,Tw,Th,ahk_class Shell_TrayWnd,,,
  }
   ; Default
   WorkArea_Top    :=      ( Tw > Th  and  Tx = 0  and  Ty = 0) * Th
   WorkArea_Left   :=      ( Tw < Th  and  Tx = 0  and  Ty = 0) * Tw
   WorkArea_Height := A_ScreenHeight - ( Tw > Th  ) * Th
   WorkArea_Width  := A_ScreenWidth  - ( Tw < Th  ) * Tw
 
  if show_taskbar and mc > 1
  {   
    md := main_monitor ; // change this where you want to show your thumbnails Number of Monitor
    ; fix for dual monitor
    WorkArea_Top    := mon%md%Top
    WorkArea_Left   := mon%md%Left
    WorkArea_Width  := mon%md%Right - mon%md%Left
    WorkArea_Height := mon%md%Bottom - mon%md%Top
  }

 
 ; TrayTip,,% "Taskbar = " Tx " " Ty " " Tw " " Th " " A_ScreenWidth " " A_ScreenHeight " mc: " mc
  ; if Ty > A_ScreenHeight then Taskbar is "below" mon1
  ; if Ty < 0 Tastbar is above mon1
Return

Create_Gui:
  Gui +AlwaysOnTop -Caption  +Toolwindow +Owner +LastFound
  ;Gui Color, %BackGroundColor%
 
  ; create blank screens for non-main monitor
  ; SysGet, mc, MonitorCount
  ;   Loop, %mc%
  ;  {   
  ;    SysGet, mon%A_Index%, MonitorWorkArea, %A_Index%
  ;    md := A_Index
  ;    WorkArea_Top    := mon%md%Top
  ;    WorkArea_Left   := mon%md%Left
  ;    WorkArea_Width  := mon%md%Right - mon%md%Left
  ;    WorkArea_Height := mon%md%Bottom - mon%md%Top
  ; 
  ;    Gui +AlwaysOnTop -Caption  +Toolwindow +Owner +LastFound
  ;    Gui Color, %BackGroundColor%
  ;    Gui Show,  Hide w%WorkArea_Width% h%WorkArea_Height% x%WorkArea_Left% y%WorkArea_Top%, »Expose%A_Index%«
  ;  }

   ; Last
   Gui Show, Hide  w%WorkArea_Width% h%WorkArea_Height% x%WorkArea_Left% y%WorkArea_Top%, »Expose«

  ;Gui, Add, Pic, x0 y0 w%WorkArea_Width% h%WorkArea_Height%, c:\test.bmp
  DetectHiddenWindows ON
  WinGet Expose_ID , ID, »Expose«
  WinGet Desktop_ID, ID, Program Manager
  DetectHiddenWindows OFF
Return

Create_Buffers:
  hdc_frontbuffer  := GetDC( Expose_ID )

  hdc_printwindow := CreateCompatibleDC(    hdc_frontbuffer)
  hbm_printwindow := CreateCompatibleBitmap(hdc_frontbuffer,WorkArea_Width,WorkArea_Height)
  hbm_old         := SelectObject(          hdc_printwindow,hbm_printwindow)

  hdc_thumbnails  := CreateCompatibleDC(    hdc_frontbuffer)
  hbm_thumbnails  := CreateCompatibleBitmap(hdc_frontbuffer,WorkArea_Width,WorkArea_Height)
  hbm_old         := SelectObject(          hdc_thumbnails,hbm_thumbnails)

  hdc_backbuffer  := CreateCompatibleDC(    hdc_frontbuffer)
  hbm_backbuffer  := CreateCompatibleBitmap(hdc_frontbuffer,WorkArea_Width,WorkArea_Height)
  hbm_old         := SelectObject(          hdc_backbuffer,hbm_backbuffer)

  hdc_desktop     := CreateCompatibleDC(    hdc_frontbuffer)
  hbm_desktop     := CreateCompatibleBitmap(hdc_frontbuffer,WorkArea_Width,WorkArea_Height)
  hbm_old         := SelectObject(          hdc_desktop,hbm_desktop)

  Gui Show
  PaintDesktop( hdc_frontbuffer ) ; 0=window, 1=Child(no toolbars)
  BitBlt(hdc_desktop     , 0, 0, WorkArea_Width, WorkArea_Height
      ,  hdc_frontbuffer , 0, 0 ,0xCC0020) ; SRCCOPY
  BitBlt(hdc_thumbnails  , 0, 0, WorkArea_Width, WorkArea_Height
      ,  hdc_frontbuffer , 0, 0 ,0xCC0020) ; SRCCOPY
  Gui Hide

Return

Window_Choose:
   WinGet ActiveID, ID, A
   show_minimized := 1
   gosub fill_mini_List

   SetTimer Window_Choose_Thread, 0       ; new thread to make thumbnail draws interruptible
Return

Window_Choose_No_Minimize:
   WinGet ActiveID, ID, A
   show_minimized := 0

   SetTimer Window_Choose_Thread, 0       ; new thread to make thumbnail draws interruptible
Return

;Current_App_Choose:
;   WinGet, activeProcessName, ProcessName, A
;   show_minimized := 1
;   gosub fill_mini_list_current         ; I'm sure there's an easier way, but too lazy and unskilled :P
;   
;   SetTimer Window_Choose_Thread, 0       ; new thread to make thumbnail draws interruptible
;return

Window_Choose_Thread:
   Stop_Drawing  =
   yield         := time_gap        ; yield time to other tasks after each thumbnail drawn
   SetTimer Window_Choose_Thread, OFF     ; run once
   GoSub Window_Info           ; list window IDs, sizes, etc.
   Gosub Animate_In

  GoSub Draw_Thumbnails
Return

Window_Activate:
   Stop_Drawing = 1
   MouseGetPos X, Y
   pos := 1 + X*cols//WorkArea_Width + Y*rows//WorkArea_Height * cols
   task_id := task_ids_%pos%

   If (pos <= num_win and X >= 0 and X <= WorkArea_Width and Y >= 0 and Y <= WorkArea_Height)
   {
      Gosub Animate_Out
      WinActivate(task_id)                 ; activate selected window
      Gosub fade_out
   }

   if ( show_minimized)
      gosub restore_position

   Gui_Hide()
Return

WinActivate(ID) {
   WinGet ,ActiveID2, ID, A
   if ActiveID2 <> ID
       WinActivate ahk_id %ID%
}

Window_Info:
   WinGet ids, list,,,Program Manager      ; all active windows-tasks (processes)
   task_info =
   num_win = 0
 
   Loop %ids%
   {
   task_id := ids%A_Index%              ; id of this window
   WinGetClass class, ahk_id %task_id%
   WinGetTitle title, ahk_id %task_id%
   WinGetPos,,, w, h, ahk_id %task_id%
   If Window_Hidden()                 ; small windows not shown (e.g. taskbar)
      Continue
   num_win++
   task_info := task_info class "|" ids%A_Index% "|" w "|" h ","
   TrayTip, task_info
   }
   
   StringTrimRight task_info, task_info, 1 ; remove last comma
   Sort task_info, D,                      ; keep positions of thumbnails
   cols := ceil(sqrt(num_win))
   rows := ceil(sqrt(num_win))
 
   If (cols*(rows-1) >= num_win)           ; minimize table size
       rows--
   
   thumb_w := WorkArea_Width  // cols
   thumb_h := WorkArea_Height // rows
   ratio_of_screen := WorkArea_Width / WorkArea_Height * rows / cols
 
   Loop Parse, task_info, `,               ; task_info has been set up in get_wins()
   {
      StringSplit z, A_LoopField, |        ; separate ID, w, h
      task_ids_%A_Index% := z2             ; needed for activation
      if ( z2 = ActiveID )
      pos = %A_Index%
     w%A_Index% := z3                     ; w
      h%A_Index% := z4                     ; h
      ratio_of_win := z3 / z4              ; w/h
      If ( scale_thumb_space  )  {
         If (ratio_of_win < ratio_of_screen) { ; tall window
            thumb_h%A_Index% := thumb_h - thumb_border
            thumb_w%A_Index% := Floor(thumb_w * ratio_of_win / ratio_of_screen) - thumb_border
         } Else {                              ; wide window
            thumb_w%A_Index% := thumb_w - thumb_border
            thumb_h%A_Index% := Floor(thumb_h * ratio_of_screen / ratio_of_win) - thumb_border
         }
      } Else {
         thumb_w%A_Index% := z3//cols - 2*thumb_border
         thumb_h%A_Index% := z4//cols - 2*thumb_border  ; cols >= rows, keep aspect ratio of window
      }
   
     if ( thumb_w%A_Index% > w%A_Index% or thumb_h%A_Index% > h%A_Index% )
     {
        thumb_w%A_Index% := w%A_Index%
         thumb_h%A_Index% := h%A_Index%
      }
   }
Return

Draw_Thumbnails:

   
    If ( Stop_Drawing )
   {
      tooltip,
           Return
   }

   
   SetStretchBltMode(hdc_thumbnails,quality_high) ; 3: Lower quality at 1st draw
 
   WinGet ids_count, list,,,Program Manager      ; all active windows-tasks (processes)
   if ( old_ids_count <> ids_count )
      gosub Window_Info   ; detect if windows were added in expose mode
   
   ; layout changed full refresh (start with empty desktop)
   if ( cols <> old_cols or rows <> old_rows)
       BitBlt( hdc_frontbuffer, 0, 0, WorkArea_Width, WorkArea_Height
           , hdc_desktop, 0, 0 , 0xCC0020) ; SRCCOPY
       BitBlt( hdc_thumbnails, 0, 0, WorkArea_Width, WorkArea_Height
           , hdc_desktop, 0, 0 , 0xCC0020) ; SRCCOPY
   
   ; clear "now empty" places , only needed when less, more are filled automatically
   gaps := old_num_win - num_win
    if ( gaps )
   {
     loop %gaps%
     {
        a_index2 := num_win + gaps
       pos_x := thumb_w * Mod(A_Index2-1,cols)
       pos_y := thumb_h * ((A_Index2-1)//cols)
 
       BitBlt( hdc_thumbnails, pos_x, pos_y, thumb_w, thumb_h
              , hdc_desktop,    pos_x, pos_y ,0xCC0020) ;
   
        BitBlt( hdc_frontbuffer, pos_x, pos_y, thumb_w, thumb_h
              , hdc_thumbnails,  pos_x, pos_y ,0xCC0020) ;
      }   
   }

    old_ids_count := ids_count
    old_rows := rows
    old_cols := cols
   old_num_win := num_win

    Loop %num_win%  {                       ; task_ids, dims have been set up in win_list
     ;  Sleep %yield%                        ; CPU cycles to other tasks @ frequent redraw
      If Stop_Drawing
         Break
   
      pos_x := thumb_w * Mod(A_Index-1,cols)
      pos_y := thumb_h * ((A_Index-1)//cols)
     
      PrintWindow( task_ids_%A_Index%, hdc_printwindow, 0) ; 0=window, 1=Child(no toolbars)
   
      BitBlt( hdc_thumbnails, pos_x , pos_y, thumb_w, thumb_h
            , hdc_desktop   , pos_x , pos_y ,0xCC0020) ; Clear slot . (could load Image here ?)
   
      ; prevent flicker with backbuffer , store it in hdc_thumbnails for later reuse!
      StretchBlt( hdc_thumbnails , pos_x + ( thumb_w - thumb_w%A_Index% ) // 2
                            , pos_y + ( thumb_h - thumb_h%A_Index% ) // 2     
                            , thumb_w%A_Index%
                          , thumb_h%A_Index%
             ,hdc_printwindow, 0, 0, w%A_Index%, h%A_Index% ,0xCC0020) ; SRCCOPY
 
        BitBlt( hdc_frontbuffer, pos_x , pos_y , thumb_w, thumb_h
             ,hdc_thumbnails,  pos_x , pos_y ,0xCC0020) ; Clear slot . (could load Image here ?)
   }

 
   MouseGetPos X, Y
      pos := 1 + X*cols//WorkArea_Width + Y*rows//WorkArea_Height * cols
 
   if pos > 0 ; dual monitor !
     winid := task_ids_%pos%
   
   WinGetTitle title, ahk_id %winid%

   tooltip, %title% ; + %old_pos2% + %pos%

   ; force Gui to foreground, maybe some windows have been opened or closed
 ; Gui_Show()
     
    If live_redraw
    {
       Gosub draw_active
       Return
      }
Return

Window_Preview:

   do_zoom := 1 - do_zoom ; toggle state
   BitBlt(hdc_frontbuffer, 0, 0, WorkArea_Width, WorkArea_Height
             ,  hdc_thumbnails, 0, 0 ,0xCC0020) ; SRCCOPY
   
return

draw_active:

  ; are gui windows also showing up and make a wrong ids_count ?
   WinGet ids_count, list,,,Program Manager      ; all active windows-tasks (processes)
   if ( old_ids_count <> ids_count ) {
      gosub,  Window_Info   ; detect if windows were added in expose mode
      gosub,  Draw_Thumbnails ;
      return
  }
  ; we need to check here if there are new windows, or windows missing and refresh the whole
  ; thing accordingly. maybe brutforce, destroy gui and paint as we have clicked "Window_Choose"
  ; only skip animation

  zoom :=  zoom_preview

  sleep %yield%                        ; CPU cycles to other tasks @ frequent redraw
       If ( Stop_Drawing )
   {
      tooltip,
           Return
   }
      MouseGetPos X, Y
      pos := 1 + X*cols//WorkArea_Width + Y*rows//WorkArea_Height * cols
 
      if pos > 0
       winid := task_ids_%pos%

      pos_x := thumb_w * Mod(pos -1,cols)
      pos_y := thumb_h * ((pos -1)//cols)

      A_Index2 = 0

      if pos > 0 
         A_Index2 := pos

       task_id := task_ids_%A_Index2%
   
   diff_x := WorkArea_Left
   diff_y := WorkArea_Top
   diff_w := WorkArea_Width
   diff_h := WorkArea_Height


   WinGetPos, diff_x, diff_y, diff_w, diff_h , ahk_id %task_id%
   diff_x := X - diff_w // 2 ; -  ( WorkArea_Width - WorkArea_Left ) // 2

   diff_y := Y - diff_h // 2 ; - ( WorkArea_Height - WorkArea_Top ) // 2
   



   diff_x := diff_x - ( pos_x + (thumb_w - thumb_w%A_Index2% ) // 2 ) - WorkArea_Left
   diff_y := diff_y - ( pos_y + (thumb_h - thumb_h%A_Index2% ) // 2 ) - WorkArea_Top
   diff_w := diff_w - ( thumb_w%A_Index2% )
   diff_h := diff_h - ( thumb_h%A_Index2% )

   
      ; you can comment this line to get bit speed, acceptable
      BitBlt( hdc_backbuffer, 0, 0, WorkArea_Width, WorkArea_Height
              , hdc_thumbnails, 0, 0, 0xCC0020) ; SRCCOPY
      PrintWindow( task_ids_%A_Index2%, hdc_printwindow, 0) ; 0=window, 1=Child(no toolbars)
      SetStretchBltMode(hdc_backbuffer,quality_high) ; 3: Lower quality at 1st draw
      SetStretchBltMode(hdc_frontbuffer,quality_high) ; 3: Lower quality at 1st draw
   
     ; counter for debugging
     counter := counter +1

     if ( do_zoom = 1 ) {   
  ;   tooltip , Drawing Zoomed window %counter%

      x0 := pos_x + (thumb_w - thumb_w%A_Index2% ) // 2 - ( diff_w * zoom  ) // 2
      y0 := pos_y + (thumb_h - thumb_h%A_Index2% ) // 2 - ( diff_h * zoom  ) // 2
      w  := thumb_w%A_Index2% + diff_w * zoom
      h  := thumb_h%A_Index2% + diff_h * zoom

      if ( zoom_maximized ) {
   WinGetPos,,, w_temp, h_temp, ahk_id %task_id%
           
    if ( w > w_temp or h > h_temp )
         {
          w := w_temp
          h := h_temp
          zoom_preview1 := w / ( thumb_w%A_Index2% + diff_w ) - 0.05
          zoom_preview  := h / ( thumb_h%A_Index2% + diff_h ) - 0.05
          if (zoom_preview1 > zoom_preview)
            zoom_preview = zoom_preview1 ; use minimum
         }
      
          ; refresh, prevent flicker
          zoom := zoom_preview
     x0 := pos_x + (thumb_w - thumb_w%A_Index2% ) // 2 - ( diff_w * zoom  ) // 2
           y0 := pos_y + (thumb_h - thumb_h%A_Index2% ) // 2 - ( diff_h * zoom  ) // 2
           w  := thumb_w%A_Index2% + diff_w * zoom
          h  := thumb_h%A_Index2% + diff_h * zoom

        }

      ; if bottom/right of zoomed thumb is out move it back into view
      if x0 + w > WorkArea_Width
        x0 := WorkArea_Width - w

      if y0 + h > WorkArea_Height
        y0 := WorkArea_Height - h

      ; if top/left is out, move it back into view, can lead to clipping of bottom or right !
      if x0 < 0
   x0 := 0 ; // overflow

      if y0 < 0
        y0 := 0 ; // overflow


      StretchBlt( hdc_backbuffer
            , x0
                           , y0
                           , w
                           , h
                           , hdc_printwindow, 0, 0, w%A_Index2%, h%A_Index2% ,0xCC0020) ; SRCCOPY
      BitBlt(hdc_frontbuffer, 0, 0, WorkArea_Width, WorkArea_Height
               ,  hdc_backbuffer, 0, 0 ,0xCC0020) ; SRCCOPY
   
   }
else  {

     Loop %num_win%  {                       ; task_ids, dims have been set up in win_list
     ;  Sleep %yield%                        ; CPU cycles to other tasks @ frequent redraw
      If Stop_Drawing
         Break
   
      pos_x := thumb_w * Mod(A_Index-1,cols)
      pos_y := thumb_h * ((A_Index-1)//cols)
     
      PrintWindow( task_ids_%A_Index%, hdc_printwindow, 0) ; 0=window, 1=Child(no toolbars)
   
      BitBlt( hdc_thumbnails, pos_x , pos_y, thumb_w, thumb_h
            , hdc_desktop   , pos_x , pos_y ,0xCC0020) ; Clear slot . (could load Image here ?)
   
      ; prevent flicker with backbuffer , store it in hdc_thumbnails for later reuse!
      StretchBlt( hdc_thumbnails , pos_x + ( thumb_w - thumb_w%A_Index% ) // 2
                            , pos_y + ( thumb_h - thumb_h%A_Index% ) // 2     
                            , thumb_w%A_Index%
                          , thumb_h%A_Index%
             ,hdc_printwindow, 0, 0, w%A_Index%, h%A_Index% ,0xCC0020) ; SRCCOPY
 
        BitBlt( hdc_frontbuffer, pos_x , pos_y , thumb_w, thumb_h
             ,hdc_thumbnails,  pos_x , pos_y ,0xCC0020) ; Clear slot . (could load Image here ?)
     }
}

   
   MouseGetPos X, Y

   pos := 1 + X*cols//WorkArea_Width + Y*rows//WorkArea_Height * cols

   if ( pos > 0 )
     winid := task_ids_%pos%

   if ( pos < 0 )
     tooltip, %pos%

   WinGetTitle title, ahk_id %winid%

   if ( pos > 0 )
      tooltip, %title% ;  + %old_pos2% + %pos%

   

   If live_redraw
   {
      Gosub draw_active
      Return
   }

return

Animate_In:
    if !animate_in_steps
        return

    SetStretchBltMode(hdc_backbuffer, quality_low) ; 3: Lower quality at 1st draw
   
     A_index2 := pos
    pos_x := thumb_w * Mod(A_Index2-1,cols)
    pos_y := thumb_h * ((A_Index2-1)//cols)
 
    PrintWindow(task_ids_%A_Index2%,hdc_printwindow,0)
 
    task_id := task_ids_%A_Index2%
   WinGetPos, diff_x, diff_y, diff_w, diff_h , ahk_id %task_id%

    diff_x := diff_x - ( pos_x + (thumb_w - thumb_w%A_Index2% ) // 2 ) - WorkArea_Left
    diff_y := diff_y - ( pos_y + (thumb_h - thumb_h%A_Index2% ) // 2 ) - WorkArea_Top
    diff_w := diff_w - ( thumb_w%A_Index2% )
    diff_h := diff_h - ( thumb_h%A_Index2% )
   
   Loop %animate_in_steps%
   {
       sleep %animate_in_delay%
       zoom := 1 - ( A_Index / animate_in_steps )
     
        BitBlt( hdc_backbuffer, 0, 0, WorkArea_Width, WorkArea_Height
                 , hdc_thumbnails, 0, 0 , 0xCC0020) ; SRCCOPY
   
      if ( zoom = 0 )
         SetStretchBltMode(hdc_backbuffer, quality_high) ; 3: Lower quality at 1st draw
         StretchBlt( hdc_backbuffer , pos_x + (thumb_w - thumb_w%A_Index2% ) // 2 + diff_x * zoom     
                           , pos_y + (thumb_h - thumb_h%A_Index2% ) // 2 + diff_y * zoom     
                           , thumb_w%A_Index2% + diff_w * zoom   
                           , thumb_h%A_Index2% + diff_h * zoom
                           , hdc_printwindow, 0, 0, w%A_Index2%, h%A_Index2% ,0xCC0020) ; SRCCOPY
     
       if ( zoom = 0 )
         SetStretchBltMode(hdc_backbuffer, quality_low) ; 3: Lower quality at 1st draw
         Gui_Show()
         BitBlt(hdc_frontbuffer, 0, 0 ,WorkArea_Width ,WorkArea_Height
                 ,hdc_backbuffer , 0, 0 ,0xCC0020) ; SRCCOPY
   }

   old_cols := cols ; prevent full refresh on next draw
   old_rows := rows

Return

; should be reverse of animate in ? combine them ...
Animate_Out:
   
   if !animate_out_steps
         return

   A_index2 := pos
    pos_x := thumb_w * Mod(A_Index2-1,cols)
    pos_y := thumb_h * ((A_Index2-1)//cols)
 
    If (!(pos <= num_win and X >= 0 and X <= WorkArea_Width and Y >= 0 and Y <= WorkArea_Height))
       return

   ;SetStretchBltMode(hdc_frontbuffer,quality_low) ;
    PrintWindow( task_ids_%A_Index2%, hdc_printwindow ,0) ; get selected window
   
   ; clear
     BitBlt( hdc_backbuffer, pos_x, pos_y, thumb_w, thumb_h
              , hdc_desktop   , pos_x, pos_y, 0xCC0020) ; clear with desktopimage

   task_id := task_ids_%A_Index2%
   WinGetPos, diff_x, diff_y, diff_w, diff_h , ahk_id %task_id%

   diff_x := diff_x - ( pos_x + (thumb_w - thumb_w%A_Index2% ) // 2 ) - WorkArea_Left
   diff_y := diff_y - ( pos_y + (thumb_h - thumb_h%A_Index2% ) // 2 ) - WorkArea_Top
   diff_w := diff_w - ( thumb_w%A_Index2% )
   diff_h := diff_h - ( thumb_h%A_Index2% )

   SetStretchBltMode(hdc_backbuffer,quality_low) ; 3: Lower quality at 1st draw
    Loop %animate_out_steps%
   {
       sleep %animate_out_delay%
          zoom := ( A_Index / animate_out_steps )
       
      ; you can comment this line to get bit speed, acceptable
      BitBlt( hdc_backbuffer, 0, 0, WorkArea_Width, WorkArea_Height
              , hdc_thumbnails, 0, 0, 0xCC0020) ; SRCCOPY
     
      StretchBlt( hdc_backbuffer, pos_x + (thumb_w - thumb_w%A_Index2% ) // 2 + diff_x * zoom
                           , pos_y + (thumb_h - thumb_h%A_Index2% ) // 2 + diff_y * zoom
                           , thumb_w%A_Index2% + diff_w * zoom
                           , thumb_h%A_Index2% + diff_h * zoom
                           ,hdc_printwindow, 0, 0, w%A_Index2%, h%A_Index2% ,0xCC0020) ; SRCCOPY
   
       BitBlt(hdc_frontbuffer, 0, 0, WorkArea_Width, WorkArea_Height
                ,  hdc_backbuffer, 0, 0 ,0xCC0020) ; SRCCOPY
     }
   
Return

fade_in:
   ; not used ?
Return

fade_out:
   ; fade last animate_out with real desktop
Return


; subroutines by kli6891 to show minimized windows


; generate an array of minimized windows
fill_mini_List:

   minimized_counter := minimized_counter + 1 ; simulate "cleaning" groupadd

   miniList =
   miniCount = 0
   WinGet, listOfWindows, list,,, Program Manager
   Loop %listOfWindows%
   {
      currentWindowID := listOfWindows%A_Index%
      WinGetTitle, title, ahk_id %currentWindowID%
      if (title != "start" && title != "")
      {
         Winget, isMinimize, MinMax, ahk_id %currentWindowID%
         if (isMinimize == -1)
         {
            GroupAdd , mini%minimized_counter% , ahk_id %currentWindowID%
         }
      }
   }
   
   minAnimation(0)
   WinRestore, ahk_group mini%minimized_counter%
return

;generate group of the current process name NOT WORKING YET
;fill_mini_list_current:
;   minimized_counter := minimized_counter + 1 ; simulate "cleaning" groupadd
;
;   miniList =
;   miniCount = 0
;   WinGet, listOfWindows, list,,, Program Manager
;   Loop %listOfWindows%
;   {
;      currentWindowID := listOfWindows%A_Index%
;      WinGetTitle, title, ahk_id %currentWindowID%
;      WinGet, currentProcessName, ProcessName, hiahk_id %currentWindowID%
;      if (title != "start" && title != "")
;      {
;         Winget, isMinimize, MinMax, ahk_id %currentWindowID%
;         if (isMinimize == -1 && currentProcessName == activeProcessName)   ; only if the process name matches also
;         {
;            GroupAdd , mini%minimized_counter% , ahk_id %currentWindowID%
;         }
;      }
;   }
;   
;   minAnimation(0)
;   WinRestore, ahk_group mini%minimized_counter%
;return


; minimize all windows that were previously captured by fill_mini_list
; except if the window is currently active
restore_position:
   WinGet ActiveID, ID, A

   WinMinimize, ahk_group mini%minimized_counter%
   WinActivate ahk_id %ActiveID%
   minAnimation(1)
return


minAnimation(set="")
{
   VarSetCapacity(AnimationInfo, 8,0)
   cbSize := VarSetCapacity(AnimationInfo)
   NumPut(cbSize, AnimationInfo, 0, "UInt")

   if set =
   {
      DllCall("SystemParametersInfo", UInt, 0x48, UInt, cbSize, "UInt", &AnimationInfo, UInt, 1 )
      return NumGet(AnimationInfo,4)
   }
   
   if (set = 0 || set = 1)
   {
      NumPut(cbSize, AnimationInfo, 0, "UInt")
      NumPut(set, AnimationInfo, 4, "Int")
     
      DllCall("SystemParametersInfo", UInt, 0x49, UInt, cbSize, "UInt", &AnimationInfo, UInt, 1 )
      return 1
   }
   return 0
}


Gui_Show() {
   global
   if Shown
      return

  ; SysGet, mc, MonitorCount
  ; Loop, %mc%
  ;     Gui, %A_Index%:Show
    Gui, Show
   Shown = 1
}

Gui_Hide() {
   global
   tooltip,
   if !Shown
     return
   
  ; SysGet, mc, MonitorCount
  ; Loop, %mc% + 1
  ;     Gui, %A_Index%:Hide
   
   Gui, Hide 
   Shown =
}

hide_gui:
   Stop_Drawing = 1
   Gui_Hide()
   WinActivate(ActiveID)                   ; activate last active window
Return

handle_exit:
   Gui Destroy
   ReleaseDC(hw_frame,hdc_frontbuffer)     ; free lock?
   DeleteObject( hbm_printwindow)
   DeleteDC(     hdc_printwindow)
   DeleteObject( hbm_window)
   DeleteDC(     hdc_window)
   DeleteObject( hbm_backbuffer)
   DeleteDC(     hdc_backbuffer)
 ;  WinActivate ahk_id %ActiveID%    ; activate last active window
ExitApp


; --------------------------------------------------------------------------------------------------
; Library: no need to modify below

; Libary (could be put in extra file )
; #include <GDI.ahk>
; for documentation of commands see: http://msdn.microsoft.com/library/default.asp?url=/library/en-us/gdi/wingdistart_9ezp.asp

; -- highlevel not direct dllcall mapping , simplifiers
CreateDCBuffer(ByRef hdc_from, ByRef hdc_to, ByRef hbm_to, w ,h ) {
   ; does not work, something wrong with ByRef and global
   hdc_to  := CreateCompatibleDC(hdc_from) ; buffer
   hbm_to  := CreateCompatibleBitmap(hdc_from,w,h)
   old     := SelectObject(hdc_to,hbm_to)
}

; -- mfc wrapper
GetDC( hw ) {
   return DLLCall("GetDC", UInt, hw )
}

CreateDC( driver,device,output,mode  ) {
   return DLLCall("GetDC", UInt, driver, UInt, device, UInt, output, UInt, mode )
}

SetStretchBltMode( hdc , value ) {
     return DllCall("gdi32.dll\SetStretchBltMode", UInt,hdc, "int",value)
}

CreateCompatibleDC( hdc ) {
   return DllCall("gdi32.dll\CreateCompatibleDC", UInt,hdc)
}

CreateCompatibleBitmap( hdc , w, h ) {
     return DllCall("gdi32.dll\CreateCompatibleBitmap", UInt,hdc, Int,w, Int,h)
}

SelectObject( hdc , hbm ) {
   return DllCall("gdi32.dll\SelectObject", UInt,hdc, UInt,hbm)
}

DeleteObject( hbm ) {
   return DllCall("gdi32.dll\DeleteObject", UInt,hbm)   
}

DeleteDC( hdc ) {
   return DllCall("gdi32.dll\DeleteDC", UInt,hdc )
}

ReleaseDC( hwnd, hdc ) {
   return DllCall("gdi32.dll\ReleaseDC", UInt,hwnd,UInt,hdc )
}

PrintWindow( window_id , hdc , mode ) {
   return DllCall("PrintWindow", UInt, window_id , UInt,hdc, UInt, mode)
}

StretchBlt( hdc_dest , x1, y1, w1, h1, hdc_source , x2, y2, w2, h2 , mode) {
   return DllCall("gdi32.dll\StretchBlt"
          , UInt,hdc_dest  , Int,x1, Int,y1, Int,w1, Int,h1
             , UInt,hdc_source, Int,x2, Int,y2, Int,w2, Int,h2
          , UInt,mode)
}

BitBlt( hdc_dest, x1, y1, w1, h1 , hdc_source, x2, y2 , mode ) {
   return DllCall("gdi32.dll\BitBlt"
          , UInt,hdc_dest   , Int, x1, Int, y1, Int, w1, Int, h1
             , UInt,hdc_source    , Int, x2, Int, y2
          , UInt, mode)
}

PaintDesktop(  hdc ) {
   return DllCall("PaintDesktop", UInt, hdc )
}

; constants
; see: http://www.adaptiveintelligence.net/Developers/Reference/Win32API/GDIConstants.aspx
; #SRCCOPY = 0xCC0020

