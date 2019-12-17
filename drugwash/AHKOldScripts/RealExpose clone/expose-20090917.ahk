; v.20090917 -- expose.ahk - Thumbnails of Windows. Clean Rewrite

OnExit handle_exit
#include Gdip.ahk ; in library folder or next to this script
;
;
;
;
;

Main:
   Gosub, Config
   Gosub, Init_Gui
   ; Idle in Background ... Wait for KeyPress => "Window_Choose"
Return

Config:
   ; -- Keys to Start/Show Expose
   Hotkey, MButton, Window_Choose
   ;
   ;

   ; -- Keys while in Gui-Mode
   Hotkey, IfWinActive, EXPOSE_GUI
      Hotkey, MButton , Window_Activate
      ;
      ;
      ;
      Hotkey, #F12 , Debug_Info

   ; -- Predefined Variables and other Configs
   show_win_min_w = 110 ; min width of windows to be shown
   show_win_min_h = 110 ; min height of windows to be shown, hides Taskbar
   animate_delay  = 5 ;
   show_taskbar   = 1 ; Leave a gap so Taskbar is still visible
   main_monitor   = 1 ; (or 2,3,4,...)
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

   ; Create a Gui, but Hide it Immediately, so preparing in Background, we dont want to see
   ; ... whats going on
   Gui Show, Hide ..... , EXPOSE_GUI

   ; Create Buffers
   
   ; Buffer 1: Main-Display "frontbuffer" is the EXPOSE_GUI, the only thing which we SEE
   ; ... nothing to do here, its a real window ! we cannot paint directly on Desktop as
   ; ... we need to remove it when closing Expose. Also the window holds the old "state"

   ; Buffer 2: Print-Window; This is our Handle to Read the Current Look of one of the
   ; ... Application-Windows. Is it needed or can we read it directly ?

   ; Buffer 3: Backbuffer; This holds the Screen for Rendering Our "Scene", We do it in Background,
   ; ... so there is no flicker while Drawing, giving a nice View. This also prevents funny
   ; ... drawings when windows get reaaranged due to chaning of windows.
   ; ... Is it really needed or can we directly paint on the frontbuffer ?
   ; ... One Problem could be flicker, because we clear the "scene" in each round to paint the
   ; ... Desktop-Wallpaper. Done in Realtime will result in flicker as thumbs are hidden by wallpaper.

   ; Buffer 4: Wallpaper; This holds the Wallpaper from Desktop and is the Base for Repaint
   ; ... On each Loop whe paint first the Wallpaper and then the Thumbnails.
   ; ... Optimization is not to clear all from Backbuffer, but draw over the Backbuffer all
   ; ... the time because only little is changing. If we have a Gap, or Window-Rearrangement
   ; ... then we need to copy "repair" this sections with the Wallpaper and the new Thumbnail


   ; Restore Minimized Windows here as we also want to show them in Expose mode
   ; ... Remember their State and Minimize them Later when needed. (When Hide, Close ExposeGUI !)
Return

Window_Choose:
   ; Open The Gui (with Animate_In-Effect )
   ; ... and Start Repainting the Thumbnail in a Loop
   ; ... Until User Activates a Window, or Closes/Hides the ExposeGUI
   ; ... Actually Hide/Close also Calls Window_Activate and Activates the old one
Return

Window_Activate:
   ; Find the Window which is under the Mouse-Pointer (Hovered)
   ; ... And Zoom this Window out with "Animate_Out" and make it the Active One.
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

   ; Sleep %yield% ; give CPU some Rest otherwise Expose tries to grab 100% CPU, always updating windows
   if (do_zoom = 0 or force_refresh = 1) {
      WinGet ids_count, list,,,Program Manager      ; all active windows-tasks (processes)
        Loop %num_win% {
         ; if needed Restore part of Wallpaper on this Tile to Backbuffer
         ; copy Applicationwindow to Backbuffer with Printwindow() using StrechBlt to Resize
         ; ... (Minimize it)
         ; ... is Gdip_Worldtransform a better alternative to StrechBlt, or is it internally the same ?
         ; copy Backbuffer to Frontbuffer   
        }
   } else {
      ; Only Repaint the Hovered Window/Thumbnail
      ; ... Here Backbuffer comes Handy, as we keep the current State in Backbuffer
      ; ... and only Paint the Zoomed Thumbnail/Live-Window over the Backbuffer
      ; ... or we use another GUI-Window On-Top and let Windows do the Updating which
      ; ... holds the Zoomed Version
   }

   ; As an optimization, we could repaint all Thumbnails in low-priority even if in zoomed mode
   ; like every 10seconds, so we react correctly on changes in them and opened/closed windows.
   
   Goto, Repaint ; call self in a loop
   ;    Gosub, Repaint ; => will this cause a big Stack as Repaint is never Returned ?
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
   Gui Destroy
   ; DeleteDC....
   ;
ExitApp

; -- Library now will be #include Gdip.ahk
