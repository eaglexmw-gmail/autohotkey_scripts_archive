; v1.03-experimental -- expose.ahk - Thumbnails of windows over the working area

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
  ^!p::Pause
  ; wait for key/mouse
Return


									

Read_Keymapping:
  Hotkey, #TAB    ,  Window_Choose 
  Hotkey, MButton ,  Window_Choose
  Hotkey, IfWinActive , 틿xpose�
  Hotkey, #TAB    ,  Window_Activate
  Hotkey, LButton ,  Window_Activate
  Hotkey, Esc	  ,  hide_gui
  Hotkey, +MButton , handle_exit ; panik-key
  Hotkey, Space   ,  toggle_fast_mode
  Capslock:: #TAB
Return 

toggle_fast_mode:
  fast_redraw_mode := !fast_redraw_mode ; toggle
return

Read_Config: 
  min_w                = 110  ; min width of windows to be shown
  min_h                = 110  ; min height of windows to be shown (hides taskbar etc)
  scale_thumb_space    = 1    ; scale thumbnails to best fit to box?
  live_redraw          = 1    ; 1/0 = Yes/No
  time_gap             = 10   ; ms, time left for others after each thumbnail draw
  thumb_border	       = 1   ; 1 for gap between thumbnail  s
  animate_in_delay     = 0 
  animate_in_steps 	   = 9 
  animate_out_delay    = 0 
  animate_out_steps    = 9 
  show_taskbar 		   = 1
  show_desktop_image   = 1
  fast_redraw_mode     = 0
  ;fade_in_steps       = 5
  ;fade_in_delay       = 5
  ;fade_out_steps	   = 5
  ;fade_out_delay      = 50
  quality_low	 	   = 3 ; allowed: 1 (terrible) , 3 (accepatable) 4 (good = slow)
  quality_high         = 4 ; allowed: 1 (terrible) , 3 (accepatable) 4 (good = slow)
  ;BackGroundColor      = 004E98  ; using desktop!
Return 

Window_Hidden() { 
   global
   Return w < min_w or h < min_h or title ="틿xpose�" or title =""
}

Detect_ScreenSize:
  Th=0 
  Tw=0
  Ty=0
  Tx=0
  if show_taskbar
	WinGetPos,Tx,Ty,Tw,Th,ahk_class Shell_TrayWnd,,,
  WorkArea_Top    :=      ( Tw > Th  and  Tx = 0  and  Ty = 0) * Th
  WorkArea_Left   :=      ( Tw < Th  and  Tx = 0  and  Ty = 0) * Tw
  WorkArea_Height := ( A_ScreenHeight - ( Tw > Th  ) * Th ) 
  WorkArea_Width  := ( A_ScreenWidth  - ( Tw < Th  ) * Tw ) 
Return 

Create_Gui:
  Gui +AlwaysOnTop -Caption  +Toolwindow +Owner +LastFound 
  ;WinSet, Transparent, 255
  ;Gui Color, %BackGroundColor%
  Gui Show, Hide  w%WorkArea_Width% h%WorkArea_Height% x%WorkArea_Left% y%WorkArea_Top%, 틿xpose�
  ;Gui, Add, Pic, x0 y0 w%WorkArea_Width% h%WorkArea_Height%, c:\test.bmp
  DetectHiddenWindows ON
  WinGet Expose_ID , ID, 틿xpose�
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

  if show_desktop_image
  {
    hdc_desktop     := CreateCompatibleDC(    hdc_frontbuffer) 
    hbm_desktop     := CreateCompatibleBitmap(hdc_frontbuffer,WorkArea_Width,WorkArea_Height)
    hbm_old         := SelectObject(          hdc_desktop,hbm_desktop)

    Gui Show
    PaintDesktop( hdc_frontbuffer ) 
    BitBlt(hdc_desktop     , 0, 0, WorkArea_Width, WorkArea_Height, hdc_frontbuffer , 0, 0 ,0xCC0020) ; SRCCOPY
    BitBlt(hdc_thumbnails  , 0, 0, WorkArea_Width, WorkArea_Height, hdc_frontbuffer , 0, 0 ,0xCC0020) ; SRCCOPY
    Gui Hide
   }
 
