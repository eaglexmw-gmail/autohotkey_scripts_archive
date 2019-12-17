; v.20090922 -- expose.ahk - Thumbnails of Windows. Clean Rewrite

OnExit Handle_Exit
#include Gdip.ahk ; in library folder or next to this script
#SingleInstance Force
#NoEnv
SetBatchLines -1
SetWinDelay 0               ; larger values also fail under heavy load, changing windows
Process Priority,,Above Normal
CoordMode Mouse, Relative

Main:
   Gosub, Config
   Gosub, Init_Gui
   ;Gosub, Repaint
   ; idle in background, wait for key (Window_Activate)
Return

Config:
   ; -- Keys to Start/Show Expose
   Hotkey, MButton, Window_Choose
   Hotkey, ESC, Handle_Exit
   ;
   ;

   ; -- Keys while in Gui-Mode
   Hotkey, IfWinActive, EXPOSE_GUI_1
      Hotkey, MButton , Window_Activate
      ;
      ;
      ;
      Hotkey, #F12 , Debug_Info
      Hotkey, ESC , Handle_Exit

   ; -- Predefined Variables and other Configs
   show_win_min_w = 110 ; min width of windows to be shown
   show_win_min_h = 110 ; min height of windows to be shown, hides Taskbar
   cpu_yield = 100 ; ms to wait
   gui_background = 333333
   do_zoom := 0 ;
   ; animate_delay  = 5 ;
   ; show_taskbar   = 1 ; Leave a gap so Taskbar is still visible
   ; main_monitor   = 1 ; (or 2,3,4,...)
   win_count_old := 0
   can_repaint := 1
   ;
   ;
   ;
   ;
Return

Debug_Info:
   ListLines
Return

Init_Gui:
   ; Detect Screensize, means where is the Taskbar, Is it Multi-Monitor ?
   ; ... Either very Short directly here or as a Helper-Function only Returning x0,y0,w,h ?

   ; Start gdi+ , we dont need it until we draw on surface with lines etc.
   if (0) {
      If !pToken := Gdip_Startup()
      {
         MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
         ExitApp
      }
   }
   
   ; Copy bounds of all monitors to an array.
   SysGet, mc, MonitorCount
   Loop, %mc% {
      if ( A_Index > 1 )
         continue
      
      SysGet, mon%A_Index%, MonitorWorkArea, %A_Index%
      md := A_Index
      WorkArea_Top    := mon%md%Top  ; + 50
      WorkArea_Left   := mon%md%Left ; + 50
       WorkArea_Width  := mon%md%Right - mon%md%Left ; - 50
       WorkArea_Height := mon%md%Bottom - mon%md%Top ; - 50
   
      ; create Gui For Each Monitor, because we want to hide them all

      Gui +AlwaysOnTop -Caption  +Toolwindow +Owner +LastFound ; +OwnDialogs ; +E0x80000        
      Gui Show,  Hide w%WorkArea_Width% h%WorkArea_Height% x%WorkArea_Left% y%WorkArea_Top%, EXPOSE_GUI_%A_Index%
      ;Gui Show,  Hide w%WorkArea_Width% h%WorkArea_Height% x%WorkArea_Left% y%WorkArea_Top%,   »Expose«

    ;   Gui %A_Index%:Color, %gui_background%
   ;   WinSet, TransColor, %gui_backgroundcolor% 128

   ;      hwnd%A_Index% := WinExist() ; grab handle for this new gui-window for later use   
 
   }

   ; Create a Gui, but Hide it Immediately, so preparing in Background, we dont want to see
   ; ... whats going on
   ;Gui Show, Hide ..... , EXPOSE_GUI

   ; Create Buffers
   
   ; Buffer 1: Main-Display "frontbuffer" is the EXPOSE_GUI, the only thing which we SEE
   ; ... nothing to do here, its a real window ! we cannot paint directly on Desktop as
   ; ... we need to remove it when closing Expose. Also the window holds the old "state"
   md := 1 ; use monitor 1 (which should be main-monitor with taskbar by default)
   Width :=  ( mon%md%Right - mon%md%Left )
   Height:=  ( mon%md%Bottom - mon%md%Top )
  DetectHiddenWindows ON
  WinGet Expose_ID , ID, EXPOSE_GUI_1
  WinGet Desktop_ID, ID, Program Manager
  DetectHiddenWindows OFF

   ;   tooltip, "e: " %Expose_ID% " + " %Expose2_ID%  " - " %Desktop_ID% + " w " %Width%
   
   hdc_gui := GetDC( Expose_ID )

   ; Buffer 2: Print-Window; This is our Handle to Read the Current Look of one of the
   ; ... Application-Windows. Is it needed or can we read it directly ?
   hdc_thumb := CreateCompatibleDC(     hdc_gui )
   hbm_thumb := CreateCompatibleBitmap( hdc_gui, Width , Height )
   hbm_old   := SelectObject(        hdc_thumb, hbm_thumb )

   ; Buffer 3: Backbuffer; This holds the Screen for Rendering Our "Scene", We do it in Background,
   ; ... so there is no flicker while Drawing, giving a nice View. This also prevents funny
   ; ... drawings when windows get reaaranged due to chaning of windows.
   ; ... Is it really needed or can we directly paint on the frontbuffer ?
   ; ... One Problem could be flicker, because we clear the "scene" in each round to paint the
   ; ... Desktop-Wallpaper. Done in Realtime will result in flicker as thumbs are hidden by wallpaper.
   ; visible Gui
   ; ???
   hdc_display := CreateCompatibleDC(     hdc_gui )
   hbm_display := CreateCompatibleBitmap( hdc_gui, Width , Height )
   hbm_old := SelectObject(        hdc_display, hbm_display )

   ; Buffer 4: Wallpaper; This holds the Wallpaper from Desktop and is the Base for Repaint
   ; ... On each Loop whe paint first the Wallpaper and then the Thumbnails.
   ; ... Optimization is not to clear all from Backbuffer, but draw over the Backbuffer all
   ; ... the time because only little is changing. If we have a Gap, or Window-Rearrangement
   ; ... then we need to copy "repair" this sections with the Wallpaper and the new Thumbnail
   hdc_desktop := CreateCompatibleDC(     hdc_gui )
   hbm_desktop := CreateCompatibleBitmap( hdc_gui, Width , Height )
   hbm_old   := SelectObject(        hdc_desktop, hbm_desktop )
   

   ;SetStretchBltMode(hdc_thumb   ,4) ;
   ;SetStretchBltMode(hdc_gui     ,4) ;
   SetStretchBltMode(hdc_display ,4) ;
   ;SetStretchBltMode(hdc_desktop ,4) ;

   ; to front
   Gui Show
   PaintDesktop( hdc_gui ) ; Paint Desktop-Wallpaper on Top of GUI:1
   BitBlt( hdc_desktop , 0,0, Width, Height, hdc_gui , 0,0, 0xCC0020 ) ; Copy Surface of GUI:1 to Buffer:Desktop
   BitBlt( hdc_display , 0,0, Width, Height, hdc_gui , 0,0, 0xCC0020 ) ; Copy Surface of GUI:1 to Buffer:Desktop
   Gui  Hide

   ; autostart on launch of expose ??
   ;Gosub, Window_Choose

   ;Gui 1:Hide
   ; Hide and wait for user to start

   ; Restore Minimized Windows here as we also want to show them in Expose mode
   ; ... Remember their State and Minimize them Later when needed. (When Hide, Close ExposeGUI !)
Return

Window_Hidden( w, h, title, class) {
   global
   Return w < show_min_win_w or h < show_min_win_h or InStr(title ,"EXPOSE_GUI_") or title ="" or class ="tooltips_class32"
}

Window_Choose:
   ; Open The Gui (with Animate_In-Effect )
   ; ... and Start Repainting the Thumbnail in a Loop
   ; ... Until User Activates a Window, or Closes/Hides the ExposeGUI
   ; ... Actually Hide/Close also Calls Window_Activate and Activates the old one
   ;Gui 1:Show
   WinGet ActiveID, ID, A

   Gui, Show
   can_repaint := 1 ; start/allow repaint loop
   Gosub, Repaint
Return

Window_Activate:
   ; Find the Window which is under the Mouse-Pointer (Hovered)
   ; ... And Zoom this Window out with "Animate_Out" and make it the Active One.
   Gui 1:Hide
   can_repaint := 0 ; stop repainting loop
Return

Repaint:
   ; Loop through all Active Tasks and Paint them with help of PrintWindow() to the
   ; ... Backbuffer. Then flip the Backbuffert to the Frontbuffer to show the updated Scene.
   ; ... BitBlt from Backbuffer to Frontbuffer is quite fast.
   ; ... But Update of the Thumbnails could be Painted to Frontbuffer Directly if we are
   ; ... Good in "Repairing" the Gaps etc.
   ; ... Maybe we use the Backbuffer only for one Tile (eg. one Thumbnail + Wallpaper as Background)
   ; ... and Minimize Repainting of screen but Prevent Flicker this way.
   ; ... If we Repaint less pixels with BitBlt (or Strechblt) then the App will be faster / smoother!

   Sleep %cpu_yield% ; give CPU some Rest otherwise Expose tries to grab 100% CPU, always updating windows
   
   ; count visible windows (windows we should paint)
      win_count_old := win_count ;
      win_count := 0
      WinGet task, list,,,Program Manager      ; all active windows-tasks (processes)
        Loop %task% {
         ; if needed Restore part of Wallpaper on this Tile to Backbuffer
         ; copy Applicationwindow to Backbuffer with Printwindow() using StrechBlt to Resize
         ; ... (Minimize it)
         ; ... is Gdip_Worldtransform a better alternative to StrechBlt, or is it internally the same ?
         ; copy Backbuffer to Frontbuffer
         id := task%A_Index%
         WinGetClass class, ahk_id %id%
         WinGetTitle title, ahk_id %id%
         WinGetPos ,,, w,h, ahk_id %id%

         if Window_Hidden(w,h,title,class)
            Continue
         win_count ++
      }
   


   if (do_zoom = 0 or force_refresh = 1) {
      Gui 1:Show
      ; refresh the canvas if number of windows changed, which changes layout !
      ; later only when layout changes (eg. rows and/or cols of thumbnail-grid !)
      if (1 or win_count <> win_count_old ) {
         ; can be optimized !
         BitBlt( hdc_display, 0,0, Width,Height, hdc_desktop, 0,0 ) ; Restore Wallpaper   
      }   
      titles := ""
      win_nr := 0
      WinGet task, list,,,Program Manager      ; all active windows-tasks (processes)
        Loop %task% {
         ; if needed Restore part of Wallpaper on this Tile to Backbuffer
         ; copy Applicationwindow to Backbuffer with Printwindow() using StrechBlt to Resize
         ; ... (Minimize it)
         ; ... is Gdip_Worldtransform a better alternative to StrechBlt, or is it internally the same ?
         ; copy Backbuffer to Frontbuffer
         id := task%A_Index%
         WinGetClass class, ahk_id %id%
         WinGetTitle title, ahk_id %id%
         WinGetPos ,,, w,h, ahk_id %id%

         if Window_Hidden(w,h,title,class)
            Continue

         win_nr ++
         titles := titles "`n" A_Index ": " class ", " title  "(" w  "," h ")"
         

         PrintWindow( id , hdc_thumb , 0 )

         ;Put the Painted window in
         MouseGetPos X, Y
         X=0
         Y=0
      ; Render into Display_Buffer
         WW :=  Width/win_count
         HH := WW * h / w ; make proportional zu original window
         YY := (Height / 2) - ( HH ) / 2
         StretchBlt( hdc_display , (WW) * (win_nr - 1 ) + X, YY + Y
                  ;, w/win_count, w*Height/Width/win_count
                  , WW , HH
                  ,  hdc_thumb ,  0 , 0, w, h,0xCC0020 ) ;
         ;sleep , 100
      }
      
         BitBlt( hdc_gui , 0 , 0  ,Width,Height,  hdc_display ,  0 , 0 ) ;
   ;   tooltip, iff
   } else {
      ; Only Repaint the Hovered Window/Thumbnail
      ; ... Here Backbuffer comes Handy, as we keep the current State in Backbuffer
      ; ... and only Paint the Zoomed Thumbnail/Live-Window over the Backbuffer
      ; ... or we use another GUI-Window On-Top and let Windows do the Updating which
      ; ... holds the Zoomed Version
      
   ;   tooltip, elsee
   }