Return 

Window_Choose:
   WinGet ActiveID, ID, A
   SetTimer Window_Choose_Thread, 0       ; new thread to make thumbnail draws interruptible
Return
Window_Choose_Thread:
   SetTimer Window_Choose_Thread, OFF     ; run once
   Stop_Drawing  =
   yield         := time_gap        ; yield time to other tasks after each thumbnail drawn
   GoSub Window_Info           ; list window IDs, sizes, etc.
   Gosub Animate_In
   SetStretchBltMode(hdc_thumbnails,quality_high) ; 3: Lower quality at 1st draw
   fast_redraw = 0 ; force full refresh
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
   Gui_Hide()
Return

Window_Send_Click: 
   Stop_Drawing = 1
   CoordMode, Mouse, Screen
   MouseGetPos X,Y
   pos := 1 + X*cols//WorkArea_Width + Y*rows//WorkArea_Height * cols  
   task_id := task_ids_%pos%
   If (pos <= num_win and X >= 0 and X <= WorkArea_Width and Y >= 0 and Y <= WorkArea_Height)
   {
	   X_Relative := ( X - ( X*cols//WorkArea_Width  ) * WorkArea_Width/cols  ) * cols
	   Y_Relative := ( Y - ( Y*rows//WorkArea_Height ) * WorkArea_Height/rows ) * rows
	
	   CoordMode, Mouse, Screen
	
	   ;Tooltip % "click at: " X_Relative " " Y_Relative ": " X " : " Y    
	   ;ControlClick , x%X_Relative% y%Y_Relative%, ahk_id %task_id% 
	   x1 := X_Relative -5
       y1 := Y_Relative -5
       x2 := x1+10
       y2 := y1+10
   	   WinSet, Region, 0-0 %A_ScreenWidth%-0 %A_ScreenWidth%-%A_ScreenHeight%  0-%A_ScreenHeight% 0-0  %x1%-%y1% %x2%-%y1% %x2%-%y2% %x1%-%y2% %x1%-%y1% 
	   sleep 5
	   WinActivate(task_id)
       MouseClick, Left, X_Relative, Y_Relative	
       sleep 5
	   WinSet, Region

	   /*
	   ; click the target window
   	   Gui Hide
	   Sleep 20
	   Sleep 20
       Gui Show
	   
	   ; restore mouse
       */
	
	   ; continue paint
       MouseMove, X+1, Y
       MouseMove, X, Y
	   Stop_Drawing =   
       fast_redraw = 0
	   ;WinActivate(last_id)
	   WinActivate(Expose_ID)
	   SetTimer,  Draw_Thumbnails , 0
   }
   
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
   Loop %ids% {
      task_id := ids%A_Index%              ; id of this window
      WinGetClass class, ahk_id %task_id%
      WinGetTitle title, ahk_id %task_id%
      WinGetPos,,, w, h, ahk_id %task_id%
      If Window_Hidden()                 ; small windows not shown (e.g. taskbar)
         Continue
      num_win++
      task_info := task_info class "|" ids%A_Index% "|" w "|" h ","
   }
   StringTrimRight task_info, task_info, 1
   Sort task_info, D,                      ; keep positions of thumbnails
   cols := ceil(sqrt(num_win))
   rows := ceil(sqrt(num_win))
   ;If (cols*(rows-1) >= num_win)           ; minimize table size
   ;    rows--
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
	SetTimer, Draw_Thumbnails, Off
	If Stop_Drawing
           Return 
	
	WinGet ids_count, list,,,Program Manager      ; all active windows-tasks (processes)
  	
	if ( old_ids_count <> ids_count )
		gosub Window_Info	; detect if windows were added in expose mode

  
	; layout changed full refresh (start with empty desktop)
 	if ( old_ids_count <> ids_count and !fast_redraw)
      if show_desktop_image
		BitBlt( hdc_thumbnails, 0, 0, WorkArea_Width, WorkArea_Height , hdc_desktop, 0, 0 , 0xCC0020) ; SRCCOPY
      else
   		BitBlt( hdc_thumbnails, 0, 0, WorkArea_Width, WorkArea_Height  , hdc_thumbnails, 0, 0 , 0x00000042) ; Black

    old_ids_count := ids_count  
    old_rows := rows
    old_cols := cols
	old_num_win := num_win
    MouseGetPos, X_live, Y_live
    Loop %num_win%  {                       ; task_ids, dims have been set up in win_list
      
	  if !fast_redraw
		Sleep %yield%                        ; CPU cycles to other tasks @ frequent redraw

	  if !fast_redraw
		Sleep %yield%                        ; CPU cycles to other tasks @ frequent redraw
	
      Sleep %yield%                        ; CPU cycles to other tasks @ frequent redraw

      If Stop_Drawing
         Break
    
      ;tooltip % "mode is" fast_redraw " and " fast_redraw_mode
      pos_x := thumb_w * Mod(A_Index-1,cols)
      pos_y := thumb_h * ((A_Index-1)//cols)
      if ( !fast_redraw or ( X_live > pos_x and X_live < pos_x + thumb_w and Y_live > pos_y and Y_live < pos_y + thumb_h ) )
	  {
          PrintWindow( task_ids_%A_Index%, hdc_printwindow, 0) ; 0=window, 1=Child(no toolbars)
   	
          if show_desktop_image
		    BitBlt( hdc_thumbnails, pos_x , pos_y, thumb_w, thumb_h , hdc_desktop   , pos_x , pos_y ,0xCC0020) ; Clear slot
          else
		    BitBlt( hdc_thumbnails, pos_x , pos_y, thumb_w, thumb_h , hdc_thumbnails , pos_x , pos_y ,0x00000042) ; Black 
  		
		  hdc_target := fast_redraw * hdc_frontbuffer + (1-fast_redraw) * hdc_thumbnails

          StretchBlt( hdc_target , pos_x + ( thumb_w - thumb_w%A_Index% ) // 2
	  						     , pos_y + ( thumb_h - thumb_h%A_Index% ) // 2		
	  						     , thumb_w%A_Index%
							     , thumb_h%A_Index% 
				 ,hdc_printwindow, 0, 0, w%A_Index%, h%A_Index% ,0xCC0020) ; SRCCOPY
	  }
   }
    
   if !fast_redraw
	BitBlt( hdc_frontbuffer, 0 , 0 , WorkArea_Width, WorkArea_Height ,hdc_thumbnails,  0 , 0 , 0xCC0020) ; flip

   fast_redraw := fast_redraw_mode
   SetStretchBltMode(hdc_frontbuffer, quality_low) ; 3: Lower quality at 1st draw
 
   If live_redraw           ; redraw thumbnails until Break is set
   	   Gosub draw_thumbnails
Return

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
	if !old_cols
		old_cols := cols ; prevent full refresh on next draw
	if !old_rows    
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

Gui_Show() { 
	global
	if Shown
	   return 
	Gui, Show
	Shown = 1
}

Gui_Hide() {
   global
   if !Shown
     return
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
   ReleaseDC(Expose_ID,hdc_frontbuffer) ; free lock?
   ReleaseDC(Expose_ID,hdc_copy) ; free lock?
   DeleteObject( hbm_printwindow)
   DeleteDC(     hdc_printwindow)
   DeleteObject( hbm_window)
   DeleteDC(     hdc_window)
   DeleteObject( hbm_backbuffer)
   DeleteDC(     hdc_backbuffer)
   if ( show_desktop_image ) {
     DeleteObject( hbm_desktop)
     DeleteDC(     hdc_desktop)
   }
   ;  WinActivate ahk_id %ActiveID%           ; activate last active window
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
			 , UInt,hdc_dest	, Int, x1, Int, y1, Int, w1, Int, h1
             , UInt,hdc_source 	, Int, x2, Int, y2
			 , UInt, mode) 
}

PaintDesktop(  hdc ) {
	return DllCall("PaintDesktop", UInt, hdc )
}

; constants
; see: http://www.adaptiveintelligence.net/Developers/Reference/Win32API/GDIConstants.aspx 
; #SRCCOPY = 0xCC0020