;   tooltip, aaa
   ; As an optimization, we could repaint all Thumbnails in low-priority even if in zoomed mode
   ; like every 10seconds, so we react correctly on changes in them and opened/closed windows.
   ;   MouseGetPos X, Y
   ;   if ( X>0 and Y>0 ) {
   ;      UpdateLayeredWindow(hwnd1, hdc, X, Y, Width, Height)
   ;   }
   ;tooltip , %titles% ,,1

   if ( can_repaint = 1 )
      Goto, Repaint ; call self in a loop
Return

Animate_In:
   ; Make Screenshot of Current Desktop or Active-Window and Un-Zoom it into Thumbnail - Possition
   ; .. This makes Expose MUCH more integrated. Small Animation , Big Effect
Return

Animate_Out:
   ; Simulate Zoom Back to Real size
Return

; I cant remember but there was some sense in using the "Shown" -Variable,
; ... maybe this is not used/needed anymore ?

Gui_Show() {
   ; prevent showing twice when active already
}

Gui_Hide() {
   ; hide only when visible
}

Handle_Exit:
   ; Clean Up all Resources so we dont get MemoryLeaks when Closing Expose
   ; for each monitor
    SysGet, mc, MonitorCount
   Loop, %mc% {
      Gui %A_Index%: Destroy
   }

;

   ReleaseDC(hw_frame,hdc_gui)

   SelectObject(hdc_display,hdc_display_old )
   DeleteObject(hbm_display)
   DeleteDC(    hdc_display)

   SelectObject(hdc_thumb,hdc_thumb_old)
   DeleteObject(hbm_thumb)
   DeleteDC(    hdc_thumb)

   SelectObject(hdc_desktop,hdc_desktop_old)
   DeleteObject(hbm_desktop)
   DeleteDC(    hdc_desktop)

   Gui Destroy

   Gdip_Shutdown(pToken)
ExitApp

; -- Library now will be #include Gdip.ahk
; vim:ts=3:sw=3:ft=c

; -- Missing in GDIP !!!
 
PaintDesktop(  hdc ) {
   return DllCall("PaintDesktop", UInt, hdc )
}

CreateCompatibleBitmap( hdc , w, h ) {
     return DllCall("gdi32.dll\CreateCompatibleBitmap", UInt,hdc, Int,w, Int,h)
}


SetStretchBltMode( hdc , value ) {
     return DllCall("gdi32.dll\SetStretchBltMode", UInt,hdc, "int",value)
}
